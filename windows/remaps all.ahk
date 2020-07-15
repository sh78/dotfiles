; Put in Windows startup directory
; C:\Users\NAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

; Caps lock is escape when tapped, ctrl when held
*CapsLock::
    Send {Blind}{Ctrl Down}
    cDown := A_TickCount
Return

*CapsLock up::
    ; Modify the threshold time (in milliseconds) as necessary
    If ((A_TickCount-cDown) < 150)
        Send {Blind}{Ctrl Up}{Esc}
    Else
        Send {Blind}{Ctrl Up}
Return

; Enter is ctrl when held down, Enter when tapped
*Enter::
    Send {Blind}{Ctrl Down}
    cDown := A_TickCount
Return

*Enter up::
    If ((A_TickCount-cDown) < 150)
        Send {Blind}{Ctrl Up}{Enter}
    Else
        Send {Blind}{Ctrl Up}
Return

; Press both shift kes simultaneously for caps lock
<+RShift::
>+LShift::
	Suspend,Permit
	SetCapsLockState,% GetKeyState("CapsLock","T") ? "Off" : "On"
Return

; Seems to be unecessary and break ctrl hold
;Capslock::
	;Suspend,Off
	;If (A_PriorKey="Capslock" && A_TimeSincePriorHotkey<500)
		;return
	;KeyWait,CapsLock
	;Suspend,On
;Return
