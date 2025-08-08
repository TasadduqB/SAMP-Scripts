// Common server utilities and functions
// Include this file in your gamemode for additional functionality

#if defined _server_utils_included
    #endinput
#endif
#define _server_utils_included

// Additional color definitions
#define COLOR_ORANGE 0xFF8000FF
#define COLOR_PINK 0xFF00FFFF
#define COLOR_GREY 0x808080FF
#define COLOR_BROWN 0x8B4513FF
#define COLOR_LIME 0x00FF00FF

// Useful macros
#define GetPlayerMoney(%0) PlayerInfo[%0][pMoney]
#define IsPlayerAdmin(%0) (PlayerInfo[%0][pAdmin] > 0)
#define IsPlayerLogged(%0) PlayerInfo[%0][pLogged]

// Function prototypes for common server operations
stock bool:IsValidPlayerName(const name[])
{
    new len = strlen(name);
    if(len < 3 || len > MAX_PLAYER_NAME) return false;
    
    for(new i = 0; i < len; i++)
    {
        if(!((name[i] >= 'A' && name[i] <= 'Z') || 
             (name[i] >= 'a' && name[i] <= 'z') || 
             (name[i] >= '0' && name[i] <= '9') ||
             name[i] == '_' || name[i] == '[' || name[i] == ']'))
        {
            return false;
        }
    }
    return true;
}

stock GetPlayerCount()
{
    new count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i)) count++;
    }
    return count;
}

stock GetOnlineAdmins()
{
    new count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerInfo[i][pAdmin] > 0) count++;
    }
    return count;
}

stock SendMessageToAdmins(color, const message[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerInfo[i][pAdmin] > 0)
        {
            SendClientMessage(i, color, message);
        }
    }
}

stock FormatMoney(amount)
{
    new string[16];
    if(amount >= 1000000)
    {
        format(string, sizeof(string), "$%.1fM", float(amount) / 1000000.0);
    }
    else if(amount >= 1000)
    {
        format(string, sizeof(string), "$%.1fK", float(amount) / 1000.0);
    }
    else
    {
        format(string, sizeof(string), "$%d", amount);
    }
    return string;
}

stock GetPlayerIP(playerid, ip[], len)
{
    new pip[16];
    GetPlayerIp(playerid, pip, sizeof(pip));
    format(ip, len, "%s", pip);
}

stock BanPlayerWithReason(playerid, const reason[])
{
    new string[128], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(string, sizeof(string), "%s has been banned. Reason: %s", pname, reason);
    SendClientMessageToAll(COLOR_RED, string);
    
    SetTimerEx("DelayedBan", 1000, false, "i", playerid);
}

forward DelayedBan(playerid);
public DelayedBan(playerid)
{
    Ban(playerid);
}

stock KickPlayerWithReason(playerid, const reason[])
{
    new string[128], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(string, sizeof(string), "%s has been kicked. Reason: %s", pname, reason);
    SendClientMessageToAll(COLOR_YELLOW, string);
    
    SetTimerEx("DelayedKick", 1000, false, "i", playerid);
}

forward DelayedKick(playerid);
public DelayedKick(playerid)
{
    Kick(playerid);
}