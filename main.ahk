#include classMemory.ahk

global ClientPIDs := []
global MainPID := 0
global isMain := "False"
global range = 32

Gui, New, , "Phj's Range Detector"
Gui, Font, s12
Gui +AlwaysOnTop
Gui, Add, ListView, , Client PID|X  |Y  |Z    |Main  |In Range
Gui, Add, Button, gStart, Start
Gui, Show, W400 H300 X0 Y0

return

start:

if(%MainPID% == 0) {
    MsgBox, Please select a main Client
} else {
    WinGet,l,list,ahk_exe Trove.exe
loop %l%{
WinGet,pidU,PID,% "ahk_id " l%a_index%
ClientPIDs.Insert(pidU)
}

for index, clientPID in ClientPIDs {
    if(clientPID == MainPID) {
        isMain := "True"
    } else {
        isMain := "False"
    }
    LV_Add("", clientPID, 0, 0, 0, isMain)
}

loop {

    for index, clientPID in ClientPIDs {
        if(clientPID == MainPID) {
            allAltsInRange := "True"
            mainMem := new _ClassMemory("ahk_pid" MainPID, "", hProcessCopy)
            mainX := mainMem.read(mainMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xC8)
            mainY := mainMem.read(mainMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xCC)
            mainZ := mainMem.read(mainMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xD0) - 4294967295
            for _, _clientPID in ClientPIDs {
                if(_clientPID != MainPID) {
                    altMem := new _ClassMemory("ahk_pid" _clientPID, "", hProcessCopy)
                    altX := altMem.read(altMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xC8)
                    altY := altMem.read(altMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xCC)
                    altZ := altMem.read(altMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xD0) - 4294967295
                    spaceBetweenX := mainX - altX
                    spaceBetweenY := mainY - altY
                    spaceBetweenZ := mainZ - altZ
                    if(spaceBetweenX > range || spaceBetweenY > range || spaceBetweenZ > range) {
                        allAltsInRange := "False"
                    }
                }
            }
            LV_Modify(index, "", , mainX, mainY, mainZ, , allAltsInRange)
            LV_ModifyCol(1, 100)
        } else {
            isInRangeOfMain := "False"
            mainMem := new _ClassMemory("ahk_pid" MainPID, "", hProcessCopy)
            mainX := mainMem.read(mainMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xC8)
            mainY := mainMem.read(mainMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xCC)
            mainZ := mainMem.read(mainMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xD0) - 4294967295
            altMem := new _ClassMemory("aahk_pid" clientPID, "", hProcessCopy)
            altX := altMem.read(altMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xC8)
            altY := altMem.read(altMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xCC)
            altZ := altMem.read(altMem.BaseAddress + 0x00F4C670, "UInt", 0x0, 0x28, 0xC4, 0x6C, 0xD0) - 4294967295
            spaceBetweenX := mainX - altX
            spaceBetweenY := mainY - altY
            spaceBetweenZ := mainZ - altZ
            if(spaceBetweenX <= range && spaceBetweenY <= range && spaceBetweenZ <= range) {
                isInRangeOfMain := "True"
            }
            LV_Modify(index, "", , altX, altY, altZ, , isInRangeOfMain)
            LV_ModifyCol(1, 100)
        }
    }

    Sleep, 20
}
}

GuiClose:

ExitApp

return

^5:: 

WinGet,pidU,PID, A
MainPID = %pidU%
MsgBox, Main PID set to: %MainPID%

return