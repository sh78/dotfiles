tell application "Mail"
	
	set theSelection to selection
	set theMessage to first item of theSelection
	set theUrl to "message://%3c" & message id of theMessage & "%3e"
	set the clipboard to theUrl
	
end tell