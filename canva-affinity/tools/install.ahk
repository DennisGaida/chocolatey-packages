#Requires AutoHotkey 2.0-a
#SingleInstance force
SetTitleMatchMode 3

winTitle := "Affinity"

WinWait(winTitle)
Sleep(1000)
ControlSend("{Tab}",, winTitle)
Sleep(100)
ControlSend("{Tab}",, winTitle)
Sleep(100)
ControlSend("{Tab}",, winTitle)
Sleep(100)
; clicking the installation button
ControlSend("{Enter}",, winTitle)
; waiting 30s for the installation to finish. unfortunately no installer window title change
Sleep(30000)
; we somehow need to press tab twice to select the one exit button
ControlSend("{Tab}",, winTitle)
Sleep(100)
ControlSend("{Tab}",, winTitle)
Sleep(100)
ControlSend("{Enter}",, winTitle)
