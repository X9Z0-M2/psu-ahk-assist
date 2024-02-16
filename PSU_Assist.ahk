#Requires AutoHotkey v2
;@Ahk2Exe-SetVersion 0.0.0.1 

#SingleInstance Force
#MaxThreadsPerHotkey 2
SendMode "Event"

CoordMode "Pixel", "Screen"
SetKeyDelay 50, 40  ; 75ms between keys, 25ms between down/up.


; full_command_line := DllCall("GetCommandLine", "str")

; if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
; {
;     try
;     {
;         if A_IsCompiled
;             Run '*RunAs "' A_ScriptFullPath '" /restart'
;         else
;             Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
;     }
;     ExitApp
; }

;VARS
global JA_X := 0
global JA_Y := 0
global JA_W := 11
global JA_H := 11
Skip_JAResize := 0
JustAttackCount := 0
JustAttackFreq := 1
JustAttackThresh := 3
JustAttackDelay := 70
JustAttackHotKey := "Right"
JustAttackPressKey := ConvertHotKeyToKeyPress(JustAttackHotKey)
JustAttackWindowCanMove := 0

global PC_X := 0
global PC_Y := 0
global PC_MX := 0
global PC_MY := 0
global PC_W := 120
global PC_H := 1
Skip_PCResize := 0
PhotonChargeCount := 0
PhotonChargeFreq := 200
PhotonChargePPThresh := 7
PhotonChargeTrigThresh := 2
PhotonChargeDelay := 0
PC_Bar_Norm := -1
PhotonChargeHotKey := "+F9"
PhotonChargePressKey := ConvertHotKeyToKeyPress(PhotonChargeHotKey)
PhotonChargeWindowCanMove := 0

global TH_X := 0
global TH_Y := 0
global TH_MX := 0
global TH_MY := 0
global TH_W := 130
global TH_H := 1
Skip_THResize := 0
TrimateHealCount := 0
TrimateHealFreq := 150
TrimateHealHPThresh := 60
TrimateHealTrigThresh := 2
TrimateHealDelay := 0
TH_Bar_Norm := -1
TrimateHealHotKey := "+F8"
TrimateHealPressKey := ConvertHotKeyToKeyPress(TrimateHealHotKey)
TrimateHealWindowCanMove := 0

global AS_X := 0
global AS_Y := 0
global AS_MX := 0
global AS_MY := 0
global AS_W := 16
global AS_H := 1
Skip_ASResize := 0
ArmorSwapCount := 0
ArmorSwapFreq := 300
ArmorSwapDetectionVariation := 10 ; can be 0-255
ArmorSwapTrigThresh := 2
ArmorSwapDelay := 0
ArmorSwapElemType := 0 ; 0=neutral, 1=fire, 2=ice, 3=lightning, 4=ground, 5=dark, 6=light
ArmorSwapLastElemType := ArmorSwapElemType
ArmorSwapElemFireHotKey := "+F1"
ArmorSwapElemIceHotKey := "+F2"
ArmorSwapElemLightningHotKey := "+F3"
ArmorSwapElemGroundHotKey := "+F4"
ArmorSwapElemDarkHotKey := "+F5"
ArmorSwapElemLightHotKey := "+F6"
ArmorSwapElemFirePressKey := ConvertHotKeyToKeyPress(ArmorSwapElemFireHotKey)
ArmorSwapElemIcePressKey := ConvertHotKeyToKeyPress(ArmorSwapElemIceHotKey)
ArmorSwapElemLightningPressKey := ConvertHotKeyToKeyPress(ArmorSwapElemLightningHotKey)
ArmorSwapElemGroundPressKey := ConvertHotKeyToKeyPress(ArmorSwapElemGroundHotKey)
ArmorSwapElemDarkPressKey := ConvertHotKeyToKeyPress(ArmorSwapElemDarkHotKey)
ArmorSwapElemLightPressKey := ConvertHotKeyToKeyPress(ArmorSwapElemLightHotKey)
ArmorSwapWindowCanMove := 0


; ; Create custom gui to control all script components
Menu_Gui := Gui("+AlwaysOnTop +MinSize50x50 +MaxSize900x900 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu -DPIScale", "PSU AIO Auto")
Menu_Gui.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
MButton_StartPSU := Menu_Gui.Add("Button", , "Start PSU")
MButton_StartPSU.OnEvent("Click", StartPSU)
MButton_RunPSUFR := Menu_Gui.Add("Button", "YS", "Run PSUFR")
MButton_RunPSUFR.OnEvent("Click", RunPSUFR)

; MButton_PCUse := Menu_Gui.Add("Button", "XS vPhotonChargeUse", "Use Photon Charge")
; MButton_PCUse.OnEvent("Click", PhotonChargeUse)
MProgress_JA := Menu_Gui.Add("Progress", "XS w100 h10 c0x3A89DB Smooth vJustAttackProgress", -1)
MProgress_PC := Menu_Gui.Add("Progress", "w100 h18 c0x3A89DB Smooth vPhotonChargeProgress", -1)
MProgress_TH := Menu_Gui.Add("Progress", "w100 h18 c0x5BD847 Smooth vTrimateHealProgress", -1)
MProgress_AS := Menu_Gui.Add("Progress", "w100 h18 c0x666666 Smooth vArmorSwapProgress", -1)


MTab_Settings := Menu_Gui.Add("Tab3","-Wrap w130", ["JA","PC","TH","AS","AS Keys"])

MTab_Settings.UseTab(1)
MButton_ShowJA := Menu_Gui.Add("Button", "", "Hide JA")
MButton_ShowJA.OnEvent("Click", JustAttackAllowMoveWindow)

Menu_Gui.Add("Text", , "JA Key")
MHotkey_JAPressKey := Menu_Gui.Add("Hotkey", "w110 vJAPressKeyHotkey", JustAttackHotKey)
MHotkey_JAPressKey.OnEvent("Change", JustAttackPressKeyChanged)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", JustAttackFreqChanged)
MUpDown_JAFreq := Menu_Gui.Add("UpDown", "vJAFreqUpDown Range1-1000", JustAttackFreq)
MUpDown_JAFreq.OnEvent("Change", JustAttackFreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", JustAttackThreshChanged)
MUpDown_JAThresh := Menu_Gui.Add("UpDown", "vJAThreshUpDown Range0-50", JustAttackThresh)
MUpDown_JAThresh.OnEvent("Change", JustAttackThreshChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", JustAttackDelayChanged)
MUpDown_JADelay :=Menu_Gui.Add("UpDown", "vJADelayUpDown Range0-500", JustAttackDelay)
MUpDown_JADelay.OnEvent("Change", JustAttackDelayChanged)

Menu_Gui.Add("Text", , "Position Detect Pixel")
MUpDown_JAVert := Menu_Gui.Add("UpDown", "-16 H40 vJAVertUpDown Range-1-1", 0)
MUpDown_JAVert.OnEvent("Change", JustAttackVertChanged)
MUpDown_JAHorz := Menu_Gui.Add("UpDown", "XS35 W45 vJAVHorzUpDown Horz Range-1-1", 0)
MUpDown_JAHorz.OnEvent("Change", JustAttackHorzChanged)

MTab_Settings.UseTab(2)
MButton_ShowPC := Menu_Gui.Add("Button", "", "Hide PC")
MButton_ShowPC.OnEvent("Click", PhotonChargeAllowMoveWindow)

Menu_Gui.Add("Text", , "PC Key")
MHotkey_PCPressKey := Menu_Gui.Add("Hotkey", "w110 vPCPressKeyHotkey", PhotonChargeHotKey)
MHotkey_PCPressKey.OnEvent("Change", PhotonChargePressKeyChanged)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", PhotonChargeFreqChanged)
MUpDown_PCFreq := Menu_Gui.Add("UpDown", "vPCFreqUpDown Range1-1000", PhotonChargeFreq)
MUpDown_PCFreq.OnEvent("Change", PhotonChargeFreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", PhotonChargeTrigThreshChanged)
MUpDown_PCTrigThresh := Menu_Gui.Add("UpDown", "vPCTrigThreshUpDown Range0-50", PhotonChargeTrigThresh)
MUpDown_PCTrigThresh.OnEvent("Change", PhotonChargeTrigThreshChanged)
Menu_Gui.Add("Text", , "PP Threshold %")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", PhotonChargePPThreshChanged)
MUpDown_PCPPThresh := Menu_Gui.Add("UpDown", "vPCPPThreshUpDown Range0-50", PhotonChargePPThresh)
MUpDown_PCPPThresh.OnEvent("Change", PhotonChargePPThreshChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", PhotonChargeDelayChanged)
MUpDown_PCDelay :=Menu_Gui.Add("UpDown", "vPCDelayUpDown Range0-500", PhotonChargeDelay)
MUpDown_PCDelay.OnEvent("Change", PhotonChargeDelayChanged)

Menu_Gui.Add("Text", , "Position Detect Line")
MUpDown_PCVert := Menu_Gui.Add("UpDown", "-16 H40 vPCVertUpDown Range-1-1", 0)
MUpDown_PCVert.OnEvent("Change", PhotonChargeVertChanged)
MUpDown_PCHorz := Menu_Gui.Add("UpDown", "XS35 W45 vPCVHorzUpDown Horz Range-1-1", 0)
MUpDown_PCHorz.OnEvent("Change", PhotonChargeHorzChanged)

MTab_Settings.UseTab(3)
MButton_ShowTH := Menu_Gui.Add("Button", "", "Hide TH")
MButton_ShowTH.OnEvent("Click", TrimateHealAllowMoveWindow)

Menu_Gui.Add("Text", , "TH Key")
MHotkey_THPressKey := Menu_Gui.Add("Hotkey", "w110 vTHPressKeyHotkey", TrimateHealHotKey)
MHotkey_THPressKey.OnEvent("Change", TrimateHealPressKeyChanged)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", TrimateHealFreqChanged)
MUpDown_THFreq := Menu_Gui.Add("UpDown", "vTHFreqUpDown Range1-1000", TrimateHealFreq)
MUpDown_THFreq.OnEvent("Change", TrimateHealFreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", TrimateHealTrigThreshChanged)
MUpDown_THTrigThresh := Menu_Gui.Add("UpDown", "vTHTrigThreshUpDown Range0-50", TrimateHealTrigThresh)
MUpDown_THTrigThresh.OnEvent("Change", TrimateHealTrigThreshChanged)

Menu_Gui.Add("Text", , "HP Threshold %")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", TrimateHealThreshChanged)
MUpDown_THHPThresh := Menu_Gui.Add("UpDown", "vTHHPThreshUpDown Range0-100", TrimateHealHPThresh)
MUpDown_THHPThresh.OnEvent("Change", TrimateHealThreshChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", TrimateHealDelayChanged)
MUpDown_THDelay :=Menu_Gui.Add("UpDown", "vTHDelayUpDown Range0-500", TrimateHealDelay)
MUpDown_THDelay.OnEvent("Change", TrimateHealDelayChanged)

Menu_Gui.Add("Text", , "Position Detect Line")
MUpDown_THVert := Menu_Gui.Add("UpDown", "-16 H40 vTHVertUpDown Range-1-1", 0)
MUpDown_THVert.OnEvent("Change", TrimateHealVertChanged)
MUpDown_THHorz := Menu_Gui.Add("UpDown", "Y+6 XS35 W45 vTHVHorzUpDown Horz Range-1-1", 0)
MUpDown_THHorz.OnEvent("Change", TrimateHealHorzChanged)

MTab_Settings.UseTab(4)
MButton_ShowAS := Menu_Gui.Add("Button", "", "Hide AS")
MButton_ShowAS.OnEvent("Click", ArmorSwapAllowMoveWindow)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", ArmorSwapFreqChanged)
MUpDown_ASFreq := Menu_Gui.Add("UpDown", "vASFreqUpDown Range1-1000", ArmorSwapFreq)
MUpDown_ASFreq.OnEvent("Change", ArmorSwapFreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", ArmorSwapTrigThreshChanged)
MUpDown_ASTrigThresh := Menu_Gui.Add("UpDown", "vASTrigThreshUpDown Range0-50", ArmorSwapTrigThresh)
MUpDown_ASTrigThresh.OnEvent("Change", ArmorSwapTrigThreshChanged)

Menu_Gui.Add("Text", , "Detection Variation 0-255")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", ArmorSwapDetectionVariationChanged)
MUpDown_ASDTVARTN := Menu_Gui.Add("UpDown", "vASHPDetectionVariationUpDown Range0-255", ArmorSwapDetectionVariation)
MUpDown_ASDTVARTN.OnEvent("Change", ArmorSwapDetectionVariationChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", ArmorSwapDelayChanged)
MUpDown_ASDelay :=Menu_Gui.Add("UpDown", "vASDelayUpDown Range0-500", ArmorSwapDelay)
MUpDown_ASDelay.OnEvent("Change", ArmorSwapDelayChanged)

Menu_Gui.Add("Text", , "Position Detect Line")
MUpDown_ASVert := Menu_Gui.Add("UpDown", "-16 H40 vASVertUpDown Range-1-1", 0)
MUpDown_ASVert.OnEvent("Change", ArmorSwapVertChanged)
MUpDown_ASHorz := Menu_Gui.Add("UpDown", "Y+6 XS35 W45 vASVHorzUpDown Horz Range-1-1", 0)
MUpDown_ASHorz.OnEvent("Change", ArmorSwapHorzChanged)

MTab_Settings.UseTab(5)
Menu_Gui.Add("Text", , "AS FIRE")
MHotkey_ASPressKeyElemFire := Menu_Gui.Add("Hotkey", "w90 vASPressKeyElemFireHotkey", ArmorSwapElemFireHotKey)
MHotkey_ASPressKeyElemFire.OnEvent("Change", ArmorSwapElemFirePressKeyChanged)
Menu_Gui.Add("Text", , "AS ICE")
MHotkey_ASPressKeyElemIce := Menu_Gui.Add("Hotkey", "w90 vASPressKeyElemIceHotkey", ArmorSwapElemIceHotKey)
MHotkey_ASPressKeyElemIce.OnEvent("Change", ArmorSwapElemIcePressKeyChanged)
Menu_Gui.Add("Text", , "AS LIGHTNING")
MHotkey_ASPressKeyElemLightning := Menu_Gui.Add("Hotkey", "w90 vASPressKeyElemLightningHotkey", ArmorSwapElemLightningHotKey)
MHotkey_ASPressKeyElemLightning.OnEvent("Change", ArmorSwapElemLightningPressKeyChanged)
Menu_Gui.Add("Text", , "AS GROUND")
MHotkey_ASPressKeyElemGround := Menu_Gui.Add("Hotkey", "w90 vASPressKeyElemGroundHotkey", ArmorSwapElemGroundHotKey)
MHotkey_ASPressKeyElemGround.OnEvent("Change", ArmorSwapElemGroundPressKeyChanged)
Menu_Gui.Add("Text", , "AS DARK")
MHotkey_ASPressKeyElemDark := Menu_Gui.Add("Hotkey", "w90 vASPressKeyElemDarkHotkey", ArmorSwapElemDarkHotKey)
MHotkey_ASPressKeyElemDark.OnEvent("Change", ArmorSwapElemDarkPressKeyChanged)
Menu_Gui.Add("Text", , "AS LIGHT")
MHotkey_ASPressKeyElemLight := Menu_Gui.Add("Hotkey", "w90 vASPressKeyElemLightHotkey", ArmorSwapElemLightHotKey)
MHotkey_ASPressKeyElemLight.OnEvent("Change", ArmorSwapElemLightPressKeyChanged)

MTab_Settings.UseTab(0)
Menu_Gui.Show("W150 H490")


; ; Create custom gui to represent where ahk is detecting pixels for auto Just Attack 
JA_Gui := Gui("+AlwaysOnTop +MinSize5x5 +MaxSize25x25 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "JA")
JA_Gui.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
JA_Gui.OnEvent("Size", JAResize )
JAResize(GuiObj, MinMax, Width, Height)
{
    global
    if (Skip_JAResize = 0)
    {
        GuiObj.GetClientPos(&JA_X, &JA_Y, &JA_W, &JA_H)
    }
    ToolTip "X" JA_X " Y" JA_Y " W" JA_W " H" JA_H
    SetTimer () => ToolTip(), -1000, 10000
    return True
}
JA_Gui.Show("W" . JA_W . " H" . JA_H)
WinSetTransColor(JA_Gui.BackColor ,JA_Gui.Hwnd)


; ; Create custom gui to represent where ahk is detecting pixels for auto Photon Charge 
PC_Gui := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "PC")
PC_Gui.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
PC_Gui.OnEvent("Size", PCResize )
PCResize(GuiObj, MinMax, Width, Height)
{
    global
    if (Skip_PCResize = 0)
    {
        GuiObj.GetClientPos(&PC_X, &PC_Y, &PC_W, &PC_H)
        PC_MX := PC_X + PC_W
        PC_MY := PC_Y + PC_H
    }
    ToolTip "X" PC_X " Y" PC_Y " W" PC_W " H" PC_H
    SetTimer () => ToolTip(), -1000, 10000
    return True
}
PC_Gui.Show("W" . PC_W . " H" . PC_H)
WinSetTransColor(PC_Gui.BackColor , PC_Gui.Hwnd)


; ; Create custom gui to represent where ahk is detecting pixels for auto Trimates (healing) 
TH_Gui := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "TH")
TH_Gui.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
TH_Gui.OnEvent("Size", THResize )
THResize(GuiObj, MinMax, Width, Height)
{
    global
    if (Skip_THResize = 0)
    {
        GuiObj.GetClientPos(&TH_X, &TH_Y, &TH_W, &TH_H)
        TH_MX := TH_X + TH_W
        TH_MY := TH_Y + TH_H
    }
    ToolTip "X" TH_X " Y" TH_Y " W" TH_W " H" TH_H
    SetTimer () => ToolTip(), -1000, 10000
    return True
}
TH_Gui.Show("W" . TH_W . " H" . TH_H)
WinSetTransColor(TH_Gui.BackColor , TH_Gui.Hwnd)


; ; Create custom gui for enemy element type detection to armor swap
AS_Gui := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "AS")
AS_Gui.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
AS_Gui.OnEvent("Size", ASResize )
ASResize(GuiObj, MinMax, Width, Height)
{
    global
    if (Skip_ASResize = 0)
    {
        GuiObj.GetClientPos(&AS_X, &AS_Y, &AS_W, &AS_H)
        AS_MX := AS_X + AS_W
        AS_MY := AS_Y + AS_H
    }
    ToolTip "X" AS_X " Y" AS_Y " W" AS_W " H" AS_H
    SetTimer () => ToolTip(), -1000, 10000
    return True
}
AS_Gui.Show("W" . AS_W . " H" . AS_H)
WinSetTransColor(AS_Gui.BackColor , AS_Gui.Hwnd)


; add hook for repositioning the ahk custom window
OnMessage(0x03, MsgMonitor)
MsgMonitor(wParam, lParam, msg, hwnd)
{
    if( hwnd = JA_Gui.Hwnd )
    {
        JAResize(JA_Gui, 0, 0, 0)
    }
    else if ( hwnd = PC_Gui.Hwnd )
    {
        PCResize(PC_Gui, 0, 0, 0)
    }
    else if ( hwnd = TH_Gui.Hwnd )
    {
        THResize(TH_Gui, 0, 0, 0)
    }
    else if ( hwnd = AS_Gui.Hwnd )
    {
        ASResize(AS_Gui, 0, 0, 0)
    }
}
JAResize(JA_Gui, 0, 0, 0)
PCResize(PC_Gui, 0, 0, 0)
THResize(TH_Gui, 0, 0, 0)
ASResize(AS_Gui, 0, 0, 0)



; Auto Just Attack
SetTimer JustAttackLoop, JustAttackFreq
JustAttackLoop()
{
    global
    P_Color := PixelGetColor(JA_X, JA_Y)
    If ( P_Color = 0x00FF00 )  ; green color
    {
        MProgress_JA.Value := Max(Min(Round(JustAttackCount / JustAttackThresh * 100), 100),0)
        JustAttackCount := JustAttackCount + 1
    } Else {
        If (JustAttackCount > 0)
        {
            ToolTip "Time Green" JustAttackCount
            SetTimer () => ToolTip(), -1000, 10000
        }
        JustAttackCount := 0
        If ( P_Color = 0xFF0000 )
        {
            MProgress_JA.Opt("+c0xFF0000")
            MProgress_JA.Value := 100
        } Else {
            MProgress_JA.Opt("+c0x3A89DB")
            MProgress_JA.Value := 0
        }
    }
    If (JustAttackCount >= JustAttackThresh)
    {
        MProgress_JA.Opt("+c0x00FF00")
        MProgress_JA.Value := 100
        Sleep JustAttackDelay
        ToolTip "Just Attack!"
        SetTimer () => ToolTip(), -200, 10000
        Send JustAttackPressKey
        JustAttackCount := 0
    }
    return True
}


; Auto Photon Charge
SetTimer PhotonChargeLoop, PhotonChargeFreq
PhotonChargeLoop()
{
    global
    If ( PixelSearch(&PC_Px, &PC_Py, PC_MX, PC_MY, PC_X, PC_Y, 0x3A89DB) ) ; mid-blue color. Also can be 0x3987DB ?
    {
        PC_Bar_Norm := Round((PC_Px - PC_X) / (PC_W) * 100)
        MProgress_PC.Value := PC_Bar_Norm
        PC_Gui.Title := "PC " . PC_Bar_Norm . "/100"
        If ( PC_Bar_Norm < PhotonChargePPThresh && PC_Bar_Norm > 0 ){
            PhotonChargeCount := PhotonChargeCount + 1
        }
        
    } Else {
        If (PhotonChargeCount > 0)
        {
            ToolTip "Time Blue" PhotonChargeCount
            SetTimer () => ToolTip(), -1000, 10000
        }
        PhotonChargeCount := 0
        PC_Gui.Title := "PC"
    }
;ToolTip "Pixel Search" PhotonChargeCount " " PC_X ":" PC_Y " " PC_W ":" PC_H " FOUND:" PC_Px ":" PC_Py " " PC_Bar_Norm
    If (PhotonChargeCount >= PhotonChargeTrigThresh)
    {
        PhotonChargeUse()
    }
    return True
}


; Auto Trimate Heal
SetTimer TrimateHealLoop, TrimateHealFreq
TrimateHealLoop()
{
    global
    If ( PixelSearch(&TH_Px, &TH_Py, TH_MX, TH_MY, TH_X, TH_Y, 0x5BD847 ) ) ; green color. Also can be, 0x5BD847, 0x58CD46, 0x47983D, 0x4D9F44  ?
    {
        TH_Bar_Norm := Round((TH_Px - TH_X) / (TH_W) * 100)
        MProgress_TH.Value := TH_Bar_Norm
        MProgress_TH.Opt("+c0x5BD847")
        TH_Gui.Title := "TH " . TH_Bar_Norm . "/100"
        If ( TH_Bar_Norm < TrimateHealHPThresh && TH_Bar_Norm > 0 ){
            TrimateHealCount := TrimateHealCount + 1
        }
        
    } Else {
        If ( PixelSearch(&TH_Px, &TH_Py, TH_MX, TH_MY, TH_X, TH_Y, 0xFFFF00 ) ) ; yellow color. Also can be others, but changes constantly !
        {
            TH_Bar_Norm := Round((TH_Px - TH_X) / (TH_W) * 100)
            MProgress_TH.Value := TH_Bar_Norm
            MProgress_TH.Opt("+c0xFFFF00")
            TH_Gui.Title := "TH " . TH_Bar_Norm . "/100"
            If ( TH_Bar_Norm < TrimateHealHPThresh && TH_Bar_Norm > 0 ){
                TrimateHealCount := TrimateHealCount + 1
            }
        } Else {
            If (TrimateHealCount > 0)
            {
                ToolTip "Time Yellow" TrimateHealCount
                SetTimer () => ToolTip(), -1000, 10000
            }
            MProgress_TH.Value := -1
            TrimateHealCount := 0
            TH_Gui.Title := "TH"
        }
    }
;ToolTip "Pixel Search" TrimateHealCount " " TH_X ":" TH_Y " " TH_W ":" TH_H " FOUND:" TH_Px ":" TH_Py " " TH_Bar_Norm
    If (TrimateHealCount >= TrimateHealTrigThresh)
    {
        TrimateHealUse()
    }
    return True
}


; Auto Armor Swap
SetTimer ArmorSwapLoop, ArmorSwapFreq
ArmorSwapLoop()
{
    global
    If ( PixelSearch(&AS_Px, &AS_Py, AS_MX, AS_Y, AS_X, AS_Y, 0xFE7878, ArmorSwapDetectionVariation ) ) ; dull red color.
    {
        MProgress_AS.Value := 22
        MProgress_AS.Opt("+c0xFE7878")
        AS_Gui.Title := "AS FIRE"
        ArmorSwapCount := ArmorSwapCount + 1
        ArmorSwapElemType := 1
    }
    Else If ( PixelSearch(&AS_Px, &AS_Py, AS_MX, AS_Y, AS_X, AS_Y, 0x7272FF, ArmorSwapDetectionVariation ) ) ; deep blue color.
    {
        MProgress_AS.Value := 22
        MProgress_AS.Opt("+c0x7272FF")
        AS_Gui.Title := "AS ICE"
        ArmorSwapCount := ArmorSwapCount + 1
        ArmorSwapElemType := 2
    }
    Else If ( PixelSearch(&AS_Px, &AS_Py, AS_MX, AS_Y, AS_X, AS_Y, 0xFFFF29, ArmorSwapDetectionVariation ) ) ; yellow color.
    {
        MProgress_AS.Value := 22
        MProgress_AS.Opt("+c0xFFFF29")
        AS_Gui.Title := "AS LIGHTNING"
        ArmorSwapCount := ArmorSwapCount + 1
        ArmorSwapElemType := 3
    }
    Else If ( PixelSearch(&AS_Px, &AS_Py, AS_MX, AS_Y, AS_X, AS_Y, 0xFF8000, ArmorSwapDetectionVariation ) ) ; burnt orange color.
    {
        MProgress_AS.Value := 22
        MProgress_AS.Opt("+c0xFF8000")
        AS_Gui.Title := "AS GROUND"
        ArmorSwapCount := ArmorSwapCount + 1
        ArmorSwapElemType := 4
    }
    Else If ( PixelSearch(&AS_Px, &AS_Py, AS_MX, AS_Y, AS_X, AS_Y, 0x653865, ArmorSwapDetectionVariation ) ) ; bright purple color.
    {
        MProgress_AS.Value := 22
        MProgress_AS.Opt("+c0x653865")
        AS_Gui.Title := "AS DARK"
        ArmorSwapCount := ArmorSwapCount + 1
        ArmorSwapElemType := 5
    }
    Else If ( PixelSearch(&AS_Px, &AS_Py, AS_MX, AS_Y, AS_X, AS_Y, 0xFFC7AD, ArmorSwapDetectionVariation ) ) ; beige color.
    {
        MProgress_AS.Value := 22
        MProgress_AS.Opt("+c0xFFC7AD")
        AS_Gui.Title := "AS LIGHT"
        ArmorSwapCount := ArmorSwapCount + 1
        ArmorSwapElemType := 6
    }
    Else {
        If (ArmorSwapCount > 0)
        {
            ToolTip "Time ArmorSwap" ArmorSwapCount
            SetTimer () => ToolTip(), -1000, 10000
        }
        ArmorSwapCount := 0
        MProgress_AS.Value := -1
        AS_Gui.Title := "AS"
        ArmorSwapElemType := 0
    }
; ToolTip "Pixel Search" ArmorSwapCount " " AS_X ":" AS_Y " " AS_W ":" AS_H " FOUND:" AS_Px ":" AS_Py " " ArmorSwapElemType
    If (ArmorSwapCount >= ArmorSwapTrigThresh)
    {
        ArmorSwapUse()
    }
    return True
}



PhotonChargeUse(*)
{
    global
    Sleep PhotonChargeDelay
    ToolTip "Photon Charge!"
    SetTimer () => ToolTip(), -1900, 10000
    Send PhotonChargePressKey
    PhotonChargeCount := 0
}
TrimateHealUse(*)
{
    global
    Sleep TrimateHealDelay
    ToolTip "Trimate Heal!"
    SetTimer () => ToolTip(), -1900, 10000
    Send TrimateHealPressKey
    TrimateHealCount := 0
}
ArmorSwapUse(*)
{
    global
    if (ArmorSwapLastElemType != ArmorSwapElemType)
    {
        Sleep ArmorSwapDelay
        ToolTip "Armor Swap!"
        SetTimer () => ToolTip(), -1900, 10000
        If (ArmorSwapElemType = 1)
        {
            ArmorSwapPressKey := ArmorSwapElemFirePressKey
        } Else If (ArmorSwapElemType = 2)
        {
            ArmorSwapPressKey := ArmorSwapElemIcePressKey
        } Else If (ArmorSwapElemType = 3)
        {
            ArmorSwapPressKey := ArmorSwapElemLightningPressKey
        } Else If (ArmorSwapElemType = 4)
        {
            ArmorSwapPressKey := ArmorSwapElemGroundPressKey
        } Else If (ArmorSwapElemType = 5)
        {
            ArmorSwapPressKey := ArmorSwapElemDarkPressKey
        } Else If (ArmorSwapElemType = 6)
        {
            ArmorSwapPressKey := ArmorSwapElemLightPressKey
        }
        
        Send ArmorSwapPressKey
        ArmorSwapLastElemType := ArmorSwapElemType
    }
        ArmorSwapCount := 0
}


StartPSU(*)
{
    try
        WinKill "Clementine Launcher ahk_exe online.exe"
    catch TargetError as err
    try
        WinKill "Phantasy Star Universe ahk_exe PSUC.exe"
    catch TargetError as err
    ProcessClose "PSUC.exe"
    curdir := A_WorkingDir
    SetWorkingDir "C:\Program Files (x86)\Phantasy Star Universe Clementine"
    Run '*RunAs "C:\Program Files (x86)\Phantasy Star Universe Clementine\online.exe"'
    SetWorkingDir curdir
}
RunPSUFR(*)
{
    try
        WinKill "ahk_exe PSUFR.exe"
    catch TargetError as err
    ProcessClose "PSUFR.exe"
    curdir := A_WorkingDir
    SetWorkingDir "C:\Program Files (x86)\Phantasy Star Universe Clementine\PSUFR 0.7.4"
    Run '*RunAs "C:\Program Files (x86)\Phantasy Star Universe Clementine\PSUFR 0.7.4\PSUFR.exe"'
    SetWorkingDir curdir
}


JustAttackAllowMoveWindow(*)
{
    global
    if (JustAttackWindowCanMove = 0)
    {
        JustAttackWindowCanMove := 1
        Skip_JAResize := 1
        JA_Gui.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowJA.Text := "Show JA"
    }
    Else
    {
        JustAttackWindowCanMove := 0
        Skip_JAResize := 0
        JA_Gui.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowJA.Text := "Hide JA"
    }
}

PhotonChargeAllowMoveWindow(*)
{
    global
    if (PhotonChargeWindowCanMove = 0)
    {
        PhotonChargeWindowCanMove := 1
        Skip_PCResize := 1
        PC_Gui.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowPC.Text := "Show PC"
    }
    Else
    {
        PhotonChargeWindowCanMove := 0
        Skip_PCResize := 0
        PC_Gui.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowPC.Text := "Hide PC"
    }
}

TrimateHealAllowMoveWindow(*)
{
    global
    if (TrimateHealWindowCanMove = 0)
    {
        TrimateHealWindowCanMove := 1
        Skip_THResize := 1
        TH_Gui.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowTH.Text := "Show TH"
    }
    Else
    {
        TrimateHealWindowCanMove := 0
        Skip_THResize := 0
        TH_Gui.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowTH.Text := "Hide TH"
    }
}

ArmorSwapAllowMoveWindow(*)
{
    global
    if (ArmorSwapWindowCanMove = 0)
    {
        ArmorSwapWindowCanMove := 1
        Skip_ASResize := 1
        AS_Gui.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowAS.Text := "Show AS"
    }
    Else
    {
        ArmorSwapWindowCanMove := 0
        Skip_ASResize := 0
        AS_Gui.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowAS.Text := "Hide AS"
    }
}

JustAttackPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_JAPressKey.Value) > 0)
    {
        JustAttackPressKey := ConvertHotKeyToKeyPress(MHotkey_JAPressKey.Value)
    }    
}
JustAttackFreqChanged(*)
{
    global
    JustAttackFreq := MUpDown_JAFreq.Value
    SetTimer JustAttackLoop, JustAttackFreq
}
JustAttackThreshChanged(*)
{
    global
    JustAttackThresh := MUpDown_JAThresh.Value
}
JustAttackDelayChanged(*)
{
    global
    JustAttackDelay := MUpDown_JADelay.Value
}
JustAttackVertChanged(*)
{
    global
    temp_Skip_JAResize := Skip_JAResize
    Skip_JAResize := 0
    JA_Gui.GetPos( &X, &Y )
    If (MUpDown_JAVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_JAVert.Value < 0) {
        Y := Y + 1
    }
    JA_Gui.Move( X, Y )
    MUpDown_JAVert.Value := 0
    Skip_JAResize := temp_Skip_JAResize
}
JustAttackHorzChanged(*)
{
    global
    temp_Skip_JAResize := Skip_JAResize
    Skip_JAResize := 0
    JA_Gui.GetPos( &X, &Y )
    If (MUpDown_JAHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_JAHorz.Value < 0) {
        X := X - 1
    }
    JA_Gui.Move( X, Y )
    MUpDown_JAHorz.Value := 0
    Skip_JAResize := temp_Skip_JAResize
}

PhotonChargePressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_PCPressKey.Value) > 0)
    {
        PhotonChargePressKey := ConvertHotKeyToKeyPress(MHotkey_PCPressKey.Value)
    }
}
PhotonChargeFreqChanged(*)
{
    global
    PhotonChargeFreq := MUpDown_PCFreq.Value
    SetTimer PhotonChargeLoop, PhotonChargeFreq
}
PhotonChargeTrigThreshChanged(*)
{
    global
    PhotonChargeTrigThresh := MUpDown_PCTrigThresh.Value
}
PhotonChargePPThreshChanged(*)
{
    global
    PhotonChargePPThresh := MUpDown_PCPPThresh.Value
}
PhotonChargeDelayChanged(*)
{
    global
    PhotonChargeDelay := MUpDown_PCDelay.Value
}
PhotonChargeVertChanged(*)
{
    global
    temp_Skip_PCResize := Skip_PCResize
    Skip_PCResize := 0
    PC_Gui.GetPos( &X, &Y )
    If (MUpDown_PCVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_PCVert.Value < 0) {
        Y := Y + 1
    }
    PC_Gui.Move( X, Y )
    MUpDown_PCVert.Value := 0
    Skip_PCResize := temp_Skip_PCResize
}
PhotonChargeHorzChanged(*)
{
    global
    temp_Skip_PCResize := Skip_PCResize
    Skip_PCResize := 0
    PC_Gui.GetPos( &X, &Y )
    If (MUpDown_PCHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_PCHorz.Value < 0) {
        X := X - 1
    }
    PC_Gui.Move( X, Y )
    MUpDown_PCHorz.Value := 0
    Skip_PCResize := temp_Skip_PCResize
}

TrimateHealPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_THPressKey.Value) > 0)
    {
        TrimateHealPressKey := ConvertHotKeyToKeyPress(MHotkey_THPressKey.Value)
    }    
}
TrimateHealFreqChanged(*)
{
    global
    TrimateHealFreq := MUpDown_THFreq.Value
    SetTimer TrimateHealLoop, TrimateHealFreq
}
TrimateHealTrigThreshChanged(*)
{
    global
    TrimateHealTrigThresh := MUpDown_THTrigThresh.Value
}
TrimateHealThreshChanged(*)
{
    global
    TrimateHealHPThresh := MUpDown_THHPThresh.Value
}
TrimateHealDelayChanged(*)
{
    global
    TrimateHealDelay := MUpDown_THDelay.Value
}
TrimateHealVertChanged(*)
{
    global
    temp_Skip_THResize := Skip_THResize
    Skip_THResize := 0
    TH_Gui.GetPos( &X, &Y )
    If (MUpDown_THVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_THVert.Value < 0) {
        Y := Y + 1
    }
    TH_Gui.Move( X, Y )
    MUpDown_THVert.Value := 0
    Skip_THResize := temp_Skip_THResize
}
TrimateHealHorzChanged(*)
{
    global
    temp_Skip_THResize := Skip_THResize
    Skip_THResize := 0
    TH_Gui.GetPos( &X, &Y )
    If (MUpDown_THHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_THHorz.Value < 0) {
        X := X - 1
    }
    TH_Gui.Move( X, Y )
    MUpDown_THHorz.Value := 0
    Skip_THResize := temp_Skip_THResize
}

ArmorSwapElemFirePressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemFire.Value) > 0)
    {
        ArmorSwapElemFirePressKey := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemFire.Value)
    }    
}
ArmorSwapElemIcePressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemIce.Value) > 0)
    {
        ArmorSwapElemIcePressKey := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemIce.Value)
    }    
}
ArmorSwapElemLightningPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemLightning.Value) > 0)
    {
        ArmorSwapElemLightningPressKey := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemLightning.Value)
    }    
}
ArmorSwapElemGroundPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemGround.Value) > 0)
    {
        ArmorSwapElemGroundPressKey := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemGround.Value)
    }    
}
ArmorSwapElemDarkPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemDark.Value) > 0)
    {
        ArmorSwapElemDarkPressKey := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemDark.Value)
    }    
}
ArmorSwapElemLightPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemLight.Value) > 0)
    {
        ArmorSwapElemLightPressKey := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemLight.Value)
    }    
}
ArmorSwapFreqChanged(*)
{
    global
    ArmorSwapFreq := MUpDown_ASFreq.Value
    SetTimer ArmorSwapLoop, ArmorSwapFreq
}
ArmorSwapTrigThreshChanged(*)
{
    global
    ArmorSwapTrigThresh := MUpDown_ASTrigThresh.Value
}
ArmorSwapDetectionVariationChanged(*)
{
    global
    ArmorSwapDetectionVariation := MUpDown_ASDTVARTN.Value
}
ArmorSwapDelayChanged(*)
{
    global
    ArmorSwapDelay := MUpDown_ASDelay.Value
}
ArmorSwapVertChanged(*)
{
    global
    temp_Skip_ASResize := Skip_ASResize
    Skip_ASResize := 0
    AS_Gui.GetPos( &X, &Y )
    If (MUpDown_ASVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_ASVert.Value < 0) {
        Y := Y + 1
    }
    AS_Gui.Move( X, Y )
    MUpDown_ASVert.Value := 0
    Skip_ASResize := temp_Skip_ASResize
}
ArmorSwapHorzChanged(*)
{
    global
    temp_Skip_ASResize := Skip_ASResize
    Skip_ASResize := 0
    AS_Gui.GetPos( &X, &Y )
    If (MUpDown_ASHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_ASHorz.Value < 0) {
        X := X - 1
    }
    AS_Gui.Move( X, Y )
    MUpDown_ASHorz.Value := 0
    Skip_ASResize := temp_Skip_ASResize
}

IsValidKey(KeyPress)
{
    Switch KeyPress, "On"
    {
        case "LButton": Return 1
        case "RButton": Return 1
        case "MButton": Return 1
        case "XButton1": Return 1
        case "XButton2": Return 1
        case "WheelDown": Return 1
        case "WheelUp": Return 1
        case "WheelLeft": Return 1
        case "WheelRight": Return 1
        case "CapsLock": Return 1
        case "Space": Return 1
        case "Tab": Return 1
        case "Enter": Return 1
        case "Escape": Return 1
        case "Esc": Return 1
        case "Backspace": Return 1
        case "BS": Return 1
        case "AppsKey": Return 1
        case "PrintScreen": Return 1
        case "Pause": Return 1
        default:
            Switch KeyPress, "On"
            {
                case "ScrollLock": Return 1
                case "CtrlBreak": Return 1
                case "Delete": Return 1
                case "Del": Return 1
                case "Insert": Return 1
                case "Ins": Return 1
                case "Home": Return 1
                case "End": Return 1
                case "PgUp": Return 1
                case "PgDn": Return 1
                case "Up": Return 1
                case "Down": Return 1
                case "Left": Return 1
                case "Right": Return 1
                case "Help": Return 1
                case "Sleep": Return 1
                case "NumLock": Return 1
                default:
                    Switch KeyPress, "On"
                    {
                        case "Numpad0": Return 1
                        case "Numpad1": Return 1
                        case "Numpad2": Return 1
                        case "Numpad3": Return 1
                        case "Numpad4": Return 1
                        case "Numpad5": Return 1
                        case "Numpad6": Return 1
                        case "Numpad7": Return 1
                        case "Numpad8": Return 1
                        case "Numpad9": Return 1
                        case "NumpadDot": Return 1
                        case "NumpadDiv": Return 1
                        case "NumpadMult": Return 1
                        case "NumpadAdd": Return 1
                        case "NumpadSub": Return 1
                        case "NumpadEnter": Return 1
                        case "NumpadIns": Return 1
                        case "NumpadEnd": Return 1
                        case "NumpadDown": Return 1
                        case "NumpadPgDn": Return 1
                        default:
                            Switch KeyPress, "On"
                            {
                                case "NumpadLeft": Return 1
                                case "NumpadClear": Return 1
                                case "NumpadRight": Return 1
                                case "NumpadHome": Return 1
                                case "NumpadUp": Return 1
                                case "NumpadPgUp": Return 1
                                case "NumpadDel": Return 1
                                case "F1": Return 1
                                case "F2": Return 1
                                case "F3": Return 1
                                case "F4": Return 1
                                case "F5": Return 1
                                case "F6": Return 1
                                case "F7": Return 1
                                case "F8": Return 1
                                case "F9": Return 1
                                case "F10": Return 1
                                case "F11": Return 1
                                case "F12": Return 1
                                case "F13": Return 1
                                default:
                                    Switch KeyPress, "On"
                                    {
                                        case "F15": Return 1
                                        case "F16": Return 1
                                        case "F17": Return 1
                                        case "F18": Return 1
                                        case "F19": Return 1
                                        case "F20": Return 1
                                        case "F21": Return 1
                                        case "F22": Return 1
                                        case "F23": Return 1
                                        case "F24": Return 1
                                        case "LWin": Return 1
                                        case "RWin": Return 1
                                        case "Control": Return 1
                                        case "Ctrl": Return 1
                                        case "Alt": Return 1
                                        case "Shift": Return 1
                                        case "LControl": Return 1
                                        case "LCtrl": Return 1
                                        case "RControl": Return 1
                                        case "RCtrl": Return 1
                                        default:
                                            Switch KeyPress, "On"
                                            {
                                                case "LShift": Return 1
                                                case "RShift": Return 1
                                                case "LAlt": Return 1
                                                case "RAlt": Return 1
                                                case "Browser_Back": Return 1
                                                case "Browser_Forward": Return 1
                                                case "Browser_Refresh": Return 1
                                                case "Browser_Stop": Return 1
                                                case "Browser_Search": Return 1
                                                case "Browser_Favorites": Return 1
                                                case "Browser_Home": Return 1
                                                case "Volume_Mute": Return 1
                                                case "Volume_Down": Return 1
                                                case "Volume_Up": Return 1
                                                case "Media_Next": Return 1
                                                case "Media_Prev": Return 1
                                                case "Media_Stop": Return 1
                                                case "Media_Play_Pause": Return 1
                                                case "Launch_Mail": Return 1
                                                case "Launch_Media": Return 1
                                                default:
                                                    
                                            }
                                    }
                            }
                    }
            }
    }
    Return 0
}

IsModifierKey(ModifierKey)
{
    Switch ModifierKey, "On"
    {
        case "+": Return 1
        case "^": Return 1
        case "!": Return 1
    }
    Return 0
}

ConvertHotKeyToKeyPress(HotK)
{
    If (StrLen(HotK) > 0)
    {
        TmpStr := HotK
        StrBuilder := ""
        StrPointer := 0
        While (IsModifierKey(SubStr(TmpStr, 1, 1)))
        {
            ModifierKey := SubStr(TmpStr, 1, 1)
            TmpStr := SubStr(TmpStr, 2)
            If (ModifierKey = "+") ; shift
            {
                If (StrPointer > 0)
                {
                    StrBuilder := SubStr(StrBuilder, 1, StrPointer) . "{Shift down}{Shift up}" . SubStr(StrBuilder, StrPointer + 1)
                } 
                Else
                {
                    StrBuilder := StrBuilder . "{Shift down}{Shift up}"
                }
                StrPointer := StrPointer + 12
            } 
            Else If (ModifierKey = "^") ; ctrl
            {
                If (StrPointer > 0)
                {
                    StrBuilder := SubStr(StrBuilder, 1, StrPointer) . "{Ctrl down}{Ctrl up}" . SubStr(StrBuilder, StrPointer + 1)
                } 
                Else
                {
                    StrBuilder := StrBuilder . "{Ctrl down}{Ctrl up}"
                }
                StrPointer := StrPointer + 11
            }
            Else If (ModifierKey = "!") ; alt
            {
                If (StrPointer > 0)
                {
                    StrBuilder := SubStr(StrBuilder, 1, StrPointer) . "{Alt down}{Alt up}" . SubStr(StrBuilder, StrPointer + 1)
                } 
                Else
                {
                    StrBuilder := StrBuilder . "{Alt down}{Alt up}"
                }
                StrPointer := StrPointer + 10
            }
        }
        If (StrPointer > 0)
        {
            If (StrLen(TmpStr) > 0)
            {
                StrBuilder := SubStr(StrBuilder, 1, StrPointer) . "{" . TmpStr . "}" . SubStr(StrBuilder, StrPointer + 1)
            }
            Else
            {
                StrBuilder := SubStr(StrBuilder, 1, StrPointer) . TmpStr . SubStr(StrBuilder, StrPointer + 1)
            }
        } 
        Else
        {
            StrBuilder := "{" . TmpStr . "}"
        }
        ToolTip "KeyPress String: " . StrBuilder
        SetTimer () => ToolTip(), -4000, 10000
        Return StrBuilder
    }
}


OnExit ExitFunc

ExitFunc(ExitReason, ExitCode)
{
    Send "{Right up}{F9 up}{F8 up}{Shift up}"
}


