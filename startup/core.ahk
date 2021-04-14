; core ahk script
  #SingleInstance Force
  #Include, %A_ScriptDir%\virtual-desktop-enhancer\virtual-desktop-enhancer.ahk
  #Include, %A_ScriptDir%\box\box.ahk
  #InstallKeybdHook
  #InstallMouseHook
  #UseHook, On
  ; #WinActivateForce
  SetBatchLines, -1
  SetWinDelay, 0

  ; TODO: remove dependency on virtual-desktop-enhancer, replace with stripped down version
  ; TODO: better directional switching and moving of windows

    OutputDebug script running
    Return

  ; functions
    SendWindowLeft() {
      sendinput {lwin down}{left}{lwin up}
      return
    }
  
    SendWindowRight() {
      sendinput {lwin down}{right}{lwin up}
      return
    }
          
    AltTab_window_list() {
      Global
      Static WS_EX_TOOLWINDOW = 0x80, WS_EX_APPWINDOW = 0x40000, GW_OWNER = 4
      DetectHiddenWindows, Off
      AltTab_ID_List_0 =   ; the number of windows found
      AltTab_ID_List_1 =   ; hwnd from last active windows
      AltTab_ID_List_2 =   ; hwnd from previous active windows
      WinGet, wid_List, List,,, Program Manager ; gather a list of running programs
      Loop, %wid_List% {
        ownerID := wid := wid_List%A_Index%
        Loop {
          ownerID := Decimal_to_Hex( DllCall("GetWindow", "UInt", ownerID, "UInt", GW_OWNER))
        } Until !Decimal_to_Hex( DllCall("GetWindow", "UInt", ownerID, "UInt", GW_OWNER))
        ownerID := ownerID ? ownerID : wid
        If (Decimal_to_Hex(DllCall("GetLastActivePopup", "UInt", ownerID)) = wid) {
          WinGet, es, ExStyle, ahk_id %wid%
          If !((es & WS_EX_TOOLWINDOW) && !(es & WS_EX_APPWINDOW)) {
            AltTab_ID_List_0 ++
            AltTab_ID_List_%AltTab_ID_List_0% := wid
          }
        }
      }
    }

    Decimal_to_Hex(var) {
      SetFormat, integer, hex
      var += 0
      SetFormat, integer, d
      return var
    }

    GetCenterpoint(ahkid, byref x, byref y) {
      WinGetPos,x_i,y_i,w,h,ahk_id %ahkid%
      x := Floor(x_i + w / 2)
      y := Floor(y_i + h / 2)
    }

    HighlightActiveWindow() {
      WinGet, active_id, ID, A
      GetCenterpoint(active_id, x_a, y_a)
      CoordMode, Mouse, Screen
      MouseMove, x_a, y_a, 0
      sendinput {lctrl}
      return
    }

    DirectionalFocus(direction) {
      global
      AltTab_window_list()    
      if (direction == "right") {
        multiplier := 1
      } else if (direction == "left") {
        multiplier := -1
      } else {
        return
      }
      WinGet, active_id, ID, A
      GetCenterpoint(active_id, x_a, y_a)
      min_distance := 99999
      switch_index := -1
      Loop, %AltTab_ID_List_0%
      {
        ahkid := AltTab_ID_List_%A_Index%
        GetCenterpoint(ahkid, x, y)
        distance := (x - x_a) * multiplier
        if (distance > 0 && distance < min_distance) {
          min_distance := distance
          switch_index := A_Index
        }
      }
      if (switch_index != -1) {
        ahkid := AltTab_ID_List_%switch_index%
        WinActivate, ahk_id %ahkid%
      }
      HighlightActiveWindow()
      DetectHiddenWindows, On
      return
    }


  ; tap ctrl for start menu
    ~lctrl::
      if (ctrl_down_time <= 0) {
        ctrl_down_time := A_TickCount
      }
      return

    lctrl up::
      if (A_PriorKey = "LControl" && A_TickCount - ctrl_down_time < 300) {
        SendInput ^{esc}
      }
      ctrl_down_time := 0
      return

    ; space::MButton

  ; capslock layer
    *capslock::
      if (!capslock_down) {
        capslock_down := true
        time_capslock_down := A_TickCount
      }
      return

    capslock up::
      capslock_down := false
      if (A_PriorHotkey = "*capslock" && A_TickCount - time_capslock_down < 300) {
        SendInput, {esc}
      }
      return


    #If (capslock_down)
      i::up
      k::down
      j::left
      l::right
      h::^left
      `;::^right
      
      u::
        if WinActive("ahk_exe Messenger.exe") {
          CoordMode, Mouse, Window
          click 20,20
          Sleep 50
          sendinput wp
        } else {
          sendinput ^+{tab}
        }
        return
      o::
        if WinActive("ahk_exe Messenger.exe") {
          CoordMode, Mouse, Window
          click 20,20
          Sleep 50
          sendinput wn
        } else {
          sendinput ^{tab}
        }
        return

      d::
        sendinput ^#{left}
        Sleep, 30
        HighlightActiveWindow()
        return

      f::
        sendinput ^#{right}
        Sleep, 30
        HighlightActiveWindow()
        return
  
      ; old cycle behavior: switch to least recent window
        s::
        sendinput !+{tab}
        sleep 100
        HighlightActiveWindow()      
        return
      
      ; cycle through open windows workflow: send window to back
        ins::
          WinGet, active_id, ID, A
          GetCenterpoint(active_id, x_a, y_a)
          CoordMode, Mouse, Screen
          sendinput !{esc}
          if (x_a > 0 && y_a > 0) {
            OutputDebug click!
            ; Click, x_a, y_a
          } else {
            OutputDebug bad mouse location
          }
          sleep 50
          HighlightActiveWindow()      
          return

      e::DirectionalFocus("left")
      r::DirectionalFocus("right")

      ; TODO: make a switcher that works like the app switcher on your phone
      ; as long as the last shortcut was this one, keep going deeper in the list
      ; this will require knowing the full list of recent apps

      ; old window switcher
      ; e::!+tab
      ; r::!tab

      space::
        WinGet, minmaxstate, MinMax, A
        if (minmaxstate == 1) {
          WinGetPos, x, y, w, h, A
          WinRestore, A
          x := x + 100
          y := y + 100
          w := w - 200
          h := h - 200
          WinMove, A, , x, y, w, h
        } else {
          WinMaximize, A
        }
        return

      \::+f10
      w::sendinput {ctrl up}{alt down}{f4}{alt up}
      
      [::+f4
      ]::f4

      ^i::sendinput {pgup}
      ^k::sendinput {pgdn}
      ^j::sendinput {home}
      ^l::sendinput {end}
      ^h::sendinput {home}
      ^`;::sendinput {end}

      ^u::^+f13
      ^o::^+f14

      ^d::OnMoveAndShiftLeftPress()
      ^f::OnMoveAndShiftRightPress()

      ; ^e::sendEvent {rwin down}{left}{rwin up}
      ; ^r::sendEvent {rwin down}{right}{rwin up}

      ^e::sendEvent #{left}
      ^r::sendEvent #{right}

      ; TODO: better window management/snapping
      ; ^e::sendinput #{left}
      ; ^r::sendinput #{right}
      
      ; minimize window
        ; m::WinMinimize, A
      
      ; m::b
      ; .::a
      m::SendInput {ctrlup}{AltDown}{left}{AltUp}
      .::SendInput {ctrlup}{AltDown}{right}{AltUp}


    #If

  ; globals
    ; forward/back navigation
      ; ^[::SendInput {ctrlup}{AltDown}{left}{AltUp}
      ; ^]::SendInput {ctrlup}{AltDown}{right}{AltUp}

    ; iterm style behavior
      ; TODO: switch back and forth between last vscode window and wt
      ^`;::
        id := WinActive("ahk_exe WindowsTerminal.exe")
        if (id) {
          WinHide ahk_id %id%
          WinActivate ahk_id %prev_window_id%
          ; WinMinimize ahk_id %id%
        } else {
          WinGet, prev_window_id, ID, A
          DetectHiddenWindows, On
          id := WinExist("ahk_exe WindowsTerminal.exe")
          if (id) {
            WinShow ahk_id %id%
            WinActivate ahk_id %id%
          } else {
            run wt
            WinWait Windows Terminal
            WinActivate
          }
        }
        return

    ; play with taskbar
      ^f11::WinHide ahk_class Shell_TrayWnd
      ^f12::WinShow ahk_class Shell_TrayWnd

    ; launch chrome
      ^Space::
      run % "chrome.exe"
      SetTitleMatchMode, 2
      WinWait New Tab - Google Chrome
      WinActivate
      WinGet, minmaxstate, MinMax, A
      if (minmaxstate == 1) {
        WinRestore, A
      }
      WinMove, A, , 92, 92, 1736, 896
      return

    ; open explorer
      ^e::run % "explorer c:\users\josh"

    ; google it
      ^g::
        sendinput {ctrl down}c{ctrl up}
        SetTitleMatchMode, 2
        ; don't look on other desktops
        ; todo: open new window if no chrome window on this desktop
        ; todo: make a function for opening chrome and putting it in a reasonable place
        DetectHiddenWindows, Off
        sleep, 50
        WinActivate, - Google Chrome
        DetectHiddenWindows, On
        sendinput {ctrl down}tv{ctrl up}{enter}
        return

    ; alt-tab shortcuts
      lctrl & tab::alttab
      lctrl & `::shiftalttab

    ; quit app
      ^q::sendinput {ctrl up}{alt down}{f4}{alt up}

    ; reload
      !'::Reload

    ; ctrl + backspace for delete
      ^backspace::sendinput {delete}

    ; steal alt+space from windows
      !space::^+f13

    ; pause for muting zoom
      pause::ControlSend,,{alt down}a{alt up},Zoom Meeting

    ; open chrome bookmarks
      #If WinActive("ahk_exe chrome.exe")
        ^+o::
          sendinput ^+o
          sleep 1000
          sendinput {tab}{tab}{tab}{tab}{down}{up}
          ; TODO: do some script injection on chrome://bookmarks/ to make it be how you want it to be

      #If


