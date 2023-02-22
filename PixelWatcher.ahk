#Requires AutoHotkey v2.0
#SingleInstance Force    ; run script only once


; ------ CONFIG AND VARS ------
A_ScriptName := "PixelWatcher"
LogFile := A_ScriptDir . "/" . A_ScriptName . ".log"
DebugEnabled := true
ClientTitle := "Target Application Window Title"

TimerDelay := 5000    ; ms delay
TimerOff := 0    ; 0ms delay = disable timer

TrayWarnIcon := 2
TrayErrorIcon := 3
TrayTipNoSound := 16    ; option value to disable notification sound

; set coordinate system to screen, with x=0,y=0 being the top left corner
CoordMode("Pixel", "Screen")    ; set coordinate context (absolute)
; use AHK Window Spy to get desired coordinates
OffsetX := 1    ; leftmost pixel of application
OffsetY := 1    ; topmost pixel of application

ColorTarget := 0xff0000    ; target color in hex 0xRRGGBB
ColorPrevious := 0x000000
;---------------------------


; example for logging to a file
LogMsg(msg)
{
    if ( not (DebugEnabled))
    {
        return
    }

    try FileAppend(Format('[{1}:{2}]: {3}`n', FormatTime(A_NowUTC, "hh:mm:ss"), A_MSec, msg), LogFile)
}

IsEnabled := false    ; current watcher status
^+a::    ; Ctrl+Shift+A to toggle timer
{
    ; global vars have to be declared as such to allow RW in local scope
    global IsEnabled

    ; skip if target application is not running
    if ( not (WinExist(ClientTitle)))
    {
        IsEnabled := false
        local msg := "'" . ClientTitle . "' not running"
        LogMsg(msg)
        TrayTip(msg, A_ScriptName, TrayWarnIcon)
        SetTimer(WatchThatPixel, TimerOff)
        return
    }

    IsEnabled := not (IsEnabled)    ; toggle state
    if (IsEnabled) {
        local msg := "Starting watcher thread."
        TrayTip(msg, A_ScriptName, TrayTipNoSound)
        try FileDelete(LogFile)
        LogMsg(msg . " Delay: " . TimerDelay . "ms")

        ; start timer thread with fixed delay between function calls
        SetTimer(WatchThatPixel, TimerDelay)
    } else {
        local msg := "Stopping watcher thread."
        TrayTip(msg, A_ScriptName, TrayTipNoSound)
        SetTimer(WatchThatPixel, TimerOff)    ; exit timer thread
        LogMsg(msg)
    }

    return
}

WatchThatPixel()
{
    if ( not (WinExist(ClientTitle)))
    {
        local msg := "'" . ClientTitle . "' has been closed"
        LogMsg(msg)
        TrayTip(msg, A_ScriptName, TrayErrorIcon)
        SetTimer(WatchThatPixel, TimerOff)
        return
    }

    ; get absolute position of target application (xy: top left corner)
    WinGetClientPos(&x, &y, &w, &h, ClientTitle)

    global ColorPrevious

    ; get color of pixel relative to the target application window
    local color := PixelGetcolor(x + OffsetX, y + OffsetY)
    if (ColorPrevious = color)
    {
        ; no change in color, skip
        return
    }

    ; otherwise react to color change, for instance to detect movement
    ColorPrevious := color
    LogMsg(Format("x={1},y={2},w={3},h={4},color={5}", x, y, w, h, color))

    ; check for one or more specific colors
    if (color = ColorTarget) {
        LogMsg("Color match!")
        ; react to specific color
    }

    return
}