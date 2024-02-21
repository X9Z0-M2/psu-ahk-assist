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
global Conf := {}
Conf.SettingsFile := "psuassist.conf"

global JAG := {}
global JAV := {}
JAG.X := 0
JAG.Y := 0
JAG.W := 11
JAG.H := 11
JAV.Freq := 1
JAV.Thresh := 3
JAV.Delay := 70
JAV.HotKey := "Right"
JAV.PressKey := ConvertHotKeyToKeyPress(JAV.HotKey)
JAG.SkipGuiResize := 0
JAG.WindowCanMove := 0
JAV.Count := 0

global PCG := {}
global PCV := {}
PCG.X := 0
PCG.Y := 0
PCG.MX := 0
PCG.MY := 0
PCG.W := 120
PCG.H := 1
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
THG.MX := 0
THG.MY := 0
THG.W := 130
THG.H := 1
THV.Count := 0
THV.Freq := 150
THV.HPThresh := 60
THV.TrigThresh := 2
THV.Delay := 0
THV.BarPercent := -1
THV.HotKey := "+F8"
THV.PressKey := ConvertHotKeyToKeyPress(THV.HotKey)
THG.SkipGuiResize := 0
THG.WindowCanMove := 0

global ASG := {}
global ASV := {}
ASG.X := 0
ASG.Y := 0
ASG.MX := 0
ASG.MY := 0
ASG.W := 16
ASG.H := 1
ASV.Count := 0
ASV.Freq := 225
ASV.DetectionVariation := 12 ; can be 0-255
ASV.TrigThresh := 2
ASV.Delay := 0
ASV.CanChange := 1
ASV.DurationBeforeNextChange := 10000 ; 15 seconds before can swap again
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
ASV.TypeText.InsertAt( ASV.ColorLookup["Dark"],      "/sl l" )
ASV.TypeText.InsertAt( ASV.ColorLookup["Light"],     "/sl d" )
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
ASG.WindowCanMove := 0


; TODO: enable and finish settings file loading
; LoadSettings(FileName)
; {
;     global
;     If (FileExist(FileName))
;     {
;         Loop read, FileName
;         {
;             LoadSettings_TermArray := StrSplit(A_LoopReadLine, "=")
;             LoadSettings_SearchTerm := LoadSettings_TermArray[1]
;             LoadSettings_TermValue := LoadSettings_TermArray[2]
;             If (LoadSettings_SearchTerm = "JAG.X")
;             {
;                 JAG.X := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "JAG.Y")
;             {
;                 JAG.Y := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "JAG.W")
;             {
;                 JAG.W := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "JAG.H")
;             {
;                 JAG.H := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "JAV.Freq")
;             {
;                 JAV.Freq := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "JAV.Thresh")
;             {
;                 JAV.Thresh := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "JAV.Delay")
;             {
;                 JAV.Delay := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "JAV.HotKey")
;             {
;                 JAV.HotKey := LoadSettings_TermValue
;                 JAV.PressKey := ConvertHotKeyToKeyPress(JAV.HotKey)
;             }

;             If (LoadSettings_SearchTerm = "PCG.X")
;             {
;                 PCG.X := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "PCG.Y")
;             {
;                 PCG.Y := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "PCG.W")
;             {
;                 PCG.W := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "PCG.H")
;             {
;                 PCG.H := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "PCV.Freq")
;             {
;                 PCV.Freq := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "PCV.PPThresh")
;             {
;                 PCV.PPThresh := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "PCV.TrigThresh")
;             {
;                 PCV.TrigThresh := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "PCV.Delay")
;             {
;                 PCV.Delay := LoadSettings_TermValue
;             }
;             If (LoadSettings_SearchTerm = "PCV.HotKey")
;             {
;                 PCV.HotKey := LoadSettings_TermValue
;                 PCV.PressKey := ConvertHotKeyToKeyPress(PCV.HotKey)
;             }
;         }
;     }
; }
; LoadSettings(Conf.SettingsFile)

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
MProgress_ASC := Menu_Gui.Add("Progress", "YS93 XS103 w20 h18 c0x666666 Smooth vArmorSwapCurrent", -1)
MProgress_ASC.Value := 100


MTab_Settings := Menu_Gui.Add("Tab3","-Wrap XS w130", ["JA","PC","TH","AS","AS Keys","AS Clrs"])

MTab_Settings.UseTab(1)
MButton_ShowJA := Menu_Gui.Add("Button", "", "Hide JA")
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
Menu_Gui.Add("Text", "Section", "FIRE")
MProgress_ASCCFEMX := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorFireElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[1],ASV.DetectionVariation), -1)
MProgress_ASCCFEMX.Value := 100
MProgress_ASCCFE := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorFireElement c" . Format("{:X}", ASV.Color[1]), -1)
MProgress_ASCCFE.Value := 100
MProgress_ASCCFEMN := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorFireElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[1],ASV.DetectionVariation), -1)
MProgress_ASCCFEMN.Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ArmorSwapColorRElemFireChanged)
MUpDown_ASColorRElemFire := Menu_Gui.Add("UpDown", "vASColorRElemFireUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[1]))
MUpDown_ASColorRElemFire.OnEvent("Change", ArmorSwapColorRElemFireChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ArmorSwapColorGElemFireChanged)
MUpDown_ASColorGElemFire := Menu_Gui.Add("UpDown", "vASColorGElemFireUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[1]))
MUpDown_ASColorGElemFire.OnEvent("Change", ArmorSwapColorGElemFireChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ArmorSwapColorBElemFireChanged)
MUpDown_ASColorBElemFire := Menu_Gui.Add("UpDown", "vASColorBElemFireUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[1]))
MUpDown_ASColorBElemFire.OnEvent("Change", ArmorSwapColorBElemFireChanged)

Menu_Gui.Add("Text", "Section XS", "ICE")
MProgress_ASCCIEMX := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorIceElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[2],ASV.DetectionVariation), -1)
MProgress_ASCCIEMX.Value := 100
MProgress_ASCCIE := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorIceElement c" . Format("{:X}", ASV.Color[2]), -1)
MProgress_ASCCIE.Value := 100
MProgress_ASCCIEMN := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorIceElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[2],ASV.DetectionVariation), -1)
MProgress_ASCCIEMN.Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ArmorSwapColorRElemIceChanged)
MUpDown_ASColorRElemIce := Menu_Gui.Add("UpDown", "vASColorRElemIceUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[2]))
MUpDown_ASColorRElemIce.OnEvent("Change", ArmorSwapColorRElemIceChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ArmorSwapColorGElemIceChanged)
MUpDown_ASColorGElemIce := Menu_Gui.Add("UpDown", "vASColorGElemIceUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[2]))
MUpDown_ASColorGElemIce.OnEvent("Change", ArmorSwapColorGElemIceChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ArmorSwapColorBElemIceChanged)
MUpDown_ASColorBElemIce := Menu_Gui.Add("UpDown", "vASColorBElemIceUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[2]))
MUpDown_ASColorBElemIce.OnEvent("Change", ArmorSwapColorBElemIceChanged)

Menu_Gui.Add("Text", "Section XS", "LIGHTNING")
MProgress_ASCCLNEMX := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorLightningElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[3],ASV.DetectionVariation), -1)
MProgress_ASCCLNEMX.Value := 100
MProgress_ASCCLNE := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorLightningElement c" . Format("{:X}", ASV.Color[3]), -1)
MProgress_ASCCLNE.Value := 100
MProgress_ASCCLNEMN := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorLightningElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[3],ASV.DetectionVariation), -1)
MProgress_ASCCLNEMN.Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ArmorSwapColorRElemLightningChanged)
MUpDown_ASColorRElemLightning := Menu_Gui.Add("UpDown", "vASColorRElemLightningUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[3]))
MUpDown_ASColorRElemLightning.OnEvent("Change", ArmorSwapColorRElemLightningChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ArmorSwapColorGElemLightningChanged)
MUpDown_ASColorGElemLightning := Menu_Gui.Add("UpDown", "vASColorGElemLightningUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[3]))
MUpDown_ASColorGElemLightning.OnEvent("Change", ArmorSwapColorGElemLightningChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ArmorSwapColorBElemLightningChanged)
MUpDown_ASColorBElemLightning := Menu_Gui.Add("UpDown", "vASColorBElemLightningUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[3]))
MUpDown_ASColorBElemLightning.OnEvent("Change", ArmorSwapColorBElemLightningChanged)

Menu_Gui.Add("Text", "Section XS", "GROUND")
MProgress_ASCCGEMX := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorGroundElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[4],ASV.DetectionVariation), -1)
MProgress_ASCCGEMX.Value := 100
MProgress_ASCCGE := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorGroundElement c" . Format("{:X}", ASV.Color[4]), -1)
MProgress_ASCCGE.Value := 100
MProgress_ASCCGEMN := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorGroundElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[4],ASV.DetectionVariation), -1)
MProgress_ASCCGEMN.Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ArmorSwapColorRElemGroundChanged)
MUpDown_ASColorRElemGround := Menu_Gui.Add("UpDown", "vASColorRElemGroundUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[4]))
MUpDown_ASColorRElemGround.OnEvent("Change", ArmorSwapColorRElemGroundChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ArmorSwapColorGElemGroundChanged)
MUpDown_ASColorGElemGround := Menu_Gui.Add("UpDown", "vASColorGElemGroundUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[4]))
MUpDown_ASColorGElemGround.OnEvent("Change", ArmorSwapColorGElemGroundChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ArmorSwapColorBElemGroundChanged)
MUpDown_ASColorBElemGround := Menu_Gui.Add("UpDown", "vASColorBElemGroundUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[4]))
MUpDown_ASColorBElemGround.OnEvent("Change", ArmorSwapColorBElemGroundChanged)

Menu_Gui.Add("Text", "Section XS", "DARK")
MProgress_ASCCDEMX := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorDarkElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[5],ASV.DetectionVariation), -1)
MProgress_ASCCDEMX.Value := 100
MProgress_ASCCDE := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorDarkElement c" . Format("{:X}", ASV.Color[5]), -1)
MProgress_ASCCDE.Value := 100
MProgress_ASCCDEMN := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorDarkElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[5],ASV.DetectionVariation), -1)
MProgress_ASCCDEMN.Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ArmorSwapColorRElemDarkChanged)
MUpDown_ASColorRElemDark := Menu_Gui.Add("UpDown", "vASColorRElemDarkUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[5]))
MUpDown_ASColorRElemDark.OnEvent("Change", ArmorSwapColorRElemDarkChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ArmorSwapColorGElemDarkChanged)
MUpDown_ASColorGElemDark := Menu_Gui.Add("UpDown", "vASColorGElemDarkUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[5]))
MUpDown_ASColorGElemDark.OnEvent("Change", ArmorSwapColorGElemDarkChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ArmorSwapColorBElemDarkChanged)
MUpDown_ASColorBElemDark := Menu_Gui.Add("UpDown", "vASColorBElemDarkUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[5]))
MUpDown_ASColorBElemDark.OnEvent("Change", ArmorSwapColorBElemDarkChanged)

Menu_Gui.Add("Text", "Section XS", "LIGHT")
MProgress_ASCCLIEMX := Menu_Gui.Add("Progress", "YS XS" . MinColorPos . " w" . MinColorWidth . " h14 Smooth vASCurrentColorLightElementMax c" . MaxVariationColorFromHexToHexString(ASV.Color[6],ASV.DetectionVariation), -1)
MProgress_ASCCLIEMX.Value := 100
MProgress_ASCCLIE := Menu_Gui.Add("Progress", "YS XS" . MidColorPos . " w" . MidColorWidth . " h14 Smooth vASCurrentColorLightElement c" . Format("{:X}", ASV.Color[6]), -1)
MProgress_ASCCLIE.Value := 100
MProgress_ASCCLIEMN := Menu_Gui.Add("Progress", "YS XS" . MaxColorPos . " w" . MaxColorWidth . " h14 Smooth vASCurrentColorLightElementMin c" . MinVariationColorFromHexToHexString(ASV.Color[6],ASV.DetectionVariation), -1)
MProgress_ASCCLIEMN.Value := 100
Menu_Gui.Add("Edit", "Section XS w40").OnEvent("Change", ArmorSwapColorRElemLightChanged)
MUpDown_ASColorRElemLight := Menu_Gui.Add("UpDown", "vASColorRElemLightUpDown Range0-255", RedComponentFromHexAsRGBInt(ASV.Color[6]))
MUpDown_ASColorRElemLight.OnEvent("Change", ArmorSwapColorRElemLightChanged)
Menu_Gui.Add("Edit", "YS XS40 w40").OnEvent("Change", ArmorSwapColorGElemLightChanged)
MUpDown_ASColorGElemLight := Menu_Gui.Add("UpDown", "vASColorGElemLightUpDown Range0-255", GreenComponentFromHexAsRGBInt(ASV.Color[6]))
MUpDown_ASColorGElemLight.OnEvent("Change", ArmorSwapColorGElemLightChanged)
Menu_Gui.Add("Edit", "YS XS80 w40").OnEvent("Change", ArmorSwapColorBElemLightChanged)
MUpDown_ASColorBElemLight := Menu_Gui.Add("UpDown", "vASColorBElemLightUpDown Range0-255", BlueComponentFromHexAsRGBInt(ASV.Color[6]))
MUpDown_ASColorBElemLight.OnEvent("Change", ArmorSwapColorBElemLightChanged)


MTab_Settings.UseTab(0)
Menu_Gui.Show("W150 H490")



; ; Create custom gui to represent where ahk is detecting pixels for auto Just Attack 
JAG.GUI := Gui("+AlwaysOnTop +MinSize5x5 +MaxSize25x25 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "JA")
JAG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
JAG.GUI.OnEvent("Size", GUI_Resize )
JAG.GUI.Show("W" . JAG.W . " H" . JAG.H)
WinSetTransColor(JAG.GUI.BackColor ,JAG.GUI.Hwnd)

; ; Create custom gui to represent where ahk is detecting pixels for auto Photon Charge 
PCG.GUI := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "PC")
PCG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
PCG.GUI.OnEvent("Size", GUI_Resize )
PCG.GUI.Show("W" . PCG.W . " H" . PCG.H)
WinSetTransColor(PCG.GUI.BackColor , PCG.GUI.Hwnd)

; ; Create custom gui to represent where ahk is detecting pixels for auto Trimates (healing) 
THG.GUI := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "TH")
THG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
THG.GUI.OnEvent("Size", GUI_Resize )
THG.GUI.Show("W" . THG.W . " H" . THG.H)
WinSetTransColor(THG.GUI.BackColor , THG.GUI.Hwnd)

; ; Create custom gui for enemy element type detection to armor swap
ASG.GUI := Gui("+AlwaysOnTop +MinSize5x1 +MaxSize900x10 +Resize +ToolWindow -MaximizeBox -MinimizeBox -SysMenu +Caption -DPIScale", "AS")
ASG.GUI.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
ASG.GUI.OnEvent("Size", GUI_Resize )
ASG.GUI.Show("W" . ASG.W . " H" . ASG.H)
WinSetTransColor(ASG.GUI.BackColor , ASG.GUI.Hwnd)

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
    Else
    {
        GUI_Resized := false
    }

    If (GUI_Resized = true)
    {
        ToolTip "X" X " Y" Y " W" W " H" H
        SetTimer () => ToolTip(), -1000, 10000
    }
    return True
}

; add hook for repositioning the ahk custom window
OnMessage(0x03, GuiRepositionedHook)
GuiRepositionedHook(wParam, lParam, msg, hwnd)
{
    if( hwnd = JAG.GUI.Hwnd )
    {
        GUI_Resize(JAG.GUI, 0, 0, 0)
    }
    else if ( hwnd = PCG.GUI.Hwnd )
    {
        GUI_Resize(PCG.GUI, 0, 0, 0)
    }
    else if ( hwnd = THG.GUI.Hwnd )
    {
        GUI_Resize(THG.GUI, 0, 0, 0)
    }
    else if ( hwnd = ASG.GUI.Hwnd )
    {
        GUI_Resize(ASG.GUI, 0, 0, 0)
    }
}
; Init position and size values
GUI_Resize(JAG.GUI, 0, 0, 0)
GUI_Resize(PCG.GUI, 0, 0, 0)
GUI_Resize(THG.GUI, 0, 0, 0)
GUI_Resize(ASG.GUI, 0, 0, 0)



; Auto Just Attack
SetTimer JAV_Loop, JAV.Freq
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
            ToolTip "Time Green" JAV.Count
            SetTimer () => ToolTip(), -1000, 10000
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
        Sleep JAV.Delay
        ToolTip "Just Attack!"
        SetTimer () => ToolTip(), -200, 10000
        Send JAV.PressKey
        JAV.Count := 0
    }
    return True
}


; Auto Photon Charge
SetTimer PCV_Loop, PCV.Freq
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
            ToolTip "Time Blue" PCV.Count
            SetTimer () => ToolTip(), -1000, 10000
        }
        PCV.Count := 0
        PCG.GUI.Title := "PC"
    }
;ToolTip "Pixel Search" PCV.Count " " PCG.X ":" PCG.Y " " PCG.W ":" PCG.H " FOUND:" PC_Px ":" PC_Py " " PCV.BarPercent
    If (PCV.Count >= PCV.TrigThresh)
    {
        PhotonChargeUse()
    }
    return True
}


; Auto Trimate Heal
SetTimer THV_Loop, THV.Freq
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
                ToolTip "Time Yellow" THV.Count
                SetTimer () => ToolTip(), -1000, 10000
            }
            MProgress_TH.Value := -1
            THV.Count := 0
            THG.GUI.Title := "TH"
        }
    }
;ToolTip "Pixel Search" THV.Count " " THG.X ":" THG.Y " " THG.W ":" THG.H " FOUND:" TH_Px ":" TH_Py " " THV.BarPercent
    If (THV.Count >= THV.TrigThresh)
    {
        TrimateHealUse()
    }
    return True
}


; Auto Armor Swap
SetTimer ASV_Loop, ASV.Freq
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
            ToolTip "Time ArmorSwap" ASV.Count
            SetTimer () => ToolTip(), -1000, 10000
        }
        ASV.Count := 0
        MProgress_AS.Value := -1
        ASG.GUI.Title := "AS"
        ASV.ElemType := 0
        ASV.DetectionState := 0
    }
; ToolTip "Pixel Search" ASV.Count " " ASG.X ":" ASG.Y " " ASG.W ":" ASG.H " FOUND:" AS_Px ":" AS_Py " " ASV.ElemType
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
IntWrap(kX, LB, UB)
{
    Rang := UB - LB + 1
    If (kX < LB)
    {
        kX := kX + Rang * ((LB - kX) / Rang + 1)
    }

    return LB + Mod((kX - LB), Rang)
}


PhotonChargeUse(*)
{
    global
    Sleep PCV.Delay
    ToolTip "Photon Charge!"
    SetTimer () => ToolTip(), -1900, 10000
    Send PCV.PressKey
    PCV.Count := 0
}
TrimateHealUse(*)
{
    global
    Sleep THV.Delay
    ToolTip "Trimate Heal!"
    SetTimer () => ToolTip(), -1900, 10000
    Send THV.PressKey
    THV.Count := 0
}
ArmorSwapUse(*)
{
    global
    if (ASV.LastElemType != ASV.ElemType && ASV.CanChange = 1)
    {
        Sleep ASV.Delay
        ToolTip "Armor Swap!"
        SetTimer () => ToolTip(), -1900, 10000
        
        local ArmorSwapPressInputted := false
        If (ASV.InputMode = 1)
        {
            ArmorSwapPressInput := ASV.PressKey[ASV.ElemType]
            Send ArmorSwapPressInput
            MProgress_ASC.Opt("+c0x" . Format("{:X}", ASV.Color[ASV.ElemType]))
            ArmorSwapPressInputted := true
        }
        Else If (ASV.InputMode = 2)
        {
            ArmorSwapPressInput := ASV.TypeText[ASV.ElemType]
            Send "{Space}"
            Send "{Text}" . ArmorSwapPressInput
            Send "{Enter}"
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


JAGC_AllowMoveWindow(*)
{
    global
    if (JAG.WindowCanMove = 0)
    {
        JAG.WindowCanMove := 1
        JAG.SkipGuiResize := 1
        JAG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowJA.Text := "Show JA"
    }
    Else
    {
        JAG.WindowCanMove := 0
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
        PCG.SkipGuiResize := 1
        PCG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowPC.Text := "Show PC"
    }
    Else
    {
        PCG.WindowCanMove := 0
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
        THG.SkipGuiResize := 1
        THG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowTH.Text := "Show TH"
    }
    Else
    {
        THG.WindowCanMove := 0
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
        ASG.SkipGuiResize := 1
        ASG.GUI.Opt("+AlwaysOnTop -Caption -Resize")
        MButton_ShowAS.Text := "Show AS"
    }
    Else
    {
        ASG.WindowCanMove := 0
        ASG.SkipGuiResize := 0
        ASG.GUI.Opt("+AlwaysOnTop +Caption +Resize")
        MButton_ShowAS.Text := "Hide AS"
    }
}

JAGC_PressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_JAPressKey.Value) > 0)
    {
        JAV.PressKey := ConvertHotKeyToKeyPress(MHotkey_JAPressKey.Value)
    }    
}
JAGC_FreqChanged(*)
{
    global
    JAV.Freq := MUpDown_JAFreq.Value
    SetTimer JAV_Loop, JAV.Freq
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
        PCV.PressKey := ConvertHotKeyToKeyPress(MHotkey_PCPressKey.Value)
    }
}
PCGC_FreqChanged(*)
{
    global
    PCV.Freq := MUpDown_PCFreq.Value
    SetTimer PCV_Loop, PCV.Freq
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
        THV.PressKey := ConvertHotKeyToKeyPress(MHotkey_THPressKey.Value)
    }    
}
THGC_FreqChanged(*)
{
    global
    THV.Freq := MUpDown_THFreq.Value
    SetTimer THV_Loop, THV.Freq
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
    SetTimer ASV_Loop, ASV.Freq
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
    ArmorSwapColorElemFireUpdate()
    ArmorSwapColorElemIceUpdate()
    ArmorSwapColorElemLightningUpdate()
    ArmorSwapColorElemGroundUpdate()
    ArmorSwapColorElemDarkUpdate()
    ArmorSwapColorElemLightUpdate()
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
        ASV.PressKey[1] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemFire.Value)
    }
}
ASGC_ElemIcePressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemIce.Value) > 0)
    {
        ASV.PressKey[2] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemIce.Value)
    }
}
ASGC_ElemLightningPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemLightning.Value) > 0)
    {
        ASV.PressKey[3] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemLightning.Value)
    }
}
ASGC_ElemGroundPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemGround.Value) > 0)
    {
        ASV.PressKey[4] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemGround.Value)
    }
}
ASGC_ElemDarkPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemDark.Value) > 0)
    {
        ASV.PressKey[5] := ConvertHotKeyToKeyPress(MHotkey_ASPressKeyElemDark.Value)
    }
}
ASGC_ElemLightPressKeyChanged(*)
{
    global
    If (StrLen(MHotkey_ASPressKeyElemLight.Value) > 0)
    {
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

ArmorSwapColorElemFireUpdate()
{
    MProgress_ASCCFEMX.Opt("+c" . MaxVariationColorFromHexToHexString(ASV.Color[1],ASV.DetectionVariation))
    MProgress_ASCCFE.Opt("+c" . Format("{:X}", ASV.Color[1]))
    MProgress_ASCCFEMN.Opt("+c" . MinVariationColorFromHexToHexString(ASV.Color[1],ASV.DetectionVariation))
}
ArmorSwapColorRElemFireChanged(*)
{
    ASV.Color[1] := UpdateRedComponentFromHexToHexInt(ASV.Color[1], MUpDown_ASColorRElemFire.Value)
    ArmorSwapColorElemFireUpdate()
}
ArmorSwapColorGElemFireChanged(*)
{
    ASV.Color[1] := UpdateGreenComponentFromHexToHexInt(ASV.Color[1], MUpDown_ASColorGElemFire.Value)
    ArmorSwapColorElemFireUpdate()
}
ArmorSwapColorBElemFireChanged(*)
{
    ASV.Color[1] := UpdateBlueComponentFromHexToHexInt(ASV.Color[1], MUpDown_ASColorBElemFire.Value)
    ArmorSwapColorElemFireUpdate()
}

ArmorSwapColorElemIceUpdate()
{
    MProgress_ASCCIEMX.Opt("+c" . MaxVariationColorFromHexToHexString(ASV.Color[2],ASV.DetectionVariation))
    MProgress_ASCCIE.Opt("+c" . Format("{:X}", ASV.Color[2]))
    MProgress_ASCCIEMN.Opt("+c" . MinVariationColorFromHexToHexString(ASV.Color[2],ASV.DetectionVariation))
}
ArmorSwapColorRElemIceChanged(*)
{
    ASV.Color[2] := UpdateRedComponentFromHexToHexInt(ASV.Color[2], MUpDown_ASColorRElemIce.Value)
    ArmorSwapColorElemIceUpdate()
}
ArmorSwapColorGElemIceChanged(*)
{
    ASV.Color[2] := UpdateGreenComponentFromHexToHexInt(ASV.Color[2], MUpDown_ASColorGElemIce.Value)
    ArmorSwapColorElemIceUpdate()
}
ArmorSwapColorBElemIceChanged(*)
{
    ASV.Color[2] := UpdateBlueComponentFromHexToHexInt(ASV.Color[2], MUpDown_ASColorBElemIce.Value)
    ArmorSwapColorElemIceUpdate()
}

ArmorSwapColorElemLightningUpdate()
{
    MProgress_ASCCLNEMX.Opt("+c" . MaxVariationColorFromHexToHexString(ASV.Color[3],ASV.DetectionVariation))
    MProgress_ASCCLNE.Opt("+c" . Format("{:X}", ASV.Color[3]))
    MProgress_ASCCLNEMN.Opt("+c" . MinVariationColorFromHexToHexString(ASV.Color[3],ASV.DetectionVariation))
}
ArmorSwapColorRElemLightningChanged(*)
{
    ASV.Color[3] := UpdateRedComponentFromHexToHexInt(ASV.Color[3], MUpDown_ASColorRElemLightning.Value)
    ArmorSwapColorElemLightningUpdate()
}
ArmorSwapColorGElemLightningChanged(*)
{
    ASV.Color[3] := UpdateGreenComponentFromHexToHexInt(ASV.Color[3], MUpDown_ASColorGElemLightning.Value)
    ArmorSwapColorElemLightningUpdate()
}
ArmorSwapColorBElemLightningChanged(*)
{
    ASV.Color[3] := UpdateBlueComponentFromHexToHexInt(ASV.Color[3], MUpDown_ASColorBElemLightning.Value)
    ArmorSwapColorElemLightningUpdate()
}

ArmorSwapColorElemGroundUpdate()
{
    MProgress_ASCCGEMX.Opt("+c" . MaxVariationColorFromHexToHexString(ASV.Color[4],ASV.DetectionVariation))
    MProgress_ASCCGE.Opt("+c" . Format("{:X}", ASV.Color[4]))
    MProgress_ASCCGEMN.Opt("+c" . MinVariationColorFromHexToHexString(ASV.Color[4],ASV.DetectionVariation))
}
ArmorSwapColorRElemGroundChanged(*)
{
    ASV.Color[4] := UpdateRedComponentFromHexToHexInt(ASV.Color[4], MUpDown_ASColorRElemGround.Value)
    ArmorSwapColorElemGroundUpdate()
}
ArmorSwapColorGElemGroundChanged(*)
{
    ASV.Color[4] := UpdateGreenComponentFromHexToHexInt(ASV.Color[4], MUpDown_ASColorGElemGround.Value)
    ArmorSwapColorElemGroundUpdate()
}
ArmorSwapColorBElemGroundChanged(*)
{
    ASV.Color[4] := UpdateBlueComponentFromHexToHexInt(ASV.Color[4], MUpDown_ASColorBElemGround.Value)
    ArmorSwapColorElemGroundUpdate()
}

ArmorSwapColorElemDarkUpdate()
{
    MProgress_ASCCDEMX.Opt("+c" . MaxVariationColorFromHexToHexString(ASV.Color[5],ASV.DetectionVariation))
    MProgress_ASCCDE.Opt("+c" . Format("{:X}", ASV.Color[5]))
    MProgress_ASCCDEMN.Opt("+c" . MinVariationColorFromHexToHexString(ASV.Color[5],ASV.DetectionVariation))
}
ArmorSwapColorRElemDarkChanged(*)
{
    ASV.Color[5] := UpdateRedComponentFromHexToHexInt(ASV.Color[5], MUpDown_ASColorRElemDark.Value)
    ArmorSwapColorElemDarkUpdate()
}
ArmorSwapColorGElemDarkChanged(*)
{
    ASV.Color[5] := UpdateGreenComponentFromHexToHexInt(ASV.Color[5], MUpDown_ASColorGElemDark.Value)
    ArmorSwapColorElemDarkUpdate()
}
ArmorSwapColorBElemDarkChanged(*)
{
    ASV.Color[5] := UpdateBlueComponentFromHexToHexInt(ASV.Color[5], MUpDown_ASColorBElemDark.Value)
    ArmorSwapColorElemDarkUpdate()
}

ArmorSwapColorElemLightUpdate()
{
    MProgress_ASCCLIEMX.Opt("+c" . MaxVariationColorFromHexToHexString(ASV.Color[6],ASV.DetectionVariation))
    MProgress_ASCCLIE.Opt("+c" . Format("{:X}", ASV.Color[6]))
    MProgress_ASCCLIEMN.Opt("+c" . MinVariationColorFromHexToHexString(ASV.Color[6],ASV.DetectionVariation))
}
ArmorSwapColorRElemLightChanged(*)
{
    ASV.Color[6] := UpdateRedComponentFromHexToHexInt(ASV.Color[6], MUpDown_ASColorRElemLight.Value)
    ArmorSwapColorElemLightUpdate()
}
ArmorSwapColorGElemLightChanged(*)
{
    ASV.Color[6] := UpdateGreenComponentFromHexToHexInt(ASV.Color[6], MUpDown_ASColorGElemLight.Value)
    ArmorSwapColorElemLightUpdate()
}
ArmorSwapColorBElemLightChanged(*)
{
    ASV.Color[6] := UpdateBlueComponentFromHexToHexInt(ASV.Color[6], MUpDown_ASColorBElemLight.Value)
    ArmorSwapColorElemLightUpdate()
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


OnExit ExitFunc

ExitFunc(ExitReason, ExitCode)
{
    Send "{Right up}{F9 up}{F8 up}{Shift up}"
}


