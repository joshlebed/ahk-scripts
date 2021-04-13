#SingleInstance, force

SwitchToDesktop(n:=1) {
    doFocusAfterNextSwitch=1
    _ChangeDesktop(n)
}

MoveToDesktop(n:=1) {
    _MoveCurrentWindowToDesktop(n)
    _Focus()
}

MoveAndSwitchToDesktop(n:=1) {
    doFocusAfterNextSwitch=1
    _MoveCurrentWindowToDesktop(n)
    _ChangeDesktop(n)
}

OpenDesktopManager() {
    Send #{Tab}
}

; Let the user change desktop names with a prompt, without having to edit the 'settings.ini'
; file and reload the program.
; The changes are temprorary (names will be overwritten by the default values of
; 'settings.ini' when the program will be restarted.
ChangeDesktopName() {
    currentDesktopNumber := _GetCurrentDesktopNumber()
    currentDesktopName := _GetDesktopName(currentDesktopNumber)
    InputBox, newDesktopName, % changeDesktopNamesPopupTitle, % Format(changeDesktopNamesPopupText, _GetCurrentDesktopNumber()), , , , , , , , %currentDesktopName%
    ; If the user choose "Cancel" ErrorLevel is set to 1.
    if (ErrorLevel == 0) {
        _SetDesktopName(currentDesktopNumber, newDesktopName)
    }
    _ChangeAppearance(currentDesktopNumber)
}

Reload() {
    Reload
}

Exit() {
    ExitApp
}

_IsPrevNextDesktopSwitchingKeyboardShortcutConflicting(hkModifiersSwitch, hkIdentifierNextOrPrevious) {
    return ((hkModifiersSwitch == "<#<^" || hkModifiersSwitch == ">#<^" || hkModifiersSwitch == "#<^" || hkModifiersSwitch == "<#>^" || hkModifiersSwitch == ">#>^" || hkModifiersSwitch == "#>^" || hkModifiersSwitch == "<#^" || hkModifiersSwitch == ">#^" || hkModifiersSwitch == "#^") && (hkIdentifierNextOrPrevious == "Left" || hkIdentifierNextOrPrevious == "Right"))
}

_IsCursorHoveringTaskbar() {
    MouseGetPos,,, mouseHoveringID
    if (!taskbarPrimaryID) {
        WinGet, taskbarPrimaryID, ID, ahk_class Shell_TrayWnd
    }
    if (!taskbarSecondaryID) {
        WinGet, taskbarSecondaryID, ID, ahk_class Shell_SecondaryTrayWnd
    }
    return (mouseHoveringID == taskbarPrimaryID || mouseHoveringID == taskbarSecondaryID)
}

_GetCurrentWindowID() {
    WinGet, activeHwnd, ID, A
    return activeHwnd
}

_GetCurrentWindowTitle() {
    WinGetTitle, activeHwnd, A
    return activeHwnd
}

_TruncateString(string:="", n:=10) {
    return (StrLen(string) > n ? SubStr(string, 1, n-3) . "..." : string)
}

_GetDesktopName(n:=1) {
    if (n == 0) {
        n := 10
    }
    name := DesktopNames%n%
    if (!name) {
        name := "Desktop " . n
    }
    return name
}

; Set the name of the nth desktop to the value of a given string.
_SetDesktopName(n:=1, name:=0) {
    if (n == 0) {
        n := 10
    }
    if (!name) {
        ; Default value: "Desktop N".
        name := "Desktop " %n%
    }
    DesktopNames%n% := name
}

_GetNextDesktopNumber() {
    i := _GetCurrentDesktopNumber()
	if (GeneralDesktopWrapping == 1) {
		i := (i == _GetNumberOfDesktops() ? 1 : i + 1)
	} else {
		i := (i == _GetNumberOfDesktops() ? i : i + 1)
	}

    return i
}

_GetPreviousDesktopNumber() {
    i := _GetCurrentDesktopNumber()
	if (GeneralDesktopWrapping == 1) {
		i := (i == 1 ? _GetNumberOfDesktops() : i - 1)
	} else {
		i := (i == 1 ? i : i - 1)
	}

    return i
}

_GetCurrentDesktopNumber() {
    return DllCall(GetCurrentDesktopNumberProc) + 1
}

_GetNumberOfDesktops() {
    return DllCall(GetDesktopCountProc)
}

_MoveCurrentWindowToDesktop(n:=1) {
    activeHwnd := _GetCurrentWindowID()
    DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, n-1)
}

_ChangeDesktop(n:=1) {
    if (n == 0) {
        n := 10
    }
    DllCall(GoToDesktopNumberProc, Int, n-1)
}

_CallWindowProc(proc, window:="") {
    if (window == "") {
        window := _GetCurrentWindowID()
    }
    return DllCall(proc, UInt, window)
}

_PinWindow(windowID:="") {
    _CallWindowProc(PinWindowProc, windowID)
}

_UnpinWindow(windowID:="") {
    _CallWindowProc(UnpinWindowProc, windowID)
}

_GetIsWindowPinned(windowID:="") {
    return _CallWindowProc(IsPinnedWindowProc, windowID)
}

_PinApp(windowID:="") {
    _CallWindowProc(PinAppProc, windowID)
}

_UnpinApp(windowID:="") {
    _CallWindowProc(UnpinAppProc, windowID)
}

_GetIsAppPinned(windowID:="") {
    return _CallWindowProc(IsPinnedAppProc, windowID)
}

_RunProgram(program:="", settingName:="") {
    if (program <> "") {
        if (FileExist(program)) {
            Run, % program
        }
        else {
            MsgBox, 16, Error, The program "%program%" is not valid. `nPlease reconfigure the "%settingName%" setting. `n`nPlease read the README for instructions.
        }
    }
}

_RunProgramWhenSwitchingToDesktop(n:=1) {
    if (n == 0) {
        n := 10
    }
    _RunProgram(RunProgramWhenSwitchingToDesktop%n%, "[RunProgramWhenSwitchingToDesktop] " . n)
}

_RunProgramWhenSwitchingFromDesktop(n:=1) {
    if (n == 0) {
        n := 10
    }
    _RunProgram(RunProgramWhenSwitchingFromDesktop%n%, "[RunProgramWhenSwitchingFromDesktop] " . n)
}

_ChangeBackground(n:=1) {
    line := Wallpapers%n%
    isHex := RegExMatch(line, "^0x([0-9A-Fa-f]{1,6})", hexMatchTotal)
    if (isHex) {
        hexColorReversed := SubStr("00000" . hexMatchTotal1, -5)

        RegExMatch(hexColorReversed, "^([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})", match)
        hexColor := "0x" . match3 . match2 . match1, hexColor += 0

        DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "", UInt, 1)
        DllCall("SetSysColors", "Int", 1, "Int*", 1, "UInt*", hexColor)
    }
    else {
        filePath := line

        isRelative := (substr(filePath, 1, 1) == ".")
        if (isRelative) {
            filePath := (A_WorkingDir . substr(filePath, 2))
        }
        if (filePath and FileExist(filePath)) {
            DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, filePath, UInt, 1)
        }
    }
}

_ChangeAppearance(n:=1) {
    Menu, Tray, Tip, % _GetDesktopName(n)
    if (FileExist("./icons/" . n ".ico")) {
        Menu, Tray, Icon, icons/%n%.ico
    }
    else {
        Menu, Tray, Icon, icons/+.ico
    }
}

; Only give focus to the foremost window if it has been requested.
_FocusIfRequested() {
    if (doFocusAfterNextSwitch) {
        _Focus()
        doFocusAfterNextSwitch=0
    }
}

; Give focus to the foremost window on the desktop.
_Focus() {
    foremostWindowId := _GetForemostWindowIdOnDesktop(_GetCurrentDesktopNumber())
    WinActivate, ahk_id %foremostWindowId%
}

; Select the ahk_id of the foremost window in a given virtual desktop.
_GetForemostWindowIdOnDesktop(n) {
    if (n == 0) {
        n := 10
    }
    ; Desktop count starts at 1 for this script, but at 0 for Windows.
    n -= 1

    ; winIDList contains a list of windows IDs ordered from the top to the bottom for each desktop.
    WinGet winIDList, list
    Loop % winIDList {
        windowID := % winIDList%A_Index%
        windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, WindowID, UInt, n)
        ; Select the first (and foremost) window which is in the specified desktop.
        if (WindowIsOnDesktop == 1) {
            return WindowID
        }
    }
}

_ShowTooltip(message:="") {
    params := {}
    params.message := message
    params.lifespan := TooltipsLifespan
    params.position := TooltipsCentered
    params.fontSize := TooltipsFontSize
    params.fontWeight := TooltipsFontInBold
    params.fontColor := TooltipsFontColor
    params.backgroundColor := TooltipsBackgroundColor
    Toast(params)
}

_ShowTooltipForDesktopSwitch(n:=1) {
    if (n == 0) {
        n := 10
    }
    _ShowTooltip(_GetDesktopName(n))
}

_ShowTooltipForPinnedWindow(windowTitle) {
    _ShowTooltip("Window """ . _TruncateString(windowTitle, 30) . """ pinned.")
}

_ShowTooltipForUnpinnedWindow(windowTitle) {
    _ShowTooltip("Window """ . _TruncateString(windowTitle, 30) . """ unpinned.")
}

_ShowTooltipForPinnedApp(windowTitle) {
    _ShowTooltip("App """ . _TruncateString(windowTitle, 30) . """ pinned.")
}

_ShowTooltipForUnpinnedApp(windowTitle) {
    _ShowTooltip("App """ . _TruncateString(windowTitle, 30) . """ unpinned.")
}
