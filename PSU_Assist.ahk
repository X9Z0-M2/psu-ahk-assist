#Requires AutoHotkey v2
;@Ahk2Exe-SetVersion 0.0.1.1 

#SingleInstance Force
#MaxThreadsPerHotkey 2
SendMode "Event"

CoordMode "Pixel", "Screen"
SetKeyDelay 35, 25  ; 75ms between keys, 25ms between down/up.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.

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
global Conf := {}
Conf.SettingsFile := "psuassist.conf"
PSUWinTitle := "ahk_exe PSUC.exe"
UseInputLockout := false

global JAG := {}
global JAV := {}
JAG.X := 0
JAG.Y := 0
JAG.XW := 0
JAG.YW := 0
JAG.W := 11
JAG.H := 11
JAV.Enabled := true
JAV.Freq := 1
JAV.Thresh := 3
JAV.Delay := 120
JAV.HotKey := "Right"
JAV.PressKey := ConvertHotKeyToKeyPress(JAV.HotKey)
JAG.SkipGuiResize := 0
JAG.WindowCanMove := 1
JAV.Count := 0

global PCG := {}
global PCV := {}
PCG.X := 0
PCG.Y := 0
PCG.XW := 0
PCG.YW := 0
PCG.MX := 0
PCG.MY := 0
PCG.W := 120
PCG.H := 1
PCV.Enabled := true
PCV.Freq := 200
PCV.PPThresh := 7
PCV.TrigThresh := 2
PCV.Delay := 0
PCV.HotKey := "+F9"
PCV.PressKey := ConvertHotKeyToKeyPress(PCV.HotKey)
PCV.BarPercent := -1
PCV.Count := 0
PCG.SkipGuiResize := 0
PCG.WindowCanMove := 0

global THG := {}
global THV := {}
THG.X := 0
THG.Y := 0
THG.XW := 0
THG.YW := 0
THG.MX := 0
THG.MY := 0
THG.W := 130
THG.H := 1
THV.Enabled := true
THV.Count := 0
THV.Freq := 150
THV.HPThresh := 60
THV.TrigThresh := 2
THV.Delay := 0
THV.BarPercent := -1
THV.HotKey := "+F8"
THV.PressKey := ConvertHotKeyToKeyPress(THV.HotKey)
THG.SkipGuiResize := 0
THG.WindowCanMove := 1

global ASG := {}
global ASV := {}
ASG.X := 0
ASG.Y := 0
ASG.XW := 0
ASG.YW := 0
ASG.MX := 0
ASG.MY := 0
ASG.W := 16
ASG.H := 1
ASV.Enabled := true
ASV.Count := 0
ASV.Freq := 225
ASV.DetectionVariation := 12 ; can be 0-255
ASV.TrigThresh := 2
ASV.Delay := 0
ASV.CanChange := 1
ASV.DurationBeforeNextChange := 8000 ; 15 seconds before can swap again
ASV.ElemType := 0 ; 0=neutral, 1=fire, 2=ice, 3=lightning, 4=ground, 5=dark, 6=light
ASV.LastElemType := ASV.ElemType
ASV.LastElemForCount := ASV.ElemType
ASV.Color := []
ASV.HotKey := []
ASV.PressKey := []
ASV.TypeText := []
ASV.TitleText := []
ASV.ColorLookup :=    Map("Fire",1, "Ice",2, "Lightning",3, "Ground",4, "Dark",5, "Light",6)
ASV.ColorRevLookup := Map(1,"Fire", 2,"Ice", 3,"Lightning", 4,"Ground", 5,"Dark", 6,"Light")
ASV.Color.InsertAt( ASV.ColorLookup["Fire"],      0xFE7878 )
ASV.Color.InsertAt( ASV.ColorLookup["Ice"],       0x7272FF )
ASV.Color.InsertAt( ASV.ColorLookup["Lightning"], 0xDADA2B )
ASV.Color.InsertAt( ASV.ColorLookup["Ground"],    0xE47D00 )
ASV.Color.InsertAt( ASV.ColorLookup["Dark"],      0x653865 )
ASV.Color.InsertAt( ASV.ColorLookup["Light"],     0xFFC7AD )
ASV.HotKey.InsertAt( ASV.ColorLookup["Fire"],      "+F1" )
ASV.HotKey.InsertAt( ASV.ColorLookup["Ice"],       "+F2" )
ASV.HotKey.InsertAt( ASV.ColorLookup["Lightning"], "+F3" )
ASV.HotKey.InsertAt( ASV.ColorLookup["Ground"],    "+F4" )
ASV.HotKey.InsertAt( ASV.ColorLookup["Dark"],      "+F5" )
ASV.HotKey.InsertAt( ASV.ColorLookup["Light"],     "+F6" )
ASV.TypeText.InsertAt( ASV.ColorLookup["Fire"],      "/sl f" )
ASV.TypeText.InsertAt( ASV.ColorLookup["Ice"],       "/sl i" )
ASV.TypeText.InsertAt( ASV.ColorLookup["Lightning"], "/sl t" )
ASV.TypeText.InsertAt( ASV.ColorLookup["Ground"],    "/sl e" )
ASV.TypeText.InsertAt( ASV.ColorLookup["Dark"],      "/sl d" )
ASV.TypeText.InsertAt( ASV.ColorLookup["Light"],     "/sl l" )
ASV.TitleText.InsertAt( ASV.ColorLookup["Fire"],      "AS FIRE" )
ASV.TitleText.InsertAt( ASV.ColorLookup["Ice"],       "AS ICE" )
ASV.TitleText.InsertAt( ASV.ColorLookup["Lightning"], "AS LIGHTNING" )
ASV.TitleText.InsertAt( ASV.ColorLookup["Ground"],    "AS GROUND" )
ASV.TitleText.InsertAt( ASV.ColorLookup["Dark"],      "AS DARK" )
ASV.TitleText.InsertAt( ASV.ColorLookup["Light"],     "AS LIGHT" )
Loop 6
{
    ASV.PressKey.InsertAt( A_Index, ConvertHotKeyToKeyPress(ASV.HotKey[A_Index]) )
}
ASV.InputMode := 1 ; 1= hotkey based, 2= string literal input
ASV.CurDetectColorIdx := 1
ASV.DetectionState := 0 ; 0=new search, 1=recheck find
ASV.NewDetectTries := 2
ASG.SkipGuiResize := 0
ASG.WindowCanMove := 1

global WCG := {}
global WCV := {}
WCG.X := 0
WCG.Y := 0
WCG.XW := 0
WCG.YW := 0
WCG.MX := 0
WCG.MY := 0
WCG.W := 16
WCG.H := 1
WCV.Enabled := true
WCV.Count := 0
WCV.Freq := 225
WCV.DetectionVariation := 5 ; can be 0-255
WCV.TrigThresh := 2
WCV.Delay := 0
WCV.CanChange := 1
WCV.DurationBeforeNextChange := 1550 ; millisecs  before can swap again 
WCV.ElemType := 0 ; 0=neutral, 1=fire, 2=ice, 3=lightning, 4=ground, 5=dark, 6=light
WCV.LastElemType := WCV.ElemType
WCV.LastElemForCount := WCV.ElemType
WCV.Color := []
WCV.HotKey := []
WCV.PressKey := []
WCV.TypeText := []
WCV.TitleText := []
WCV.ColorLookup :=    Map("Fire",1, "Ice",2, "Lightning",3, "Ground",4, "Dark",5, "Light",6)
WCV.ColorRevLookup := Map(1,"Fire", 2,"Ice", 3,"Lightning", 4,"Ground", 5,"Dark", 6,"Light")
WCV.ColorOppositeLookup := Map(1,2, 2,1, 3,4, 4,3, 5,6, 6,5)
WCV.Color.InsertAt( WCV.ColorLookup["Fire"],      0xFE7878 )
WCV.Color.InsertAt( WCV.ColorLookup["Ice"],       0x7D7DFF )
WCV.Color.InsertAt( WCV.ColorLookup["Lightning"], 0xFFFF32 )
WCV.Color.InsertAt( WCV.ColorLookup["Ground"],    0xFF8C00 )
WCV.Color.InsertAt( WCV.ColorLookup["Dark"],      0xFF8CFF )
WCV.Color.InsertAt( WCV.ColorLookup["Light"],     0xFFCDB4 )
WCV.HotKey.InsertAt( WCV.ColorLookup["Fire"],      "+F7" )
WCV.HotKey.InsertAt( WCV.ColorLookup["Ice"],       "+F8" )
WCV.HotKey.InsertAt( WCV.ColorLookup["Lightning"], "+F9" )
WCV.HotKey.InsertAt( WCV.ColorLookup["Ground"],    "+F10" )
WCV.HotKey.InsertAt( WCV.ColorLookup["Dark"],      "+F11" )
WCV.HotKey.InsertAt( WCV.ColorLookup["Light"],     "+F12" )
WCV.TypeText.InsertAt( WCV.ColorLookup["Fire"],      "/wp 1" )
WCV.TypeText.InsertAt( WCV.ColorLookup["Ice"],       "/wp 2" )
WCV.TypeText.InsertAt( WCV.ColorLookup["Lightning"], "/wp 3" )
WCV.TypeText.InsertAt( WCV.ColorLookup["Ground"],    "/wp 4" )
WCV.TypeText.InsertAt( WCV.ColorLookup["Dark"],      "/wp 5" )
WCV.TypeText.InsertAt( WCV.ColorLookup["Light"],     "/wp 6" )
WCV.TitleText.InsertAt( WCV.ColorLookup["Fire"],      "WC FIRE" )
WCV.TitleText.InsertAt( WCV.ColorLookup["Ice"],       "WC ICE" )
WCV.TitleText.InsertAt( WCV.ColorLookup["Lightning"], "WC LIGHTNING" )
WCV.TitleText.InsertAt( WCV.ColorLookup["Ground"],    "WC GROUND" )
WCV.TitleText.InsertAt( WCV.ColorLookup["Dark"],      "WC DARK" )
WCV.TitleText.InsertAt( WCV.ColorLookup["Light"],     "WC LIGHT" )
Loop 6
{
    WCV.PressKey.InsertAt( A_Index, ConvertHotKeyToKeyPress(WCV.HotKey[A_Index]) )
}
WCV.InputMode := 2 ; 1= hotkey based, 2= string literal input
WCV.CurDetectColorIdx := 1
WCV.DetectionState := 0 ; 0=new search, 1=recheck find
WCV.NewDetectTries := 2
WCG.SkipGuiResize := 0
WCG.WindowCanMove := 1


; ; TODO: enable and finish settings file loading
LoadSettingsIni



; ; Create custom gui to control all script components
Menu_Gui := Gui("+AlwaysOnTop +MinSize50x50 +MaxSize900x900 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu -DPIScale", "PSU AIO Assistant")
Menu_Gui.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
FileMenu := Menu()
FileMenu.Add("&Save", SaveSettingsIni)
MyMenuBar := MenuBar()
MyMenuBar.Add("&File", FileMenu)
Menu_Gui.MenuBar := MyMenuBar

MButton_StartPSU := Menu_Gui.Add("Button", , "Start PSU")
MButton_StartPSU.OnEvent("Click", StartPSU)
MButton_RunPSUFR := Menu_Gui.Add("Button", "YS", "Run PSUFR")
MButton_RunPSUFR.OnEvent("Click", RunPSUFR)

; MButton_PCUse := Menu_Gui.Add("Button", "XS vPhotonChargeUse", "Use Photon Charge")
; MButton_PCUse.OnEvent("Click", PhotonChargeUse)
MProgress_JA  := Menu_Gui.Add("Progress", "YS29 XS0 w100 h10 c0x3A89DB Smooth vJustAttackProgress", -1)
MProgress_JAC := Menu_Gui.Add("Progress", "YS29 XS103 w20 h10 c0x666666 Smooth vJustAttackCurrent", -1)
MCheckBox_JAE := Menu_Gui.Add("CheckBox", "YS29 XS126 w20 h10 c0x666666 vJustAttackEnable", -1)
MCheckBox_JAE.OnEvent("Click", JAE_ToggleFeatureEnabled)
MCheckBox_JAE.Value := JAV.Enabled = true ? 1 : 0

MProgress_PC  := Menu_Gui.Add("Progress", "YS47 XS0 w100 h16 c0x3A89DB Smooth vPhotonChargeProgress", -1)
MProgress_PCC := Menu_Gui.Add("Progress", "YS47 XS103 w20 h16 c0x666666 Smooth vPhotonChargeCurrent", -1)
MCheckBox_PCE := Menu_Gui.Add("CheckBox", "YS47 XS126 w20 h10 c0x666666 vPhotonChargeEnable", -1)
MCheckBox_PCE.OnEvent("Click", PCE_ToggleFeatureEnabled)
MCheckBox_PCE.Value := PCV.Enabled = true ? 1 : 0

MProgress_TH  := Menu_Gui.Add("Progress", "YS68 XS0 w100 h16 c0x5BD847 Smooth vTrimateHealProgress", -1)
MProgress_THC := Menu_Gui.Add("Progress", "YS68 XS103 w20 h16 c0x666666 Smooth vTrimateHealCurrent", -1)
MCheckBox_THE := Menu_Gui.Add("CheckBox", "YS68 XS126 w20 h10 c0x666666 vTrimateHealEnable", -1)
MCheckBox_THE.OnEvent("Click", THE_ToggleFeatureEnabled)
MCheckBox_THE.Value := THV.Enabled = true ? 1 : 0

MProgress_AS  := Menu_Gui.Add("Progress", "YS89 XS0 w100 h16 c0x666666 Smooth vArmorSwapProgress", -1)
MProgress_ASC := Menu_Gui.Add("Progress", "YS89 XS103 w20 h16 c0x666666 Smooth vArmorSwapCurrent", -1)
MCheckBox_ASE := Menu_Gui.Add("CheckBox", "YS89 XS126 w20 h10 c0x666666 vArmorSwapEnable", -1)
MCheckBox_ASE.OnEvent("Click", ASE_ToggleFeatureEnabled)
MCheckBox_ASE.Value := ASV.Enabled = true ? 1 : 0

MProgress_WC  := Menu_Gui.Add("Progress", "YS110 XS0 w100 h16 c0x666666 Smooth vWeaponChangeProgress", -1)
MProgress_WCC := Menu_Gui.Add("Progress", "YS110 XS103 w20 h16 c0x666666 Smooth vWeaponChangeCurrent", -1)
MCheckBox_WCE := Menu_Gui.Add("CheckBox", "YS110 XS126 w20 h10 c0x666666 vWeaponChangeEnable", -1)
MCheckBox_WCE.OnEvent("Click", WCE_ToggleFeatureEnabled)
MCheckBox_WCE.Value := WCV.Enabled = true ? 1 : 0

MProgress_JAC.Value := 100
MProgress_PCC.Value := 100
MProgress_THC.Value := 100
MProgress_ASC.Value := 100
MProgress_WCC.Value := 100

MStatusBar_MainStatus := Menu_Gui.Add("StatusBar", "vMainStatusBar", "")

MTab_Settings := Menu_Gui.Add("Tab3","-Wrap XS w130", ["JA","PC","TH","AS","AS Keys","AS Clrs","WC","WC Keys","WC Clrs"])

MTab_Settings.UseTab(1)
MButton_ShowJA := Menu_Gui.Add("Button", "", "Hide JA")
MButton_ShowJA.OnEvent("Click", JAGC_AllowMoveWindow)
MButton_ShowJA := Menu_Gui.Add("Button", "", "Sim JA")
MButton_ShowJA.OnEvent("Click", JAGC_AllowMoveWindow)

Menu_Gui.Add("Text", , "JA Key")
MHotkey_JAPressKey := Menu_Gui.Add("Hotkey", "w110 vJAPressKeyHotkey", JAV.HotKey)
MHotkey_JAPressKey.OnEvent("Change", JAGC_PressKeyChanged)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", JAGC_FreqChanged)
MUpDown_JAFreq := Menu_Gui.Add("UpDown", "vJAFreqUpDown Range1-1000", JAV.Freq)
MUpDown_JAFreq.OnEvent("Change", JAGC_FreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", JAGC_ThreshChanged)
MUpDown_JAThresh := Menu_Gui.Add("UpDown", "vJAThreshUpDown Range0-50", JAV.Thresh)
MUpDown_JAThresh.OnEvent("Change", JAGC_ThreshChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", JAGC_DelayChanged)
MUpDown_JADelay :=Menu_Gui.Add("UpDown", "vJADelayUpDown Range0-500", JAV.Delay)
MUpDown_JADelay.OnEvent("Change", JAGC_DelayChanged)

Menu_Gui.Add("Text", , "Position Detect Pixel")
MUpDown_JAVert := Menu_Gui.Add("UpDown", "-16 H40 vJAVertUpDown Range-1-1", 0)
MUpDown_JAVert.OnEvent("Change", JAGC_VertChanged)
MUpDown_JAHorz := Menu_Gui.Add("UpDown", "XS35 W45 vJAVHorzUpDown Horz Range-1-1", 0)
MUpDown_JAHorz.OnEvent("Change", JAGC_HorzChanged)

MTab_Settings.UseTab(2)
MButton_ShowPC := Menu_Gui.Add("Button", "", "Hide PC")
MButton_ShowPC.OnEvent("Click", PCGC_AllowMoveWindow)

Menu_Gui.Add("Text", , "PC Key")
MHotkey_PCPressKey := Menu_Gui.Add("Hotkey", "w110 vPCPressKeyHotkey", PCV.HotKey)
MHotkey_PCPressKey.OnEvent("Change", PCGC_PressKeyChanged)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", PCGC_FreqChanged)
MUpDown_PCFreq := Menu_Gui.Add("UpDown", "vPCFreqUpDown Range1-1000", PCV.Freq)
MUpDown_PCFreq.OnEvent("Change", PCGC_FreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", PCGC_TrigThreshChanged)
MUpDown_PCTrigThresh := Menu_Gui.Add("UpDown", "vPCTrigThreshUpDown Range0-50", PCV.TrigThresh)
MUpDown_PCTrigThresh.OnEvent("Change", PCGC_TrigThreshChanged)
Menu_Gui.Add("Text", , "PP Threshold %")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", PCGC_PPThreshChanged)
MUpDown_PCPPThresh := Menu_Gui.Add("UpDown", "vPCPPThreshUpDown Range0-50", PCV.PPThresh)
MUpDown_PCPPThresh.OnEvent("Change", PCGC_PPThreshChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", PCGC_DelayChanged)
MUpDown_PCDelay :=Menu_Gui.Add("UpDown", "vPCDelayUpDown Range0-500", PCV.Delay)
MUpDown_PCDelay.OnEvent("Change", PCGC_DelayChanged)

Menu_Gui.Add("Text", , "Position Detect Line")
MUpDown_PCVert := Menu_Gui.Add("UpDown", "-16 H40 vPCVertUpDown Range-1-1", 0)
MUpDown_PCVert.OnEvent("Change", PCGC_VertChanged)
MUpDown_PCHorz := Menu_Gui.Add("UpDown", "XS35 W45 vPCVHorzUpDown Horz Range-1-1", 0)
MUpDown_PCHorz.OnEvent("Change", PCGC_HorzChanged)

MTab_Settings.UseTab(3)
MButton_ShowTH := Menu_Gui.Add("Button", "", "Hide TH")
MButton_ShowTH.OnEvent("Click", THGC_AllowMoveWindow)

Menu_Gui.Add("Text", , "TH Key")
MHotkey_THPressKey := Menu_Gui.Add("Hotkey", "w110 vTHPressKeyHotkey", THV.HotKey)
MHotkey_THPressKey.OnEvent("Change", THGC_PressKeyChanged)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", THGC_FreqChanged)
MUpDown_THFreq := Menu_Gui.Add("UpDown", "vTHFreqUpDown Range1-1000", THV.Freq)
MUpDown_THFreq.OnEvent("Change", THGC_FreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", THGC_TrigThreshChanged)
MUpDown_THTrigThresh := Menu_Gui.Add("UpDown", "vTHTrigThreshUpDown Range0-50", THV.TrigThresh)
MUpDown_THTrigThresh.OnEvent("Change", THGC_TrigThreshChanged)

Menu_Gui.Add("Text", , "HP Threshold %")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", THGC_HPThreshChanged)
MUpDown_THHPThresh := Menu_Gui.Add("UpDown", "vTHHPThreshUpDown Range0-100", THV.HPThresh)
MUpDown_THHPThresh.OnEvent("Change", THGC_HPThreshChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", THGC_DelayChanged)
MUpDown_THDelay :=Menu_Gui.Add("UpDown", "vTHDelayUpDown Range0-500", THV.Delay)
MUpDown_THDelay.OnEvent("Change", THGC_DelayChanged)

Menu_Gui.Add("Text", , "Position Detect Line")
MUpDown_THVert := Menu_Gui.Add("UpDown", "-16 H40 vTHVertUpDown Range-1-1", 0)
MUpDown_THVert.OnEvent("Change", THGC_VertChanged)
MUpDown_THHorz := Menu_Gui.Add("UpDown", "Y+6 XS35 W45 vTHVHorzUpDown Horz Range-1-1", 0)
MUpDown_THHorz.OnEvent("Change", THGC_HorzChanged)

MTab_Settings.UseTab(4)
MButton_ShowAS := Menu_Gui.Add("Button", "", "Hide AS")
MButton_ShowAS.OnEvent("Click", ArmorSwapAllowMoveWindow)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", ASGC_FreqChanged)
MUpDown_ASFreq := Menu_Gui.Add("UpDown", "vASFreqUpDown Range1-1000", ASV.Freq)
MUpDown_ASFreq.OnEvent("Change", ASGC_FreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", ASGC_TrigThreshChanged)
MUpDown_ASTrigThresh := Menu_Gui.Add("UpDown", "vASTrigThreshUpDown Range0-50", ASV.TrigThresh)
MUpDown_ASTrigThresh.OnEvent("Change", ASGC_TrigThreshChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", ASGC_DelayChanged)
MUpDown_ASDelay := Menu_Gui.Add("UpDown", "vASDelayUpDown Range0-500", ASV.Delay)
MUpDown_ASDelay.OnEvent("Change", ASGC_DelayChanged)

Menu_Gui.Add("Text", , "Time Before Next Swap")
Menu_Gui.Add("Edit", "w60").OnEvent("Change", ASGC_DurationNextChgChanged)
MUpDown_ASDurationNextChg := Menu_Gui.Add("UpDown", "vASDurationNextChgUpDown Range0-60000", ASV.DurationBeforeNextChange)
MUpDown_ASDurationNextChg.OnEvent("Change", ASGC_DurationNextChgChanged)

Menu_Gui.Add("Text", , "Position Detect Line")
MUpDown_ASVert := Menu_Gui.Add("UpDown", "-16 H40 vASVertUpDown Range-1-1", 0)
MUpDown_ASVert.OnEvent("Change", ASGC_VertChanged)
MUpDown_ASHorz := Menu_Gui.Add("UpDown", "Y+6 XS35 W45 vASVHorzUpDown Horz Range-1-1", 0)
MUpDown_ASHorz.OnEvent("Change", ASGC_HorzChanged)

MTab_Settings.UseTab(5)
Menu_Gui.Add("Text", , "Input Mode")
MDDList_ASPressKeyInputMode := Menu_Gui.Add("DropDownList", "w75 Choose" . ASV.InputMode, ["HotKey","TypeText"])
MDDList_ASPressKeyInputMode.OnEvent("Change", ASGC_PressKeyInputModeChanged)
Menu_Gui.Add("Text", "Section", "FIRE")
MHotkey_ASPressKeyElemFire := Menu_Gui.Add("Hotkey", "YS20 XS w110 vASPressKeyElemFireHotkey", ASV.HotKey[1])
MHotkey_ASPressKeyElemFire.OnEvent("Change", ASGC_ElemFirePressKeyChanged)
MText_ASTypeInputElemFire := Menu_Gui.Add("Edit", "YS20 XS w110 vASTypeInputElemFireText", ASV.TypeText[1])
MText_ASTypeInputElemFire.OnEvent("Change", ASGC_ElemFireTypeInputChanged)
Menu_Gui.Add("Text", "Section", "ICE")
MHotkey_ASPressKeyElemIce := Menu_Gui.Add("Hotkey", "YS20 XS w110 vASPressKeyElemIceHotkey", ASV.HotKey[2])
MHotkey_ASPressKeyElemIce.OnEvent("Change", ASGC_ElemIcePressKeyChanged)
MText_ASTypeInputElemIce := Menu_Gui.Add("Edit", "YS20 XS w110 vASTypeInputElemIceText", ASV.TypeText[2])
MText_ASTypeInputElemIce.OnEvent("Change", ASGC_ElemIceTypeInputChanged)
Menu_Gui.Add("Text", "Section", "LIGHTNING")
MHotkey_ASPressKeyElemLightning := Menu_Gui.Add("Hotkey", "YS20 XS w110 vASPressKeyElemLightningHotkey", ASV.HotKey[3])
MHotkey_ASPressKeyElemLightning.OnEvent("Change", ASGC_ElemLightningPressKeyChanged)
MText_ASTypeInputElemLightning := Menu_Gui.Add("Edit", "YS20 XS w110 vASTypeInputElemLightningText", ASV.TypeText[3])
MText_ASTypeInputElemLightning.OnEvent("Change", ASGC_ElemLightningTypeInputChanged)
Menu_Gui.Add("Text", "Section", "GROUND")
MHotkey_ASPressKeyElemGround := Menu_Gui.Add("Hotkey", "YS20 XS w110 vASPressKeyElemGroundHotkey", ASV.HotKey[4])
MHotkey_ASPressKeyElemGround.OnEvent("Change", ASGC_ElemGroundPressKeyChanged)
MText_ASTypeInputElemGround := Menu_Gui.Add("Edit", "YS20 XS w110 vASTypeInputElemGroundText", ASV.TypeText[4])
MText_ASTypeInputElemGround.OnEvent("Change", ASGC_ElemGroundTypeInputChanged)
Menu_Gui.Add("Text", "Section", "DARK")
MHotkey_ASPressKeyElemDark := Menu_Gui.Add("Hotkey", "YS20 XS w110 vASPressKeyElemDarkHotkey", ASV.HotKey[5])
MHotkey_ASPressKeyElemDark.OnEvent("Change", ASGC_ElemDarkPressKeyChanged)
MText_ASTypeInputElemDark := Menu_Gui.Add("Edit", "YS20 XS w110 vASTypeInputElemDarkText", ASV.TypeText[5])
MText_ASTypeInputElemDark.OnEvent("Change", ASGC_ElemDarkTypeInputChanged)
Menu_Gui.Add("Text", "Section", "LIGHT")
MHotkey_ASPressKeyElemLight := Menu_Gui.Add("Hotkey", "YS20 XS w110 vASPressKeyElemLightHotkey", ASV.HotKey[6])
MHotkey_ASPressKeyElemLight.OnEvent("Change", ASGC_ElemLightPressKeyChanged)
MText_ASTypeInputElemLight := Menu_Gui.Add("Edit", "YS20 XS w110 vASTypeInputElemLightText", ASV.TypeText[6])
MText_ASTypeInputElemLight.OnEvent("Change", ASGC_ElemLightTypeInputChanged)
        
ASGC_PressKeyInputModeChanged()
ASGC_PressKeyInputModeChanged(*)
{
    global
    If (MDDList_ASPressKeyInputMode.Value = 1)
    {
        MText_ASTypeInputElemFire.Visible := false
        MText_ASTypeInputElemIce.Visible := false
        MText_ASTypeInputElemLightning.Visible := false
        MText_ASTypeInputElemGround.Visible := false
        MText_ASTypeInputElemDark.Visible := false
        MText_ASTypeInputElemLight.Visible := false
        
        MHotkey_ASPressKeyElemFire.Visible := true
        MHotkey_ASPressKeyElemIce.Visible := true
        MHotkey_ASPressKeyElemLightning.Visible := true
        MHotkey_ASPressKeyElemGround.Visible := true
        MHotkey_ASPressKeyElemDark.Visible := true
        MHotkey_ASPressKeyElemLight.Visible := true
        ASV.InputMode := 1
    }
    Else If (MDDList_ASPressKeyInputMode.Value = 2)
    {
        MHotkey_ASPressKeyElemFire.Visible := false
        MHotkey_ASPressKeyElemIce.Visible := false
        MHotkey_ASPressKeyElemLightning.Visible := false
        MHotkey_ASPressKeyElemGround.Visible := false
        MHotkey_ASPressKeyElemDark.Visible := false
        MHotkey_ASPressKeyElemLight.Visible := false

        MText_ASTypeInputElemFire.Visible := true
        MText_ASTypeInputElemIce.Visible := true
        MText_ASTypeInputElemLightning.Visible := true
        MText_ASTypeInputElemGround.Visible := true
        MText_ASTypeInputElemDark.Visible := true
        MText_ASTypeInputElemLight.Visible := true
        ASV.InputMode := 2
    }
}

MTab_Settings.UseTab(6)
Menu_Gui.Add("Text", , "Detect Variation 0-255")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", ASGC_DetectionVariationChanged)
MUpDown_ASDTVARTN := Menu_Gui.Add("UpDown", "vASHPDetectionVariationUpDown Range0-255", ASV.DetectionVariation)
MUpDown_ASDTVARTN.OnEvent("Change", ASGC_DetectionVariationChanged)

MidColorWidth := 20
MidColorPos := 75
MinColorWidth := 10
MinColorPos := MidColorPos - MinColorWidth + 1
MaxColorWidth := 10
MaxColorPos := MidColorPos + MidColorWidth - 1
ASG.ClrChgElementMax := [1,2,3,4,5,6]
ASG.ClrChgElementCur := [1,2,3,4,5,6]
ASG.ClrChgElementMin := [1,2,3,4,5,6]
Menu_Gui.Add("Text", "Section", "FIRE")
ASG.ClrChgElementMax[1] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorFireElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[1],ASV.DetectionVariation), -1)
ASG.ClrChgElementMax[1].Value := 100
ASG.ClrChgElementCur[1] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorFireElement c" . Format("{:X}", ASV.Color[1]), -1)
ASG.ClrChgElementCur[1].Value := 100
ASG.ClrChgElementMin[1] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorFireElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[1],ASV.DetectionVariation), -1)
ASG.ClrChgElementMin[1].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ASGC_RedCompElemFireChanged)
MUpDown_ASColorRElemFire := Menu_Gui.Add("UpDown", "vASColorRElemFireUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[1]))
MUpDown_ASColorRElemFire.OnEvent("Change", ASGC_RedCompElemFireChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ASGC_GreenCompElemFireChanged)
MUpDown_ASColorGElemFire := Menu_Gui.Add("UpDown", "vASColorGElemFireUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[1]))
MUpDown_ASColorGElemFire.OnEvent("Change", ASGC_GreenCompElemFireChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ASGC_BlueCompElemFireChanged)
MUpDown_ASColorBElemFire := Menu_Gui.Add("UpDown", "vASColorBElemFireUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[1]))
MUpDown_ASColorBElemFire.OnEvent("Change", ASGC_BlueCompElemFireChanged)

Menu_Gui.Add("Text", "Section XS", "ICE")
ASG.ClrChgElementMax[2] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorIceElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[2],ASV.DetectionVariation), -1)
ASG.ClrChgElementMax[2].Value := 100
ASG.ClrChgElementCur[2] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorIceElement c" . Format("{:X}", ASV.Color[2]), -1)
ASG.ClrChgElementCur[2].Value := 100
ASG.ClrChgElementMin[2] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorIceElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[2],ASV.DetectionVariation), -1)
ASG.ClrChgElementMin[2].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ASGC_RedCompElemIceChanged)
MUpDown_ASColorRElemIce := Menu_Gui.Add("UpDown", "vASColorRElemIceUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[2]))
MUpDown_ASColorRElemIce.OnEvent("Change", ASGC_RedCompElemIceChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ASGC_GreenCompElemIceChanged)
MUpDown_ASColorGElemIce := Menu_Gui.Add("UpDown", "vASColorGElemIceUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[2]))
MUpDown_ASColorGElemIce.OnEvent("Change", ASGC_GreenCompElemIceChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ASGC_BlueCompElemIceChanged)
MUpDown_ASColorBElemIce := Menu_Gui.Add("UpDown", "vASColorBElemIceUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[2]))
MUpDown_ASColorBElemIce.OnEvent("Change", ASGC_BlueCompElemIceChanged)

Menu_Gui.Add("Text", "Section XS", "LIGHTNING")
ASG.ClrChgElementMax[3] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorLightningElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[3],ASV.DetectionVariation), -1)
ASG.ClrChgElementMax[3].Value := 100
ASG.ClrChgElementCur[3] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorLightningElement c" . Format("{:X}", ASV.Color[3]), -1)
ASG.ClrChgElementCur[3].Value := 100
ASG.ClrChgElementMin[3] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorLightningElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[3],ASV.DetectionVariation), -1)
ASG.ClrChgElementMin[3].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ASGC_RedCompElemLightningChanged)
MUpDown_ASColorRElemLightning := Menu_Gui.Add("UpDown", "vASColorRElemLightningUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[3]))
MUpDown_ASColorRElemLightning.OnEvent("Change", ASGC_RedCompElemLightningChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ASGC_GreenCompElemLightningChanged)
MUpDown_ASColorGElemLightning := Menu_Gui.Add("UpDown", "vASColorGElemLightningUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[3]))
MUpDown_ASColorGElemLightning.OnEvent("Change", ASGC_GreenCompElemLightningChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ASGC_BlueCompElemLightningChanged)
MUpDown_ASColorBElemLightning := Menu_Gui.Add("UpDown", "vASColorBElemLightningUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[3]))
MUpDown_ASColorBElemLightning.OnEvent("Change", ASGC_BlueCompElemLightningChanged)

Menu_Gui.Add("Text", "Section XS", "GROUND")
ASG.ClrChgElementMax[4] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorGroundElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[4],ASV.DetectionVariation), -1)
ASG.ClrChgElementMax[4].Value := 100
ASG.ClrChgElementCur[4] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorGroundElement c" . Format("{:X}", ASV.Color[4]), -1)
ASG.ClrChgElementCur[4].Value := 100
ASG.ClrChgElementMin[4] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorGroundElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[4],ASV.DetectionVariation), -1)
ASG.ClrChgElementMin[4].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ASGC_RedCompElemGroundChanged)
MUpDown_ASColorRElemGround := Menu_Gui.Add("UpDown", "vASColorRElemGroundUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[4]))
MUpDown_ASColorRElemGround.OnEvent("Change", ASGC_RedCompElemGroundChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ASGC_GreenCompElemGroundChanged)
MUpDown_ASColorGElemGround := Menu_Gui.Add("UpDown", "vASColorGElemGroundUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[4]))
MUpDown_ASColorGElemGround.OnEvent("Change", ASGC_GreenCompElemGroundChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ASGC_BlueCompElemGroundChanged)
MUpDown_ASColorBElemGround := Menu_Gui.Add("UpDown", "vASColorBElemGroundUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[4]))
MUpDown_ASColorBElemGround.OnEvent("Change", ASGC_BlueCompElemGroundChanged)

Menu_Gui.Add("Text", "Section XS", "DARK")
ASG.ClrChgElementMax[5] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorDarkElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[5],ASV.DetectionVariation), -1)
ASG.ClrChgElementMax[5].Value := 100
ASG.ClrChgElementCur[5] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorDarkElement c" . Format("{:X}", ASV.Color[5]), -1)
ASG.ClrChgElementCur[5].Value := 100
ASG.ClrChgElementMin[5] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorDarkElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[5],ASV.DetectionVariation), -1)
ASG.ClrChgElementMin[5].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ASGC_RedCompElemDarkChanged)
MUpDown_ASColorRElemDark := Menu_Gui.Add("UpDown", "vASColorRElemDarkUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[5]))
MUpDown_ASColorRElemDark.OnEvent("Change", ASGC_RedCompElemDarkChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ASGC_GreenCompElemDarkChanged)
MUpDown_ASColorGElemDark := Menu_Gui.Add("UpDown", "vASColorGElemDarkUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[5]))
MUpDown_ASColorGElemDark.OnEvent("Change", ASGC_GreenCompElemDarkChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ASGC_BlueCompElemDarkChanged)
MUpDown_ASColorBElemDark := Menu_Gui.Add("UpDown", "vASColorBElemDarkUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[5]))
MUpDown_ASColorBElemDark.OnEvent("Change", ASGC_BlueCompElemDarkChanged)

Menu_Gui.Add("Text", "Section XS", "LIGHT")
ASG.ClrChgElementMax[6] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorLightElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[6],ASV.DetectionVariation), -1)
ASG.ClrChgElementMax[6].Value := 100
ASG.ClrChgElementCur[6] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorLightElement c" . Format("{:X}", ASV.Color[6]), -1)
ASG.ClrChgElementCur[6].Value := 100
ASG.ClrChgElementMin[6] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorLightElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[6],ASV.DetectionVariation), -1)
ASG.ClrChgElementMin[6].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ASGC_RedCompElemLightChanged)
MUpDown_ASColorRElemLight := Menu_Gui.Add("UpDown", "vASColorRElemLightUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[6]))
MUpDown_ASColorRElemLight.OnEvent("Change", ASGC_RedCompElemLightChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ASGC_GreenCompElemLightChanged)
MUpDown_ASColorGElemLight := Menu_Gui.Add("UpDown", "vASColorGElemLightUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[6]))
MUpDown_ASColorGElemLight.OnEvent("Change", ASGC_GreenCompElemLightChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ASGC_BlueCompElemLightChanged)
MUpDown_ASColorBElemLight := Menu_Gui.Add("UpDown", "vASColorBElemLightUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[6]))
MUpDown_ASColorBElemLight.OnEvent("Change", ASGC_BlueCompElemLightChanged)





MTab_Settings.UseTab(7)
MButton_ShowWC := Menu_Gui.Add("Button", "", "Hide WC")
MButton_ShowWC.OnEvent("Click", WeaponChangeAllowMoveWindow)

Menu_Gui.Add("Text", , "Frequency (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", WCGC_FreqChanged)
MUpDown_WCFreq := Menu_Gui.Add("UpDown", "vWCFreqUpDown Range1-1000", WCV.Freq)
MUpDown_WCFreq.OnEvent("Change", WCGC_FreqChanged)

Menu_Gui.Add("Text", , "Trigger Threshold")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", WCGC_TrigThreshChanged)
MUpDown_WCTrigThresh := Menu_Gui.Add("UpDown", "vWCTrigThreshUpDown Range0-50", WCV.TrigThresh)
MUpDown_WCTrigThresh.OnEvent("Change", WCGC_TrigThreshChanged)

Menu_Gui.Add("Text", , "Input Delay (ms)")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", WCGC_DelayChanged)
MUpDown_WCDelay := Menu_Gui.Add("UpDown", "vWCDelayUpDown Range0-500", WCV.Delay)
MUpDown_WCDelay.OnEvent("Change", WCGC_DelayChanged)

Menu_Gui.Add("Text", , "Time Before Next Swap")
Menu_Gui.Add("Edit", "w60").OnEvent("Change", WCGC_DurationNextChgChanged)
MUpDown_WCDurationNextChg := Menu_Gui.Add("UpDown", "vWCDurationNextChgUpDown Range0-60000", WCV.DurationBeforeNextChange)
MUpDown_WCDurationNextChg.OnEvent("Change", WCGC_DurationNextChgChanged)

Menu_Gui.Add("Text", , "Position Detect Line")
MUpDown_WCVert := Menu_Gui.Add("UpDown", "-16 H40 vWCVertUpDown Range-1-1", 0)
MUpDown_WCVert.OnEvent("Change", WCGC_VertChanged)
MUpDown_WCHorz := Menu_Gui.Add("UpDown", "Y+6 XS35 W45 vWCVHorzUpDown Horz Range-1-1", 0)
MUpDown_WCHorz.OnEvent("Change", WCGC_HorzChanged)

MTab_Settings.UseTab(8)
Menu_Gui.Add("Text", , "Input Mode")
MDDList_WCPressKeyInputMode := Menu_Gui.Add("DropDownList", "w75 Choose" . WCV.InputMode, ["HotKey","TypeText"])
MDDList_WCPressKeyInputMode.OnEvent("Change", WCGC_PressKeyInputModeChanged)
Menu_Gui.Add("Text", "Section", "FIRE")
MHotkey_WCPressKeyElemFire := Menu_Gui.Add("Hotkey", "YS20 XS w110 vWCPressKeyElemFireHotkey", WCV.HotKey[1])
MHotkey_WCPressKeyElemFire.OnEvent("Change", WCGC_ElemFirePressKeyChanged)
MText_WCTypeInputElemFire := Menu_Gui.Add("Edit", "YS20 XS w110 vWCTypeInputElemFireText", WCV.TypeText[1])
MText_WCTypeInputElemFire.OnEvent("Change", WCGC_ElemFireTypeInputChanged)
Menu_Gui.Add("Text", "Section", "ICE")
MHotkey_WCPressKeyElemIce := Menu_Gui.Add("Hotkey", "YS20 XS w110 vWCPressKeyElemIceHotkey", WCV.HotKey[2])
MHotkey_WCPressKeyElemIce.OnEvent("Change", WCGC_ElemIcePressKeyChanged)
MText_WCTypeInputElemIce := Menu_Gui.Add("Edit", "YS20 XS w110 vWCTypeInputElemIceText", WCV.TypeText[2])
MText_WCTypeInputElemIce.OnEvent("Change", WCGC_ElemIceTypeInputChanged)
Menu_Gui.Add("Text", "Section", "LIGHTNING")
MHotkey_WCPressKeyElemLightning := Menu_Gui.Add("Hotkey", "YS20 XS w110 vWCPressKeyElemLightningHotkey", WCV.HotKey[3])
MHotkey_WCPressKeyElemLightning.OnEvent("Change", WCGC_ElemLightningPressKeyChanged)
MText_WCTypeInputElemLightning := Menu_Gui.Add("Edit", "YS20 XS w110 vWCTypeInputElemLightningText", WCV.TypeText[3])
MText_WCTypeInputElemLightning.OnEvent("Change", WCGC_ElemLightningTypeInputChanged)
Menu_Gui.Add("Text", "Section", "GROUND")
MHotkey_WCPressKeyElemGround := Menu_Gui.Add("Hotkey", "YS20 XS w110 vWCPressKeyElemGroundHotkey", WCV.HotKey[4])
MHotkey_WCPressKeyElemGround.OnEvent("Change", WCGC_ElemGroundPressKeyChanged)
MText_WCTypeInputElemGround := Menu_Gui.Add("Edit", "YS20 XS w110 vWCTypeInputElemGroundText", WCV.TypeText[4])
MText_WCTypeInputElemGround.OnEvent("Change", WCGC_ElemGroundTypeInputChanged)
Menu_Gui.Add("Text", "Section", "DARK")
MHotkey_WCPressKeyElemDark := Menu_Gui.Add("Hotkey", "YS20 XS w110 vWCPressKeyElemDarkHotkey", WCV.HotKey[5])
MHotkey_WCPressKeyElemDark.OnEvent("Change", WCGC_ElemDarkPressKeyChanged)
MText_WCTypeInputElemDark := Menu_Gui.Add("Edit", "YS20 XS w110 vWCTypeInputElemDarkText", WCV.TypeText[5])
MText_WCTypeInputElemDark.OnEvent("Change", WCGC_ElemDarkTypeInputChanged)
Menu_Gui.Add("Text", "Section", "LIGHT")
MHotkey_WCPressKeyElemLight := Menu_Gui.Add("Hotkey", "YS20 XS w110 vWCPressKeyElemLightHotkey", WCV.HotKey[6])
MHotkey_WCPressKeyElemLight.OnEvent("Change", WCGC_ElemLightPressKeyChanged)
MText_WCTypeInputElemLight := Menu_Gui.Add("Edit", "YS20 XS w110 vWCTypeInputElemLightText", WCV.TypeText[6])
MText_WCTypeInputElemLight.OnEvent("Change", WCGC_ElemLightTypeInputChanged)
        
WCGC_PressKeyInputModeChanged()
WCGC_PressKeyInputModeChanged(*)
{
    global
    If (MDDList_WCPressKeyInputMode.Value = 1)
    {
        MText_WCTypeInputElemFire.Visible := false
        MText_WCTypeInputElemIce.Visible := false
        MText_WCTypeInputElemLightning.Visible := false
        MText_WCTypeInputElemGround.Visible := false
        MText_WCTypeInputElemDark.Visible := false
        MText_WCTypeInputElemLight.Visible := false
        
        MHotkey_WCPressKeyElemFire.Visible := true
        MHotkey_WCPressKeyElemIce.Visible := true
        MHotkey_WCPressKeyElemLightning.Visible := true
        MHotkey_WCPressKeyElemGround.Visible := true
        MHotkey_WCPressKeyElemDark.Visible := true
        MHotkey_WCPressKeyElemLight.Visible := true
        WCV.InputMode := 1
    }
    Else If (MDDList_WCPressKeyInputMode.Value = 2)
    {
        MHotkey_WCPressKeyElemFire.Visible := false
        MHotkey_WCPressKeyElemIce.Visible := false
        MHotkey_WCPressKeyElemLightning.Visible := false
        MHotkey_WCPressKeyElemGround.Visible := false
        MHotkey_WCPressKeyElemDark.Visible := false
        MHotkey_WCPressKeyElemLight.Visible := false

        MText_WCTypeInputElemFire.Visible := true
        MText_WCTypeInputElemIce.Visible := true
        MText_WCTypeInputElemLightning.Visible := true
        MText_WCTypeInputElemGround.Visible := true
        MText_WCTypeInputElemDark.Visible := true
        MText_WCTypeInputElemLight.Visible := true
        WCV.InputMode := 2
    }
}

MTab_Settings.UseTab(9)
Menu_Gui.Add("Text", , "Detect Variation 0-255")
Menu_Gui.Add("Edit", "w50").OnEvent("Change", WCGC_DetectionVariationChanged)
MUpDown_WCDTVARTN := Menu_Gui.Add("UpDown", "vWCHPDetectionVariationUpDown Range0-255", WCV.DetectionVariation)
MUpDown_WCDTVARTN.OnEvent("Change", WCGC_DetectionVariationChanged)

MidColorWidth := 20
MidColorPos := 75
MinColorWidth := 10
MinColorPos := MidColorPos - MinColorWidth + 1
MaxColorWidth := 10
MaxColorPos := MidColorPos + MidColorWidth - 1
WCG.ClrChgElementMax := [1,2,3,4,5,6]
WCG.ClrChgElementCur := [1,2,3,4,5,6]
WCG.ClrChgElementMin := [1,2,3,4,5,6]
Menu_Gui.Add("Text", "Section", "FIRE")
WCG.ClrChgElementMax[1] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vWCCurrentColorFireElementMax c" . MaxVariationColorFromHexToHexString(WCV.Color[1],WCV.DetectionVariation), -1)
WCG.ClrChgElementMax[1].Value := 100
WCG.ClrChgElementCur[1] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vWCCurrentColorFireElement c" . Format("{:X}", WCV.Color[1]), -1)
WCG.ClrChgElementCur[1].Value := 100
WCG.ClrChgElementMin[1] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vWCCurrentColorFireElementMin c" . MinVariationColorFromHexToHexString(WCV.Color[1],WCV.DetectionVariation), -1)
WCG.ClrChgElementMin[1].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", WCGC_RedCompElemFireChanged)
MUpDown_WCColorRElemFire := Menu_Gui.Add("UpDown", "vWCColorRElemFireUpDown Range0-255", RedComponentFromHexAsRGBInt(WCV.Color[1]))
MUpDown_WCColorRElemFire.OnEvent("Change", WCGC_RedCompElemFireChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", WCGC_GreenCompElemFireChanged)
MUpDown_WCColorGElemFire := Menu_Gui.Add("UpDown", "vWCColorGElemFireUpDown Range0-255", GreenComponentFromHexAsRGBInt(WCV.Color[1]))
MUpDown_WCColorGElemFire.OnEvent("Change", WCGC_GreenCompElemFireChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", WCGC_BlueCompElemFireChanged)
MUpDown_WCColorBElemFire := Menu_Gui.Add("UpDown", "vWCColorBElemFireUpDown Range0-255", BlueComponentFromHexAsRGBInt(WCV.Color[1]))
MUpDown_WCColorBElemFire.OnEvent("Change", WCGC_BlueCompElemFireChanged)

Menu_Gui.Add("Text", "Section XS", "ICE")
WCG.ClrChgElementMax[2] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vWCCurrentColorIceElementMax c" . MaxVariationColorFromHexToHexString(WCV.Color[2],WCV.DetectionVariation), -1)
WCG.ClrChgElementMax[2].Value := 100
WCG.ClrChgElementCur[2] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vWCCurrentColorIceElement c" . Format("{:X}", WCV.Color[2]), -1)
WCG.ClrChgElementCur[2].Value := 100
WCG.ClrChgElementMin[2] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vWCCurrentColorIceElementMin c" . MinVariationColorFromHexToHexString(WCV.Color[2],WCV.DetectionVariation), -1)
WCG.ClrChgElementMin[2].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", WCGC_RedCompElemIceChanged)
MUpDown_WCColorRElemIce := Menu_Gui.Add("UpDown", "vWCColorRElemIceUpDown Range0-255", RedComponentFromHexAsRGBInt(WCV.Color[2]))
MUpDown_WCColorRElemIce.OnEvent("Change", WCGC_RedCompElemIceChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", WCGC_GreenCompElemIceChanged)
MUpDown_WCColorGElemIce := Menu_Gui.Add("UpDown", "vWCColorGElemIceUpDown Range0-255", GreenComponentFromHexAsRGBInt(WCV.Color[2]))
MUpDown_WCColorGElemIce.OnEvent("Change", WCGC_GreenCompElemIceChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", WCGC_BlueCompElemIceChanged)
MUpDown_WCColorBElemIce := Menu_Gui.Add("UpDown", "vWCColorBElemIceUpDown Range0-255", BlueComponentFromHexAsRGBInt(WCV.Color[2]))
MUpDown_WCColorBElemIce.OnEvent("Change", WCGC_BlueCompElemIceChanged)

Menu_Gui.Add("Text", "Section XS", "LIGHTNING")
WCG.ClrChgElementMax[3] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vWCCurrentColorLightningElementMax c" . MaxVariationColorFromHexToHexString(WCV.Color[3],WCV.DetectionVariation), -1)
WCG.ClrChgElementMax[3].Value := 100
WCG.ClrChgElementCur[3] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vWCCurrentColorLightningElement c" . Format("{:X}", WCV.Color[3]), -1)
WCG.ClrChgElementCur[3].Value := 100
WCG.ClrChgElementMin[3] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vWCCurrentColorLightningElementMin c" . MinVariationColorFromHexToHexString(WCV.Color[3],WCV.DetectionVariation), -1)
WCG.ClrChgElementMin[3].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", WCGC_RedCompElemLightningChanged)
MUpDown_WCColorRElemLightning := Menu_Gui.Add("UpDown", "vWCColorRElemLightningUpDown Range0-255", RedComponentFromHexAsRGBInt(WCV.Color[3]))
MUpDown_WCColorRElemLightning.OnEvent("Change", WCGC_RedCompElemLightningChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", WCGC_GreenCompElemLightningChanged)
MUpDown_WCColorGElemLightning := Menu_Gui.Add("UpDown", "vWCColorGElemLightningUpDown Range0-255", GreenComponentFromHexAsRGBInt(WCV.Color[3]))
MUpDown_WCColorGElemLightning.OnEvent("Change", WCGC_GreenCompElemLightningChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", WCGC_BlueCompElemLightningChanged)
MUpDown_WCColorBElemLightning := Menu_Gui.Add("UpDown", "vWCColorBElemLightningUpDown Range0-255", BlueComponentFromHexAsRGBInt(WCV.Color[3]))
MUpDown_WCColorBElemLightning.OnEvent("Change", WCGC_BlueCompElemLightningChanged)

Menu_Gui.Add("Text", "Section XS", "GROUND")
WCG.ClrChgElementMax[4] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vWCCurrentColorGroundElementMax c" . MaxVariationColorFromHexToHexString(WCV.Color[4],WCV.DetectionVariation), -1)
WCG.ClrChgElementMax[4].Value := 100
WCG.ClrChgElementCur[4] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vWCCurrentColorGroundElement c" . Format("{:X}", WCV.Color[4]), -1)
WCG.ClrChgElementCur[4].Value := 100
WCG.ClrChgElementMin[4] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vWCCurrentColorGroundElementMin c" . MinVariationColorFromHexToHexString(WCV.Color[4],WCV.DetectionVariation), -1)
WCG.ClrChgElementMin[4].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", WCGC_RedCompElemGroundChanged)
MUpDown_WCColorRElemGround := Menu_Gui.Add("UpDown", "vWCColorRElemGroundUpDown Range0-255", RedComponentFromHexAsRGBInt(WCV.Color[4]))
MUpDown_WCColorRElemGround.OnEvent("Change", WCGC_RedCompElemGroundChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", WCGC_GreenCompElemGroundChanged)
MUpDown_WCColorGElemGround := Menu_Gui.Add("UpDown", "vWCColorGElemGroundUpDown Range0-255", GreenComponentFromHexAsRGBInt(WCV.Color[4]))
MUpDown_WCColorGElemGround.OnEvent("Change", WCGC_GreenCompElemGroundChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", WCGC_BlueCompElemGroundChanged)
MUpDown_WCColorBElemGround := Menu_Gui.Add("UpDown", "vWCColorBElemGroundUpDown Range0-255", BlueComponentFromHexAsRGBInt(WCV.Color[4]))
MUpDown_WCColorBElemGround.OnEvent("Change", WCGC_BlueCompElemGroundChanged)

Menu_Gui.Add("Text", "Section XS", "DARK")
WCG.ClrChgElementMax[5] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vWCCurrentColorDarkElementMax c" . MaxVariationColorFromHexToHexString(WCV.Color[5],WCV.DetectionVariation), -1)
WCG.ClrChgElementMax[5].Value := 100
WCG.ClrChgElementCur[5] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vWCCurrentColorDarkElement c" . Format("{:X}", WCV.Color[5]), -1)
WCG.ClrChgElementCur[5].Value := 100
WCG.ClrChgElementMin[5] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vWCCurrentColorDarkElementMin c" . MinVariationColorFromHexToHexString(WCV.Color[5],WCV.DetectionVariation), -1)
WCG.ClrChgElementMin[5].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", WCGC_RedCompElemDarkChanged)
MUpDown_WCColorRElemDark := Menu_Gui.Add("UpDown", "vWCColorRElemDarkUpDown Range0-255", RedComponentFromHexAsRGBInt(WCV.Color[5]))
MUpDown_WCColorRElemDark.OnEvent("Change", WCGC_RedCompElemDarkChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", WCGC_GreenCompElemDarkChanged)
MUpDown_WCColorGElemDark := Menu_Gui.Add("UpDown", "vWCColorGElemDarkUpDown Range0-255", GreenComponentFromHexAsRGBInt(WCV.Color[5]))
MUpDown_WCColorGElemDark.OnEvent("Change", WCGC_GreenCompElemDarkChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", WCGC_BlueCompElemDarkChanged)
MUpDown_WCColorBElemDark := Menu_Gui.Add("UpDown", "vWCColorBElemDarkUpDown Range0-255", BlueComponentFromHexAsRGBInt(WCV.Color[5]))
MUpDown_WCColorBElemDark.OnEvent("Change", WCGC_BlueCompElemDarkChanged)

Menu_Gui.Add("Text", "Section XS", "LIGHT")
WCG.ClrChgElementMax[6] := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vWCCurrentColorLightElementMax c" . MaxVariationColorFromHexToHexString(WCV.Color[6],WCV.DetectionVariation), -1)
WCG.ClrChgElementMax[6].Value := 100
WCG.ClrChgElementCur[6] := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vWCCurrentColorLightElement c" . Format("{:X}", WCV.Color[6]), -1)
WCG.ClrChgElementCur[6].Value := 100
WCG.ClrChgElementMin[6] := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vWCCurrentColorLightElementMin c" . MinVariationColorFromHexToHexString(WCV.Color[6],WCV.DetectionVariation), -1)
WCG.ClrChgElementMin[6].Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", WCGC_RedCompElemLightChanged)
MUpDown_WCColorRElemLight := Menu_Gui.Add("UpDown", "vWCColorRElemLightUpDown Range0-255", RedComponentFromHexAsRGBInt(WCV.Color[6]))
MUpDown_WCColorRElemLight.OnEvent("Change", WCGC_RedCompElemLightChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", WCGC_GreenCompElemLightChanged)
MUpDown_WCColorGElemLight := Menu_Gui.Add("UpDown", "vWCColorGElemLightUpDown Range0-255", GreenComponentFromHexAsRGBInt(WCV.Color[6]))
MUpDown_WCColorGElemLight.OnEvent("Change", WCGC_GreenCompElemLightChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", WCGC_BlueCompElemLightChanged)
MUpDown_WCColorBElemLight := Menu_Gui.Add("UpDown", "vWCColorBElemLightUpDown Range0-255", BlueComponentFromHexAsRGBInt(WCV.Color[6]))
MUpDown_WCColorBElemLight.OnEvent("Change", WCGC_BlueCompElemLightChanged)





MTab_Settings.UseTab(0)
Menu_Gui.Show("W155 H560")



; ; Create custom gui to represent where ahk is detecting pixels for auto Just Attack 
JAG.GUI := Gui("+AlwaysOnTop +MinSize5x5 +MaxSize25x25 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "JA")
JAG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
JAG.GUI.OnEvent("Size", GUI_Resize )
JAG.GUI.Show("W" . JAG.W . " H" . JAG.H)
JAG.GUI.Move( JAG.XW, JAG.YW )
WinSetTransColor(JAG.GUI.BackColor ,JAG.GUI.Hwnd)

; ; Create custom gui to represent where ahk is detecting pixels for auto Photon Charge 
PCG.GUI := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "PC")
PCG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
PCG.GUI.OnEvent("Size", GUI_Resize )
PCG.GUI.Show("W" . PCG.W . " H" . PCG.H)
PCG.GUI.Move( PCG.XW, PCG.YW )
WinSetTransColor(PCG.GUI.BackColor , PCG.GUI.Hwnd)

; ; Create custom gui to represent where ahk is detecting pixels for auto Trimates (healing) 
THG.GUI := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "TH")
THG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
THG.GUI.OnEvent("Size", GUI_Resize )
THG.GUI.Show("W" . THG.W . " H" . THG.H)
THG.GUI.Move( THG.XW, THG.YW )
WinSetTransColor(THG.GUI.BackColor , THG.GUI.Hwnd)

; ; Create custom gui for enemy element type detection to armor swap
ASG.GUI := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "AS")
ASG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
ASG.GUI.OnEvent("Size", GUI_Resize )
ASG.GUI.Show("W" . ASG.W . " H" . ASG.H)
ASG.GUI.Move( ASG.XW, ASG.YW )
WinSetTransColor(ASG.GUI.BackColor , ASG.GUI.Hwnd)

; ; Create custom gui for enemy element type detection to armor swap
WCG.GUI := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "WC")
WCG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
WCG.GUI.OnEvent("Size", GUI_Resize )
WCG.GUI.Show("W" . WCG.W . " H" . WCG.H)
WCG.GUI.Move( WCG.XW, WCG.YW )
WinSetTransColor(WCG.GUI.BackColor , WCG.GUI.Hwnd)

; function to update the position and size of custom guis when changed
GUI_Resize(GuiObj, MinMax, Width, Height)
{
    global
    local GUI_Resized := true
    If (JAG.GUI = GuiObj)
    {
        If (JAG.SkipGuiResize = 0)
        {
            JAG.GUI.GetClientPos(&X, &Y, &W, &H)
            JAG.X := X
            JAG.Y := Y
            JAG.W := W
            JAG.H := H
        }
    }
    Else If (PCG.GUI = GuiObj)
    {
        If (PCG.SkipGuiResize = 0)
        {
            PCG.GUI.GetClientPos(&X, &Y, &W, &H)
            PCG.X := X
            PCG.Y := Y
            PCG.W := W
            PCG.H := H
            PCG.MX := PCG.X + PCG.W
            PCG.MY := PCG.Y + PCG.H
        }
    }
    Else If (THG.GUI = GuiObj)
    {
        If (THG.SkipGuiResize = 0)
        {
            THG.GUI.GetClientPos(&X, &Y, &W, &H)
            THG.X := X
            THG.Y := Y
            THG.W := W
            THG.H := H
            THG.MX := THG.X + THG.W
            THG.MY := THG.Y + THG.H
        }
    }
    Else If (ASG.GUI = GuiObj)
    {
        If (ASG.SkipGuiResize = 0)
        {
            ASG.GUI.GetClientPos(&X, &Y, &W, &H)
            ASG.X := X
            ASG.Y := Y
            ASG.W := W
            ASG.H := H
            ASG.MX := ASG.X + ASG.W
            ASG.MY := ASG.Y + ASG.H
        }
    }
    Else If (WCG.GUI = GuiObj)
    {
        If (WCG.SkipGuiResize = 0)
        {
            WCG.GUI.GetClientPos(&X, &Y, &W, &H)
            WCG.X := X
            WCG.Y := Y
            WCG.W := W
            WCG.H := H
            WCG.MX := WCG.X + WCG.W
            WCG.MY := WCG.Y + WCG.H
        }
    }
    Else
    {
        GUI_Resized := false
    }

    If (GUI_Resized = true)
    {
        MStatusBar_MainStatus.SetText( "X" . X . " Y" . Y . " W" . W . " H" . H ,, 0 )
    }
    return True
}

; add hook for repositioning the ahk custom window
OnMessage(0x03, GuiRepositionedHook)
GuiRepositionedHook(wParam, lParam, msg, hwnd)
{
    If( hwnd = JAG.GUI.Hwnd )
    {
        GUI_Resize(JAG.GUI, 0, 0, 0)
    }
    Else If ( hwnd = PCG.GUI.Hwnd )
    {
        GUI_Resize(PCG.GUI, 0, 0, 0)
    }
    Else If ( hwnd = THG.GUI.Hwnd )
    {
        GUI_Resize(THG.GUI, 0, 0, 0)
    }
    Else If ( hwnd = ASG.GUI.Hwnd )
    {
        GUI_Resize(ASG.GUI, 0, 0, 0)
    }
    Else If ( hwnd = WCG.GUI.Hwnd )
    {
        GUI_Resize(WCG.GUI, 0, 0, 0)
    }
}


; Init position and size values
GUI_Resize(JAG.GUI, 0, 0, 0)
GUI_Resize(PCG.GUI, 0, 0, 0)
GUI_Resize(THG.GUI, 0, 0, 0)
GUI_Resize(ASG.GUI, 0, 0, 0)
GUI_Resize(WCG.GUI, 0, 0, 0)

JAGC_EvalWindowHidden
PCGC_EvalWindowHidden
THGC_EvalWindowHidden
WeaponChangeEvalWindowHidden
ArmorSwapEvalWindowHidden

; Auto Just Attack

if (JAV.Enabled = true)
{
    SetTimer JAV_Loop, JAV.Freq
}
JAV_Loop()
{
    global
    local P_Color := PixelGetColor(JAG.X, JAG.Y)
    If ( P_Color = 0x00FF00 )  ; green color
    {
        MProgress_JA.Value := Max(Min(Round(JAV.Count / JAV.Thresh * 100), 100),0)
        JAV.Count := JAV.Count + 1
    } Else {
        If (JAV.Count > 0)
        {
            MStatusBar_MainStatus.SetText( "Time Green" . JAV.Count ,, 0 )
        }
        JAV.Count := 0
        If ( P_Color = 0xFF0000 )
        {
            MProgress_JA.Opt("+c0xFF0000")
            MProgress_JA.Value := 100
        } Else {
            MProgress_JA.Opt("+c0x3A89DB")
            MProgress_JA.Value := 0
        }
    }
    If (JAV.Count >= JAV.Thresh)
    {
        MProgress_JA.Opt("+c0x00FF00")
        MProgress_JA.Value := 100
        if (UseInputLockout != true)
        {
            UseInputLockout := true
            Sleep JAV.Delay
            MStatusBar_MainStatus.SetText( "Just Attack!" ,, 0 )
            if (WinActive(PSUWinTitle)) 
            {
                Send "{Right}{Right}{Right}"
            }
            JAV.Count := 0
            UseInputLockout := false
        }
    }
    return True
}


; Auto Photon Charge
if (PCV.Enabled = true)
{
    SetTimer PCV_Loop, PCV.Freq
}
PCV_Loop()
{
    global
    If ( PixelSearch(&PC_Px, &PC_Py, PCG.MX, PCG.MY, PCG.X, PCG.Y, 0x3A89DB) ) ; mid-blue color. Also can be 0x3987DB ?
    {
        PCV.BarPercent := Round((PC_Px - PCG.X) / (PCG.W) * 100)
        MProgress_PC.Value := PCV.BarPercent
        PCG.GUI.Title := "PC " . PCV.BarPercent . "/100"
        If ( PCV.BarPercent < PCV.PPThresh && PCV.BarPercent > 0 ){
            PCV.Count := PCV.Count + 1
        }
        
    } Else {
        If (PCV.Count > 0)
        {
            MStatusBar_MainStatus.SetText( "Time Blue" . PCV.Count ,, 0)
        }
        PCV.Count := 0
        PCG.GUI.Title := "PC"
    }
;MStatusBar_MainStatus.SetText( "Pixel Search" PCV.Count " " PCG.X ":" PCG.Y " " PCG.W ":" PCG.H " FOUND:" PC_Px ":" PC_Py " " PCV.BarPercent ,, 0)
    If (PCV.Count >= PCV.TrigThresh)
    {
        PhotonChargeUse()
    }
    return True
}


; Auto Trimate Heal
if (THV.Enabled = true)
{
    SetTimer THV_Loop, THV.Freq
}
THV_Loop()
{
    global
    If ( PixelSearch(&TH_Px, &TH_Py, THG.MX, THG.MY, THG.X, THG.Y, 0x5BD847 ) ) ; green color. Also can be, 0x5BD847, 0x58CD46, 0x47983D, 0x4D9F44  ?
    {
        THV.BarPercent := Round((TH_Px - THG.X) / (THG.W) * 100)
        MProgress_TH.Value := THV.BarPercent
        MProgress_TH.Opt("+c0x5BD847")
        THG.GUI.Title := "TH " . THV.BarPercent . "/100"
        If ( THV.BarPercent < THV.HPThresh && THV.BarPercent > 0 ){
            THV.Count := THV.Count + 1
        }
        
    } Else {
        If ( PixelSearch(&TH_Px, &TH_Py, THG.MX, THG.MY, THG.X, THG.Y, 0xFFFF00 ) ) ; yellow color. Also can be others, but changes constantly !
        {
            THV.BarPercent := Round((TH_Px - THG.X) / (THG.W) * 100)
            MProgress_TH.Value := THV.BarPercent
            MProgress_TH.Opt("+c0xFFFF00")
            THG.GUI.Title := "TH " . THV.BarPercent . "/100"
            If ( THV.BarPercent < THV.HPThresh && THV.BarPercent > 0 ){
                THV.Count := THV.Count + 1
            }
        } Else {
            If (THV.Count > 0)
            {
                MStatusBar_MainStatus.SetText( "Time Yellow" . THV.Count ,, 0)
            }
            MProgress_TH.Value := -1
            THV.Count := 0
            THG.GUI.Title := "TH"
        }
    }
;MStatusBar_MainStatus.SetText( "Pixel Search" THV.Count " " THG.X ":" THG.Y " " THG.W ":" THG.H " FOUND:" TH_Px ":" TH_Py " " THV.BarPercent ,, 0)
    If (THV.Count >= THV.TrigThresh)
    {
        TrimateHealUse()
    }
    return True
}


; Auto Armor Swap
if (ASV.Enabled = true)
{
    SetTimer ASV_Loop, ASV.Freq
}
ASV_Loop()
{
    global
    local ASV_ColorDetected := false
    local ASV_DetectTries := 1
    If (ASV.DetectionState = 0)
    {
        ASV_DetectTries := ASV.NewDetectTries
    }

    Loop ASV_DetectTries
    {
        If ( ASV_ColorEval( ASV.CurDetectColorIdx ) )
        {
            ASV_ColorDetected := true
            ASV.DetectionState := 1
            Break
        }
        ASV.CurDetectColorIdx := IntWrap(ASV.CurDetectColorIdx + 1, 1, 6)
    }

    If (ASV_ColorDetected = false)
    {
        If (ASV.Count > 0)
        {
            MStatusBar_MainStatus.SetText( "Time ArmorSwap" . ASV.Count ,, 0)
        }
        ASV.Count := 0
        MProgress_AS.Value := -1
        ASG.GUI.Title := "AS"
        ASV.ElemType := 0
        ASV.DetectionState := 0
    }
; MStatusBar_MainStatus.SetText( "Pixel Search" ASV.Count " " ASG.X ":" ASG.Y " " ASG.W ":" ASG.H " FOUND:" AS_Px ":" AS_Py " " ASV.ElemType ,, 0)
    If (ASV.Count >= ASV.TrigThresh)
    {
        ArmorSwapUse()
    }
    return True
}
ASV_ColorEval( ColorIdx )
{
    global
    If (PixelSearch(&AS_Px, &AS_Py, ASG.MX, ASG.MY, ASG.X, ASG.Y, ASV.Color[ColorIdx], ASV.DetectionVariation ))
    {
        MProgress_AS.Opt("+c0x" . Format("{:X}", ASV.Color[ColorIdx]))
        ASG.GUI.Title := ASV.TitleText[ColorIdx]
        ASV.ElemType := ColorIdx
        If (ASV.LastElemForCount = 0 || ASV.ElemType = ASV.LastElemForCount)
        {
            MProgress_AS.Value := Min(22 + (ASV.Count / ASV.TrigThresh) * (100-22), 100)
            ASV.Count := ASV.Count + 1
        }
        Else
        {
            ASV.Count := 0
            MProgress_AS.Value := Min(22 + (ASV.Count / ASV.TrigThresh) * (100-22), 100)
        }
        ASV.LastElemForCount := ASV.ElemType
        Return True
    }
    Return False
}

; Auto Weapon Change
if (WCV.Enabled = true)
{
    SetTimer WCV_Loop, WCV.Freq
}
WCV_Loop()
{
    global
    local WCV_ColorDetected := false
    local WCV_DetectTries := 1
    If (WCV.DetectionState = 0)
    {
        WCV_DetectTries := WCV.NewDetectTries
    }

    Loop WCV_DetectTries
    {
        If ( WCV_ColorEval( WCV.CurDetectColorIdx ) )
        {
            WCV_ColorDetected := true
            WCV.DetectionState := 1
            Break
        }
        WCV.CurDetectColorIdx := IntWrap(WCV.CurDetectColorIdx + 1, 1, 6)
    }

    If (WCV_ColorDetected = false)
    {
        If (WCV.Count > 0)
        {
            MStatusBar_MainStatus.SetText( "Time WeaponChange" . WCV.Count ,, 0)
        }
        WCV.Count := 0
        MProgress_WC.Value := -1
        WCG.GUI.Title := "WC"
        WCV.ElemType := 0
        WCV.DetectionState := 0
    }
; MStatusBar_MainStatus.SetText( "Pixel Search" WCV.Count " " WCG.X ":" WCG.Y " " WCG.W ":" WCG.H " FOUND:" WC_Px ":" WC_Py " " WCV.ElemType ,, 0)
    If (WCV.Count >= WCV.TrigThresh)
    {
        WeaponChangeUse()
    }
    return True
}
WCV_ColorEval( ColorIdx )
{
    global
    If (PixelSearch(&WC_Px, &WC_Py, WCG.MX, WCG.MY, WCG.X, WCG.Y, WCV.Color[ColorIdx], WCV.DetectionVariation ))
    {
        MProgress_WC.Opt("+c0x" . Format("{:X}", WCV.Color[ColorIdx]))
        WCG.GUI.Title := WCV.TitleText[ColorIdx]
        WCV.ElemType := ColorIdx
        If (WCV.LastElemForCount = 0 || WCV.ElemType = WCV.LastElemForCount)
        {
            MProgress_WC.Value := Min(22 + (WCV.Count / WCV.TrigThresh) * (100-22), 100)
            WCV.Count := WCV.Count + 1
        }
        Else
        {
            WCV.Count := 0
            MProgress_WC.Value := Min(22 + (WCV.Count / WCV.TrigThresh) * (100-22), 100)
        }
        WCV.LastElemForCount := WCV.ElemType
        Return True
    }
    Return False
}


PhotonChargeUse(*)
{
    global
    if (UseInputLockout != true)
    {
        UseInputLockout := true
        Sleep PCV.Delay
        MStatusBar_MainStatus.SetText( "Photon Charge!" ,, 0)
        if (WinActive(PSUWinTitle)) 
        {
            Send PCV.PressKey
        }
        PCV.Count := 0
        UseInputLockout := false
    }
}
TrimateHealUse(*)
{
    global
    if (UseInputLockout != true)
    {
        UseInputLockout := true
        Sleep THV.Delay
        MStatusBar_MainStatus.SetText( "Trimate Heal!" ,, 0)
        if (WinActive(PSUWinTitle)) 
        {
            Send THV.PressKey
        }
        THV.Count := 0
        UseInputLockout := false
    }
}
ArmorSwapUse(*)
{
    global
    if (ASV.LastElemType != ASV.ElemType && ASV.CanChange = 1 && UseInputLockout != true)
    {
        Sleep ASV.Delay
        MStatusBar_MainStatus.SetText( "Armor Swap!" ,, 0)
        
        UseInputLockout := true
        local ArmorSwapPressInputted := false
        If (ASV.InputMode = 1)
        {
            ArmorSwapPressInput := ASV.PressKey[ASV.ElemType]
            if (WinActive(PSUWinTitle)) 
            {
                Send ArmorSwapPressInput
            }
            MProgress_ASC.Opt("+c0x" . Format("{:X}", ASV.Color[ASV.ElemType]))
            ArmorSwapPressInputted := true
        }
        Else If (ASV.InputMode = 2)
        {
            ArmorSwapPressInput := ASV.TypeText[ASV.ElemType]
            if (WinActive(PSUWinTitle)) 
            {
                Send "{Space}"
                Send "{Text}" . ArmorSwapPressInput
                Send "{Enter}{Enter}{Enter}"
            }
            MProgress_ASC.Opt("+c0x" . Format("{:X}", ASV.Color[ASV.ElemType]))
            ArmorSwapPressInputted := true
        }
        If (ArmorSwapPressInputted = true)
        {
            ASV.LastElemType := ASV.ElemType
            MProgress_AS.Value := 100
            ASV.CanChange := 0
            SetTimer () => ASV.CanChange := 1, -ASV.DurationBeforeNextChange, 10001
            ; ASV.Count := 0
        }
        UseInputLockout := false
    }
}
WeaponChangeUse(*)
{
    global
    local ASV_ElemType := ASV.ElemType ; copy variable due to bug with 'multithreading'. There is a small chance the elemtype is 0 after we just checked it...
    if (ASV_ElemType != 0 && WCV.ElemType != WCV.ColorOppositeLookup[ASV_ElemType] && WCV.CanChange = 1 && UseInputLockout != true)
    {
        Sleep WCV.Delay
        MStatusBar_MainStatus.SetText( "Weapon Change!" ,, 0)
        
        UseInputLockout := true
        local WeaponChangePressInputted := false
        If (WCV.InputMode = 1)
        {
            WeaponChangePressInput := WCV.PressKey[WCV.ColorOppositeLookup[ASV_ElemType]]
            if (WinActive(PSUWinTitle)) 
            {
                Send WeaponChangePressInput
            }
            MProgress_WCC.Opt("+c0x" . Format("{:X}", WCV.Color[WCV.ColorOppositeLookup[ASV_ElemType]]))
            WeaponChangePressInputted := true
        }
        Else If (WCV.InputMode = 2)
        {
            WeaponChangePressInput := WCV.TypeText[WCV.ColorOppositeLookup[ASV_ElemType]]
            if (WinActive(PSUWinTitle)) 
            {
                Send "{Space}"
                Send "{Text}" . WeaponChangePressInput
                Send "{Enter}{Enter}{Enter}"
            }
            MProgress_WCC.Opt("+c0x" . Format("{:X}", WCV.Color[WCV.ColorOppositeLookup[ASV_ElemType]]))
            WeaponChangePressInputted := true
        }
        If (WeaponChangePressInputted = true)
        {
            WCV.LastElemType := WCV.ElemType
            MProgress_WC.Value := 100
            WCV.CanChange := 0
            SetTimer () => WCV.CanChange := 1, -WCV.DurationBeforeNextChange, 10001
        }
        UseInputLockout := false
    }
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
JAE_ToggleFeatureEnabled(*)
{
    global
    if (MCheckBox_JAE.Value = 0)
    {
        SetTimer JAV_Loop, 0
        JAV.Enabled := false
        MStatusBar_MainStatus.SetText( "JA Disabled!" ,, 0)
    }
    Else
    {
        SetTimer JAV_Loop, JAV.Freq
        JAV.Enabled := true
        MStatusBar_MainStatus.SetText( "JA Enabled!" ,, 0)
    }
}
PCE_ToggleFeatureEnabled(*)
{
    global
    if (MCheckBox_PCE.Value = 0)
    {
        SetTimer PCV_Loop, 0
        PCV.Enabled := false
        MStatusBar_MainStatus.SetText( "PC Disabled!" ,, 0)
    }
    Else
    {
        SetTimer PCV_Loop, PCV.Freq
        PCV.Enabled := true
        MStatusBar_MainStatus.SetText( "PC Enabled!" ,, 0)
    }
}
THE_ToggleFeatureEnabled(*)
{
    global
    if (MCheckBox_THE.Value = 0)
    {
        SetTimer THV_Loop, 0
        THV.Enabled := false
        MStatusBar_MainStatus.SetText( "TH Disabled!" ,, 0)
    }
    Else
    {
        SetTimer THV_Loop, THV.Freq
        THV.Enabled := true
        MStatusBar_MainStatus.SetText( "TH Enabled!" ,, 0)
    }
}
ASE_ToggleFeatureEnabled(*)
{
    global
    if (MCheckBox_ASE.Value = 0)
    {
        SetTimer ASV_Loop, 0
        ASV.Enabled := false
        MStatusBar_MainStatus.SetText( "AS Disabled!" ,, 0)
    }
    Else
    {
        SetTimer ASV_Loop, ASV.Freq
        ASV.Enabled := true
        MStatusBar_MainStatus.SetText( "AS Enabled!" ,, 0)
    }
}
WCE_ToggleFeatureEnabled(*)
{
    global
    if (MCheckBox_WCE.Value = 0)
    {
        SetTimer WCV_Loop, 0
        WCV.Enabled := false
        MStatusBar_MainStatus.SetText( "WC Disabled!" ,, 0)
    }
    Else
    {
        SetTimer WCV_Loop, WCV.Freq
        WCV.Enabled := true
        MStatusBar_MainStatus.SetText( "WC Enabled!" ,, 0)
    }
}


JAGC_AllowMoveWindow(*)
{
    global
    if (JAG.WindowCanMove = 0)
    {
        JAG.WindowCanMove := 1
    }
    Else
    {
        JAG.WindowCanMove := 0
    }
    JAGC_EvalWindowHidden
}
JAGC_EvalWindowHidden()
{
    global
    if (JAG.WindowCanMove = 0)
    {
        JAG.SkipGuiResize := 1
        JAG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowJA.Text := "Show JA"
    }
    Else
    {
        JAG.SkipGuiResize := 0
        JAG.GUI.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowJA.Text := "Hide JA"
    }
}

PCGC_AllowMoveWindow(*)
{
    global
    if (PCG.WindowCanMove = 0)
    {
        PCG.WindowCanMove := 1
    }
    Else
    {
        PCG.WindowCanMove := 0
    }
    PCGC_EvalWindowHidden
}
PCGC_EvalWindowHidden()
{
    global
    if (PCG.WindowCanMove = 0)
    {
        PCG.SkipGuiResize := 1
        PCG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowPC.Text := "Show PC"
    }
    Else
    {
        PCG.SkipGuiResize := 0
        PCG.GUI.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowPC.Text := "Hide PC"
    }
}

THGC_AllowMoveWindow(*)
{
    global
    if (THG.WindowCanMove = 0)
    {
        THG.WindowCanMove := 1
    }
    Else
    {
        THG.WindowCanMove := 0
    }
    THGC_EvalWindowHidden
}
THGC_EvalWindowHidden()
{
    global
    if (THG.WindowCanMove = 0)
    {
        THG.SkipGuiResize := 1
        THG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowTH.Text := "Show TH"
    }
    Else
    {
        THG.SkipGuiResize := 0
        THG.GUI.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowTH.Text := "Hide TH"
    }
}

ArmorSwapAllowMoveWindow(*)
{
    global
    if (ASG.WindowCanMove = 0)
    {
        ASG.WindowCanMove := 1
    }
    Else
    {
        ASG.WindowCanMove := 0
    }
    ArmorSwapEvalWindowHidden
}
ArmorSwapEvalWindowHidden()
{
    global
    if (ASG.WindowCanMove = 0)
    {
        ASG.SkipGuiResize := 1
        ASG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowAS.Text := "Show AS"
    }
    Else
    {
        ASG.SkipGuiResize := 0
        ASG.GUI.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowAS.Text := "Hide AS"
    }
}

WeaponChangeAllowMoveWindow(*)
{
    global
    if (WCG.WindowCanMove = 0)
    {
        WCG.WindowCanMove := 1
    }
    Else
    {
        WCG.WindowCanMove := 0
    }
    WeaponChangeEvalWindowHidden
}
WeaponChangeEvalWindowHidden()
{
    global
    if (WCG.WindowCanMove = 0)
    {
        WCG.SkipGuiResize := 1
        WCG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowWC.Text := "Show WC"
    }
    Else
    {
        WCG.SkipGuiResize := 0
        WCG.GUI.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowWC.Text := "Hide WC"
    }
}

JAGC_PressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_JAPressKey.Value) > 0)
    {
        JAV.HotKey :=   MHotkey_JAPressKey.Value
        JAV.PressKey := ConvertHotKeyToKeyPress(MHotkey_JAPressKey.Value)
    }
}
JAGC_FreqChanged(*)
{
    global
    JAV.Freq := MUpDown_JAFreq.Value
    if (JAV.Enabled = true)
    {
        SetTimer JAV_Loop, JAV.Freq
    }
}
JAGC_ThreshChanged(*)
{
    global
    JAV.Thresh := MUpDown_JAThresh.Value
}
JAGC_DelayChanged(*)
{
    global
    JAV.Delay := MUpDown_JADelay.Value
}
JAGC_VertChanged(*)
{
    global
    local TempSkipGuiResize := JAG.SkipGuiResize
    JAG.SkipGuiResize := 0
    JAG.GUI.GetPos( &X, &Y )
    If (MUpDown_JAVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_JAVert.Value < 0) {
        Y := Y + 1
    }
    JAG.GUI.Move( X, Y )
    MUpDown_JAVert.Value := 0
    JAG.SkipGuiResize := TempSkipGuiResize
}
JAGC_HorzChanged(*)
{
    global
    local TempSkipGuiResize := JAG.SkipGuiResize
    JAG.SkipGuiResize := 0
    JAG.GUI.GetPos( &X, &Y )
    If (MUpDown_JAHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_JAHorz.Value < 0) {
        X := X - 1
    }
    JAG.GUI.Move( X, Y )
    MUpDown_JAHorz.Value := 0
    JAG.SkipGuiResize := TempSkipGuiResize
}

PCGC_PressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_PCPressKey.Value) > 0)
    {
        PCV.HotKey :=   MHotkey_PCPressKey.Value
        PCV.PressKey := ConvertHotKeyToKeyPress(MHotkey_PCPressKey.Value)
    }
}
PCGC_FreqChanged(*)
{
    global
    PCV.Freq := MUpDown_PCFreq.Value
    if (PCV.Enabled = true)
    {
        SetTimer PCV_Loop, PCV.Freq
    }
}
PCGC_TrigThreshChanged(*)
{
    global
    PCV.TrigThresh := MUpDown_PCTrigThresh.Value
}
PCGC_PPThreshChanged(*)
{
    global
    PCV.PPThresh := MUpDown_PCPPThresh.Value
}
PCGC_DelayChanged(*)
{
    global
    PCV.Delay := MUpDown_PCDelay.Value
}
PCGC_VertChanged(*)
{
    global
    local TempSkipGuiResize := PCG.SkipGuiResize
    PCG.SkipGuiResize := 0
    PCG.GUI.GetPos( &X, &Y )
    If (MUpDown_PCVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_PCVert.Value < 0) {
        Y := Y + 1
    }
    PCG.GUI.Move( X, Y )
    MUpDown_PCVert.Value := 0
    PCG.SkipGuiResize := TempSkipGuiResize
}
PCGC_HorzChanged(*)
{
    global
    local TempSkipGuiResize := PCG.SkipGuiResize
    PCG.SkipGuiResize := 0
    PCG.GUI.GetPos( &X, &Y )
    If (MUpDown_PCHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_PCHorz.Value < 0) {
        X := X - 1
    }
    PCG.GUI.Move( X, Y )
    MUpDown_PCHorz.Value := 0
    PCG.SkipGuiResize := TempSkipGuiResize
}

THGC_PressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_THPressKey.Value) > 0)
    {
        THV.HotKey :=   MHotkey_THPressKey.Value
        THV.PressKey := ConvertHotKeyToKeyPress(MHotkey_THPressKey.Value)
    }    
}
THGC_FreqChanged(*)
{
    global
    THV.Freq := MUpDown_THFreq.Value
    if (THV.Enabled = true)
    {
        SetTimer THV_Loop, THV.Freq
    }
}
THGC_TrigThreshChanged(*)
{
    global
    THV.TrigThresh := MUpDown_THTrigThresh.Value
}
THGC_HPThreshChanged(*)
{
    global
    THV.HPThresh := MUpDown_THHPThresh.Value
}
THGC_DelayChanged(*)
{
    global
    THV.Delay := MUpDown_THDelay.Value
}
THGC_VertChanged(*)
{
    global
    local TempSkipGuiResize := THG.SkipGuiResize
    THG.SkipGuiResize := 0
    THG.GUI.GetPos( &X, &Y )
    If (MUpDown_THVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_THVert.Value < 0) {
        Y := Y + 1
    }
    THG.GUI.Move( X, Y )
    MUpDown_THVert.Value := 0
    THG.SkipGuiResize := TempSkipGuiResize
}
THGC_HorzChanged(*)
{
    global
    local TempSkipGuiResize := THG.SkipGuiResize
    THG.SkipGuiResize := 0
    THG.GUI.GetPos( &X, &Y )
    If (MUpDown_THHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_THHorz.Value < 0) {
        X := X - 1
    }
    THG.GUI.Move( X, Y )
    MUpDown_THHorz.Value := 0
    THG.SkipGuiResize := TempSkipGuiResize
}


ASGC_FreqChanged(*)
{
    global
    ASV.Freq := MUpDown_ASFreq.Value
    if (ASV.Enabled = true)
    {
        SetTimer ASV_Loop, ASV.Freq
    }
}
ASGC_TrigThreshChanged(*)
{
    global
    ASV.TrigThresh := MUpDown_ASTrigThresh.Value
}
ASGC_DetectionVariationChanged(*)
{
    global
    ASV.DetectionVariation := MUpDown_ASDTVARTN.Value
    ASGC_ColorElemUpdate(1)
    ASGC_ColorElemUpdate(2)
    ASGC_ColorElemUpdate(3)
    ASGC_ColorElemUpdate(4)
    ASGC_ColorElemUpdate(5)
    ASGC_ColorElemUpdate(6)
}
ASGC_DurationNextChgChanged(*)
{
    global
    ASV.DurationBeforeNextChange := MUpDown_ASDurationNextChg.Value
}
ASGC_DelayChanged(*)
{
    global
    ASV.Delay := MUpDown_ASDelay.Value
}
ASGC_VertChanged(*)
{
    global
    local TempSkipGuiResize := ASG.SkipGuiResize
    ASG.SkipGuiResize := 0
    ASG.GUI.GetPos( &X, &Y )
    If (MUpDown_ASVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_ASVert.Value < 0) {
        Y := Y + 1
    }
    ASG.GUI.Move( X, Y )
    MUpDown_ASVert.Value := 0
    ASG.SkipGuiResize := TempSkipGuiResize
}
ASGC_HorzChanged(*)
{
    global
    local TempSkipGuiResize := ASG.SkipGuiResize
    ASG.SkipGuiResize := 0
    ASG.GUI.GetPos( &X, &Y )
    If (MUpDown_ASHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_ASHorz.Value < 0) {
        X := X - 1
    }
    ASG.GUI.Move( X, Y )
    MUpDown_ASHorz.Value := 0
    ASG.SkipGuiResize := TempSkipGuiResize
}
ASGC_ElemFirePressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemFire.Value) > 0)
    {
        ASV.HotKey[1] :=   MHotkey_ASPressKeyElemFire.Value
        ASV.PressKey[1] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemFire.Value)
    }
}
ASGC_ElemIcePressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemIce.Value) > 0)
    {
        ASV.HotKey[2] :=   MHotkey_ASPressKeyElemIce.Value
        ASV.PressKey[2] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemIce.Value)
    }
}
ASGC_ElemLightningPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemLightning.Value) > 0)
    {
        ASV.HotKey[3] :=   MHotkey_ASPressKeyElemLightning.Value
        ASV.PressKey[3] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemLightning.Value)
    }
}
ASGC_ElemGroundPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemGround.Value) > 0)
    {
        ASV.HotKey[4] :=   MHotkey_ASPressKeyElemGround.Value
        ASV.PressKey[4] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemGround.Value)
    }
}
ASGC_ElemDarkPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemDark.Value) > 0)
    {
        ASV.HotKey[5] :=   MHotkey_ASPressKeyElemDark.Value
        ASV.PressKey[5] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemDark.Value)
    }
}
ASGC_ElemLightPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemLight.Value) > 0)
    {
        ASV.HotKey[6] :=   MHotkey_ASPressKeyElemLight.Value
        ASV.PressKey[6] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemLight.Value)
    }
}

ASGC_ElemFireTypeInputChanged(*)
{
    global
    If (StrLen(MText_ASTypeInputElemFire.Value) > 0)
    {
        ASV.TypeText[1] := MText_ASTypeInputElemFire.Value
    }
}
ASGC_ElemIceTypeInputChanged(*)
{
    global
    If (StrLen(MText_ASTypeInputElemIce.Value) > 0)
    {
        ASV.TypeText[2] := MText_ASTypeInputElemIce.Value
    }
}
ASGC_ElemLightningTypeInputChanged(*)
{
    global
    If (StrLen(MText_ASTypeInputElemLightning.Value) > 0)
    {
        ASV.TypeText[3] := MText_ASTypeInputElemLightning.Value
    }
}
ASGC_ElemGroundTypeInputChanged(*)
{
    global
    If (StrLen(MText_ASTypeInputElemGround.Value) > 0)
    {
        ASV.TypeText[4] := MText_ASTypeInputElemGround.Value
    }
}
ASGC_ElemDarkTypeInputChanged(*)
{
    global
    If (StrLen(MText_ASTypeInputElemDark.Value) > 0)
    {
        ASV.TypeText[5] := MText_ASTypeInputElemDark.Value
    }
}
ASGC_ElemLightTypeInputChanged(*)
{
    global
    If (StrLen(MText_ASTypeInputElemLight.Value) > 0)
    {
        ASV.TypeText[6] := MText_ASTypeInputElemLight.Value
    }
}

ASGC_ColorElemUpdate(ElemType)
{
    ASG.ClrChgElementMax[ElemType].Opt("+c" . MaxVariationColorFromHexToHexString(ASV.Color[ElemType], ASV.DetectionVariation))
    ASG.ClrChgElementCur[ElemType].Opt("+c" . Format("{:X}", ASV.Color[ElemType]))
    ASG.ClrChgElementMin[ElemType].Opt("+c" . MinVariationColorFromHexToHexString(ASV.Color[ElemType], ASV.DetectionVariation))
}
ASGC_RedCompElemFireChanged(*)
{
    ASV.Color[1] := UpdateRedComponentFromHexToHexInt(ASV.Color[1], MUpDown_ASColorRElemFire.Value)
    ASGC_ColorElemUpdate(1)
}
ASGC_GreenCompElemFireChanged(*)
{
    ASV.Color[1] := UpdateGreenComponentFromHexToHexInt(ASV.Color[1], MUpDown_ASColorGElemFire.Value)
    ASGC_ColorElemUpdate(1)
}
ASGC_BlueCompElemFireChanged(*)
{
    ASV.Color[1] := UpdateBlueComponentFromHexToHexInt(ASV.Color[1], MUpDown_ASColorBElemFire.Value)
    ASGC_ColorElemUpdate(1)
}

ASGC_RedCompElemIceChanged(*)
{
    ASV.Color[2] := UpdateRedComponentFromHexToHexInt(ASV.Color[2], MUpDown_ASColorRElemIce.Value)
    ASGC_ColorElemUpdate(2)
}
ASGC_GreenCompElemIceChanged(*)
{
    ASV.Color[2] := UpdateGreenComponentFromHexToHexInt(ASV.Color[2], MUpDown_ASColorGElemIce.Value)
    ASGC_ColorElemUpdate(2)
}
ASGC_BlueCompElemIceChanged(*)
{
    ASV.Color[2] := UpdateBlueComponentFromHexToHexInt(ASV.Color[2], MUpDown_ASColorBElemIce.Value)
    ASGC_ColorElemUpdate(2)
}

ASGC_RedCompElemLightningChanged(*)
{
    ASV.Color[3] := UpdateRedComponentFromHexToHexInt(ASV.Color[3], MUpDown_ASColorRElemLightning.Value)
    ASGC_ColorElemUpdate(3)
}
ASGC_GreenCompElemLightningChanged(*)
{
    ASV.Color[3] := UpdateGreenComponentFromHexToHexInt(ASV.Color[3], MUpDown_ASColorGElemLightning.Value)
    ASGC_ColorElemUpdate(3)
}
ASGC_BlueCompElemLightningChanged(*)
{
    ASV.Color[3] := UpdateBlueComponentFromHexToHexInt(ASV.Color[3], MUpDown_ASColorBElemLightning.Value)
    ASGC_ColorElemUpdate(3)
}

ASGC_RedCompElemGroundChanged(*)
{
    ASV.Color[4] := UpdateRedComponentFromHexToHexInt(ASV.Color[4], MUpDown_ASColorRElemGround.Value)
    ASGC_ColorElemUpdate(4)
}
ASGC_GreenCompElemGroundChanged(*)
{
    ASV.Color[4] := UpdateGreenComponentFromHexToHexInt(ASV.Color[4], MUpDown_ASColorGElemGround.Value)
    ASGC_ColorElemUpdate(4)
}
ASGC_BlueCompElemGroundChanged(*)
{
    ASV.Color[4] := UpdateBlueComponentFromHexToHexInt(ASV.Color[4], MUpDown_ASColorBElemGround.Value)
    ASGC_ColorElemUpdate(4)
}

ASGC_RedCompElemDarkChanged(*)
{
    ASV.Color[5] := UpdateRedComponentFromHexToHexInt(ASV.Color[5], MUpDown_ASColorRElemDark.Value)
    ASGC_ColorElemUpdate(5)
}
ASGC_GreenCompElemDarkChanged(*)
{
    ASV.Color[5] := UpdateGreenComponentFromHexToHexInt(ASV.Color[5], MUpDown_ASColorGElemDark.Value)
    ASGC_ColorElemUpdate(5)
}
ASGC_BlueCompElemDarkChanged(*)
{
    ASV.Color[5] := UpdateBlueComponentFromHexToHexInt(ASV.Color[5], MUpDown_ASColorBElemDark.Value)
    ASGC_ColorElemUpdate(5)
}

ASGC_RedCompElemLightChanged(*)
{
    ASV.Color[6] := UpdateRedComponentFromHexToHexInt(ASV.Color[6], MUpDown_ASColorRElemLight.Value)
    ASGC_ColorElemUpdate(6)
}
ASGC_GreenCompElemLightChanged(*)
{
    ASV.Color[6] := UpdateGreenComponentFromHexToHexInt(ASV.Color[6], MUpDown_ASColorGElemLight.Value)
    ASGC_ColorElemUpdate(6)
}
ASGC_BlueCompElemLightChanged(*)
{
    ASV.Color[6] := UpdateBlueComponentFromHexToHexInt(ASV.Color[6], MUpDown_ASColorBElemLight.Value)
    ASGC_ColorElemUpdate(6)
}


WCGC_FreqChanged(*)
{
    global
    WCV.Freq := MUpDown_WCFreq.Value
    if (WCV.Enabled = true)
    {
        SetTimer WCV_Loop, WCV.Freq
    }
}
WCGC_TrigThreshChanged(*)
{
    global
    WCV.TrigThresh := MUpDown_WCTrigThresh.Value
}
WCGC_DetectionVariationChanged(*)
{
    global
    WCV.DetectionVariation := MUpDown_WCDTVARTN.Value
    WCGC_ColorElemUpdate(1)
    WCGC_ColorElemUpdate(2)
    WCGC_ColorElemUpdate(3)
    WCGC_ColorElemUpdate(4)
    WCGC_ColorElemUpdate(5)
    WCGC_ColorElemUpdate(6)
}
WCGC_DurationNextChgChanged(*)
{
    global
    WCV.DurationBeforeNextChange := MUpDown_WCDurationNextChg.Value
}
WCGC_DelayChanged(*)
{
    global
    WCV.Delay := MUpDown_WCDelay.Value
}
WCGC_VertChanged(*)
{
    global
    local TempSkipGuiResize := WCG.SkipGuiResize
    WCG.SkipGuiResize := 0
    WCG.GUI.GetPos( &X, &Y )
    If (MUpDown_WCVert.Value > 0)
    {
        Y := Y - 1
    } Else If (MUpDown_WCVert.Value < 0) {
        Y := Y + 1
    }
    WCG.GUI.Move( X, Y )
    MUpDown_WCVert.Value := 0
    WCG.SkipGuiResize := TempSkipGuiResize
}
WCGC_HorzChanged(*)
{
    global
    local TempSkipGuiResize := WCG.SkipGuiResize
    WCG.SkipGuiResize := 0
    WCG.GUI.GetPos( &X, &Y )
    If (MUpDown_WCHorz.Value > 0)
    {
        X := X + 1
    } Else If (MUpDown_WCHorz.Value < 0) {
        X := X - 1
    }
    WCG.GUI.Move( X, Y )
    MUpDown_WCHorz.Value := 0
    WCG.SkipGuiResize := TempSkipGuiResize
}
WCGC_ElemFirePressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_WCPressKeyElemFire.Value) > 0)
    {
        WCV.HotKey[1] :=   MHotkey_WCPressKeyElemFire.Value
        WCV.PressKey[1] := ConvertHotKeyToKeyPress(MHotkey_WCPressKeyElemFire.Value)
    }
}
WCGC_ElemIcePressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_WCPressKeyElemIce.Value) > 0)
    {
        WCV.HotKey[2] :=   MHotkey_WCPressKeyElemIce.Value
        WCV.PressKey[2] := ConvertHotKeyToKeyPress(MHotkey_WCPressKeyElemIce.Value)
    }
}
WCGC_ElemLightningPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_WCPressKeyElemLightning.Value) > 0)
    {
        WCV.HotKey[3] :=   MHotkey_WCPressKeyElemLightning.Value
        WCV.PressKey[3] := ConvertHotKeyToKeyPress(MHotkey_WCPressKeyElemLightning.Value)
    }
}
WCGC_ElemGroundPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_WCPressKeyElemGround.Value) > 0)
    {
        WCV.HotKey[4] :=   MHotkey_WCPressKeyElemGround.Value
        WCV.PressKey[4] := ConvertHotKeyToKeyPress(MHotkey_WCPressKeyElemGround.Value)
    }
}
WCGC_ElemDarkPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_WCPressKeyElemDark.Value) > 0)
    {
        WCV.HotKey[5] :=   MHotkey_WCPressKeyElemDark.Value
        WCV.PressKey[5] := ConvertHotKeyToKeyPress(MHotkey_WCPressKeyElemDark.Value)
    }
}
WCGC_ElemLightPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_WCPressKeyElemLight.Value) > 0)
    {
        WCV.HotKey[6] :=   MHotkey_WCPressKeyElemLight.Value
        WCV.PressKey[6] := ConvertHotKeyToKeyPress(MHotkey_WCPressKeyElemLight.Value)
    }
}

WCGC_ElemFireTypeInputChanged(*)
{
    global
    If (StrLen(MText_WCTypeInputElemFire.Value) > 0)
    {
        WCV.TypeText[1] := MText_WCTypeInputElemFire.Value
    }
}
WCGC_ElemIceTypeInputChanged(*)
{
    global
    If (StrLen(MText_WCTypeInputElemIce.Value) > 0)
    {
        WCV.TypeText[2] := MText_WCTypeInputElemIce.Value
    }
}
WCGC_ElemLightningTypeInputChanged(*)
{
    global
    If (StrLen(MText_WCTypeInputElemLightning.Value) > 0)
    {
        WCV.TypeText[3] := MText_WCTypeInputElemLightning.Value
    }
}
WCGC_ElemGroundTypeInputChanged(*)
{
    global
    If (StrLen(MText_WCTypeInputElemGround.Value) > 0)
    {
        WCV.TypeText[4] := MText_WCTypeInputElemGround.Value
    }
}
WCGC_ElemDarkTypeInputChanged(*)
{
    global
    If (StrLen(MText_WCTypeInputElemDark.Value) > 0)
    {
        WCV.TypeText[5] := MText_WCTypeInputElemDark.Value
    }
}
WCGC_ElemLightTypeInputChanged(*)
{
    global
    If (StrLen(MText_WCTypeInputElemLight.Value) > 0)
    {
        WCV.TypeText[6] := MText_WCTypeInputElemLight.Value
    }
}

WCGC_ColorElemUpdate(ElemType)
{
    WCG.ClrChgElementMax[ElemType].Opt("+c" . MaxVariationColorFromHexToHexString(WCV.Color[ElemType], WCV.DetectionVariation))
    WCG.ClrChgElementCur[ElemType].Opt("+c" . Format("{:X}", WCV.Color[ElemType]))
    WCG.ClrChgElementMin[ElemType].Opt("+c" . MinVariationColorFromHexToHexString(WCV.Color[ElemType], WCV.DetectionVariation))
}
WCGC_RedCompElemFireChanged(*)
{
    WCV.Color[1] := UpdateRedComponentFromHexToHexInt(WCV.Color[1], MUpDown_WCColorRElemFire.Value)
    WCGC_ColorElemUpdate(1)
}
WCGC_GreenCompElemFireChanged(*)
{
    WCV.Color[1] := UpdateGreenComponentFromHexToHexInt(WCV.Color[1], MUpDown_WCColorGElemFire.Value)
    WCGC_ColorElemUpdate(1)
}
WCGC_BlueCompElemFireChanged(*)
{
    WCV.Color[1] := UpdateBlueComponentFromHexToHexInt(WCV.Color[1], MUpDown_WCColorBElemFire.Value)
    WCGC_ColorElemUpdate(1)
}

WCGC_RedCompElemIceChanged(*)
{
    WCV.Color[2] := UpdateRedComponentFromHexToHexInt(WCV.Color[2], MUpDown_WCColorRElemIce.Value)
    WCGC_ColorElemUpdate(2)
}
WCGC_GreenCompElemIceChanged(*)
{
    WCV.Color[2] := UpdateGreenComponentFromHexToHexInt(WCV.Color[2], MUpDown_WCColorGElemIce.Value)
    WCGC_ColorElemUpdate(2)
}
WCGC_BlueCompElemIceChanged(*)
{
    WCV.Color[2] := UpdateBlueComponentFromHexToHexInt(WCV.Color[2], MUpDown_WCColorBElemIce.Value)
    WCGC_ColorElemUpdate(2)
}

WCGC_RedCompElemLightningChanged(*)
{
    WCV.Color[3] := UpdateRedComponentFromHexToHexInt(WCV.Color[3], MUpDown_WCColorRElemLightning.Value)
    WCGC_ColorElemUpdate(3)
}
WCGC_GreenCompElemLightningChanged(*)
{
    WCV.Color[3] := UpdateGreenComponentFromHexToHexInt(WCV.Color[3], MUpDown_WCColorGElemLightning.Value)
    WCGC_ColorElemUpdate(3)
}
WCGC_BlueCompElemLightningChanged(*)
{
    WCV.Color[3] := UpdateBlueComponentFromHexToHexInt(WCV.Color[3], MUpDown_WCColorBElemLightning.Value)
    WCGC_ColorElemUpdate(3)
}

WCGC_RedCompElemGroundChanged(*)
{
    WCV.Color[4] := UpdateRedComponentFromHexToHexInt(WCV.Color[4], MUpDown_WCColorRElemGround.Value)
    WCGC_ColorElemUpdate(4)
}
WCGC_GreenCompElemGroundChanged(*)
{
    WCV.Color[4] := UpdateGreenComponentFromHexToHexInt(WCV.Color[4], MUpDown_WCColorGElemGround.Value)
    WCGC_ColorElemUpdate(4)
}
WCGC_BlueCompElemGroundChanged(*)
{
    WCV.Color[4] := UpdateBlueComponentFromHexToHexInt(WCV.Color[4], MUpDown_WCColorBElemGround.Value)
    WCGC_ColorElemUpdate(4)
}

WCGC_RedCompElemDarkChanged(*)
{
    WCV.Color[5] := UpdateRedComponentFromHexToHexInt(WCV.Color[5], MUpDown_WCColorRElemDark.Value)
    WCGC_ColorElemUpdate(5)
}
WCGC_GreenCompElemDarkChanged(*)
{
    WCV.Color[5] := UpdateGreenComponentFromHexToHexInt(WCV.Color[5], MUpDown_WCColorGElemDark.Value)
    WCGC_ColorElemUpdate(5)
}
WCGC_BlueCompElemDarkChanged(*)
{
    WCV.Color[5] := UpdateBlueComponentFromHexToHexInt(WCV.Color[5], MUpDown_WCColorBElemDark.Value)
    WCGC_ColorElemUpdate(5)
}

WCGC_RedCompElemLightChanged(*)
{
    WCV.Color[6] := UpdateRedComponentFromHexToHexInt(WCV.Color[6], MUpDown_WCColorRElemLight.Value)
    WCGC_ColorElemUpdate(6)
}
WCGC_GreenCompElemLightChanged(*)
{
    WCV.Color[6] := UpdateGreenComponentFromHexToHexInt(WCV.Color[6], MUpDown_WCColorGElemLight.Value)
    WCGC_ColorElemUpdate(6)
}
WCGC_BlueCompElemLightChanged(*)
{
    WCV.Color[6] := UpdateBlueComponentFromHexToHexInt(WCV.Color[6], MUpDown_WCColorBElemLight.Value)
    WCGC_ColorElemUpdate(6)
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
        ;MStatusBar_MainStatus.SetText( "KeyPress String: " . StrBuilder ,, 0)
        Return StrBuilder
    }
}

RedComponentFromHexAsRGBInt(ColorHexAsInt)
{
    Return Integer((ColorHexAsInt & 0xFF0000) >> 16)
}
GreenComponentFromHexAsRGBInt(ColorHexAsInt)
{
    Return Integer((ColorHexAsInt & 0xFF00) >> 8)
}
BlueComponentFromHexAsRGBInt(ColorHexAsInt)
{
    Return Integer(ColorHexAsInt & 0xFF)
}
UpdateRedComponentFromHexToHexInt(ColorHexAsInt, RedInt)
{
    Return ((RedInt & 0xFF)<<16) | ((GreenComponentFromHexAsRGBInt(ColorHexAsInt) & 0xFF)<<8) | (BlueComponentFromHexAsRGBInt(ColorHexAsInt) & 0xFF)
}
UpdateGreenComponentFromHexToHexInt(ColorHexAsInt, GreenInt)
{
    Return ((RedComponentFromHexAsRGBInt(ColorHexAsInt) & 0xFF)<<16) | ((GreenInt & 0xFF)<<8) | (BlueComponentFromHexAsRGBInt(ColorHexAsInt) & 0xFF)
}
UpdateBlueComponentFromHexToHexInt(ColorHexAsInt, BlueInt)
{
    Return ((RedComponentFromHexAsRGBInt(ColorHexAsInt) & 0xFF)<<16) | ((GreenComponentFromHexAsRGBInt(ColorHexAsInt) & 0xFF)<<8) | (BlueInt & 0xFF)
}
MaxVariationColorFromHexToHexString(ColorHexAsInt, VariationInt)
{
    Red := Min( RedComponentFromHexAsRGBInt(ColorHexAsInt) + VariationInt, 255 )
    Green := Min( GreenComponentFromHexAsRGBInt(ColorHexAsInt) + VariationInt, 255 )
    Blue := Min( BlueComponentFromHexAsRGBInt(ColorHexAsInt) + VariationInt, 255 )
    Return "0x" . Format("{:X}", ((Red & 0xFF)<<16) | ((Green & 0xFF)<<8) | (Blue & 0xFF))
}
MinVariationColorFromHexToHexString(ColorHexAsInt, VariationInt)
{
    Red := Max( RedComponentFromHexAsRGBInt(ColorHexAsInt) - VariationInt, 0 )
    Green := Max( GreenComponentFromHexAsRGBInt(ColorHexAsInt) - VariationInt, 0 )
    Blue := Max( BlueComponentFromHexAsRGBInt(ColorHexAsInt) - VariationInt, 0 )
    Return "0x" . Format("{:X}", ((Red & 0xFF)<<16) | ((Green & 0xFF)<<8) | (Blue & 0xFF))
}
IntWrap(kX, LB, UB)
{
    Rang := UB - LB + 1
    If (kX < LB)
    {
        kX := kX + Rang * ((LB - kX) / Rang + 1)
    }
    Return LB + Mod((kX - LB), Rang)
}
LoadSettingsIni()
{
    global
    local iniFilePath := A_ScriptDir "\"  Conf.SettingsFile

    JAG.XW                  := IniRead( iniFilePath, "JA", "JAG.XW", JAG.XW )
    JAG.YW                  := IniRead( iniFilePath, "JA", "JAG.YW", JAG.YW )
    JAG.W                   := IniRead( iniFilePath, "JA", "JAG.W", JAG.W )
    JAG.H                   := IniRead( iniFilePath, "JA", "JAG.H", JAG.H )
    JAG.WindowCanMove       := IniRead( iniFilePath, "JA", "JAG.WindowCanMove", JAG.WindowCanMove )
    JAV.Enabled             := IniRead( iniFilePath, "JA", "JAV.Enabled", JAV.Enabled )
    JAV.Freq                := IniRead( iniFilePath, "JA", "JAV.Freq", JAV.Freq )
    JAV.Thresh              := IniRead( iniFilePath, "JA", "JAV.Thresh", JAV.Thresh )
    JAV.Delay               := IniRead( iniFilePath, "JA", "JAV.Delay", JAV.Delay )
    JAV.Hotkey              := IniRead( iniFilePath, "JA", "JAV.Hotkey", JAV.Hotkey )
    JAV.PressKey            := ConvertHotKeyToKeyPress(JAV.HotKey)

    PCG.XW                  := IniRead( iniFilePath, "PC", "PCG.XW", PCG.XW )
    PCG.YW                  := IniRead( iniFilePath, "PC", "PCG.YW", PCG.YW )
    PCG.W                   := IniRead( iniFilePath, "PC", "PCG.W", PCG.W )
    PCG.H                   := IniRead( iniFilePath, "PC", "PCG.H", PCG.H )
    PCG.WindowCanMove       := IniRead( iniFilePath, "PC", "PCG.WindowCanMove", PCG.WindowCanMove )
    PCV.Enabled             := IniRead( iniFilePath, "PC", "PCV.Enabled", PCV.Enabled )
    PCV.Freq                := IniRead( iniFilePath, "PC", "PCV.Freq", PCV.Freq )
    PCV.PPThresh            := IniRead( iniFilePath, "PC", "PCV.PPThresh", PCV.PPThresh )
    PCV.TrigThresh          := IniRead( iniFilePath, "PC", "PCV.TrigThresh", PCV.TrigThresh )
    PCV.Delay               := IniRead( iniFilePath, "PC", "PCV.Delay", PCV.Delay )
    PCV.Hotkey              := IniRead( iniFilePath, "PC", "PCV.Hotkey", PCV.HotKey )
    PCV.PressKey            := ConvertHotKeyToKeyPress(PCV.HotKey)

    THG.XW                  := IniRead( iniFilePath, "TH", "THG.XW", THG.XW )
    THG.YW                  := IniRead( iniFilePath, "TH", "THG.YW", THG.YW )
    THG.W                   := IniRead( iniFilePath, "TH", "THG.W", THG.W )
    THG.H                   := IniRead( iniFilePath, "TH", "THG.H", THG.H )
    THG.WindowCanMove       := IniRead( iniFilePath, "TH", "THG.WindowCanMove", THG.WindowCanMove )
    THV.Enabled             := IniRead( iniFilePath, "TH", "THV.Enabled", THV.Enabled )
    THV.Freq                := IniRead( iniFilePath, "TH", "THV.Freq", THV.Freq )
    THV.HPThresh            := IniRead( iniFilePath, "TH", "THV.PPThresh", THV.HPThresh )
    THV.TrigThresh          := IniRead( iniFilePath, "TH", "THV.TrigThresh", THV.TrigThresh )
    THV.Delay               := IniRead( iniFilePath, "TH", "THV.Delay", THV.Delay )
    THV.Hotkey              := IniRead( iniFilePath, "TH", "THV.Hotkey", THV.HotKey )
    THV.PressKey            := ConvertHotKeyToKeyPress(THV.HotKey)

    ASG.XW                  := IniRead( iniFilePath, "AS", "ASG.XW", ASG.XW )
    ASG.YW                  := IniRead( iniFilePath, "AS", "ASG.YW", ASG.YW )
    ASG.W                   := IniRead( iniFilePath, "AS", "ASG.W", ASG.W )
    ASG.H                   := IniRead( iniFilePath, "AS", "ASG.H", ASG.H )
    ASG.WindowCanMove       := IniRead( iniFilePath, "AS", "ASG.WindowCanMove", ASG.WindowCanMove )
    ASV.Enabled             := IniRead( iniFilePath, "AS", "ASV.Enabled", ASV.Enabled )
    ASV.InputMode           := IniRead( iniFilePath, "AS", "ASV.InputMode", ASV.InputMode )
    ASV.Color.InsertAt( ASV.ColorLookup["Fire"],        IniRead( iniFilePath, "AS", "ASV.Color." . "Fire",          0xFE7878 ) )
    ASV.Color.InsertAt( ASV.ColorLookup["Ice"],         IniRead( iniFilePath, "AS", "ASV.Color." . "Ice",           0x7272FF ) )
    ASV.Color.InsertAt( ASV.ColorLookup["Lightning"],   IniRead( iniFilePath, "AS", "ASV.Color." . "Lightning",     0xDADA2B ) )
    ASV.Color.InsertAt( ASV.ColorLookup["Ground"],      IniRead( iniFilePath, "AS", "ASV.Color." . "Ground",        0xE47D00 ) )
    ASV.Color.InsertAt( ASV.ColorLookup["Dark"],        IniRead( iniFilePath, "AS", "ASV.Color." . "Dark",          0x653865 ) )
    ASV.Color.InsertAt( ASV.ColorLookup["Light"],       IniRead( iniFilePath, "AS", "ASV.Color." . "Light",         0xFFC7AD ) )
    ASV.HotKey.InsertAt( ASV.ColorLookup["Fire"],       IniRead( iniFilePath, "AS", "ASV.HotKey." . "Fire",         "+F1" ) )
    ASV.HotKey.InsertAt( ASV.ColorLookup["Ice"],        IniRead( iniFilePath, "AS", "ASV.HotKey." . "Ice",          "+F2" ) )
    ASV.HotKey.InsertAt( ASV.ColorLookup["Lightning"],  IniRead( iniFilePath, "AS", "ASV.HotKey." . "Lightning",    "+F3" ) )
    ASV.HotKey.InsertAt( ASV.ColorLookup["Ground"],     IniRead( iniFilePath, "AS", "ASV.HotKey." . "Ground",       "+F4" ) )
    ASV.HotKey.InsertAt( ASV.ColorLookup["Dark"],       IniRead( iniFilePath, "AS", "ASV.HotKey." . "Dark",         "+F5" ) )
    ASV.HotKey.InsertAt( ASV.ColorLookup["Light"],      IniRead( iniFilePath, "AS", "ASV.HotKey." . "Light",        "+F6" ) )
    ASV.TypeText.InsertAt( ASV.ColorLookup["Fire"],     IniRead( iniFilePath, "AS", "ASV.TypeText." . "Fire",       "/sl f" ) )
    ASV.TypeText.InsertAt( ASV.ColorLookup["Ice"],      IniRead( iniFilePath, "AS", "ASV.TypeText." . "Ice",        "/sl i" ) )
    ASV.TypeText.InsertAt( ASV.ColorLookup["Lightning"],IniRead( iniFilePath, "AS", "ASV.TypeText." . "Lightning",  "/sl t" ) )
    ASV.TypeText.InsertAt( ASV.ColorLookup["Ground"],   IniRead( iniFilePath, "AS", "ASV.TypeText." . "Ground",     "/sl e" ) )
    ASV.TypeText.InsertAt( ASV.ColorLookup["Dark"],     IniRead( iniFilePath, "AS", "ASV.TypeText." . "Dark",       "/sl d" ) )
    ASV.TypeText.InsertAt( ASV.ColorLookup["Light"],    IniRead( iniFilePath, "AS", "ASV.TypeText." . "Light",      "/sl l" ) )
    Loop 6
    {
        ASV.PressKey.InsertAt( A_Index, ConvertHotKeyToKeyPress(ASV.HotKey[A_Index]) )
    }
    
    WCG.XW                  := IniRead( iniFilePath, "WC", "WCG.XW", WCG.XW )
    WCG.YW                  := IniRead( iniFilePath, "WC", "WCG.YW", WCG.YW )
    WCG.W                   := IniRead( iniFilePath, "WC", "WCG.W", WCG.W )
    WCG.H                   := IniRead( iniFilePath, "WC", "WCG.H", WCG.H )
    WCG.WindowCanMove       := IniRead( iniFilePath, "WC", "WCG.WindowCanMove", WCG.WindowCanMove )
    WCV.Enabled             := IniRead( iniFilePath, "WC", "WCV.Enabled", WCV.Enabled )
    WCV.InputMode           := IniRead( iniFilePath, "WC", "WCV.InputMode", WCV.InputMode )
    WCV.Color.InsertAt( WCV.ColorLookup["Fire"],        IniRead( iniFilePath, "WC", "WCV.Color." . "Fire",          0xFE7878 ) )
    WCV.Color.InsertAt( WCV.ColorLookup["Ice"],         IniRead( iniFilePath, "WC", "WCV.Color." . "Ice",           0x7D7DFF ) )
    WCV.Color.InsertAt( WCV.ColorLookup["Lightning"],   IniRead( iniFilePath, "WC", "WCV.Color." . "Lightning",     0xFFFF32 ) )
    WCV.Color.InsertAt( WCV.ColorLookup["Ground"],      IniRead( iniFilePath, "WC", "WCV.Color." . "Ground",        0xFF8C00 ) )
    WCV.Color.InsertAt( WCV.ColorLookup["Dark"],        IniRead( iniFilePath, "WC", "WCV.Color." . "Dark",          0xFF8CFF ) )
    WCV.Color.InsertAt( WCV.ColorLookup["Light"],       IniRead( iniFilePath, "WC", "WCV.Color." . "Light",         0xFFCDB4 ) )
    WCV.HotKey.InsertAt( WCV.ColorLookup["Fire"],       IniRead( iniFilePath, "WC", "WCV.HotKey." . "Fire",         "+F7" ) )
    WCV.HotKey.InsertAt( WCV.ColorLookup["Ice"],        IniRead( iniFilePath, "WC", "WCV.HotKey." . "Ice",          "+F8" ) )
    WCV.HotKey.InsertAt( WCV.ColorLookup["Lightning"],  IniRead( iniFilePath, "WC", "WCV.HotKey." . "Lightning",    "+F9" ) )
    WCV.HotKey.InsertAt( WCV.ColorLookup["Ground"],     IniRead( iniFilePath, "WC", "WCV.HotKey." . "Ground",       "+F10" ) )
    WCV.HotKey.InsertAt( WCV.ColorLookup["Dark"],       IniRead( iniFilePath, "WC", "WCV.HotKey." . "Dark",         "+F11" ) )
    WCV.HotKey.InsertAt( WCV.ColorLookup["Light"],      IniRead( iniFilePath, "WC", "WCV.HotKey." . "Light",        "+F12" ) )
    WCV.TypeText.InsertAt( WCV.ColorLookup["Fire"],     IniRead( iniFilePath, "WC", "WCV.TypeText." . "Fire",       "/wp 1" ) )
    WCV.TypeText.InsertAt( WCV.ColorLookup["Ice"],      IniRead( iniFilePath, "WC", "WCV.TypeText." . "Ice",        "/wp 2" ) )
    WCV.TypeText.InsertAt( WCV.ColorLookup["Lightning"],IniRead( iniFilePath, "WC", "WCV.TypeText." . "Lightning",  "/wp 3" ) )
    WCV.TypeText.InsertAt( WCV.ColorLookup["Ground"],   IniRead( iniFilePath, "WC", "WCV.TypeText." . "Ground",     "/wp 4" ) )
    WCV.TypeText.InsertAt( WCV.ColorLookup["Dark"],     IniRead( iniFilePath, "WC", "WCV.TypeText." . "Dark",       "/wp 5" ) )
    WCV.TypeText.InsertAt( WCV.ColorLookup["Light"],    IniRead( iniFilePath, "WC", "WCV.TypeText." . "Light",      "/wp 6" ) )
    Loop 6
    {
        WCV.PressKey.InsertAt( A_Index, ConvertHotKeyToKeyPress(WCV.HotKey[A_Index]) )
    }

}
SaveSettingsIni(*)
{
    global
    local iniFilePath := A_ScriptDir "\"  Conf.SettingsFile
    local X, Y

    JAG.GUI.GetPos( &X, &Y )
    IniWrite  X,                    iniFilePath, "JA", "JAG.XW"
    IniWrite  Y,                    iniFilePath, "JA", "JAG.YW"
    IniWrite  JAG.W,                iniFilePath, "JA", "JAG.W"
    IniWrite  JAG.H,                iniFilePath, "JA", "JAG.H"
    IniWrite  JAG.WindowCanMove,    iniFilePath, "JA", "JAG.WindowCanMove"
    IniWrite  JAV.Enabled,          iniFilePath, "JA", "JAV.Enabled"
    IniWrite  JAV.Freq,             iniFilePath, "JA", "JAV.Freq"
    IniWrite  JAV.Thresh,           iniFilePath, "JA", "JAV.Thresh"
    IniWrite  JAV.Delay,            iniFilePath, "JA", "JAV.Delay"
    IniWrite  JAV.HotKey,           iniFilePath, "JA", "JAV.HotKey"

    PCG.GUI.GetPos( &X, &Y )
    IniWrite  X,                    iniFilePath, "PC", "PCG.XW"
    IniWrite  Y,                    iniFilePath, "PC", "PCG.YW"
    IniWrite  PCG.W,                iniFilePath, "PC", "PCG.W"
    IniWrite  PCG.H,                iniFilePath, "PC", "PCG.H"
    IniWrite  PCG.WindowCanMove,    iniFilePath, "PC", "PCG.WindowCanMove"
    IniWrite  PCV.Enabled,          iniFilePath, "PC", "PCV.Enabled"
    IniWrite  PCV.Freq,             iniFilePath, "PC", "PCV.Freq"
    IniWrite  PCV.PPThresh,         iniFilePath, "PC", "PCV.PPThresh"
    IniWrite  PCV.TrigThresh,       iniFilePath, "PC", "PCV.TrigThresh"
    IniWrite  PCV.Delay,            iniFilePath, "PC", "PCV.Delay"
    IniWrite  PCV.HotKey,           iniFilePath, "PC", "PCV.HotKey"
    
    THG.GUI.GetPos( &X, &Y )
    IniWrite  X,                    iniFilePath, "TH", "THG.XW"
    IniWrite  Y,                    iniFilePath, "TH", "THG.YW"
    IniWrite  THG.W,                iniFilePath, "TH", "THG.W"
    IniWrite  THG.H,                iniFilePath, "TH", "THG.H"
    IniWrite  THG.WindowCanMove,    iniFilePath, "TH", "THG.WindowCanMove"
    IniWrite  THV.Enabled,          iniFilePath, "TH", "THV.Enabled"
    IniWrite  THV.Freq,             iniFilePath, "TH", "THV.Freq"
    IniWrite  THV.HPThresh,         iniFilePath, "TH", "THV.HPThresh"
    IniWrite  THV.TrigThresh,       iniFilePath, "TH", "THV.TrigThresh"
    IniWrite  THV.Delay,            iniFilePath, "TH", "THV.Delay"
    IniWrite  THV.HotKey,           iniFilePath, "TH", "THV.HotKey"
    
    ASG.GUI.GetPos( &X, &Y )
    IniWrite  X,                    iniFilePath, "AS", "ASG.XW"
    IniWrite  Y,                    iniFilePath, "AS", "ASG.YW"
    IniWrite  ASG.W,                iniFilePath, "AS", "ASG.W"
    IniWrite  ASG.H,                iniFilePath, "AS", "ASG.H"
    IniWrite  ASG.WindowCanMove,    iniFilePath, "AS", "ASG.WindowCanMove"
    IniWrite  ASV.Enabled,          iniFilePath, "AS", "ASV.Enabled"
    IniWrite  ASV.InputMode,        iniFilePath, "AS", "ASV.InputMode"
    IniWrite  ASV.Color[1],         iniFilePath, "AS", "ASV.Color." . ASV.ColorRevLookup[1]
    IniWrite  ASV.Color[2],         iniFilePath, "AS", "ASV.Color." . ASV.ColorRevLookup[2]
    IniWrite  ASV.Color[3],         iniFilePath, "AS", "ASV.Color." . ASV.ColorRevLookup[3]
    IniWrite  ASV.Color[4],         iniFilePath, "AS", "ASV.Color." . ASV.ColorRevLookup[4]
    IniWrite  ASV.Color[5],         iniFilePath, "AS", "ASV.Color." . ASV.ColorRevLookup[5]
    IniWrite  ASV.Color[6],         iniFilePath, "AS", "ASV.Color." . ASV.ColorRevLookup[6]
    IniWrite  ASV.HotKey[1],        iniFilePath, "AS", "ASV.HotKey." . ASV.ColorRevLookup[1]
    IniWrite  ASV.HotKey[2],        iniFilePath, "AS", "ASV.HotKey." . ASV.ColorRevLookup[2]
    IniWrite  ASV.HotKey[3],        iniFilePath, "AS", "ASV.HotKey." . ASV.ColorRevLookup[3]
    IniWrite  ASV.HotKey[4],        iniFilePath, "AS", "ASV.HotKey." . ASV.ColorRevLookup[4]
    IniWrite  ASV.HotKey[5],        iniFilePath, "AS", "ASV.HotKey." . ASV.ColorRevLookup[5]
    IniWrite  ASV.HotKey[6],        iniFilePath, "AS", "ASV.HotKey." . ASV.ColorRevLookup[6]
    IniWrite  ASV.TypeText[1],      iniFilePath, "AS", "ASV.TypeText." . ASV.ColorRevLookup[1]
    IniWrite  ASV.TypeText[2],      iniFilePath, "AS", "ASV.TypeText." . ASV.ColorRevLookup[2]
    IniWrite  ASV.TypeText[3],      iniFilePath, "AS", "ASV.TypeText." . ASV.ColorRevLookup[3]
    IniWrite  ASV.TypeText[4],      iniFilePath, "AS", "ASV.TypeText." . ASV.ColorRevLookup[4]
    IniWrite  ASV.TypeText[5],      iniFilePath, "AS", "ASV.TypeText." . ASV.ColorRevLookup[5]
    IniWrite  ASV.TypeText[6],      iniFilePath, "AS", "ASV.TypeText." . ASV.ColorRevLookup[6]
    
    WCG.GUI.GetPos( &X, &Y )
    IniWrite  X,                    iniFilePath, "WC", "WCG.XW"
    IniWrite  Y,                    iniFilePath, "WC", "WCG.YW"
    IniWrite  WCG.W,                iniFilePath, "WC", "WCG.W"
    IniWrite  WCG.H,                iniFilePath, "WC", "WCG.H"
    IniWrite  WCG.WindowCanMove,    iniFilePath, "WC", "WCG.WindowCanMove"
    IniWrite  WCV.Enabled,          iniFilePath, "WC", "WCV.Enabled"
    IniWrite  WCV.InputMode,        iniFilePath, "WC", "WCV.InputMode"
    IniWrite  WCV.Color[1],         iniFilePath, "WC", "WCV.Color." . WCV.ColorRevLookup[1]
    IniWrite  WCV.Color[2],         iniFilePath, "WC", "WCV.Color." . WCV.ColorRevLookup[2]
    IniWrite  WCV.Color[3],         iniFilePath, "WC", "WCV.Color." . WCV.ColorRevLookup[3]
    IniWrite  WCV.Color[4],         iniFilePath, "WC", "WCV.Color." . WCV.ColorRevLookup[4]
    IniWrite  WCV.Color[5],         iniFilePath, "WC", "WCV.Color." . WCV.ColorRevLookup[5]
    IniWrite  WCV.Color[6],         iniFilePath, "WC", "WCV.Color." . WCV.ColorRevLookup[6]
    IniWrite  WCV.HotKey[1],        iniFilePath, "WC", "WCV.HotKey." . WCV.ColorRevLookup[1]
    IniWrite  WCV.HotKey[2],        iniFilePath, "WC", "WCV.HotKey." . WCV.ColorRevLookup[2]
    IniWrite  WCV.HotKey[3],        iniFilePath, "WC", "WCV.HotKey." . WCV.ColorRevLookup[3]
    IniWrite  WCV.HotKey[4],        iniFilePath, "WC", "WCV.HotKey." . WCV.ColorRevLookup[4]
    IniWrite  WCV.HotKey[5],        iniFilePath, "WC", "WCV.HotKey." . WCV.ColorRevLookup[5]
    IniWrite  WCV.HotKey[6],        iniFilePath, "WC", "WCV.HotKey." . WCV.ColorRevLookup[6]
    IniWrite  WCV.TypeText[1],      iniFilePath, "WC", "WCV.TypeText." . WCV.ColorRevLookup[1]
    IniWrite  WCV.TypeText[2],      iniFilePath, "WC", "WCV.TypeText." . WCV.ColorRevLookup[2]
    IniWrite  WCV.TypeText[3],      iniFilePath, "WC", "WCV.TypeText." . WCV.ColorRevLookup[3]
    IniWrite  WCV.TypeText[4],      iniFilePath, "WC", "WCV.TypeText." . WCV.ColorRevLookup[4]
    IniWrite  WCV.TypeText[5],      iniFilePath, "WC", "WCV.TypeText." . WCV.ColorRevLookup[5]
    IniWrite  WCV.TypeText[6],      iniFilePath, "WC", "WCV.TypeText." . WCV.ColorRevLookup[6]
}


OnExit ExitFunc

ExitFunc(ExitReason, ExitCode)
{
    Send "{Right up}{F9 up}{F8 up}{Shift up}"
}

