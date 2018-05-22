#! /usr/bin/env python
"""
Clisk, the Command-Line Interface for Skype
(formerly called Skctl until version 2.0.0)
	- Allows direct execution of Skype API commands.
	- Includes several shortcuts for API commands (see do_help()).
	- Implements per-user AutoAction functionality and the AA command to control it.
	- Provides a sklog on/off command for turning debug logging on/off (currently Mac only).
	- Allows direct Skype4Py method calls from the command line.
	- Allows direct entry of Python expressions and statements.
	- Prints various notification types including inbound chats.
	- Supports "l" and "s" AutoAction flags allowing specific users to query for status with a "?stat" command.
	- Supports commandline history editing a la readline where available.
And much more... type "help" for help and "man" for a full online users guide.

WARNING:  This program is written to provide convenience, not security:
Arbitrary Python can be executed from this program's input prompt.
It is assumed that any user that can type there is trusted.

Author:  Doug Lee
License:  Based on BSD license; see bottom of file for rules and warranty.

Author's disclaimer for Python coders:
I started this as my first Python project of any size, and thus there
are portions of this code that lack normal Pythonic structure.  For
this I apologize but also invite suggestions for improvement.
"""

CLISK_VERSION = "2.5.1"

# First set the console title if running on Windows.
# This works with ActivePython out of the box but not with Python from python.org,
# unless perhaps that can be fixed by manually instaling Windows API libraries.
win32api = None
try: import win32api
except ImportError: pass
else:
	try: win32api.SetConsoleTitle("Clisk")
	# Exception is for pythonw because it doesn't own a console window.
	except: pass

import os, sys, time, re, subprocess
import threading
import datetime  # for do_whoIs()
import textwrap   # for do_help()
import ConfigParser
# readline is apparently not available on Windows ActivePython or other Windows installations.
# The Windows console provides that functionality in at least ActivePython though.
try: import readline
except ImportError: pass

# Set up the zip file from which to import Skype4Py and other support code.
zipfile = "clisk_util.zip"
# Add all copies of zipfile to sys.path.
newpath = [os.path.join(d, zipfile)
	for d in sys.path
	if os.path.exists(os.path.join(d, zipfile))]
newpath.extend(sys.path)
sys.path = newpath
del newpath
from TableFormatter import TableFormatter
from conf import Conf
from confwatch import ConfWatch
import utils
# For convenience
msg = utils.msg
msgFromEvent = utils.msgFromEvent
msgErrOnly = utils.msgErrOnly
msgNoTime = utils.msgNoTime
show = utils.show
# Code for specific user commands.
mydir = utils.mydir
from watchEvent import do_watchEvent

"""
TODO:  This is for using the Skype4COM object instead of Skype4Py.
Motivations:
	- Try to avoid focus changes on Windows caused by Skype4Py.
	- Avoid overzealous Skype4Py caching for conference participant
	  info and possibly other things.
The interfaces are a bit too different for a quick drop-in though:
	- The Skype4COM.Skype object is roughly equivalent to the result of Skype4Py.Skype(),
	  not just Skype4Py.
	- Constants (status codes etc.) are in different places.
	- Commands may differ in whether they return synchronous results.
	- Event connections are probably done differently.
Thus for now this block is disabled.
[DGL, 2010-06-24]
try:
	from win32com.client import Dispatch
	Skype4Py = Dispatch("Skype4COM.Skype")
	print "Got COM object."
except: pass
"""
try: Skype4Py
except NameError: import Skype4Py

def connectToSkype():
	if skype is not None:
		msg("Reconnecting to Skype")
		skype.OnAttachmentStatus = None
		skype.OnCallStatus = None
		skype.OnNotify = None
		skype.OnCallDtmfReceived = None
		del globals()["app"]
		del globals()["skype"]
		globals()["skype"] = None
		globals()["app"] = None
		time.sleep(0.5)
	globals()["skype"] = Skype4Py.Skype()
	skype.FriendlyName = "Clisk, the Command-Line Interface for Skype"
	skype.OnAttachmentStatus = onAttachmentStatus
	skype.OnCallStatus = onCallStatus
	skype.OnNotify = onNotify
	skype.OnCallDtmfReceived = onCallDtmfReceived
	# TODO: Kludge: Replace %s in do_watchEvent's doc string with an event list.
	if "%s" in do_watchEvent.__doc__:
		evlist = filter(lambda e: e.startswith("On"), dir(skype))
		evlist = map(lambda e: e[2:], evlist)
		evlist = "Available events: " +" ".join(evlist) +"."
		evlist = utils.format(evlist, "", "\t", 71)
		do_watchEvent.__doc__ = do_watchEvent.__doc__.replace("%s", evlist)
	time.sleep(0.5)
	# Connect to the Skype API:
	# Wait for the Skype client if necessary:
	if skype.AttachmentStatus != 0:
		skype.Attach(99, 0)
	while skype.AttachmentStatus == -1:
		msg("Waiting for Skype client to run")
		time.sleep(10)
		skype.Attach(99, 0)
	#skype.SilentMode=1
	#skype.OnNotify = say

class UserAbort(Exception):
	def __str__(self): return "Operation canceled by user."
class NoIDError(Exception):
	def __str__(self): return "No ID given."

def onAttachmentStatus(aStatus):
	"Monitors attachment status and automatically attempts to reattach to the API following loss of connection."
	try:
		msgFromEvent("Attachment status", skype.Convert.AttachmentStatusToText(aStatus))
		# 32769 = available
		if aStatus == 4 or aStatus == Skype4Py.apiAttachAvailable:
			msgFromEvent("Attaching to Skype")
			skype.Attach(99, 0)
		elif aStatus == 0 or aStatus == Skype4Py.apiAttachSuccess:
			# reportAttachment() will be called when the CURRENTUSERHANDLE event comes through.
			# This catches API disconnect/reconnects when Skype drops the link.
			# For some reason, those don't fire this attachment event.
			# [DGL, 2010-01-24]
			pass
	except: msgFromEvent(err("onAttachmentStatus"))

def reportAttachment():
	prot = int(send("protocol 99").lower().replace("protocol", "").strip())
	msgFromEvent("Attached to Skype, user", IDAndName(skype.CurrentUserHandle))
	globals()["app"] = skype.Application("clisk")
	createAppID()
	msgFromEvent(getVersionInfo(skype))
	conf.setUser(skype.CurrentUserHandle)
	reportAttachment.cw = ConfWatch()
	# Static used to keep the main Clisk> prompt from appearing until right after the first successful attachment to Skype.
	reportAttachment.attachedOnce = True
reportAttachment.attachedOnce = False

def skypeVersion():
	"""
	Return the Skype version number.
	Works around an error in Mac Skype 5.4.0.1771 on this request.
	Other Skype versions seem to have problems with this too.
	"""
	version = ""
	substver = "5.4.0.1771"
	try: version = skype.Version
	# May result in an internal error (9901).
	except Skype4Py.errors.SkypeError: return substver
	# This catches UnicodeDecodeErrors and possibly others,
	# Seen on Sarah's machine.
	except: return substver
	if not re.match(r'^[.0-9]+$', version):
		# Seen on Sarah's machine to return the string "ION" sometimes.
		# [DGL, 2012-02-19]
		return substver
	return version

def getVersionInfo(skype):
	"""
	Return a string identifying Clisk, Skype, and API versions.
	"""
	prot = int(send("protocol 99").lower().replace("protocol", "").strip())
	return "Clisk %s, Skype %s, API protocol %d, wrapper %s" % (
		CLISK_VERSION, skypeVersion(),
		prot, skype.ApiWrapperVersion
			)

def createAppID():
	"""Create the Application ID.
	"""
	state = 0
	try:
		app.Create()
		state = 1
	except: pass
	if state == 1:
		msgFromEvent("Clisk app ID created.")
		return
	# The first Create() failed.
	# See if this is because we already have the ID.
	state = 0
	try:
		app.Delete()
		state = 1
		app.Create()
		state = 2
	except Exception, e: pass
	if state == 2:
		# The Delete/Create sequence worked.
		msgFromEvent("Clisk app ID recreated.")
		return
	# Either the Delete() or the second Create() failed.
	# Both mean we have to wait and try again later.
	#msgNoTime("App Create retry")
	thr = threading.Timer(2, lambda: createAppID())
	thr.setDaemon(True)
	thr.start()

def fullCallStatus(call, status=None, includeType=False):
	"""
	Returns a string describing the given call's status in detail.
	If status is given, it is used over the call's status,
	but other call properties are still used when available.
	callList() sends a Participant object instead of a call object.
	As of Fri Jun 3, 2011, if includeType is True,
	the status includes an indication of the call type (In or Out).
	"""
	if status is None:
		status = call.Status
	if includeType:
		callType = call.Type
		if callType.lower().startswith("in"): callType = "In "
		elif callType.lower().startswith("out"): callType = "Out "
		else: callType = ""
	else: callType = ""
	try:
		sStat = skype.Convert.CallStatusToText(status).strip()
		if sStat.lower().startswith("call "): sStat = sStat[5:].strip()
		if sStat.lower().startswith("on "): sStat = sStat[3:].strip()
		sStat = sStat.title()
	except ValueError:
		sStat = ""
	if status == "RINGING" and sStat:
		buf = sStat
	elif (sStat and sStat.replace(" ", "").lower() != status.lower()
	and sStat.lower() != "unknown"):
		buf = status +" (" +sStat +")"
	elif sStat: buf = sStat
	else: buf = status
	buf = callType +buf.title()
	try: sStat = unicode(call.PstnStatus)
	except AttributeError: return buf
	if sStat: buf += " (" +unicode(sStat).strip() +")"
	sStat = call.FailureReason
	if sStat and (type(sStat) is int or sStat.isdigit()):
		try: temp = skype.Convert.CallFailureReasonToText(sStat).strip()
		except ValueError: temp = ""
		sStat = unicode(sStat)
		if temp: sStat += " " +temp
	if sStat: buf += " (" +unicode(sStat) +")"
	return buf

def simplifyVidStat(stat):
	"""
	Return a shortened representation of the given video status.
	"""
	if stat == "AVAILABLE": return "AV"
	if stat == "NOT_AVAILABLE": return "NA"
	return stat

def fullVideoStatus(call):
	"""
	Returns a string describing send and receive video statuses, in that order.
	"""
	if fullVideoStatus.badAPI:
		return "(unknown)/(unknown)"
	try:
		sendStat = send("get call " +unicode(call.Id) +" video_send_status")
		recvStat = send("get call " +unicode(call.Id) +" video_receive_status")
	except Skype4Py.SkypeAPIError:
		sendStat = "SkypeAPIError:"
		recvStat = "SkypeAPIError:"
	if sendStat.startswith("SkypeAPIError:"):
		sendStat = "(unknown)"
		recvStat = "(unknown)"
		fullVideoStatus.badAPI = True
	sendStat = simplifyVidStat(sendStat)
	recvStat = simplifyVidStat(recvStat)
	if sendStat == recvStat == "NA": return ""
	return sendStat +"/" +recvStat
fullVideoStatus.badAPI = None

def activeCalls(status=None, orgcalls=None):
	"""
	Return a list of calls.
	Passing a status limits the results to calls with that status.
	If no status is passed, all calls are returned.
	If calls are passed, they are used as the list to choose from.
	Otherwise, skype.ActiveCalls is used.
	This function also works around the following Mac Skype-only issue:
	skype.ActiveCalls can freeze when a non-hosted conference is included.
	Also includes outbound voicemail calls, which Skype started
	leaving out of activeCalls at some point.
	If orgcalls is passed, checks for these conditions are still applied.
	"""
	# The complete rebuilding of the call list is meant to avoid a
	# case where adding an outbound voicemail call produces an error
	# about the call not being owned by the right object.
	cl = []
	if orgcalls is None:
		orgcalls = skype.ActiveCalls
	cl.extend(orgcalls)
	if (onCallStatus.lastVMCall
	and not onCallStatus.lastVMCall in orgcalls):
		# Make an outbound voicemail call look like an active call
		# even when Skype itself doesn't do this.
		cl.insert(0, onCallStatus.lastVMCall)
	orgcalls = cl
	if conf.plat == "mac" and float(skypeVersion()[:3]) < 5.1:
		calls = []
		for call in orgcalls:
			# If it doesn't answer in five seconds, we assume it's an invalid call ID.
			# The "SkypeAPIError:..." string is coming back as a result # though.
			try:
				test_handle = send("get call %d partner_handle" % (call.Id), 50)
				if not test_handle or test_handle.lower().startswith("skypeapierror:"):
					continue
			except Skype4Py.SkypeAPIError:
				continue
			calls.append(call)
	else:
		calls = orgcalls
	# Skip finished but unclosed calls (seen on MacOS).
	calls = filter(lambda call: not (
		"cancelled" in call.Status.lower()
		or "finished" in call.Status.lower()
	), calls)
	if status is not None:
		calls = filter(lambda call: call.Status.lower() == status, calls)
	return calls

def onCallStatus(aCall, aStatus, isRetry=False):
	"""
	Monitors call status and if the status is "ringing" and it is an
	incoming call, it attempts to answer the call.
	"""
	if "vm" in aStatus.lower():
		if aStatus.lower() in [
			"vm_playing_greeting",
			"vm_recording",
			"vm_uploading"
		]:
			# Save for activeCalls() so users can drop outgoing voicemail calls.
			# These cease to be in activeCalls.
			onCallStatus.lastVMCall = aCall
		else:
			# Clear so activeCalls() doesn't include it.
			onCallStatus.lastVMCall = None
	try:
		buf = IDAndName(aCall.PartnerHandle) +" call status " +fullCallStatus(aCall, aStatus)
		msgFromEvent(buf)
		acc = conf.access(aCall.PartnerHandle)
		# Highest priority (1 being highest) or null string.
		prio = set(acc) & set("123456789")
		if prio: prio = sorted(list(prio))[0]
		else: prio = ""
		actives = activeCalls()
		if (aStatus == Skype4Py.clsRinging
		and (prio or "a" in acc or "j" in acc or "r" in acc)
		and (aCall.Type == Skype4Py.cltIncomingP2P or aCall.Type == Skype4Py.cltIncomingPSTN)):
			if (len(actives) == 1
			or (len(activeCalls("inprogress")) == 0 and (prio or "j" in acc))):
				# First part: When there is no active call already, this answers "a" and "j" callers.
				# (actives == 1 means just the incoming call is there.)
				# Second part: "j" and priority callers are answered even if calls are on hold.
				# (The "a" flag will ignore calls when a call is on hold.)
				# This is an answer though, not a join.
				if "r" in acc:
					msgFromEvent("Reversing")
					send("set call " +unicode(aCall.Id) +" status finished")
					time.sleep(5.0)
					skype.PlaceCall(aCall.PartnerHandle)
				else:
					msgFromEvent("Answering")
					send("set call " +unicode(aCall.Id) +" status inprogress")
			elif "j" in acc and canAnswerWithPriority("j"):
				# Join unless someone with an "x" blocks it.
				if "r" in acc:
					msgFromEvent("Joining via reverse")
					send("set call " +unicode(aCall.Id) +" status finished")
					time.sleep(5.0)
					do_addCall("!" +aCall.PartnerHandle)
				else:
					msgFromEvent("Joining")
					do_addCall("!" + aCall.PartnerHandle)
			elif prio and canAnswerWithPriority(prio):
				# Answer and hold current call if the incoming priority is high enough.
				if "r" in acc:
					msgFromEvent("Reversing with priority " +unicode(prio))
					send("set call " +unicode(aCall.Id) +" status finished")
					time.sleep(5.0)
					skype.PlaceCall(aCall.PartnerHandle)
				else:
					msgFromEvent("Answering with priority " +unicode(prio))
					send("set call " +unicode(aCall.Id) +" status inprogress")
		elif ((aStatus == Skype4Py.clsVoicemailPlayingGreeting or aStatus == Skype4Py.clsEarlyMedia)
		and "c" in acc):
			# clsEarlyMedia is start of call forward.
			msgFromEvent("Finishing call")
			send("set call " +unicode(aCall.Id) +" status finished")
		elif ((aStatus == Skype4Py.clsFinished or aStatus == Skype4Py.clsCancelled or aStatus == Skype4Py.clsVoicemailCancelled)
		and len(actives) == 0
		and "c" in acc):
			msgFromEvent("Scheduling callback")
			time.sleep(10)
			msgFromEvent("Initiating callback")
			skype.PlaceCall(aCall.PartnerHandle)
		if aStatus != Skype4Py.clsInProgress: return
		# Auto mute when requested.
		if "m" in acc:
			send("mute on")
		# Auto record calls if file $HOME/cliskrec exists. $HOME must work also.
		# File pattern: cliskrec.nnnn, but it can overflow and get longer.
		# Recording always goes to cliskrec.wav, and that's renamed
		# when a new one is needed.
		try: fpath = os.environ["HOME"]
		except KeyError: return
		tmpl = os.path.join(fpath, "cliskrec")
		if not os.path.exists(tmpl): return
		recbase = tmpl +".wav"
		tmpl += "%04d.wav"
		if os.path.exists(recbase):
			i = 1
			while os.path.exists(tmpl % (i)): i += 1
			time.sleep(0.2)
			os.rename(recbase, tmpl % (i))
			time.sleep(0.2)
		cmd = "rec " +recbase
		# Do this in case this is a reconnect from a built-in Skype redial,
		# which won't have stopped the current recording.
		do_rec("rec", "rec off")
		# Then start a new one.
		result = do_rec("rec", cmd)
		msgFromEvent(result)
	except:
		e = err("onCallStatus")
		if isRetry:
			msgFromEvent(e)
			return
		time.sleep(0.5)
		msgFromEvent("Dodged " +e)
		return onCallStatus(aCall, aStatus, isRetry=True)
onCallStatus.lastVMCall = None

def canAnswerWithPriority(prio):
	"""
	Sets the rules for who can be auto-answered or auto-joined
	when there is already an active call or conference:
	Returns True if a call with the given flag can be answered or joined into the current call.
	prio should be the priority (1-9 or "a" or "j") of the incoming caller.
	Rules if prio is numeric:
		- Answer if prio is strictly higher than priorities of all parties in the current call.
		- Otherwise do not answer (return False).
		- On answer, the current call or conference is put on hold.
		- "x" flags have no effect here.
	Rules if prio is "a":  Simple, return False (do not answer).
	Rules if prio is "j":
		- Do not join if all parties in the current call have an "x."
		- Allow the join if someone in the current call does not have an "x."
	Helper for OnCallStatus.
	"""
	if prio == "a": return False
	calls = activeCalls("inprogress")
	prios = set("123456789")
	ncalls = 0
	nx = 0
	for call in calls:
		ncalls += 1
		acc = conf.access(call.PartnerHandle)
		if "x" in acc: nx += 1
		prio1 = prios & set(acc)
		if prio1: prio1 = sorted(list(prio1))[0]
		if prio.isdigit() and prio1 and prio1 <= prio: return False
		for p in getCallParticipants(call):
			ncalls += 1
			acc = conf.access(p.Handle)
			if "x" in acc: nx += 1
			prio1 = prios & set(acc)
			if prio1: prio1 = sorted(list(prio1))[0]
			if prio.isdigit() and prio1 and prio1 < prio: return False
	if prio.isdigit(): return True
	# prio is "j"; that's all that's left.
	# Note: To make even one "x" in the current call block a j,
	# instead of requiring *all* participants to have an x to block a j,
	# change "nx == ncalls" below to "nx >= 1."
	if nx == ncalls: return False
	return True

def hostname():
	"Host name (first domain part only)."
	if conf.plat == "windows":
		host = os.environ["COMPUTERNAME"]
	else:
		host = os.uname()[1]
		host,sep,tmp = host.partition(".")
	return host

def rawLog(s):
	"""Log s without change, other than timestamping.
	Logs to a sort of hard-coded file.
	No logging is done if the file does not already exist.
	The file name is ${HOME}/clisk_raw.log at this time.
	This is for debugging.
	"""
	fname = "clisk_raw.log"
	try: fpath = os.environ["HOME"]
	except: return
	fpath = os.path.join(fpath, fname)
	if not os.path.exists(fpath): return
	tm = unicode(datetime.datetime.now())
	f = open(fpath, "a")
	f.write("%s:\n    %s\n" % (tm, s.encode("UTF-8")))
	f.close()

def onNotify(APIMsg, isRetry=False):
	"General Skype notification handler.  Some work is done by callees below."
	rawLog(APIMsg)
	try:
		ml = APIMsg.lower()
		if ml.startswith("application "):
			ap2apHandler(APIMsg)
			return
		elif ml.startswith("currentuserhandle "):
			reportAttachment()
			return
		elif ml.startswith("voicemail "):
			voicemailHandler(APIMsg)
			return
		elif ml.startswith("chatmessage "):
			chatMessageHandler(APIMsg)
			return
		elif ml.startswith("chatmember "):
			if ml.endswith("is_active true"): return
			cmd,id,rest = APIMsg.split(None, 2)
			chatID = send("get chatmember " +id +" chatname", 5000).strip()
			if " " in chatID: chatID = chatID[chatID.rindex(" ")+1:]
			if chatID.lower() == "timeout":
				chatID = send("get chatmember " +id +" chatname").strip()
				# Warning: Command timeouts are known to come back there, at least on Mac Skype.
				if " " in chatID: chatID = chatID[chatID.rindex(" ")+1:]
				if chatID.lower() == "timeout": chatID = ""
			sendername = IDAndName(send("get chatmember " +id +" identity").strip())
			if chatID: chatname = chatName(chatFromBlob(chatID)).strip()
			else: chatname = ""
			if not chatname: chatname = "<error getting chat name>"
			if chatname and sendername != chatname: sendername += "@" +chatname
			m = "*** %s %s" % (sendername, rest)
			msgFromEvent(m)
			return
		if ml.startswith("filetransfer "):
			fileTransferHandler(APIMsg)
			return
		if ml.startswith("sms "):
			if SMSFilterOut(APIMsg): return
		if "duration" in ml: return
		cmd,sep,rest = ml.partition(" ")
		if cmd in ["userstatus", "group"]: return
		if cmd in ["chat", "call"]: return
		if cmd in ["contacts", "contacts_focused"]: return
		if cmd == "user":
			userNotificationHandler(APIMsg)
			return
		msgFromEvent(APIMsg)
	except:
		e = err("onNotify")
		if isRetry:
			msgFromEvent(e)
			return
		time.sleep(0.5)
		msgFromEvent("Dodged " +e)
		return onNotify(APIMsg, isRetry=True)

def ap2apHandler(APIMsg):
	"AP2AP notification handler called by onNotify."
	# Get rid of "application" and the app name.
	# The application name must not contain spaces.
	APIMsg = APIMsg.split(None, 2)[2]
	# The next word is the subcommand.
	cmd = APIMsg.strip()
	rest = ""
	if " " in cmd: cmd,rest = cmd.split(None, 1)
	cmd = cmd.lower()
	if cmd in ["connecting", "sending"]: return
	if cmd == "datagram" and handleDatagrams(rest):
		return
	msgFromEvent("AP2AP %s" % (APIMsg))

def handleDatagrams(data):
	"""
	Handles incoming datagrams.
	"""
	data = data.strip()
	stream,dgram = data.split(None, 1)
	id,instance = stream.split(":", 1)
	msgFromEvent("=%s:%s= %s" % (
		IDAndName(id),
		instance,
		dgram
	))
	cmd = dgram
	rest = ""
	if " " in cmd: cmd,rest = dgram.split(None, 1)
	cmd = cmd.lower()
	try: func = eval("dgram_" +cmd)
	except NameError: return True
	func(stream, rest)
	return True

def dgram_version(stream, rest):
	"""
	Handler for datagram Version requests.
	"""
	response = getVersionInfo(skype)
	id,instance = stream.split(":", 1)
	acc = accflags(id)
	if acc:
		response += "\nYour AutoAction flags are %s" % (acc)
	sendDatagram(stream, response)

def dgram_stat(stream, rest):
	"""
	Handler for datagram stat requests.
	"""
	id = stream.split(":")[0]
	if set("ls") & set(conf.access(id)):
		sendDatagram(stream, stat(id))

def voicemailHandler(APIMsg):
	"Voicemail notification handler called by onNotify."
	# APIMsg starts out as the raw API notification text.
	# Knock off "voicemail" and get the item after that.
	# Also keep the rest of the notification.
	tmp,sep,APIMsg = APIMsg.partition(" ")
	APIMsg,sep,rest = APIMsg.partition(" ")
	# APIMsg is now the voicemail ID,
	# and rest is the actual notification.
	if not rest.lower().startswith("status "): return
	vm = skype.Voicemail(APIMsg)
	# vm is now the voicemail object.
	# Greeting and outgoing voicemails are notified well enough via Call notifications.
	if vm.Type.lower() != "incoming": return
	stat = rest.split(None, 1)[1]
	try: stat = skype.Convert.VoicemailStatusToText(stat)
	except ValueError: pass
	fr = vm.FailureReason
	if fr:
		try: fr = skype.Convert.VoicemailFailureReasonToText(fr)
		except ValueError: pass
	fr = fr.strip()
	if fr.lower() == "unknown": fr = ""
	if fr: stat += " (" +fr +")"
	if stat.lower() in ["playing", "played", "deleting"]: return
	msgFromEvent("%s %s voicemail (%s) %s" % (
		IDAndName(vm.PartnerHandle),
		skype.Convert.VoicemailTypeToText(vm.Type).lower(),
		utils.msTime(vm.Duration),
		stat
	))

def chatMessageHandler(APIMsg):
	"Chatmessage notification handler called by onNotify."
	# APIMsg starts out as the raw API notification text.
	# Knock off "chatmessage" and get the item after that.
	# Also keep the rest of the notification.
	tmp,sep,APIMsg = APIMsg.partition(" ")
	APIMsg,sep,rest = APIMsg.partition(" ")
	# APIMsg is now the message number,
	# and rest is the actual message.
	APIMsg = skype.Message(APIMsg)
	# APIMsg is now the message object.
	isStat = rest.lower().startswith("status ")
	if isStat:
		st = rest[7:].lower()
		if st in "sending read": return
	if APIMsg.Type.lower() in "createdchatwith, sawmembers":
		return
	# Omit messages from me and mood text pseudo-chat updates
	#if APIMsg.FromHandle == skype.CurrentUser.Handle: return
	# A BODY chatmessage indicates message editing.
	editing = False
	if rest.lower().startswith("body "):
		editing = True
		body = rest[5:]
	else:
		body = APIMsg.Body
	# Skype 4.x messages on call termination.
	bodyLower = body.lower()
	if "<partlist" in bodyLower and "</partlist>" in bodyLower: return
	if editing:
		txt = chatLine(APIMsg, body)
		msgFromEvent(txt)
		return
	extra = ""
	try:
		if APIMsg.Role and APIMsg.Role.lower() != "unknown":
			extra += " " +APIMsg.Role
	except AttributeError: pass
	u = ", ".join(map(lambda u: IDAndName(u), APIMsg.Users))
	if u:
		extra += " " +u
	lr = APIMsg.LeaveReason
	if lr and (type(lr) is int or lr.isdigit()):
		try: lr = unicode(lr) +" " +skype.Convert.ChatLeaveReasonToText(lr)
		except ValueError: pass
	if lr:
		extra += " (" +unicode(lr) +")"
	# API docs say this can be retrieved, but I find it not to exist.
	try: fr = APIMsg.FailureReason
	except AttributeError: fr = ""
	if fr:
		extra += " (" +unicode(fr) +")"
	if not rest.lower().startswith("status "):
		if rest.lower().startswith("edited_timestamp "): return
		txt = "chatmessage %s %s%s" % (
			IDAndName(APIMsg.FromHandle),
			rest,
			extra
		)
		msgFromEvent(txt)
		return
	# A chatmessage status message.
	txt = ""
	# Use the new status just set.
	tmp,sep,st = rest.partition(" ")
	st = st.strip()
	if st.lower() == "sent" or st.lower() == "received":
		txt += " ".join([chatLine(APIMsg), extra])
	elif st:
		txt += st +" "
	if not txt:
		txt += "%s %s:%s %s" % (
			IDAndName(APIMsg.FromHandle), APIMsg.Type.lower(), extra,
			body
		)
	msgFromEvent(txt)
	if (bodyLower == "?stat"
	and APIMsg.FromHandle != skype.CurrentUserHandle
	and set("ls") & set(conf.access(APIMsg.FromHandle))):
		APIMsg.Chat.SendMessage(stat(APIMsg.FromHandle))

def fileTransferHandler(APIMsg):
	"Filetransfer notification handler called by onNotify."
	ml = APIMsg.lower()
	if ("bytestransferred" in ml or "bytespersecond" in ml or "finishtime" in ml
	or " type " in ml or " partner_" in ml or " starttime " in ml):
		return
	# APIMsg starts out as the raw API notification text.
	# Knock off "filetransfer" and get the item after that.
	tmp,sep,APIMsg = APIMsg.partition(" ")
	APIMsg,sep,rest = APIMsg.partition(" ")
	# APIMsg is now the filetransfer number.
	# Active works until the thing completes, then it won't.
	try: APIMsg = [f for f in skype.ActiveFileTransfers if f.Id == int(APIMsg)][0]
	except IndexError: APIMsg = [f for f in skype.FileTransfers if f.Id == int(APIMsg)][0]
	# APIMsg is now the filetransfer object.
	txt = "filetransfer %s %s %s %s" % (
		IDAndName(APIMsg.PartnerHandle),
		APIMsg.Type,
		APIMsg.FileName,
		rest
	)
	if APIMsg.FailureReason and APIMsg.FailureReason.lower() != "unknown":
		txt += " (" +unicode(APIMsg.FailureReason) +")"
	msgFromEvent(txt)

def SMSFilterOut(APIMsg):
	"SMS notification filter called by onNotify."
	ml = APIMsg.lower()
	# Remove "SMS" and the SMS ID, then get the command word..
	ml = ml.partition(" ")[2].partition(" ")[2]
	cmdword,sep,ml = ml.partition(" ")
	if cmdword in ["type", "price_precision", "price_currency", "timestamp", "target_numbers"]:
		# Skip these as they are generated all at once when a Skype 4 user opens a conversation window for a PSTN number.
		# Apparently this is a background analysis in case the user then wants to send an SMS to that number.
		return True
	elif cmdword == "status" and ml.rpartition(" ")[2] == "composing":
		# Early enough in the SMS process to be of little use reporting.
		return True
	elif cmdword == "price" and ml.rpartition(" ")[2] in ["0", "-1"]:
		# Generated during the background analysis also.
		return True
	elif cmdword == "target_statuses" and ml.rpartition("=")[2] == "target_analyzing":
		# Same deal.
		return True
	elif cmdword == "body" and not ml.strip():
		# Empty body, also part of the analysis process.
		return True
	# Anything else gets through to the user.
	# The analysis generally lets through a TARGET_STATUSES...=TARGET_ACCEPTABLE message and an actual PRICE value.
	return False

def userNotificationHandler(APIMsg):
	"User notification handler called by onNotify."
	# Remove "USER"
	rest = APIMsg.split(None, 1)[1]
	# Get Id separated from remainder.
	id,rest = rest.split(None, 1)
	# Don't report the myriad profile field update notifications unless requested.
	# Let through auth request notifications and contact adds/deletes etc.
	if ("receivedauthrequest" not in rest.lower()
	and "buddystatus" not in APIMsg.lower()
	and "w" not in conf.access(id)):
		return
	if rest.lower().startswith("lastonlinetimestamp"): return
	if rest.lower().startswith("buddystatus"):
		stat = rest.split(None, 1)[1]
		msgs = ["not a known contact", "deleted from your contact list", "not sharing contact details", "sharing contact details"]
		if int(stat) in range(0, len(msgs)):
			stat = msgs[int(stat)]
			rest = "is " +stat
		else:
			stat = str(stat)
			rest = "BuddyStatus " +stat
	id = IDAndName(id)
	mesg = "User %s %s" % (id, rest)
	msgFromEvent(mesg)

def onCallDtmfReceived(call, *args):
	buf = IDAndName(call.PartnerHandle) +" DTMF "
	buf += ", ".join(args)
	msgFromEvent(buf)

def accflags(userHandle):
	"""
	Returns any access flags the given user has.
	The w flag is omitted. This is for stat and version responses.
	"""
	acc = conf.access(userHandle)
	# w is not shown in Stat responses.
	acc = acc.replace("w", "")
	return acc

def stat(userHandle):
	"""Implements the "?stat" info request output."""
	m = "stat request from " +IDAndName(userHandle)
	acc = accflags(userHandle)
	if "l" in acc:
		m = "long " +m
		msgFromEvent(m)
		return "%s\nYour AutoAction flags are %s" % (
			callList(True, True),
			acc
		)
	msgFromEvent(m)
	actives = activeCalls()
	stats = {}
	for call in actives:
		status = call.Status
		try:
			sStat = skype.Convert.CallStatusToText(status).strip()
			if sStat.lower().startswith("call "): sStat = sStat[5:].strip()
			#if sStat.lower().startswith("on "): sStat = sStat[3:].strip()
			status = sStat.lower()
		except ValueError: status = status.lower()
		# Skype4Py doesn't translate this one. [DGL, 2010-02-28]
		status = status.replace("localhold", "held locally")
		stats.setdefault(status, 0)
		stats[status] += 1
	buf = ", ".join(map(lambda (k,d): unicode(d)+" "+k, stats.items()))
	if not buf: buf = "0"
	buf = ("Calls on %s: %s.  Your AutoAction flags are %s" % (
		hostname(),
		buf,
		acc
	)).rstrip()
	return buf

#********  Command and command line handling ********

def sendMac(cmd):
	# Send one Skype API command to Mac Skype and return its result.
	cmd1 = cmd.replace('"', '\\"')
	app = "skype"
	cmdarg = 'tell app "%s" to send command "%s" script name "My script"' % (app, cmd)
	cmdsend = ["osascript", "-l", "AppleScript", "-e", cmdarg]
	result = subprocess.Popen(cmdsend, stdout=subprocess.PIPE).communicate()[0]
	return result

def send(cmd, wait=1000):
	"Send a Skype API command and return the result."
	cmdl = cmd.lower()
	# Exceptions for commands that Skype4Py doesn't handle correctly on Macs at this writing.
	if (conf.plat == "mac" and (
		# These report "invalid what"
		cmdl == "get contacts_focused"
		or cmdl == "get windowstate"
		or cmdl.startswith("set windowstate")
		# This causes a freeze of the Skype4Py client.
		or cmdl.startswith("open")
	)):
		# TODO: Ignores wait request.
		result = sendMac(cmd)
	else:
		# Skype4Py for all else.
		c = skype.Command(cmd)
		if wait:
			c.Blocking = True
			c.Timeout = wait
		else:
			c.Blocking = False
		try: skype.SendCommand(c)
		except Skype4Py.SkypeAPIError: return err()
		result = c.Reply
	# Take cmd itself out of the reply where applicable.
	cmd = cmd.strip()
	isSet = False
	if cmd[:4].lower() in "get set ":
		# Get/set are not returned with replies.
		# This adjustment lets us pull off the name/id of what we're getting/setting.
		tmp,sep,cmd = cmd.partition(" ")
		isSet = (tmp.lower() == "set")
		cmd = cmd.lstrip()
	if isSet and result.lower() == cmd.lower():
		result = "Done."
	elif result.lower().startswith(cmd.lower()+" "):
		# Remove the part that repeats the command.
		result = result[len(cmd)+1:].lstrip()
	# Special case for SEARCH GREETING.
	elif cmd.lower().startswith("search greeting"):
		# Response begins with "VOICEMAILS"
		result = result[10:].lstrip()
	# What's left is the real answer to the request.
	return result

def getCallParticipants(call):
	"""Return a list of Participant objects for the given call.
	"""
	callId = call.Id
	cnt = int(send("get call %d conf_participants_count" % (callId)))
	lst = []
	for i in range(0, cnt):
		info = send("get call %d conf_participant %d" % (callId, i))
		lst.append(Participant(i, info))
	return lst

# This class simply emulates Skype4Py's Participant class enough for
# this program to use.
class Participant(object):
	def __init__(self, idx, info):
		"""Info is what the Skype API returns for a non-local
		conference participant.
		"""
		self.Idx = idx
		self.Handle,self.Type,self.CallStatus,self.DisplayName = info.split(" ", 3)

def getUserIDs(id, allowSkypeUserSearch=False):
	"""Call getUserID() on one or more IDs separated by commas and return the results as a string."""
	ids0 = id.split(",")
	ids = []
	for id in ids0:
		try: id = getUserID(id, allowSkypeUserSearch)
		except NoIDError: pass
		else: ids.append(id)
	ids = filter(None, ids)
	return ",".join(ids)

def getUserID(id, allowSkypeUserSearch=False):
	"""Translate a user specification to its user ID.
	User specification types:
		string: match against known users.
		.:  Currently selected contact in Contacts or Conversations.
		!userID:  Exact user ID.
		!!userID:  Same but will never do a search for user profile information.
		/string: Search against all Skype users.
	Anything else returns unchanged.
	For the first type, the user may match in the contact list or in any active call or conference.
	If multiple users match, you will be prompted to select one by number.
	If the !userID form is used in a whois command,
	user information will first be retrieved by a search for that user,
	so as much information as possible can be shown.
	Use a double ! to avoid this (probably not necessary for most users).
	The /string form is how to find new people without knowing a user ID.
	"""
	id = id.strip()
	if id.startswith("!!"):
		id = id[1:]
		allowSkypeUserSearch = False
	if id.startswith("/"):
		msgNoTime("Searching for users")
		ids = skype.SearchForUsers(id[1:])
		ids = [id1.Handle for id1 in ids]
	elif id.startswith("!"):
		if allowSkypeUserSearch:
			msgNoTime("Retrieving user information")
			# This makes Skype collect the info for the requested user,
			# so the next query against this ID can return it.
			skype.SearchForUsers(id[1:])
		return id[1:]
	elif id == ".":
		ids = skype.FocusedContacts
		nusers = len(ids)
		if nusers == 0: raise ValueError("No contact is focused")
		ids = [id1.Handle for id1 in ids]
	else:  # not a focused contact, Skype user search, or exact Skype ID request
		ids = getUserMatches(id)
	ids.sort(key=lambda k: k.lower())
	nids = len(ids)
	if nids == 1: return ids[0]
	elif nids == 0:
		l = ""
		while not l:
			l = utils.raw_input_withoutHistory('No user matched "' +id +'" - use anyway? (Yes/No/Cancel): ')
			l = l.lower().strip()
			if not l or l[0] not in ["y", "n", "c"]:
				msgNoTime("Please enter y, n, or c.")
				l = ""
				continue
			l = l[0]
			if l == "y": return id
			elif l == "n": raise NoIDError
			else: raise UserAbort
	idlist = [unicode(i+1) +" " +IDAndName(id1, True) for i,id1 in enumerate(ids)]
	m = "Select a user by number:\n   " +"\n   ".join(idlist)
	listing = True
	showList = True
	while listing:
		if showList:
			msgNoTime(m)
			show("Use ? to redisplay the list and ?1 etc. to check profiles before choosing.")
		showList = False
		l = ""
		l = utils.raw_input_withoutHistory("Selection: ")
		l = l.strip()
		if l == "?":
			showList = True
			continue
		elif "?" in l:
			l = l.replace("?", "")
			try: id1 = ids[int(l)-1]
			except IndexError: msgNoTime("Invalid index number")
			else:
				w_args = ["!"+id1]
				w_kwargs = {"allowSkypeUserSearch": False}
				msgNoTime(do_whoIs(*w_args, **w_kwargs))
			continue
		try:
			if l and int(l): return ids[int(l)-1]
		except IndexError:
			msgNoTime("Invalid index number")
			continue
		listing = False
	m = '%d users matched "%s"' % (nids, id)
	raise ValueError(m)

def getUserMatches(id, candidates=None):
	"""
	Returns a list of matches to the given user ID specification.
	Matching is tried against Skype ID and fullName/displayName fields,
	and the set of users is the union of
		- You (the Skype user running Clisk),
		- Friends (the contact list),
		- Users waiting for authorization (requesting to be added),
		- The users in all active and missed calls and conferences, and
		- The users in all active, missed, and recent chats.
	An exact Skype ID match from this set will always return alone.
	Otherwise any user whose Skype ID or full name/displayName contains id is returned.
	This function is a helper for getUserID().
	idToCall() also calls it and passes a specific user object candidate set.
	"""
	if candidates is None:
		# Build list of candidate User objects.
		candidates = set(skype.Friends) | set(skype.UsersWaitingAuthorization)
		candidates.add(skype.User(skype.CurrentUserHandle))
		for call in set(activeCalls()) | set(skype.MissedCalls):
			candidates.add(skype.User(call.PartnerHandle))
			[candidates.add(skype.User(p.Handle)) for p in getCallParticipants(call)]
		try: [candidates.update(chat.Members) for chat in skype.ActiveChats]
		except Skype4Py.SkypeError: pass
		try: [candidates.update(chat.Members) for chat in skype.RecentChats]
		except Skype4Py.SkypeError: pass
		[candidates.update(chat.Members) for chat in skype.MissedChats]
	# Now get the list of matches.
	idl = id.lower()
	# Exact Skype ID matches trump all else and are much quicker to detect.
	cand1 = map(lambda c: c.Handle.lower(), candidates)
	if idl in cand1: return [idl]
	# No exact handle match, so we have to collect all possibilities.
	matches = []
	# TODO: This can be a very slow line because User property retrieval can take time.
	cand1 = map(lambda c: c.Handle +", " +c.FullName +", " +c.DisplayName, candidates)
	for c in cand1:
		if idl in c.lower():
			matches.append(c.split(", ", 1)[0])
	return matches

def do_prefix(*args, **kwargs):
	"""
	Set or clear a prefix to be added to all commands until the prefix is again changed.
	Used primarily for "querying" someone for text chatting.
	To send Clisk a command when a prefix is in effect, put a slash (/) at the start of the line.
	Otherwise your command will be prefixed also.
	Examples:
		prefix msg bob
		Hi there!      (goes to Bob)
		/whoIs bob   (the slash makes this go to Clisk as a command)
		/prefix   (clears the prefix)
		whoIs bob    (goes to Clisk as a command)
	"""
	toplevel.prefix = kwargs["cmd"]

def do_profile(*args, **kwargs):

	"Built-in alias for WhoIs."
	return do_whoIs(*args, **kwargs)

def getPrompt():
	"""Get the effective input prompt string.
	"""
	prompt = conf.opt("Settings", "prompt")
	if not prompt: prompt = "Clisk"
	return prompt

def setPrompt(newPrompt):
	"""Set a new input prompt.
	"""
	return conf.opt("Settings", "prompt", newPrompt)

def onlineStatus(u, extended=False):
	"""
	Return a printable contact status given a User object.  Includes
		- Online, offline, away, not available, do not disturb, or SkypeMe.
		- Not a Contact or Deleted contact (instead of the above) where appropriate.
	and if extended is true, call forwarding, voicemail, and last-seen indications.
	"""
	ostat = u.OnlineStatus
	try: olstat = skype.Convert.OnlineStatusToText(ostat)
	except ValueError: olstat = unicode(ostat)
	bstat = u.BuddyStatus
	# Skype4Py's translations are old, so we do it ourselves here,
	# but we leave room for Skype4Py to add translations for new values.
	if bstat == 0: budstat = "not a contact"
	elif bstat == 1: budstat = "deleted contact"
	elif bstat == 2: budstat = "not sharing contact details"
	elif bstat == 3: budstat = ""
	else:
		try: budstat = skype.Convert.BuddyStatusToText(bstat)
		except ValueError: budstat = unicode(bstat)
	# Combination and simplification.
	if ostat == "OFFLINE" and bstat != 3:
		if budstat:
			olstat = budstat.title()
	elif budstat:
		olstat += " (" +budstat +")"
	if not extended:
		return olstat
	stat = olstat
	isOffline = ostat.lower().startswith("offline")
	if isOffline:
		if u.IsCallForwardActive:
			stat += " with call forwarding"
			if u.IsVoicemailCapable: stat += " and voicemail"
		elif u.IsVoicemailCapable:
			stat += " with voicemail"
	ldt = None
	if u.LastOnline:
		try: ldt = u.LastOnlineDatetime
		except: pass
	if ldt: ldt = datetime.datetime.now() -ldt
	if ldt: ldt = utils.relTimeString(ldt)
	if ldt:
		if isOffline: stat += ", last seen %s ago" % (ldt)
		else: stat += ", last verified %s ago" % (ldt)
	if not stat: return "empty result"
	return stat

def do_prompt(*args, **kwargs):
	"""Change the current input prompt.
	To change the prompt, type the desired prompt after the command.
	Type without parameters to reset to the default prompt.
	Example:  prompt Laptop Clisk
	Do not include the ">" symbol in the prompt; Clisk will add it.
	"""
	cmd = kwargs["cmd"]
	if not len(cmd):
		setPrompt("")
		return
	newPrompt = cmd
	setPrompt(newPrompt)

def do_whoIs(*args, **kwargs):
	"""
	Show information about the user indicated by id.
	id may be more than one word, such as first and last name.
	If id begins with an exclamation mark (!), only the exact skype ID given is used.
	If id begins with "/", the entire Skype community is searched for a match.
	Otherwise, your ID, your contact list, and members of all active calls and conferences are searched.
	If id matches a Skype ID exactly, that user is shown.
	Otherwise, if id is contained in a Skype user ID or full or display name, that user is shown.
	If there are multiple matches, they are listed and you may choose one by number.
	"""
	try: id = kwargs["cmd"]
	except KeyError: id = " ".join(args)
	allowSkypeUserSearch = kwargs.get("allowSkypeUserSearch")
	if allowSkypeUserSearch is None: allowSkypeUserSearch = True
	id = fixPhoneNumbers(id)
	id = getUserID(id, allowSkypeUserSearch)
	u = skype.User(id)
	m = ""
	name = u.FullName
	if name: name += " (" +u.Handle +")"
	else: name = u.Handle
	if u.IsSkypeOutContact: name = "Skypeout " +name
	m += name
	if u.SpeedDial:
		m += " (SpeedDial %s)" % (unicode(u.SpeedDial))
	m += ":\n"
	if u.DisplayName:
		m += "DisplayName: %s\n" % (u.DisplayName)
	if u.Aliases:
		m += "Aliases: %s\n" % (", ".join(u.Aliases))
	m += "Status: %s\n" % (onlineStatus(u))
	if u.ReceivedAuthRequest:
		m += "Auth Request: %s\n" % (u.ReceivedAuthRequest)
	flags = [
		getFlag(u.IsBlocked, "Blocked", ""),
		getFlag(u.IsAuthorized, "", "NotAuthorized"),
		getFlag(u.IsVideoCapable, "HasVideo", ""),
		getFlag(u.IsVoicemailCapable, "HasVoicemail", ""),
		getFlag(u.IsCallForwardActive, "CallsForwarding", "")
	]
	if u.IsAuthorized and u not in skype.Friends:
		flags.insert(0, "AuthorizedButNotInContacts")
	flags = ", ".join(filter(None, flags))
	if flags:
		m += "Flags: %s\n" % (flags)
	if u.MoodText.strip():
		m += "MoodText: %s\n" % (u.MoodText.strip())
	data = []
	if u.Sex.lower() != "unknown":
		data.append("Gender %s   " % (u.Sex.title()))
	if u.Birthday:
		today = datetime.date.today()
		bday = u.Birthday
		age = today.year -bday.year
		try: bday = bday.replace(year=today.year)
		except ValueError:  # leapyear Feb 29 birthdays do this.
			bday += datetime.timedelta(1)
			bday = bday.replace(year=today.year)
		if today < bday: age -= 1
		data.append("Age %3d   Birthday %s" % (age, u.Birthday.strftime("%B %d %Y")))
	if data:
		m += "   ".join(data) +"\n"
	phones = []
	if u.PhoneHome: phones.append("Home " +u.PhoneHome)
	if u.PhoneOffice: phones.append("Office " +u.PhoneOffice)
	if u.PhoneMobile: phones.append("Mobile " +u.PhoneMobile)
	if phones:
		m += "Phone: " +", ".join(phones) +"\n"
	loc = "%s %s %s" % (u.City, u.Province, u.Country)
	loc = loc.strip()
	if loc and u.CountryCode: loc += " (%s)" % (u.CountryCode)
	loc = loc.strip()
	if loc:
		m += "Location: %s\n" % (loc)
	tz = u.Timezone
	if tz:
		tz = (tz /3600) -24  # GMT hour offset
		myTz = (int(skype.Profile("TIMEZONE")) /3600) -24
		tzdiff = tz -myTz
		if tzdiff > 0:
			tztext = "%s hours ahead of you"
		elif tzdiff < 0:
			tztext = "%s hours behind you"
		else:
			tztext = "same as local time"
		try: tztext = tztext % (unicode(abs(tzdiff)))
		except TypeError: pass
		m += "Timezone: %s\n" % (tztext)
	if u.Language or u.LanguageCode:
		m += "Language: %s (%s)\n" % (u.Language, u.LanguageCode)
	if u.Homepage.strip():
		m += "Homepage: %s\n" % (u.Homepage.strip())
	if u.NumberOfAuthBuddies:
		m += "Contacts: %d\n" % (u.NumberOfAuthBuddies)
	if u.LastOnline:
		lo = u.LastOnlineDatetime.strftime("%A %B %d, %Y at %I:%M:%S %p")
		m += "Last Seen: %s\n" % (lo)
	if u.About.strip():
		m += "About Me: %s\n" % (u.About.strip())
	return m.strip()

def getFlag(cond, whenTrue, whenFalse):
	if cond: return whenTrue
	else: return whenFalse

def IDAndName(which, alwaysShowID=False, hidePhoneNumbers=False, maxNameLen=20):
	"""Translate the given User object or string handle into an ID and name as appropriate.
	The ID part is only included when the name-to-ID mapping changes,
	unless alwaysShowID is True, in which case it is always included.
	If hidePhoneNumbers is True, phone number IDs are replaced with "phone number."
	(This is used for long ?stat responses.)
	This is what implements id-to-name translation on output."""
	if not which: return ""
	objGiven = "Handle" in dir(which)
	if objGiven:
		u = which
		h = u.Handle
	else:
		h = which
		# We'll figure out u shortly.
	# h1 and name1 will contain the printable handle and name,
	# which incorporates phone number hiding if necessary.
	h1 = h
	if hidePhoneNumbers and (
		h1.isdigit()
		or (h1 and h1[0] == "+" and h1[1:].isdigit())
	):
		h1 = "phone number"
	if not objGiven:
		try: u = skype.User(h)
		except Skype4Py.SkypeAPIError:
			return h1
		except Skype4Py.SkypeError:
			time.sleep(1.0)
			try:
				u = skype.User(h)
				msg("IDAndName dodged a SkypeError.")
			except Skype4Py.SkypeAPIError:
				return h1
	name = u.DisplayName or u.FullName
	name1 = name
	# Replace any strings of spaces/tabs with a single space.
	# This is for users who hide their names in contact lists by embedding a lot of spaces.
	name = " ".join(name.split())
	# This is for when Skype puts a phone number in a fullName or displayName field.
	name1 = name
	if hidePhoneNumbers and (
		name1.isdigit()
		or (name1 and name1[0] == "+" and name1[1:].isdigit())
	):
		name1 = "(phone number)"
	if len(name) > maxNameLen: name = name[:maxNameLen] +"..."
	if len(name1) > maxNameLen: name1 = name1[:maxNameLen] +"..."
	name = name or h
	name1 = name1 or h1
	oldID = IDAndName.userNames.get(name) or ""
	isNew = (h != oldID)
	if isNew:
		IDAndName.userNames[name] = h
	if isNew or alwaysShowID:
		if name.lower() != h.lower(): name1 += " (" +h1 +")"
	return name1
IDAndName.userNames = dict()

def getCallInProgress(useOtherCall=False, allowCallSelection=True):
	"""
	Return the call that is to be considered "current."
	This function is responsible for defining what the "current" call is.
	In the below rules, consider that a remotely-hosted conference is
	a single call here,
	but a locally-hosted conference is several calls in progress here.
	An "active" call is one that is not ended, held, or ringing.
	The following rules apply, in this order:
		- Ended calls are completely ignored (can happen on MacOS).
		  "Ended" includes statuses Finished and Canceled.
		- If there are no calls at all, return None.
		- If there is only one call, return it even if held or ringing.
		- (Start of rules for when there are multiple calls)
		- If there are no active calls but there is exactly one ringing, return that.
		- If there are no active calls but there is exactly one held, return that.
		- If no rules yet matched and there are no active calls, return None.
		- If useOtherCall is True and there are exactly two calls
		  and one is not held, return the held one.
		  (This allows Resume to toggle between calls.)
		- If there is only one in-progress call, return it.
		- If there are multiple in-progress calls (usually a
		  locally-hosted conference), let the user choose a call from a list.
		  This rule is skipped if allowCallSelection is passed as False.
		- If no rules matched, return None.
	"""
	calls = activeCalls()
	ncalls = len(calls)
	# If there are no calls at all, return None.
	if ncalls == 0:  return None
	# If there is only one call, return it even if held or ringing.
	if ncalls == 1: return calls[0]
	# From here on, we know there are more than one call.
	# We now have to categorize all the calls by status.
	active = []
	inactive = []
	held = []
	ringing = []
	for call in calls:
		stat = call.Status
		if "ringing" in stat.lower():
			ringing.append(call)
			inactive.append(call)
		elif "hold" in stat.lower():
			held.append(call)
			inactive.append(call)
		else:
			active.append(call)
	if not len(active):
		if len(ringing) == 1: return ringing[0]
		if len(held) == 1: return held[0]
		return None
	if useOtherCall and ncalls == 2 and len(held) == 1:
		return held[0]
	if len(active) == 1:
		return active[0]
	# Deal with multiple simultaneous active calls.
	if not allowCallSelection: return None
	f = lambda call: IDAndName(call.PartnerHandle, True)
	return utils.selectMatch(active, "Select a call:", f)

def do_AA(*args, **kwargs):
	"""
	List, change, or remove AutoAction flags for users.  Examples:
	aa echo123 =a  (give echo123 exactly the "a" flag)
	aa echo123 s  (also give the "s" flag)
	aa echo123 +s  (same as just s)
	aa echo123 -a  (remove the "a" flag)
	aa  (list AutoAction assignments)
	Valid flags:
		a: AutoAnswer.
		1-9: AutoAnswer with priority, 1 is highest.
		c: AutoCall (redial on connection loss).
		j: AutoJoin (incoming call from this user autojoins current call).
		l: Long stat (or list) version of ?stat command allowed.
		m: AutoMute (outgoing mute enabled on any call status change).
		r: Reverse (hang up without answering, then return call).
		s: ?stat permission (?stat chat message from this user allowed).
		w: Watch (report the user's online status and profile field changes).
		x: Calls with this user can never be autoJoined or held by someone with a j or 1-9 flag.
	r may meaningfully be combined with 1-9 or j.
	w is not listed for the user if the user sends you a ?stat command.
	"""
	if len(args) == 0:
		return "\n".join(map(": ".join, conf.access()))
	args = list(args)
	if args[0] != "*": args[0] = getUserID(args[0])
	try: return "%s: %s" % (args[0], conf.access(*args))
	except: return err()

def do_AASummary(*args, **kwargs):
	"""
	Summarize autoAction flag assignments by flag rather than by user.
	This can produce a much shorter list than AA when there are many assignments.
	See the AA command for flags and their meanings, how to assign flags,
	and how to list flag assignments by user.
	"""
	flags = dict(conf.access())
	flagset = set("".join(flags.values()))
	results = []
	for flag in sorted(flagset):
		lst = []
		for user in sorted(flags.keys()):
			if flag in flags[user]:
				lst.append(user)
		results.append(flag +": " +", ".join(lst))
	return "\n".join(results)

def do_block(*args, **kwargs):
	"""
	Block a user.
	"""
	id = getUserID(kwargs["cmd"])
	u = skype.User(id)
	u.IsBlocked = True
	return "User %s is blocked but not deleted." % (IDAndName(id))

def do_blocks(*args, **kwargs):
	"""
	List blocked users.
	"""
	bu = filter(lambda u: u.IsBlocked, skype.Friends)
	if not len(bu):
		return "No blocked users."
	tbl = TableFormatter("Blocked users", [
		"Skype ID", "Name"
	])
	for u in bu:
		tbl.addRow([
			u.Handle, u.FullName
		])
	return tbl.format(2)

def do_unblock(*args, **kwargs):
	"""
	Unblock a user.
	"""
	id = getUserID(kwargs["cmd"])
	u = skype.User(id)
	if not u.IsBlocked:
		return "User %s is not blocked." % (IDAndName(id))
	bstat = u.BuddyStatus
	if bstat == 3:
		# Unblocking a contact has the curious side effect of deleting the contact.
		# Requesting authorization unblocks without this side effect.
		# [DGL, 2010-01-22]
		u.BuddyStatus = 2
		if u.IsBlocked:
			u.IsBlocked = False
		return "User %s is no longer blocked." % (IDAndName(id))
	u.IsBlocked = False
	return "User %s is no longer blocked but is still deleted." % (IDAndName(id))

def do_delUser(*args, **kwargs):
	"""
	Delete a user.
	"""
	id = getUserID(kwargs["cmd"])
	u = skype.User(id)
	if u.BuddyStatus == 1:
		return "User %s is already deleted." % (IDAndName(id))
	elif u.BuddyStatus == 0:
		return "User %s has never been in your contact list." % (IDAndName(id))
	u.BuddyStatus = 1
	return "User %s is deleted." % (IDAndName(id))

def do_addUser(id, *args, **kwargs):
	"""
	Add a Skype user or phone number to your contact list.
	For a Skype user, contact detail request text will be prompted for if necessary.
	For a phone number, a contact name will be prompted for if necessary.
	When adding a phone number, include the full number with country code prefix.
	A message or SkypeOut contact name may be included on the command line after the ID to be added.
	Examples:
		addUser echo123
		addUser xyzz Hello, you might remember meeting me last week at Alan's place.
		addUser +12025551212 New Jersey Information number
	"""
	id = fixPhoneNumbers(id)
	id = getUserID(id)
	# Lower cased because using upper case IDs can cause Skype4Py errors.
	id = id.lower()
	l = " ".join(args)
	u = skype.User(id)
	if u.BuddyStatus == 3:
		if u.IsSkypeOutContact:
			return "%s is already in your contact list." % (IDAndName(id))
		else:
			return "User %s is already sharing contact details." % (IDAndName(id))
	elif u.ReceivedAuthRequest:
		u.SetBuddyStatusPendingAuthorization("")
		return "User %s is now authorized." % (IDAndName(id))
	# New contact or phone number.
	if not l.strip():
		if u.IsSkypeOutContact:
			msgNoTime("Enter a name by which to identify this phone number in your contact list.")
			l = utils.raw_input_withoutHistory("Contact name: ")
		else:
			msgNoTime("Enter a message to introduce yourself.")
			l = utils.raw_input_withoutHistory("Message: ")
		if l is None: l = ""
		l = l.strip()
	if u.IsSkypeOutContact:
		u.SetBuddyStatusPendingAuthorization("")
		send("set user " +id +" displayname " +l)
		return "Phone number added."
	else:
		u.SetBuddyStatusPendingAuthorization(l)
		return "Request sent."

def do_auth(*args, **kwargs):
	"""
	Handle incoming authorization requests (people wanting to be added to your contact list).
	Auth with no arguments shows the profile of the next person and lets you add, delete, or skip the request.
	Auth with a number handles that specific request from the list of remaining ones.
	Auth list (or l) lists the authorization requests still pending.
	Auth count (or c) just shows the count of pending requests.
	"""
	uwa = sorted(skype.UsersWaitingAuthorization, key=lambda u: u.Handle)
	arg = kwargs["cmd"]
	if not arg: arg = 1
	arg = unicode(arg).lower()
	if "count".startswith(arg): return "%d" % (len(uwa))
	elif "list".startswith(arg):
		lines = []
		lines.append("%d pending request(s):" % (len(uwa)))
		for i,u in enumerate(uwa):
			lines.append("   %3d %s: %s" % (i+1, IDAndName(u.Handle), u.ReceivedAuthRequest))
		return "\n".join(lines)
	elif not arg.isdigit() or int(arg) < 1:
		return "Invalid auth command argument"
	# A specific auth record has been requested.
	try: u = uwa[int(arg)-1]
	except IndexError: return "Not that many pending authorization requests"
	arg = u.Handle
	kwargs = {"allowSkypeUserSearch": False}
	msgNoTime(do_whoIs("!"+u.Handle, **kwargs))
	l = ""
	while not l:
		l = utils.raw_input_withoutHistory("Add, delete, or Skip? (A/I/S): ")
		if not l: continue
		l = l.strip().lower()
		if not l: continue
		if "add".startswith(l):
			return do_addUser("!"+arg)
		elif "delete".startswith(l):
			u.BuddyStatus = 1
			return "Deleted"
		elif "skip".startswith(l):
			return "Skipped"
		else:
			msg("Invalid response.")
			l = ""

def do_dial(digits):
	"""
	Dial digits into the current call.
	"""
	call = getCallInProgress()
	if call is None: return "No active call"
	for ch in digits:
		send("set call " +unicode(call.Id) +" dtmf " +ch)
		# The above line returns immediately,
		# so the below time must count from the leading edge, not the trailing edge.
		# Experiments show the length of a DTMF from Skype to be a bit under 0.3 seconds.
		# [DGL, 2009-12-13]
		time.sleep(0.35)
	return ""

def do_errTrace(e=None):
	"""
	Provides a very brief traceback for the last-generated error.
	The traceback only shows file names (no paths) and line numbers.
	"""
	if e is None:
		try: e = err.trace
		except AttributeError:
			return "No error has been recorded yet."
	trc = []
	while e:
		l = e.tb_lineno
		fname = e.tb_frame.f_code.co_filename
		fname = os.path.basename(fname)
		trc.append("%s %d" % (fname, l))
		e = e.tb_next
	return ", ".join(trc)

def do_rec(which, recCmd, **kwargs):
	"""
	Implements the "rec, snd, and mic" commands:
		rec:  Report current output destination without changing it
		(may not work on MacOS).
		rec off:  Revert to output through soundcard.
		rec filename[.wav]:  Redirect output to filename.wav.
		rec portno:  Redirect output to port portno.
		rec portno |cmd: Pipe to cmd using portno as a conduit.
		rec portno ncplay [effects]:  Play through SoX(1) with optional effects.
		rec portno ncraw filename:  Record output in a raw data file.
		rec portno nctee filename [effects]:  SoX(1) output and also raw output file.
		(nc* options require nc(1), and ncplay/ncraw require sox(1).)
		mic works the same way for mic input capture.
		snd should work the same way for outgoing sound,
		but redirections containing portno seem not to work for that.
	"""
	which = which.lower()
	if which == "rec": which = "output"
	if which == "snd": which = "input"
	if which == "mic": which = "capture_mic"
	call = getCallInProgress()
	if not call: return "No active call"
	recCmd = re.sub("^\S+\s*", "", recCmd)
	file = recCmd
	if not file: return send("get call "+unicode(call.Id)+" " +which)
	if file.lower() == "off":
		dev = "soundcard"
		file = "default"
		# Kludge: Skype doesn't allow mic capture to be turned off,
		# so we send it to /dev/null to force the effect.
		if which == "capture_mic":
			dev, file = "file", "/dev/null"
		return send("alter call "+unicode(call.Id)+" set_"+which+" "+dev+"=\""+file+"\"")
	if file.partition(" ")[0].isdigit():
		# Port I/O, not file I/O.
		port,tmp,subproc = file.partition(" ")
		subproc = subproc.strip()
		if subproc:
			isTee = subproc.lower().startswith("nctee")
			isRaw = subproc.lower().startswith("ncraw")
			isPipe = subproc.startswith("|")
			if subproc.lower().startswith("ncplay") or isTee or isRaw:
				# Get rid of "ncplay" or "nctee" or "ncraw"
				subproc = subproc.partition(" ")[2].lstrip()
				# For nctee and ncraw, get the file name to write to.
				if isTee:
					fname,subproc = subproc.split(None, 1)
				elif isRaw:
					fname,subproc = subproc,""
				destcmd = "nc -l -p%s " % (port)
				if isTee:
					destcmd += "|tee " +fname +" "
				elif isRaw:
					destcmd += "> " +fname
				if not isRaw:
					destcmd += "|play -q -t raw -2 -s -c1 -r16000 - "
				subproc = destcmd +subproc
			elif isPipe:
				# Get rid of "|"
				subproc = subproc[1:].lstrip()
				destcmd = "nc -l -p%s |" % (port)
				subproc = destcmd +subproc
			subprocess.Popen(subproc, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
			time.sleep(1.0)
		cmd = "alter call "+unicode(call.Id)+" set_"+which+" port=\""+unicode(port)+"\""
		return send(cmd)
	if file[-4:] != ".wav": file = file +".wav"
	if file[0] not in "/\\" and file[1] != ":":
		home = os.environ.get("HOME") or ""
		if home: file = os.path.join(home, file)
	cmd = "alter call "+unicode(call.Id)+" set_"+which+" file=\""+file+"\""
	return send(cmd)

def inputStatusCheck(call, cmd):
	"""
	For the snd command: Check the command's success.
	"""
	result = send(cmd)
	msg(result)
	stat = send("get call " +unicode(call.Id) +" vaa_input_status")
	if "false" in stat.lower():
		# The change failed, so set things back to normal input.
		msg("Input sound redirection failed.")
		result = do_rec("snd", "snd off")
		msg(result)
	else:
		# Successful sound input redirection.
		msg("Sound input redirection succeeded.")

def idToCall(sid, exactHandle=False):
	"""
	Translate a  caller's ID or name (or part of one of those) into a call object if possible.
	A numeric ID is taken to be an actual call ID if it is a valid one.
	If exactHandle is True, sid must be an exact Skype user Id.
	Returns the associated Call object or None.
	"""
	if exactHandle:
		f = lambda call: sid.lower() == call.PartnerHandle.lower()
		calls = filter(f, activeCalls())
		if len(calls) != 1:
			raise ValueError("Invalid caller Id: " +sid)
		return calls[0]
	elif sid.isdigit():
		try: return skype.Call(sid)
		except: pass
	f = lambda call: sid.lower() in (call.PartnerHandle+", "+call.PartnerDisplayName).lower()
	calls = filter(f, activeCalls())
	if len(calls) == 0: return None
	f = lambda call: IDAndName(call.PartnerHandle, True)
	return utils.selectMatch(calls, "Select a call:", f)

def do_cache(*args, **kwargs):
	"""
	Build or clear the SkypeID-to-name cache:
		clear: Makes the next command or event show Skype IDs unconditionally.
		build: Reduces the showing of Skype IDs in subsequent commands and events.
	"Cache" by itself builds the cache.
	"""
	args = list(args)
	if not args: args.append("build")
	cmd = " ".join(args).lower()
	if "clear".startswith(cmd):
		IDAndName.userNames = dict()
		return "Name cache cleared."
	elif "build".startswith(cmd):
		# This caches all friend names.
		map(IDAndName, skype.Friends)
		return "Name cache built."
	else: return "Unknown subcommand: " +cmd

def do_call(*args, **kwargs):
	"""
	Initiate a Skype call.
	This is a direct Skype API command.
	Phone numbers with missing +1, embedded dashes or parens, etc.,
	are cleaned up by Clisk before the command is sent to Skype.
	"call ." calls the contact currently selected in the Skype graphical interface.
	"""
	args = cleanCallDestinations(args, activeCalls())
	cmd = "call " +", ".join(args)
	return send(cmd)

def do_callVoicemail(id, **kwargs):
	"""
	Initiate a Skype voicemail.
	This is a direct Skype API command.
	"callVoicemail ." sends a voicemail to the contact currently selected in the Skype graphical interface.
	Only one destination at a time is allowed for voicemails.
	"""
	id = fixPhoneNumbers(id)
	if id.startswith("+"):
		return "Phone numbers may not receive Skype voicemails."
	id = getUserID(id)
	cmd = "callVoicemail " +id
	return send(cmd)

def cleanCallDestinations(args, avoids=[], avoidPhoneNumbers=False):
	"""
	Clean up destination call IDs:
		- Convert partial user IDs or "." to full user IDs.
		- Fix phone number formatting (if phone numbers are allowed) or disallow them.
		- Remove IDs that are already in avoids.
	"""
	# Commas and spaces can both separate args.
	args = " ".join(args).replace(",", " ").split(None)
	args = map(lambda arg: fixPhoneNumbers(arg), args)
	args = map(lambda arg: getUserID(arg), args)
	args = filter(None, args)
	if not avoids: return args
	actives = map(lambda call: call.PartnerHandle.lower(), avoids)
	orgset = set(args)
	args = filter(lambda id: id.lower() not in actives, args)
	for lostArg in set(orgset - set(args)):
		msgNoTime("%s is already connected; skipping." % (lostArg))
	return args

def do_addCall(*args, **kwargs):
	"""
	Make the indicated outgoing call or calls and add them to the current call to form a conference.
	If there are no active calls, this command is equivalent to Call.
	"""
	actives = activeCalls()
	# We can't add any conferenced call to another call.
	avoids = filter(lambda call: call.ConferenceId, actives)
	args = cleanCallDestinations(args, avoids)
	if len(args) == 0: return "Please specify a Skype user or phone number to call."
	curcall = getCallInProgress(False, False)
	calls = []
	if curcall:
		calls.append(curcall)
	else:
		for call in actives:
			if call.Status == "INPROGRESS":
				if curcall is None: curcall = call
				calls.append(call)
	if not curcall:
		if len(actives) == 0:
			return do_call(*args)
		return "No active call"
	# Figure out which calls just need to be joined.
	connectedIds = []
	connectedUsers = []
	for id in args:
		call = idToCall(id)
		if call is None: continue
		connectedIds.append(call.Id)
		connectedUsers.append(id)
	for id in connectedIds:
		curcall.Join(id)
		call = skype.Call(id)
		safety = 0
		while safety < 50:
			if call.ConferenceId > 0: break
			time.sleep(0.2)
		try: call.Resume()
		except: pass
		time.sleep(0.2)
	args = list(set(args) -set(connectedUsers))
	if not args: return
	for call in calls:
		safety = 0
		while safety < 50:
			if "hold" in call.Status.lower(): break
			try: call.Hold()
			except: pass
			time.sleep(0.2)
			safety += 1
	nargs = len(args)
	for i,userID in enumerate(args):
		newcall = skype.PlaceCall(userID)
		curcall.Join(newcall.Id)
		if i == nargs-1: continue
		try: newcall.Hold()
		except: pass
		safety = 0
		while "hold" not in newcall.Status.lower() and safety < 100:
			time.sleep(0.1)
			try: newcall.Hold()
			except: pass
			safety += 1
		calls.append(newcall)
	for call in calls:
		try: call.Resume()
		except: pass

def do_answer(*args, **kwargs):
	"""
	Answer the incoming call or a specific call.
	If multiple calls are incoming at once, specify the Skype ID
	or partial ID of the caller whose call you want to answer.
	"""
	return doToActiveCall("answer", *args)

def do_hangup(*args, **kwargs):
	"""
	Hang up the active call or a specific call.
	To hang up a particular call, specify the Skype ID
	or partial ID of the caller whose call you want to hang up.
	"""
	return doToActiveCall("hangup", *args)

def do_hold(*args, **kwargs):
	"""
	Put the active call or a specific call on hold.
	To hold a particular call, specify the Skype ID
	or partial ID of the caller whose call you want to put on hold.
	"""
	return doToActiveCall("hold", *args)

def do_join(*args, **kwargs):
	"""
	Join the incoming call to the current call to create a conference.
	If multiple calls are incoming at once, specify the Skype ID
	or partial ID of the caller whose call you want to add to the current call.
	Note that a spurious Hangup sound may be generated when the calls are joined,
	and a "missed call" notification for the incoming call may also appear.
	"""
	return doToActiveCall("join", *args)

def do_reject(*args, **kwargs):
	"""
	Reject the incoming call or a specific call.
	To reject a specific call, specify the Skype ID
	or partial ID of the caller whose call you want to reject.
	"""
	return doToActiveCall("reject", *args)

def do_resume(*args, **kwargs):
	"""
	Resume the active call or a specific call.
	To resume a specific call, specify the Skype ID
	or partial ID of the caller whose call you want to resume.
	If there is an active call and exactly one call on hold and no ID is given,
	this command will hold the active call and resume the other one.
	"""
	return doToActiveCall("resume", *args)

def do_transfer(*args, **kwargs):
	"""
	Transfer a call to another destination.
	Syntax: transfer [callerSkypeID] dest1[,dest2...]
	Specify one or more call destinations separated by commas.
	To transfer a particular call, specify the Skype ID
	or partial ID of the caller whose call you want to transfer
	before the destination, then a space, then the destination(s).
	If no call ID is given and there is one incoming call, that call is used.
	If no calls are incoming, the active call is used if there is one.
	Examples:
		tr echo123  (transfer the incoming or active call to echo123)
		tr dl echo123  (transfer the call whose caller's Skype ID starts with "dl")
		tr test,echo123  (transfer to test or echo123, whichever answers first)
		tr dl test,echo123  (do that to the "dl" call)
	"""
	return doToActiveCall("transfer", *args)

def doToActiveCall(cmd, *args):
	"""
	Do something just requiring a verb to the active call or another specific call.
	Supported actions: answer, reject, hold, resume, hangup, transfer, join, members.
	Resume will toggle between this and the other call if one is active and there are exactly two.
	userID, if passed, chooses the call to use by its user's Skype ID.
	Otherwise the currently in-progress call is used.
	For answer/reject/transfer, the incoming call is used.
	For join, the incoming call is joined to the active call.
	"""
	userID = " ".join(args)
	cmdl = cmd.lower()
	if (cmdl == "answer"
	or cmdl == "reject"
	or cmdl == "transfer"
	or cmdl == "join"):
		# Handle these separately since they deal with a separate set of calls.
		calls = activeCalls()
		ringingCalls = filter(lambda call: "ringing" in call.Status.lower(), calls)
		if cmdl == "transfer":
			callInProgress = getCallInProgress(False)
			ids = userID.split(",")
			# Parsable but perhaps confusing syntax:
			# If the first word of user ID is followed by a space but not a comma,
			# it identifies the call to transfer, not the transfer destination.
			# Since there must be a destination, a single id must be it.
			try: userID,ids[0] = ids[0].split(None, 1)
			except ValueError: userID = ""
		if userID:
			call = idToCall(userID)
			if call is None: return "No matching call"
		elif len(ringingCalls) == 0:
			if not cmdl == "transfer": return "No incoming calls"
			elif callInProgress is None: return "No active or incoming call"
			else: call = callInProgress
		elif len(ringingCalls) == 1: call = ringingCalls[0]
		else: return "Multiple incoming calls, must specify which to use."
		if cmdl == "transfer":
			call.Transfer(",".join(ids))
			return None
		elif cmdl == "join":
			curcall = getCallInProgress(False, False)
			if not curcall:
				curcall = activeCalls("inprogress")[0]
			call.Join(curcall.Id)
			# Go on to answer the incoming call too.
		if cmdl == "reject": call.Finish()
		else:
			try: call.Answer()
			except Skype4Py.SkypeError: pass
		return
	# Non-answer/reject requests.
	defaultCall = (userID == "")
	useOtherCall = (defaultCall and (cmdl == "resume"))
	if defaultCall:
		call = getCallInProgress(useOtherCall)
		if not call: return "No active call"
	else:
		call = idToCall(userID)
		if call is None: return "No matching call"
	# Things like call.Hold() can produce "invalid call Id" messages at least on MacOS.
	# [DGL, 2010-04-30]
	if cmdl == "hold":
		msgErrOnly(send("set call " +unicode(call.Id) +" status onhold"))
	elif cmdl == "resume":
		msgErrOnly(send("set call " +unicode(call.Id) +" status inprogress"))
	elif cmdl == "hangup":
		msgErrOnly(send("set call " +unicode(call.Id) +" status finished"))
	elif cmdl == "members":
		# First get a handle-to-status hash built.
		stats = dict()
		if call.ConferenceId:
			# Locally-hosted conference:
			# List names of partners in calls that are in the same conference.
			calls = filter(
				lambda c1: c1.ConferenceId == call.ConferenceId,
				activeCalls()
			)
			for c1 in calls:
				stats[c1.PartnerHandle] = fullCallStatus(c1)
		else:
			# Non-locally-hosted conference or plain call.
			participants = getCallParticipants(call)
			if len(participants) == 0:
				# Plain call.
				stats[call.PartnerHandle] = fullCallStatus(call)
			else:
				# Non-locally-hosted conference.
				for p in participants:
					stat = p.CallStatus
					stat = fullCallStatus(p, stat)
					stats[p.Handle] = stat
		# We now have stats as SkypeID-to-stat,
		# but we want collections of users by status.
		d = dict()
		for id,stat in stats.items():
			d.setdefault(stat, [])
			d[stat].append(IDAndName(id))
		return "\n".join(
			[linearList(stat, sorted(names)) for stat,names in d.items()]
		)
	return None

def getCallDescription(call):
	"Gets a description for the given call."
	party = IDAndName(call.PartnerHandle)
	tm = call.Timestamp
	tm = utils.timeString(tm)
	return party +": " +tm

def getMissedCalls(cmd):
	"""
	Handles missedcalls commands (mc).
		- Add "c" to clear calls reported while reporting them.
		- Add a number to restrict calls reported/cleared to that many.
		- The default call count limit is 20 so they won't scroll off screen.
		- A limit of 0 means no limit.
	Examples: mc, mcc, mcc 15, mcc 0.
	"""
	if cmd.lower().startswith("mc"):
		cmd = cmd[2:].lstrip()
	clearing = False
	if cmd.lower().startswith("c"):
		cmd = cmd[1:].lstrip()
		clearing = True
	cmd = cmd.strip()
	if cmd and not cmd.isdigit():
		return "Syntax error in Missed Calls command"
	maxcalls = 20
	if cmd: maxcalls = int(cmd)
	calls = skype.MissedCalls
	ncalls = len(calls)
	if not ncalls: return "No missed calls"
	if maxcalls == 0: maxcalls = ncalls
	buf = "%d missed calls:" % (ncalls)
	for i,call in enumerate(calls):
		if i > maxcalls-1: break
		buf += "\n" +getCallDescription(call)
		if clearing: call.Seen = True
	return buf

def err(origin="", exctype=None, value=None, traceback=None):
	"Nice one-line error messages for when the user tries something impossible."
	errtype,errval,errtrace = (exctype, value, traceback)
	exctype,value,traceback = sys.exc_info()
	if not errtype: errtype = exctype
	if not errval: errval = value
	if not errtrace: errtrace = traceback
	# Static error trace preservation for do_error().
	err.val = errval
	err.trace = errtrace
	buf = ""
	if origin: buf += origin +" "
	buf += errtype.__name__ +": " +unicode(errval)
	for i in range(2, len(errval.args)):
		buf += ", " +unicode(errval.args[i])
	return buf

def excepthook(errtype,errval,errtrace):
	msg(err(exctype=errtype, value=errval, traceback=errtrace))
	time.sleep(5)
sys.excepthook = excepthook

def do_m():
	"""
	Toggle mute on/off.
	"""
	# At least Mac Skype 5 can fail to send Mute notifications.
	# This is probably why skype.Mute can become wrong.
	# We therefore completely sidestep Skype4Py here.
	val = send("get mute").lower()
	if val == "on":
		return send("mute off")
	elif val == "off":
		return send("mute on")
	else:
		msg("Unable to determine mute state")

def do_sklog(onOff=None):
	"Turn Skype debug logging on/off or check current status."
	if onOff is None: return conf.sklogging()
	if onOff.isdigit(): return conf.sklogging(int(onOff))
	if onOff.lower() in ["no", "off", "false"]: onOff = 0
	elif onOff.lower() in ["yes", "on", "true"]: onOff = 1
	else: return "Unrecognized logging request: " +unicode(onOff)
	return conf.sklogging(onOff)

def do_log(onOff=None):
	"Turn activity logging on/off or check current status."
	if onOff is None: return conf.logging()
	if onOff.isdigit(): return conf.logging(int(onOff))
	if onOff.lower() in ["no", "off", "false"]: onOff = 0
	elif onOff.lower() in ["yes", "on", "true"]: onOff = 1
	else: return "Unrecognized logging request: " +unicode(onOff)
	return conf.logging(onOff)


def do_vmPlay(id=None, inCall=False, wait=False):
	"""
	Play the most recent unplayed voicemail, or a specific voicemail by its ID or index.
	Also marks the voicemail as played.
	Use a positive number for an ID and a negative number for an index.
	-1 is the most recently played voicemail, -2 the next oldest, etc.
	vmPlay 0 repeats the last voicemail played by this command.
	"""
	if id is None:
		if len(skype.MissedVoicemails) == 0:
			return "No missed voicemails"
		vm = skype.MissedVoicemails[-1]
	elif int(id) == 0:
		try: vm = do_vmPlay.vm
		except AttributeError: return "Clisk has not played a voicemail yet."
	elif int(id) < 0:
		vm = skype.Voicemails[-1-int(id)]
	else:
		vm = skype.Voicemail(int(id))
	# This lets "vmPlay 0" stop and restart the currently playing voicemail.
	try:
		vm.StopPlayback()
		# The delay is necessary to avoid "action failed."
		time.sleep(0.5)
	except: pass
	if inCall:
		vm.StartPlaybackInCall()
	else:
		vm.StartPlayback()
	do_vmPlay.vm = vm
	if wait:
		waitForVMInfo(vm)
	min,sec = divmod(vm.Duration, 60)
	s = "Voicemail length %02d:%02d from %s %s (ID %d)" % (
		min, sec, IDAndName(vm.PartnerHandle), utils.timeString(vm.Timestamp),
		vm.Id
	)
	msgNoTime(s)
	time.sleep(0.25)
	return reportFailures(vm)

def waitForVMInfo(vm):
	"""
	Wait for undownloaded voicemail to provide info about itself.
	Assumes the download process has already been initiated.
	Helper for do_vmPlay().
	"""
	if vm.Duration != 0: return
	# Status goes from NOTDOWNLOADED, quickly to PLAYING,
	# then quickly to BUFFERING, then eventually back to PLAYING.
	# We need to skip the first PLAYING.
	time.sleep(0.5)
	tries = 40
	#while tries and vm.Duration == 0 and "notdownloaded" in send("get voicemail %d status" % (vm.Id)).lower():
	while tries and vm.Status.lower() not in ["notdownloaded", "buffering"]:
		tries -= 1
		time.sleep(0.25)
	# For some reason, Duration can still be 0 here.
	tries = 30
	while tries and vm.Duration == 0:
		tries -= 1
		time.sleep(0.25)
	return

def reportFailures(vm):
	fr = vm.FailureReason
	if fr and fr.lower() != "unknown":
		return fr

def do_vmToCall(id=None):
	"""
	Play the most recent unplayed voicemail, or a specific voicemail by its ID.
	Also marks the voicemail as played.
	This command plays through the active call while also playing to the default sound device.
	"""
	return do_vmPlay(id, True)

def do_vmStop():
	"""
	Stop the currently playing voicemail.
	This only works if Clisk was used to start playing it.
	"""
	try: do_vmPlay.vm.StopPlayback()
	except AttributeError: return "Clisk is not playing a voicemail."
	else:
		return reportFailures(do_vmPlay.vm) or "Stopped."

def do_vmDelete():
	"""
	Delete the currently playing or last-played voicemail.
	This only works if Clisk was used to start playing it.
	"""
	try:
		do_vmPlay.vm.Delete()
		return reportFailures(do_vmPlay.vm) or "Deleted"
	except AttributeError: return "Clisk has not played a voicemail yet."

def do_vmCount():
	"""
	Indicate the number of voicemails and the number still unplayed.
	"""
	n = len(skype.Voicemails)
	nNew = len(skype.MissedVoicemails)
	return "Voicemails: %d, %d unplayed" % (n, nNew)

def do_vmGreeting(cmd=None):
	"""
	Play a voicemail greeting.
	Without arguments, plays your greeting.
	If an argument is given, that user's greeting is played.
	"""
	if cmd:
		h = getUserID(cmd)
	else:
		h = skype.CurrentUserHandle
	vmid = send("search greeting " +h)
	if not vmid:
		return "No voicemail greeting found for that user."
	return do_vmPlay(vmid, wait=True)

def do_files():
	"""
	List active file transfers in a tabular format.
	"""
	afts = skype.ActiveFileTransfers
	if len(afts) == 0:
		return "No active file transfers"
	tbl = TableFormatter("Active File Transfers", [
		"Type", "Skype ID", "Status/Progress",
		"KBPS", "Time Left",
		"File"
	])
	for aft in afts:
		try:
			progress = (float(aft.BytesTransferred) / aft.FileSize) *100
			progress = "%6.2f" % (progress) +"%"
		except ZeroDivisionError:
			progress = ""
		stat = aft.Status.lower()
		if progress:
			stat += " " +progress
		if aft.FailureReason and aft.FailureReason.lower() != "unknown":
			stat += " (" +aft.FailureReason.lower() +")"
		tl = aft.FinishTime
		if tl:
			tl = int(tl -time.time())
			min,sec = divmod(tl, 60)
			timeleft = "%02d:%02d" % (min, sec)
		else:
			timeleft = ""
		tbl.addRow([
			aft.Type.lower(),
			IDAndName(aft.PartnerHandle),
			stat,
			"%1.2f" % (float(aft.BytesPerSecond) /1024),
			timeleft,
			aft.FileName
		])
	return tbl.format(2)

def do_fsend(*args, **kwargs):
	"""
	Open the Skype Send File dialog, already set up to send to a specific user or users. 
	Separate users with a comma.
	You may optionally add a folder to open in after the user name(s).
	NOTE: This command does NOT send files.  It opens a dialog to let you select files to send.
	If the dialog is left open too long, a harmless error message may print in the Clisk window.
	"""
	if len(args) < 1:
		raise SyntaxError("No users specified")
	folder = ""
	# The last argument is really a folder if its predecessor doesn't end with a comma.
	if len(args) >= 2 and not args[-2].endswith(","):
		args = list(args)
		folder = args.pop(-1)
	# Commas and spaces can both separate users.
	args = " ".join(args).replace(",", " ").split(None)
	args = map(lambda arg: getUserID(arg), args)
	args = filter(None, args)
	cmd = "open filetransfer " +",".join(args)
	if folder: cmd += " in " +folder
	thr = threading.Timer(0, lambda: send(cmd, 10))
	thr.setDaemon(True)
	thr.start()
	return "Opening"

def do_end():
	"""
	Show when the current SkypeOut call would end automatically.
	This assumes the Skype four-hour limit on outbound Skype-to-PSTN calls.
	"""
	call = getCallInProgress()
	if call is None:
		msg("No active call")
		return
	elif not call.Type.lower().startswith("out"):
		msg("This is not a SkypeOut call")
		return
	# Four hours, in seconds.
	maxlen = 4 *3600
	tm = utils.timeString(call.Timestamp +maxlen)
	delta = maxlen -call.Duration
	msg("Skype will end this call in %s (%s)" % (
		utils.msTime(delta),
		tm
	))

def do_calls():
	"""
	List active calls in a tabular format.
	"""
	return callList(False)

def callList(alwaysIncludeSkypeIDs = False, hidePhoneNumbers=False):
	"""
	List active calls in a tabular format.
	"""
	calls = activeCalls()
	if len(calls) == 0:
		return "No active calls on " +hostname()
	tbl = TableFormatter("Active calls on " +hostname(), [
		"Skype ID(s)", "Status", "Vid S/R", "Duration", "Call ID"
	])
	for call in calls:
		id = unicode(call.Id)
		if call.ConferenceId:
			id = "C" +unicode(call.ConferenceId) +"/" +id
		stat = fullCallStatus(call, includeType=True)
		vidstat = fullVideoStatus(call)
		duration = utils.msTime(call.Duration)
		tbl.addRow([
			callDest(call, alwaysIncludeSkypeIDs, hidePhoneNumbers),
			stat, vidstat, duration, id
		])
		for p in getCallParticipants(call):
			stat = p.CallStatus
			stat = fullCallStatus(p, stat, True)
			tbl.addRow([
				"   %d %s" % (p.Idx, IDAndName(p.Handle, alwaysIncludeSkypeIDs, hidePhoneNumbers)),
				stat, "", "", ""
			], True)
	return tbl.format(2)

def callDest(call, alwaysIncludeSkypeID=False, hidePhoneNumbers=False):
	"""Return a string representing the destination of the given call.
	This is the PartnerHandle mostly but includes TransferredTo as appropriate.
	TransferredBy is also included as appropriate.
	"""
	result = IDAndName(call.PartnerHandle, alwaysIncludeSkypeID, hidePhoneNumbers)
	tr = ""
	try: tr = IDAndName(call.TransferredTo, alwaysIncludeSkypeID, hidePhoneNumbers)
	except: pass
	if tr: result += " -> " +tr
	tr = ""
	try: tr = IDAndName(call.TransferredBy, alwaysIncludeSkypeID, hidePhoneNumbers)
	except: pass
	if tr: result += " (tr by " +tr +")"
	nparts = len(getCallParticipants(call))
	if nparts:
		result = "Conference(%d) %s" % (nparts, result)
	return result

def do_lo(user):
	"""
		Reports a contact's last online time.
		For an offline contact, this is the last time the user was seen in Skype.
		For a contact that is currently in Skype, this should be the last time
		the contact's status was verified.
		See also the "os" command for a relative time instead of an exact time.
	"""
	if not user: return "No Skype ID specified."
	user = getUserID(user)
	tm = skype.User(user).LastOnline
	if not tm: return "empty result"
	return "%s last online %s" % (IDAndName(user), utils.timeString(tm))

def do_os(user):
	"""
		Reports a contact's current online status (online, away, offline, etc.).
		For an offline contact, also indicates if the user forwards calls or has voicemail.
		Also  reports the user's last status check time,
		which is time last seen for offline contacts.
		For online contacts, this should be the last time the status was verified.
		The last seen or verification time is given as hours:minutes:seconds ago.
		Example: "00:07:45 ago" means 7 minutes 45 seconds ago.
		See the "lo" command to get an exact date/time instead of a relative time.
		Also reports the user's mood text if non-blank.
	"""
	if not user: return "No Skype ID specified."
	user = getUserID(user)
	u = skype.User(user)
	stat = onlineStatus(u, True)
	buf = "%s %s" % (IDAndName(user), stat)
	mood = u.MoodText.strip()
	if mood:
		buf += "\nMood text: " +mood
	return buf

def do_clear():
	"""
	Clears the screen.
	"""
	if conf.plat == "windows":
		os.system("cls")
		return ""
	os.system("clear")
	return ""

def do_cls():
	"""
	Clears the screen.
	"""
	return do_clear()

def contactsByStatus(stat, includeEmpty=False):
	"""
	Return a line listing contacts by status.
	"""
	contacts = filter(lambda c: c.OnlineStatus == stat, skype.Friends)
	if not includeEmpty and len(contacts) == 0: return None
	try: stat = skype.Convert.OnlineStatusToText(stat).title()
	except Skype4Py.SkypeError: stat = stat.Title()
	return linearList(stat, contacts, IDAndName)

def do_contacts(*args, **kwargs):
	"""
	List contacts by status.
	With no arguments, lists all contacts that are in Skype (online, away, DND, etc.).
	Specify a for away, d for DND, on for online, off for offline, etc., for a sublist.
	"""
	do_cache()
	if not args:
		# List connected contacts.
		stats = ["SKYPEME", "ONLINE", "AWAY", "NA", "DND"]
		return "\n".join(filter(None,
			map(lambda stat: contactsByStatus(stat, False), stats)
		))
	# All online statuses represented in the contact list,
	# plus the basic ones known at this writing.
	contacts = skype.Friends
	rawstats = set(map(lambda c: c.OnlineStatus, contacts))
	rawstats |= set(["SKYPEME", "ONLINE", "AWAY", "NA", "DND", "OFFLINE"])
	rawstats = list(rawstats)
	# Made into localized status names.
	transtats = map(skype.Convert.OnlineStatusToText, rawstats)
	# And a mapping of all possible status names to real statuses.
	stats = dict(zip(rawstats, rawstats))
	stats.update(zip(transtats, rawstats))
	# Now find out what the user asked for.
	stat = " ".join(args).lower()
	# These are the status strings that match stat.
	ustats = filter(lambda st: st.lower().startswith(stat), stats.keys())
	# And these are the associated real statuses.
	stats = list(set([stats[st] for st in ustats]))
	if len(stats) == 0:
		raise ValueError('No status found matching "' +stat +'"')
	stat = utils.selectMatch(stats, "Select an online status:")
	# Now for the set of contacts with the wanted status.
	return contactsByStatus(stat, True)

def do_msg(*args, **kwargs):
	"""
	Send a chat message to a person or chat.
	Person: msg bob Hello
	Chat: either msg #blob Hello or msg @partialChatName Hello.
	Blobs begin with a number sign and come from a SEARCH ACTIVECHATS command.
	Also supports sending slash commands like /help from inside Clisk.
	Example: msg echo123 /help.
	"""
	cmd = kwargs["cmd"].strip()
	if not len(cmd):
		raise SyntaxError("Must specify a user or chat to send to.")
	[id],content = parseline(cmd, 1)
	if id[0] in "@#":
		# Sending to a chat:  @ for chatName, for blob.
		if id.startswith("@"):
			id = chatBlobFromName(id[1:])
			if not id: return "No chat ID given."
		cmd = "chatmessage %s " % (id)
	else:
		# Sending to a person.
		id = getUserIDs(id)
		if not id: return "No Skype user ID(s) given."
		cmd = "message %s " % (id)
	if not content:
		content = getMultilineValue()
	cmd += content
	result = doCommand(cmd)
	if result.endswith("STATUS SENDING"): return "Sending"
	elif result.endswith("STATUS READ"):
		# This is for replies to things like /help when typed in Clisk.
		msgno = result.split()[1]
		return chatLine(skype.Message(msgno))
	return result

def getMultilineValue():
	"""
	Get and return a possibly multiline value,
	so the value can be sent as part of a Skype API command.
	The content is prompted for and terminated with a dot on its own line.
	An EOF also ends a value.
	"""
	show("Enter text, end with a period (.) on a line by itself.")
	content = ""
	while True:
		try:
			line = raw_input("")
		except EOFError:
			line = "."
		line = line.strip()
		if line == ".":
			break
		if content:
			content += "\n"
		content += line
	return content

def chatBlobFromName(name):
	"""
	Return a chat blob given its name or partial name.
	"""
	f = lambda chat: name.lower() in chat.FriendlyName.split("|")[0].lower()
	chats = filter(f, skype.RecentChats)
	if not chats:
		# Filter is not used because, at least on Macs,
		# a chat can exist in skype.Chats that has an invalid name.
		# This causes SkypeErrors that would otherwise keep us from finding a chat.
		# Also, going through all of skype.Chats can take several minutes for long chat history.
		#chats = filter(f, skype.Chats)
		chats = []
		for i,chat in enumerate(skype.Chats):
			try:
				if f(chat): chats.append(chat)
			except Skype4Py.SkypeError, e:
				e.args = utils.tupleAppend(e.args, "Chat index %d" % (i))
				msg(err(origin="Warning", value=e))
				pass
			# At this writing I have 5570 chats in skype.Chats. [DGL, 2010-03-17]
			if (len(chats) > 0 and i > 500) or i > 1000: break
	if not chats:
		raise ValueError('No chat names contain "' +name +'"')
	return utils.selectMatch(chats, "Select a chat:", chatName).Name

def chatFromBlob(blob):
	"""
	Returns a Chat object given its blob.
	Written to get around problems with skype.Chat(blob) and skype.FindChatUsingBlob(blob) on Macs.
	"""
	try: return skype.Chat(blob)
	except Skype4Py.SkypeError:
		# FindChatUsingBlob doesn't work either here.
		chats = filter(lambda c: c.Name == blob, skype.Chats)
		if len(chats) == 1: return chats[0]
		# Otherwise re-raise the first error.
		try: return skype.FindChatUsingBlob(blob)
		except Skype4Py.SkypeError, e:
			e.args = utils.tupleAppend(e.args,"blob " +blob)
			raise e

def do_members(*args, **kwargs):
	"""
	List the members in a call or text chat.
	For a call, just type the call's name, like for Hangup, Hold, etc.
	If you don't type anything, the current call is used.
	For a chat, type an at sign (@) followed by the chat name or part of it,
	as for the msg command when sending to a chat by name.
	You can also type a blob name (which starts with "#") for a chat.
	Call members are listed by status.
	For chats, active and inactive members are listed separately when possible.
	"""
	if not len(args) or args[0][0] not in "@#":
		# Asking about a call.
		return doToActiveCall("members", *args)
	# Asking about a chat:  @ for chatName, for blob.
	who = " ".join(args)
	if who.startswith("@"):
		who = chatBlobFromName(who[1:])
		if not who: return "No chat ID given."
	c = chatFromBlob(who)
	memfunc = lambda member: IDAndName(member.Handle)
	all = set(c.Members)
	try:
		active = set(c.ActiveMembers)
		inactive = all -active
		return "\n".join(filter(None, [
			linearList("Active", active, memfunc),
			linearList("Inactive", inactive, memfunc),
		]))
	except Skype4Py.SkypeError:
		# Mac Skype at this writing doesn't have Chat.ActiveMembers.
		return linearList("Total", all, memfunc)

def linearList(name, l, func=lambda e: unicode(e)):
	"""
	List l on a (possibly long and wrap-worthy) line.
	Null elements are removed.  If you don't want this, send in a func that avoids the issue.
	"""
	l1 = sorted(filter(None, map(func, l)), key=lambda k: k.lower())
	if len(l) == 0:
		return "%3d %s." % (0, name)
	return "%3d %s: %s." % (len(l1), name, ", ".join(l1))

def do_nc(arg=1, chatspec=""):
	"""
	Handle missed chat messages.
	Without arguments, shows the oldest unread chat message and marks it as Seen.
	Add a number to show up to that many messages at once.
	Use 0 or "all" for all remaining missed messages.
	Use "count" (or "c") for a count only.
	Use "clear" to clear all missed messages without showing them.
	Use "list" to list the conversations containing missed messages.
	You can add a chat specification to limit results to one chat (except for "list").
	"""
	arg = unicode(arg).lower()
	if "list".startswith(arg):
		# This one ignores any chatspec.
		return do_nc("count") +":  " +", ".join(
			map(chatName, skype.MissedChats)
		)
	col = skype.MissedMessages
	if chatspec:
		chatspec = getChat(chatspec)
		col = filter(lambda cm: cm.Chat == chatspec, col)
	if "count".startswith(arg):
		if chatspec: convs = [chatspec]
		else: convs = skype.MissedChats
		return "%d missed chat messages in %d conversations" % (
			len(col), len(convs)
		)
	elif "clear".startswith(arg):
		cnt = len(col)
		[cm.MarkAsSeen() for cm in col]
		return "%d (marked as read)" % (cnt)
	elif "all".startswith(arg) or arg == "0":
		arg = 99999999
	elif arg.isdigit() and int(arg) > 0:
		arg = int(arg)
	else:
		return "Invalid message count: %s" % (arg)
	# arg is now a positive (non-zero) message count.
	idx2 = len(col) -1
	if idx2 < 0: return "No missed chat messages"
	idx1 = max(idx2-arg, -1)
	# Newest message is [0], so start at the other end.
	for i in range(idx2, idx1, -1):
		cm = col[i]
		msg(chatLine(cm))
		cm.MarkAsSeen()

def getChat(chatspec):
	"""
	Return a Chat object as indicated by chatspec.
	"""
	if chatspec[0] in "@#":
		# A chat blob or partial name.
		if chatspec.startswith("@"):
			chatspec = chatBlobFromName(chatspec[1:])
			if not chatspec: return None
		chat = chatFromBlob(chatspec)
		return chat
	# A participant name or partial name.
	# TODO: Not implemented yet.
	return None

def chatName(chat):
	"""
	Return a formatted chat name from the given Chat object.
	"""
	try: name = chat.FriendlyName.split("|",1)[0]
	except:
		name = ""
		try:
			name = chat.Name
			try: name = name.split("/")[0]
			except: pass
		except: pass
		if not name: name = "(unknown chat)"
		return "(chat " +name +"...)"
	# Replace any strings of spaces/tabs with a single space.
	# This is for users who hide their names in contact lists by embedding a lot of spaces.
	# Chats often get named after their participants...
	name = " ".join(name.split())
	if len(name) > 20:
		name = name[:20] +"..."
	return name

def chatLine(cm, body=None):
	"""
	Return a formatted chat line from the given ChatMessage object.
	Formats ("<" and ">" are literal here):
		Normal line: <sender@chatName> body
		Action line: * sender@chatName body
		Other: * sender@chatName type body
	Body will include the FailureReason if there is one.
	if body is given, the message is being edited or removed and this will be indicated.
	"""
	sendername = IDAndName(cm.FromHandle).strip()
	chatname = chatName(cm.Chat).strip()
	if chatname == sendername:  name = sendername
	else: name = sendername +"@" +chatname
	if body is None:
		edit = ""
		body = fixBody(cm.Body)
	else:
		# Message is being edited or removed.
		if len(body) > 0:
			edit = "(edited) "
			body = fixBody(body)
		else:
			# Can't easily report what was removed because cm.Body is already gone.
			edit = "(removed message) "
	if cm.Type == "SAID":
		m = "<%s%s>" % (edit, name)
	elif cm.Type == "EMOTED":
		m = "* %s%s" % (edit, name)
	else:
		m = "* %s%s %s" % (edit, name, cm.Type.lower())
	if edit:
		m += " " +body
		return m
	if body:
		m += " " +body
	if cm.LeaveReason.strip():
		m += " " +cm.LeaveReason
	return m

def fixBody(body):
	"""
	Make adjustments to the body of a message to clean it up before display.
	Helper for chatLine().
	"""
	# HTML/XML tag translation/deletion.
	body = body.replace("&apos;", "'")
	# Removal of Mac mood-message adenda.
	if "<macmoodmessage " in body:
		body = re.sub(r'<macmoodmessage\s+.*?/>', '', body, 1)
	return body

def do_vidSend(subcmd="", *args, **kwargs):
	"""
	Start/stop/check video sending in the current or indicated call.
	Specify start, stop, on, off, or check, after the command.
	To alter a specific call, specify the Skype ID
	or partial ID of the caller whose call you want to alter.
	"""
	return vidOnOff(False, subcmd, *args, **kwargs)

def do_vidReceive(subcmd="", *args, **kwargs):
	"""
	Start/stop/check video receiving in the current or indicated call.
	Specify start, stop, on, off, or check, after the command.
	To alter a specific call, specify the Skype ID
	or partial ID of the caller whose call you want to alter.
	"""
	return vidOnOff(True, subcmd, *args, **kwargs)

def vidOnOff(useReceive, subcmd, *args, **kwargs):
	"""
	Turn video on or off in the current or indicated call,
	or check the current status of video send or receive.
	"""
	if not subcmd:
		subcmd = "check"
	checking = False
	if commandMatches(subcmd, ["start", "on", "yes"]):
		turnOn = True
	elif commandMatches(subcmd, ["stop", "off", "no"]):
		turnOn = False
	elif commandMatches(subcmd, "check"):
		checking = True
	else:
		raise SyntaxError("Unrecognized subcommand: " +subcmd)
	userID = " ".join(args)
	if userID == "":
		call = getCallInProgress(False)
		if not call: return "No active call"
	else:
		call = idToCall(userID)
		if call is None: return "No matching call"
	id = call.Id
	if checking:
		# These are a bit different, so just handle them right here.
		if useReceive:
			which = "video_receive_status"
		else:
			which = "video_send_status"
		return send("get call %d %s" % (call.Id, which))
	# On/off request.
	if turnOn:
		which = "start"
	else:
		which = "stop"
	which += "_video_"
	if useReceive:
		which += "receive"
	else:
		which += "send"
	send("alter call %d %s" % (id, which))
	return "Done."

def commandMatches(cmd, lst):
	"""
	Return True if cmd matches one of lst.
	lst may be a string for just one possibility.
	"""
	if type(lst) is str:
		lst = [lst]
	found = filter(lambda c: c.lower().startswith(cmd), lst)
	return len(found) > 0

def do_events():
	"""
	Indicate what events have occurred that have not been dealt with yet.
	Reports any missed calls, voicemails, chat messages, SMS messages,
	or users requesting to be added to your contact list.  Also shows which
	commands can be used to get more information about each missed event type.
	"""
	lines = []
	cnt = len(skype.MissedCalls)
	if cnt > 0:
		lines.append("%d missed calls, use mc to list/clear." % (cnt))
	cnt = len(skype.MissedVoicemails)
	if cnt > 0:
		lines.append("%d missed voicemails, use vmPlay to play." % (cnt))
	cnt = len(skype.MissedMessages)
	if cnt > 0:
		lines.append("%d missed chat messages in %d conversations, use nc to read." % (cnt, len(skype.MissedChats)))
	cnt = len(skype.MissedSmss)
	if cnt > 0:
		lines.append("%d missed SMS messages, use sms to list/clear." % (cnt))
	cnt = len(skype.UsersWaitingAuthorization)
	if cnt > 0:
		lines.append("%d missed users requesting to be added, use auth to list/clear." % (cnt))
	m = "\n".join(lines)
	if not m: m = "No missed events."
	return m

def do_alias(al=None, *cmdparts):
	"""
	Defines or shows one or all aliases or removes one or more aliases.  Examples:
	alias cl clear
	cl  (clears the screen)
	alias mse message echo123
	mse Hello!  (sends echo123 a "Hello!" message)
	alias cl  (shows that alias)
	alias  (lists all aliases)
	alias -cl mse  (removes the indicated aliases)
	"""
	if al is None and not cmdparts:
		return aliases()
	al = al.lower()
	removing = False
	if al[0] == "-":
		al = al[1:]
		if not al:
			raise SyntaxError("Must specify an alias to remove")
		removing = True
	if not removing and cmdparts and al in ["alias", "exit", "q", "quit"]:
		raise ValueError(al +" is not allowed as an alias")
	if removing:
		# Allow multiple aliases to be removed at once.
		als = list(cmdparts)
		als.insert(0, al)
	elif not cmdparts:
		# Just asking for the value of an alias.
		cmd = ""
	else:
		cmd = " ".join(cmdparts)
	c = ConfigParser.ConfigParser()
	c.read(conf.inipath)
	sSect = "Aliases"
	if removing:
		for al in als:
			if not c.has_option(sSect, al):
				msgNoTime("Alias " +al +" not found")
				continue
			try:
				c.remove_option(sSect, al)
			except (ConfigParser.NoSectionError, ConfigParser.NoOptionError):
				msgNoTime("Alias " +al +" not found")
	elif not cmd:
		if not c.has_option(sSect, al):
			return "Alias " +al +" not found"
		val = c.get(sSect, al)
		return "%s = %s" % (al, val)
	else:
		try: c.set(sSect, al, cmd)
		except ConfigParser.NoSectionError:
			c.add_section(sSect)
			c.set(sSect, al, cmd)
	c.write(open(conf.inipath, "w"))

def aliases():
	"""
	Lists all defined aliases and their values.
	"""
	c = ConfigParser.ConfigParser()
	c.read(conf.inipath)
	sSect = "Aliases"
	s = "Aliases:"
	try:
		for opt in sorted(c.options(sSect)):
			val = c.get(sSect, opt)
			s += "\n   %s = %s" % (opt, val)
	except ConfigParser.NoSectionError:
		pass
	return s

def do_option(optname="", newval=None):
	"""
	Get or set a Clisk option by its name.  Valid options:
		stampInterval: Seconds between printing of timestamps in Clisk window.
			0 means always, -1 means never.
		queueMessages: Set non-zero to make messages print only when Enter is pressed.
			This keeps events from disrupting input lines.
		speakEvents: Set non-zero to make events speak through MacOS on arrival.
			This includes incoming and outgoing chat messages, call status changes,
			user status changes for users with w flags, etc.
			Warning: Behavior on non-MacOS systems for this flag is undefined and may crash Clisk.
	Type with no parameters for a list of all options and their values.
	"""
	opts = [
		("stampInterval", "Number of seconds between printing of timestamps (0 always, -1 never)"),
		("queueMessages", "Queue messages on arrival and print on Enter."),
		("speakEvents", "Speak events through MacOS on arrival")
	]
	if not optname:
		lst = []
		for opt in opts:
			optname = opt[0]
			lst.append("%s = %s" % (
				optname,
				conf.option(optname)
			))
		msg("\n".join(lst))
		return
	f = lambda o: ": ".join(o)
	opts = filter(lambda o: optname.lower() in o[0].lower(), opts)
	opt = utils.selectMatch(opts, "Select an Option:", f)[0]
	msg("%s = %s" % (
		opt,
		conf.option(opt, newval)
	))

def getStreamIdParts(id):
	"""
	Get a user ID and (if given) instance number from the given id.
	Returns stream,id,instance, where stream is id:instance.
	This is for app-to-app communication channels.
	Includes user matching.
	"""
	if ":" in id:
		id,instance = id.split(":", 1)
	else:
		instance = ""
	id = getUserID(id, False)
	stream = id
	if instance: stream += ":" +instance
	return stream,id,instance

def sendAppCommand(cmd, prefix="alter"):
	"""
	Send a command to the SkypeAPI Application object.
	"""
	return send("%s application %s %s" % (
		prefix, app.Name,
		cmd
	))

def sendDatagram(id, dgram=None):
	"""
	Send a datagram to the indicated user's Clisk if possible.
	If no datagram is given, just makes a connection.
	"""
	stream,id,instance = getStreamIdParts(id)
	if not instance:
		# Make sure we have whatever streams might be available for this user.
		sendAppCommand("connect %s" % (id))
		notified = False
		while True:
			time.sleep(1)
			result = sendAppCommand("connecting", "get")
			if id.lower() not in result.lower(): break
			if not notified:
				msg("Connecting ...")
				notified = True
	actives = sendAppCommand("streams", "get").split()
	streams = []
	for a in actives:
		if not a.startswith(id+":"): continue
		if instance and a.split(":")[1] != instance: continue
		streams.append(a)
	if not streams: raise ValueError("%s not found online" % (stream))
	if dgram is None: return
	for s in streams:
		# Skype doesn't send the text of a datagram back to the
		# sender, unlike for chats; so we print it ourselves.
		msgFromEvent("> =%s= %s" % (
			s, dgram
		))
		sendAppCommand("datagram %s %s" % (
			s, dgram
		))
	return

def do_version(*args, **kwargs):
	"""
	Identify the running Clisk, Skype, and Skype API wrapper versions,
	and the active Skype API protocol number.
	If a user name is given, try to get that info from that user's running Clisk.
	"""
	if not args:
		msg(getVersionInfo(skype))
		return
	cmd = kwargs["cmd"].strip()
	stream,id,instance = getStreamIdParts(cmd)
	sendDatagram(stream, "version")

def do_stat(*args, **kwargs):
	"""
	Try to send a stat request to the indicated user's running Clisk.
	The user's Clisk will only respond if you have permission to send this
	command.  If you don't have permission, the user will just see the
	attempt in the Clisk window.
	"""
	if not args:
		raise SyntaxError("Must specify a user to send to.")
	cmd = kwargs["cmd"].strip()
	stream,id,instance = getStreamIdParts(cmd)
	sendDatagram(stream, "stat")

def do_DGram(*args, **kwargs):
	"""
	Try to send a datagram to the indicated user's running Clisk.
	This should show up in the user's Clisk window but not in Skype's UI.
	Usage: dgram <user> [<datagram>].
	If no datagram is given, just connects to the user.
	This is a way to check for a running Clisk.
	"""
	if not args:
		raise SyntaxError("Must specify a user to send to.")
	cmd = kwargs["cmd"].strip()
	dgram = None
	if " " in cmd: cmd,dgram = cmd.split(None, 1)
	stream,id,instance = getStreamIdParts(cmd)
	sendDatagram(stream, dgram)

def do_www(subpage=""):
	"""
	Open a web page for this utility or related to it or Skype.
	This command also sends to the Clisk web site program and Skype version information
	to help the author know what environments to support.
	Available pages (type "www <name>", example "www man"):
	Clisk-related pages:
		home or Clisk or blank (just "www"): The Clisk home page.
		man: The Clisk manual.
	Skype and Skype Developer Zone pages:
		skype: The Skype home page.
		rellinux, relmac, relwin: The Skype Release Notes pages for Linux, Mac and Windows.
		dev: The Skype Developer Zone home page.
		skype4Py: The Skype4Py documentation page.
		skype4com: The Skype4Com (Windows only) documentation page.
		python: The Python home page.
		activepython: The ActivePython home page.
	"""
	sp = subpage.lower()
	if sp == "skype":
		url = "http://www.skype.com"
	elif sp == "rellinux":
		url = "https://developer.skype.com/LinuxSkype/ReleaseNotes"
	elif sp == "relmac":
		url = "https://developer.skype.com/MacSkype/ReleaseNotes"
	elif sp == "relwin":
		url = "https://developer.skype.com/WindowsSkype/ReleaseNotes"
	elif sp == "dev":
		url = "https://developer.skype.com/"
	elif sp == "skype4py":
		url = "https://developer.skype.com/wiki/Skype4Py"
	elif sp == "skype4com":
		url = "https://developer.skype.com/Docs/Skype4COMLib"
	elif sp == "python":
		url = "http://www.python.org"
	elif sp == "activepython":
		url = "http://www.activestate.com/activepython"
	elif sp in ["", "home", "man"]:
		if sp == "home": sp = ""
		if sp != "" and "." not in sp:
			sp += ".php"
		url = "http://www.dlee.org/skype/clisk/" +sp
		url += "?CliskVer=" +CLISK_VERSION
		url += "&SkypeVer=" +skypeVersion()
		url += "&APIProtocol=" +unicode(skype.Protocol)
		url += "&APIWrapperVer=" +skype.ApiWrapperVersion
		pyver = sys.version.split(None, 1)[0]
		url += "&PyVer=" +pyver
		url += "&plat=" +utils.getPlatInfo()
		url += "&SkypeUserName=" +skype.CurrentUserHandle
	else:
		return subpage +" is not a recognized web page identifier."
	if not utils.launchURL(url):
		return "Not supported on this platform."

def do_man():
	"""
	Go to the online Clisk manual (users guide).
	Same as "www man."
	"""
	return do_www("man")

def do_help(cmd=None):
	"""
	Shows help for commands.
	Include a command name to get help on a particular command.
	"""
	if cmd:
		hlp = doCommand(cmd, True)
		if hlp is not None: return hlp
		return cmd +" is not a built-in command"
	# Top-level help.
	cmdlist = filter(lambda f: f.startswith("do_"), globals())
	cmdlist = sorted(map(lambda cmd: cmd[3:], cmdlist))
	cmdlist = " ".join(cmdlist)
	fmt = textwrap.TextWrapper()
	fmt.width = 75
	fmt.initial_indent = "   "
	fmt.subsequent_indent = "   "
	cmdlist = "\n".join(fmt.wrap(cmdlist))
	s = """
Clisk, the Command-Line Interface for Skype, version %s.
Available commands (type "help" with a specific command for details about it):
%s
You only have to type enough of a command word to identify the one you want.
Command words are also case-insensitive, so addu = addUser.
Additional commands and features by example:
mc, mcc: Missed call display, mcc clears,
	numbers are how many to show/clear (default 20).
	Examples: mcc to show and clear 20, mc5 shows 5 but does not clear them.
rec/mic/snd: Recording and sound redirection commands.
mute on, get user echo123 onlinestatus,
	(or any other raw Skype API command, case insensitive).
.Users("echo123").OnlineStatus or any other Skype4Py method call.
!len(skype.ActiveCalls)
	or any other Python expression/statement (skype is the Skype4Py object).
""" % (CLISK_VERSION, cmdlist)
	return s.strip()

def ff_repl(oMatch):
	p1,p2,p3 = oMatch.groups()
	p1 = re.search("\d\d\d", p1).group()
	result = "".join(("+1",p1,p2,p3))
	#show('Fixing "' +oMatch.group() +'" to "' +result +'"')
	return result

def fixPhoneNumbers(cmd):
	"Fix US-format phone numbers for API use.""""""""""""
	Specifically, prepend "+1" and remove dashes, parens, and spaces."""
	regexp = re.compile("(\(\d\d\d\)\s*|\d\d\d-)(\d\d\d)-(\d\d\d\d)")
	cmd = regexp.sub(ff_repl, cmd)
	return cmd

def parseline(line, n=0):
	"""
	Parse n arguments off the start of line, and return (args, line),
	where args is the list of parsed arguments, and line is what's left.
	If n is 0 or unpassed, the entire line is split up.
	Otherwise, len(args) == n, padded with None entries if necessary.
	Leading and trailing spaces from line are unconditionally removed.
	"""
	line = line.strip()
	args = []
	while line and (not n or n > len(args)):
		if line[0] in ['"', "'"]:
			# Quoted argument.
			quoteChar,line = (line[0], line[1:])
			# No escaping quotes supported here.
			arg,sep,line = line.partition(quoteChar)
			if not re.match("^\s", line):
				# This handles things like "quoteWithExtraWord"After.
				try: arg1,line = line.split(None, 1)
				except ValueError: arg1,line = (line,"")
				arg += arg1
			line = line.lstrip()
		else:
			# Not a quoted argument.
			try: arg,line = line.split(None, 1)
			# Which fails if we only had one arg left.
			except ValueError: arg,line = (line,"")
		args.append(arg)
	while n > len(args):
		args.append(None)
	return (args, line)

def commandMatch(cmdWord):
	"""
	Returns the exact command word indicated by cmdWord.
	Implements command matching when an ambiguous command prefix is typed.
	"""
	# Populate the list of valid commands as necessary.
	try: commandMatch.cmds
	except AttributeError:
		commandMatch.cmds = dict()
		for cmd in filter(lambda f: f.startswith("do_"), globals()):
			commandMatch.cmds[cmd[3:].lower()] = cmd[3:]
	# An exact match wins even if there are longer possibilities.
	try: return commandMatch.cmds[cmdWord.lower()]
	except KeyError: pass
	# Get a list of matches, capitalized as they are in the code do_* function names.
	cmdWord = cmdWord.lower()
	matches = filter(lambda f: f.startswith(cmdWord), commandMatch.cmds.keys())
	matches = map(lambda cmdKey: commandMatch.cmds[cmdKey], matches)
	return utils.selectMatch(matches, "Which command did you mean?")

def doCommand(cmd, getHelp=False):
	"""
	Top-level command handler, called for each user input line:
		help or ?:  Command-line help.
		!cmd:  Python command.
		.methodCall:  Skype4Py call, e.g., .Users("echo123").OnlineStatus
		aa <id> [<access>]: Get or set AA access permissions.
		Anything else:  Raw Skype API command.
	TODO: Some "raw API commands" honored are really shortcuts absorbed from skcmd.
	"""
	cmd = translateAliases(cmd, getHelp)
	if cmd.startswith("?"): cmd = cmd.replace("?", "help ", 1)
	cmdl = cmd.lower()
	if cmd[0] == ".":
		if getHelp:
			if cmd == ".": cmd = ""  # allows help on top-level Skype object.
			try:
				eval("help(skype" +cmd +")")
				return ""
			except: return err()
		try: return eval("skype" +cmd)
		except: return err()
	elif cmd[0] == "!":
		if getHelp: return "Direct Python expression or statement"
		cmd = cmd[1:]
		try: return eval(cmd, globals())
		except SyntaxError:
			try: exec cmd in globals()
			except: return err()
			return None
		except: return err()
	# TODO: mc is not a normal command.
	if cmdl.startswith("mc"):
		if getHelp: return "List missed calls, and clear if given as mcc."
		return getMissedCalls(cmd)
	# TODO: rec, mic, and snd aren't normal commands.
	elif cmdl[:3] in ["rec", "mic", "snd"]:
		if getHelp: return "Sound redirection command."
		return do_rec(cmd[:3], cmd)
	[cmdWord],cmd = parseline(cmd, 1)
	# Special case for "message," which is a raw API command
	# that users may type when they want "msg."
	# This allows user lookup even though it's an API command.
	if not getHelp and cmdWord.lower() in ["message"]:
		[arg],cmd = parseline(cmd, 1)
		arg = getUserIDs(arg)
		if not arg: return "No Skype user ID(s) given."
		cmd = arg +" " +cmd
		# Falls through as an API command but with an actual user ID in it.
	try: cmdWord = commandMatch(cmdWord)
	except KeyError: pass
	else:
		func = eval("do_" +cmdWord)
		if getHelp: return func.__doc__.strip()
		args,tmp = parseline(cmd)
		# First try for command functions that can handle the cmd arg.
		# Flags: 4 = *args, 8 = **kwargs.
		if func.func_code.co_flags & 12 == 12:
			return func(*args, cmd=cmd)
		# Otherwise try without the cmd argument.
		return func(*args)
	if getHelp: return None
	cmd = cmdWord +" " +cmd
	wait = 1000
	if cmd.lower().startswith("search"): wait = 60000
	return send(cmd, wait)

def translateAliases(cmd, getHelp):
	"""
	Translate the first word of cmd if it's an alias, and return the result.
	If cmd does not start with an alias, it is returned unchanged.
	Aliases are allowed to refer to other aliases, up to 16 levels.
	"""
	c = ConfigParser.ConfigParser()
	c.read(conf.inipath)
	sSect = "Aliases"
	level = 16
	while level > 0:
		level -= 1
		try: cmdword,cmdrest = cmd.split(None, 1)
		except ValueError: cmdword,cmdrest = (cmd,"")
		try:
			cmdword = c.get(sSect, cmdword.lower(), raw=True)
			# That throws an error if cmdword is not aliased,
			# so now cmdword is the whole alias RHS.
			if getHelp: return "Aliased to " +cmdword
			if re.search(r'%\d', cmdword):
				# Positional parameters exist.
				f = lambda m: getArg(m, cmdrest)
				cmd = re.sub(r'%(\d+)-?', f, cmdword)
			else: cmd = " ".join([cmdword, cmdrest])
			cmdl = cmd.lower()
		except (ConfigParser.NoSectionError, ConfigParser.NoOptionError):
			break
	if level == 0:
		raise SyntaxError("Too many levels of alias expansion")
	return cmd

def getArg(m, cmd):
	"""
	Positional parameter handler:
	Returns the arg(s) indicated by m, which is a match object.
	Helper for doCommand().
	"""
	# -1 makes alias parameters like %1 1-based instead of 0-based.
	argno = int(m.groups()[0]) -1
	if m.group().endswith("-"):
		# %n- just returns "" if there aren't n+1 args.
		args,cmd = parseline(cmd, argno)
		return cmd
	# but %n requires that at least n args are present.
	# +1 because argno is 0-based but we're passing an arg count.
	args,cmd = parseline(cmd, argno+1)
	result = args[argno]
	if result is None:
		raise IndexError("Not enough parameters given")
	return result

def toplevel(stdscr=None):
	# Command loop:  Run until asked to quit.
	globals()["conf"] = Conf()
	msg("Looking for Skype...")
	globals()["skype"] = None
	connectToSkype()
	show("""Type help or ? for help, "quit" or "exit" to exit.""")

	# Pinger to keep the API connection alive in case of, say, a slowed-down machine.
	def pinger():
		"""Ping Skype once every 10 seconds to make sure the API link stays alive."""
		while True:
			if not threading.enumerate()[0].is_alive(): break
			# A hundredth of a second; basically fire-and-forget,
			# but that's all we need; Skype4Py picks up the pieces of a broken connection,
			# once the break is detected.
			try: send("ping", 10)
			except: pass
			time.sleep(10)
	try:
		pingerThread = threading.Timer(10, pinger)
		pingerThread.setDaemon(True)
		pingerThread.start()
	except:
		msg("Warning: Ping thread can't start (%s), API connection loss may not be detected immediately."
		% (err()))
	
	# Command loop with history editing support.
	exiting = False
	# See do_prefix(): The user can set/clear this.
	toplevel.prefix = ""
	while not exiting:
		# This keeps the first prompt from appearing until attachment first succeeds.
		if not reportAttachment.attachedOnce:
			while not reportAttachment.attachedOnce: time.sleep(0.5)
			time.sleep(0.2)
			do_cache()
		prompt = ""
		prompt = getPrompt()
		msgCount = utils.pendingMessageCount()
		if msgCount:
			utils.flushMessages(1)
			msgCount = utils.pendingMessageCount()
		if msgCount:
			prompt += " (%d)" % (msgCount)
		if toplevel.prefix: prompt += " " +toplevel.prefix
		prompt += "> "
		try:
			_cmdline = raw_input(prompt)
		except EOFError:
			conf.log("> (EOF)")
			exiting = True
		except KeyboardInterrupt:
			show('Type "exit" to exit.')
		else:
			_cmdline = _cmdline.strip()
			if _cmdline:
				conf.log("> " +_cmdline)
				if toplevel.prefix and not _cmdline.startswith("/"):
					_cmdline = toplevel.prefix +" " +_cmdline
				if _cmdline.startswith("/"): _cmdline = _cmdline[1:]
				if _cmdline.lower() in ["q", "quit", "exit"]:
					exiting = True
				elif _cmdline.lower() == "reset":
					connectToSkype()
				else:
					try: msgNoTime(doCommand(_cmdline))
					except: msgNoTime(err())
	msg("Exiting.")
	try: app.Delete()
	except: pass
	sys.exit()

def _test():
	import doctest
	doctest.testmod()

# This loads supplemental per-user Clisk code if it exists.
# This is done after all the def's so that such code can override things.
# The path is searched in reverse so earlier findings override later ones.
from glob import glob
paths = [p for p in reversed(sys.path)]
p1 = os.path.dirname(sys.argv[0])
if p1 and p1 not in paths:
	paths.append(p1)
for p in paths:
	files = glob(os.path.join(p, "clisk_*.py"))
	for f in files:
		fp = os.path.join(p, f)
		show("Importing supplemental code from " +fp)
		exec open(fp).read()
	
if __name__ == "__main__":
	_test()
	if len(sys.argv) > 1:
		# Abbreviated process:  Just run one command and exit.
		conf = Conf()
		skype = Skype4Py.Skype()
		skype.FriendlyName = "Clisk, the Command-Line Interface for Skype"
		skype.Attach(99, 0)
		if skype.AttachmentStatus == -1:
			print "Skype attachment failed."
			sys.exit()
		send("protocol 99")
		conf.setUser(skype.CurrentUserHandle)
		_cmdline = " ".join(sys.argv[1:])
		show(doCommand(_cmdline))
		try: app.Delete()
		except: pass
		sys.exit()

	toplevel(None)
	try: app.Delete()
	except: pass
	sys.exit()

"""
Copyright (c) 2009-2012, Doug Lee
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* The names of the copyright holders and contributors may not be used to
  endorse or promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""
