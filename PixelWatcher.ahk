#Requires AutoHotkey v2.0
#SingleInstance Force    ; run script only once


; ------ CONFIG AND VARS ------
ScriptName := "PixelWatcher"

TimerDelay := 5000    ; ms delay
TimerOff := 0    ; 0ms delay = disable timer
TrayTipNoSound := 16    ; option value to disable notification sound

; set coordinate system to screen, with x=0,y=0 being the top left corner
CoordMode "Pixel", "Client"
; use AHK Window Spy to get desired coordinates
X := 1    ; leftmost pixel
Y := 1    ; topmost pixel

ColorTarget := 0xff0000    ; target color in hex 0xRRGGBB
ColorCurrent := 0x000000
;---------------------------

IsEnabled := false    ; current watcher status
^+a::    ; Ctrl+Shift+A to toggle timer
{
    ; global vars have to be declared as such to allow RW in local scope
    global IsEnabled
    IsEnabled := not (IsEnabled)    ; toggle state

    if (IsEnabled) {
        TrayTip(ScriptName, "Enabled the watcher", TrayTipNoSound)
        ; start timer thread with fixed delay between function calls
        SetTimer(WatchThatPixel, TimerDelay)
    } else {
        TrayTip(ScriptName, "Disabled the watcher", TrayTipNoSound)
        SetTimer(WatchThatPixel, TimerOff)    ; exit timer thread
    }

    return
}

WatchThatPixel()
{
    global ColorCurrent

    local color := PixelGetcolor(X, Y)

    if (ColorCurrent != color) {
        ColorCurrent := color
        ; react to color change, for instance to detect movement
    }

    ; check for one or more colors
    if (color = ColorTarget) {
        ; react to specific color
    }

    return
}