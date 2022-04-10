#pragma semicolon 1
#pragma newdecls required

#include <vip_core>

public Plugin myinfo = 
{
    name = "[VIP] Show Damage HUD",
	description = "Show Damage in HUD (for VIP)",
    author = "Drumanid (Fork by PSIH :{ )",
    version = "1.0.0",
    url = "https://github.com/0RaKlE19/VIP_ShowDamageHud"
};

static const char g_sFeature[] = "Showdamagehud";
static char sColors[11], sBuffer[3][4];
static float fFadeIn, fFadeOut, fHoldTime, fCoorX, fCoorY;

public void OnPluginStart()
{
    if(VIP_IsVIPLoaded())
        VIP_OnVIPLoaded();
	
    Handle hRegister;
        
    HookConVarChange(hRegister = CreateConVar("sm_vip_showdamagehud_color", "255 0 0", "RGB (Red, Green, Blue)", 0, false, 0.0, false), OnColorsChange);
	GetConVarString(hRegister, sColors, sizeof(sColors));

	HookConVarChange(hRegister = CreateConVar("sm_vip_showdamagehud_fade_in", "0.5", "Время полностью отображаемого худа на экране", 0, true, 0.0, false), OnFadeInChange);
	fFadeIn = GetConVarFloat(hRegister);

	HookConVarChange(hRegister = CreateConVar("sm_vip_showdamagehud_fade_out", "0.5", "Время исчезающего худа на экране", 0, true, 0.0, false), OnFadeOutChange);
	fFadeOut = GetConVarFloat(hRegister);

	HookConVarChange(hRegister = CreateConVar("sm_vip_showdamagehud_hold_time", "1.0", "Время убийства худа на экране", 0, true, 0.0, false), OnHoldTimeChange);
	fHoldTime = GetConVarFloat(hRegister);

	HookConVarChange(hRegister = CreateConVar("sm_vip_showdamagehud_coor_x", "0.50", "Координаты (0.0 = Влево, 1.0 = Вправо)", 0, true, 0.0, true, 1.0), OnCoorXChange);
	fCoorX = GetConVarFloat(hRegister);

	HookConVarChange(hRegister = CreateConVar("sm_vip_showdamagehud_coor_y", "0.60", "Координаты (0.0 = Вверх, 1.0 = Вниз)", 0, true, 0.0, true, 1.0), OnCoorYChange);
	fCoorY = GetConVarFloat(hRegister);
	
	AutoExecConfig(true, "VIP_ShowDamageHud", "vip");
    CloseHandle(hRegister);

	HookEvent("player_hurt", PlayerHurt);
	
	ExplodeString(sColors, " ", sBuffer, sizeof(sBuffer), sizeof(sBuffer[]));
}

public void OnColorsChange(Handle ConVars, const char[] oldValue, const char[] newValue){GetConVarString(ConVars, sColors, sizeof(sColors));ExplodeString(sColors, " ", sBuffer, sizeof(sBuffer), sizeof(sBuffer[]));}
public void OnFadeInChange(Handle ConVars, const char[] oldValue, const char[] newValue){fFadeIn = GetConVarFloat(ConVars);}
public void OnFadeOutChange(Handle ConVars, const char[] oldValue, const char[] newValue){fFadeOut = GetConVarFloat(ConVars);}
public void OnHoldTimeChange(Handle ConVars, const char[] oldValue, const char[] newValue){fHoldTime = GetConVarFloat(ConVars);}
public void OnCoorXChange(Handle ConVars, const char[] oldValue, const char[] newValue){fCoorX = GetConVarFloat(ConVars);}
public void OnCoorYChange(Handle ConVars, const char[] oldValue, const char[] newValue){fCoorY = GetConVarFloat(ConVars);}

public void VIP_OnVIPLoaded(){VIP_RegisterFeature(g_sFeature, BOOL);}

public void OnPluginEnd()
{
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
		VIP_UnregisterFeature(g_sFeature);
}

void PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int iAttacker = GetClientOfUserId(event.GetInt("attacker"));
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	char sWeapon[36];
	GetEventString(event, "weapon", sWeapon, sizeof(sWeapon));
	if(iAttacker && VIP_IsClientFeatureUse(iAttacker, g_sFeature) && (GetClientTeam(iAttacker) != GetClientTeam(iClient)) &&  !StrEqual(sWeapon, "molotov", false) && !StrEqual(sWeapon, "hegrenade", false))
	{
		SetHudTextParams(fCoorX, fCoorY, fHoldTime, StringToInt(sBuffer[0]), StringToInt(sBuffer[1]), StringToInt(sBuffer[2]), 255, 0, 0.0, fFadeIn, fFadeOut);
		ShowHudText(iAttacker, 6, "-%i", event.GetInt("dmg_health"));
	}
}