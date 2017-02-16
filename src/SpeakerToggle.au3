#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Outfile=SpeakerToggle.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3> ; Required for the $TRAY_ICONSTATE_SHOW constant.
#include <WinAPIFiles.au3>

Opt("WinTitleMatchMode", 2 );Match any String in window title
Opt("TrayMenuMode", 3);For custom tray icon

Const $settingsFile = "SpeakerToggle.ini"

Local $device =  IniRead ($settingsFile, "settings", "device", "" )
if $device = "" then
	IniWrite($settingsFile,"settings","device", 1)
	IniWrite($settingsFile,"settings","speakerMode", 4)
EndIf
Local $device = Number(IniRead ( $settingsFile, "settings", "device", "" ))
Local $speakerMode = Number(IniRead ($settingsFile, "settings", "speakerMode", "" ))

Local $soundWindow = ""
Local $soundSetup = ""

createTrayMenu()

Func createTrayMenu()
	TraySetIcon("icon.ico")
    Local $idToggle = TrayCreateItem("Toggle")
    TrayCreateItem("")
	Local $idSettings = TrayCreateItem("Settings")
    TrayCreateItem("")
    Local $idAbout = TrayCreateItem("About")
    TrayCreateItem("")
    Local $idExit = TrayCreateItem("Exit")

    TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.
	TraySetToolTip("Current Mode: " & readCurrentMode())
	WinClose($soundSetup)
	WinClose($soundWindow)

    While 1
        Switch TrayGetMsg()
            Case $idToggle
				TraySetToolTip("Current Mode: " & changeSpeakerMode())
		    Case $idSettings
				Run ( "notepad.exe " & $settingsFile, "" )
			Case $idAbout
                MsgBox($MB_SYSTEMMODAL, "SpeakerToggle", "" & _
				"A simple windows application to toggle between speaker modes."  & @CRLF & _
				"by DiabolusExMachina" & @CRLF & _
				"Version: 0.3" & @CRLF & @CRLF & _
				"Icon by Sallee Design. Thank you!" & @CRLF & _
				"Icon-Licence: CC BY-NC 3.0 NL https://creativecommons.org/licenses/by-nc/3.0/nl/legalcode ")
            Case $idExit
                ExitLoop
        EndSwitch
    WEnd
EndFunc

Func changeSpeakerMode()
	Local $selection = readCurrentMode()
	Local $newMode = ""
	if $selection == "Stereo" Then
		ControlCommand($soundSetup, "", "ListBox1", "SetCurrentSelection", $speakerMode - 1)
		$newMode = ControlCommand($soundSetup, "", "ListBox1", "GetCurrentSelection")
		send("{ENTER},{ENTER},{ENTER},{ENTER}")
	Else
		ControlCommand($soundSetup, "", "ListBox1", "SetCurrentSelection", 0)
		$newMode = ControlCommand($soundSetup, "", "ListBox1", "GetCurrentSelection")
		send("{ENTER},{ENTER},{ENTER}")
	EndIf
	ControlClick($soundWindow, "" , "Button4"); ok  button
	Return $newMode;
EndFunc

Func readCurrentMode()
	Run("c:\windows\system32\control.exe mmsys.cpl")
	sleep(500)
	$soundWindow = WinWaitActive("Sound")
	For $i = 0 To $device-1 Step 1
		send("{DOWN}"); select the device
	Next
	ControlClick($soundWindow,"","Button1")
	$soundSetup = WinWaitActive("Setup")
	return ControlCommand($soundSetup, "", "ListBox1", "GetCurrentSelection")
EndFunc