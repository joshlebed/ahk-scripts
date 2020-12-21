#SingleInstance Force
#UseHook

;--------------- script code ---------------

F14DoubleTapTime := A_TickCount

;--------------- hotkeys ---------------

; alt shortcuts to move windows around with ijkl
; !i::Send {alt up}{lwin down}{up}{lwin up}{alt down}
; !j::Send {alt up}{lwin down}{left}{lwin up}{alt down}
; !k::Send {alt up}{lwin down}{down}{lwin up}{alt down}
; !l::Send {alt up}{lwin down}{right}{lwin up}{alt down}

; new chrome window
; TODO: see what desktop we're on, figure out what size this window should be
; also make sure it's in focus
!Space::run % "chrome.exe"

; Google it
^g::

return

; alt enter for terminal
!Enter::Run wt

; Reload script
^'::
WinGet, name, ProcessName, A
ToolTip, %name%
if name = Code.exe
  Send ^s
Reload
Return

;-------------------------------
; ALTTAB AND VIRTUAL DESKTOPS
;-------------------------------

; left alt + scroll wheel for alt tab
<!WheelDown::AltTab
<!WheelUp::ShiftAltTab

; left shift + scroll wheel for alt tab
<+WheelDown::AltTab
<+WheelUp::ShiftAltTab

; F14 + scroll wheel for alt tab
F14 & WheelDown::AltTab
F14 & WheelUp::ShiftAltTab

F14 & LButton::send ^#{left}
F14 & RButton::send ^#{right}

F14::LWin

RemoveToolTip:
ToolTip
Return

EditMode:
; Send {lshift down}
Tooltip EDIT MODE
Return

; F13::Lwin

F13::
NewTime := A_TickCount
if (NewTime - F14DoubleTapTime < 300) {
  Send {lshift down}
  Tooltip EDIT MODE
} else {
  F14DoubleTapTime := NewTime
  ; Send {Lwin}
} return

<+F13::
Send {LShift up}
Tooltip QUIT EDIT MODE
SetTimer, RemoveToolTip, -1000
Return

; <!Tab::AltTab
; <!q::ShiftAltTab

<!j::send ^#{left}
<!l::send ^#{right}

;-------------------------------
; CAPSLOCK LAYER
;-------------------------------

; layer 2 arrow keys
capslock & left::home
capslock & right::end
capslock & up::pgup
capslock & down::pgdn

; layer 2 keyboard navigation - 
; should i just use vim at this point?
capslock & i::up
capslock & j::left
capslock & k::down
capslock & l::right
capslock & h::home
capslock & `;::end
capslock & '::end
capslock & 8::pgup
capslock & ,::pgdn