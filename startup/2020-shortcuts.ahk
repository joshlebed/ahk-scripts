#SingleInstance force

; layer 2 keyboard navigation - 
; should i just use vim at this point?
capslock & i::up
capslock & j::left
capslock & k::down
capslock & l::right
capslock & h::^left
capslock & `;::^right
capslock & 8::pgup
capslock & ,::pgdn

capslock & d::^#left
capslock & f::^#right
capslock & e::!+tab
capslock & r::!tab

^[::SendInput {ctrlup}{AltDown}{left}{AltUp}
^]::SendInput {ctrlup}{AltDown}{right}{AltUp}

capslock & u::^+tab
capslock & o::^tab
capslock::esc
^capslock::return

capslock & space::WinMaximize, A

; *!f::g

!'::Reload

; iterm style behavior
^'::
id := WinActive("Windows Terminal")
if (id) {
  WinMinimize ahk_id %id%
} else {
  id := WinExist("Windows Terminal")
  if (id) {
    WinActivate ahk_id %id%
  } else {
    run wt
    WinWait Windows Terminal
    WinActivate
  }
}
return

^Space::run % "chrome.exe"

lctrl & tab::alttab
lctrl & `::shiftalttab

^q::send {ctrl up}{alt down}{f4}{alt up}
