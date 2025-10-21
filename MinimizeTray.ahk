#Requires AutoHotkey v2.0
#SingleInstance Force

hiddenWindows := []

; Minimize VS Code
^!m::
{
    activeID := WinGetID("A")
    activeProcess := WinGetProcessName("A")
    activeTitle := WinGetTitle("A")
    
    if activeProcess = "CodeLight.exe"
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

; Update Tray menu
UpdateTrayMenu()
{
    global hiddenWindows
    try A_TrayMenu.Delete("Restore Windows")
    RestoreMenu := Menu()

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
    try {
        if WinExist("ahk_exe CodeLight.exe")
        {
            WinShow("ahk_exe CodeLight.exe")
            WinActivate("ahk_exe CodeLight.exe")
            TrayTip("VSCode Restored", "Restored from system tray", 1)
        }
        else
        {
            TrayTip("VSCode Not Found", "No VSCode windows to restore", 1)
        }
    }
    try A_TrayMenu.Delete("Restore VSCode")
}

; Exit Script (Restore)
ExitScript(*)
{
    global hiddenWindows
    DetectHiddenWindows(true)
   
    for window in hiddenWindows
    {
        if WinExist("ahk_id " window["hwnd"])
        {
            WinShow("ahk_id " window["hwnd"])
        }
    }
    
    try {
        if WinExist("ahk_exe CodeLight.exe")
        {
            WinShow("ahk_exe CodeLight.exe")
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
    try {
        if WinExist("ahk_exe CodeLight.exe")
        {
            WinShow("ahk_exe CodeLight.exe")
        }
    }
}