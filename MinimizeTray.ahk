#Requires AutoHotkey v2.0
#SingleInstance Force

hiddenWindows := []

; Minimize VS Code
^!m::
{
    activeID := WinGetID("A")
    activeProcess := WinGetProcessName("A")
    activeTitle := WinGetTitle("A")
    
    if InStr(activeTitle, "Visual Studio Code - Insiders") 
    || activeProcess = "Code - Insiders.exe"
    {
        WinHide("ahk_id " activeID)
        A_TrayMenu.Add("Restore VSCode", RestoreVSCode)
        TrayTip("VSCode Minimized", "Minimized to system tray", 1)
    } else {
        WinMinimize("A")
    }
}

; Hide any window
^Space::
{
    hwnd := WinGetID("A")
    Title := WinGetTitle("A")
    exeName := WinGetProcessName("A")
    
    cleanTitle := Trim(RegExReplace(Title, " - [^-]*$", ""))
    if (cleanTitle = "")
        cleanTitle := exeName
        
    windowInfo := Map("hwnd", hwnd, "title", Title, "exe", exeName, "cleanTitle", cleanTitle)
    hiddenWindows.Push(windowInfo)
    
    UpdateTrayMenu()
    
    WinHide("ahk_id " hwnd)
    TrayTip("Window Hidden", cleanTitle " is now hidden`nRight-click tray icon to restore", 1)
}

; Update tray menu
UpdateTrayMenu()
{
    global hiddenWindows
    try A_TrayMenu.Delete("Restore Windows")
    
    RestoreMenu := Menu()
    
    ; Add all hidden windows to restore menu
    for index, window in hiddenWindows
    {
        displayText := window["cleanTitle"]
        if (StrLen(displayText) > 30)
            displayText := SubStr(displayText, 1, 27) "..."
        
        RestoreMenu.Add(displayText, (*) => RestoreWindow(index))
    }
    
    A_TrayMenu.Delete()
    if (hiddenWindows.Length > 0) {
        A_TrayMenu.Add("Restore Windows", RestoreMenu)
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("Exit", ExitScript)
}

; Restore Any Window
RestoreWindow(index)
{
    global hiddenWindows
    if (index <= hiddenWindows.Length)
    {
        window := hiddenWindows[index]
        DetectHiddenWindows(true)
        if WinExist("ahk_id " window["hwnd"])
        {
            WinShow("ahk_id " window["hwnd"])
            WinActivate("ahk_id " window["hwnd"])
            TrayTip("Window Restored", window["cleanTitle"] " has been restored", 1)
        }
        else
        {
            TrayTip("Window Not Found", "The window could not be restored", 1)
        }
        hiddenWindows.RemoveAt(index)
        UpdateTrayMenu()
    }
}

; Restore VS Code
RestoreVSCode(*)
{
    DetectHiddenWindows(true)
    ; Try to find and restore any hidden VSCode windows
    try {
        if WinExist("ahk_exe Code - Insiders.exe")
        {
            WinShow("ahk_exe Code - Insiders.exe")
            WinActivate("ahk_exe Code - Insiders.exe")
            TrayTip("VSCode Restored", "Restored from system tray", 1)
        }
        else
        {
            TrayTip("VSCode Not Found", "No VSCode windows to restore", 1)
        }
    }
    try A_TrayMenu.Delete("Restore VSCode")
}

; Exit Script - Restore all windows
ExitScript(*)
{
    global hiddenWindows
    
    DetectHiddenWindows(true)
    
    ; Restore all custom hidden windows
    for window in hiddenWindows
    {
        if WinExist("ahk_id " window["hwnd"])
        {
            WinShow("ahk_id " window["hwnd"])
        }
    }
    
    ; Restore VSCode windows if they exist
    try {
        if WinExist("ahk_exe Code - Insiders.exe")
        {
            WinShow("ahk_exe Code - Insiders.exe")
        }
    }
    
    ExitApp()
}

; Auto Restore on Exit
Persistent(true)
OnExit(ExitFunc)

ExitFunc(ExitReason, ExitCode)
{
    DetectHiddenWindows(true)
    ; Only restore VSCode if windows exist
    try {
        if WinExist("ahk_exe Code - Insiders.exe")
        {
            WinShow("ahk_exe Code - Insiders.exe")
        }
    }
}