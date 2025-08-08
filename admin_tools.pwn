#include <a_samp>

// Basic Administration Filterscript
// This filterscript provides additional admin commands

#define COLOR_ADMIN 0x00FF00FF
#define COLOR_ERROR 0xFF0000FF

public OnFilterScriptInit()
{
    print("\n--------------------------------------");
    print(" Admin Tools Filterscript Loaded");
    print("--------------------------------------\n");
    return 1;
}

public OnFilterScriptExit()
{
    print("Admin Tools Filterscript Unloaded");
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(strcmp("/heal", cmdtext, true, 10) == 0)
    {
        // Basic heal command for admins
        SetPlayerHealth(playerid, 100.0);
        SendClientMessage(playerid, COLOR_ADMIN, "You have been healed!");
        return 1;
    }
    
    if(strcmp("/armour", cmdtext, true, 10) == 0)
    {
        // Basic armour command for admins
        SetPlayerArmour(playerid, 100.0);
        SendClientMessage(playerid, COLOR_ADMIN, "Armour restored!");
        return 1;
    }
    
    if(strncmp("/goto", cmdtext, 5, true) == 0)
    {
        new tmp[256], target;
        tmp = strtok(cmdtext, target);
        target = strval(tmp);
        
        if(!IsPlayerConnected(target))
        {
            SendClientMessage(playerid, COLOR_ERROR, "Player not found!");
            return 1;
        }
        
        new Float:x, Float:y, Float:z;
        GetPlayerPos(target, x, y, z);
        SetPlayerPos(playerid, x + 1, y, z);
        
        new string[128], pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME];
        GetPlayerName(playerid, pname, sizeof(pname));
        GetPlayerName(target, tname, sizeof(tname));
        format(string, sizeof(string), "You teleported to %s", tname);
        SendClientMessage(playerid, COLOR_ADMIN, string);
        
        return 1;
    }
    
    return 0;
}

stock strtok(const string[], &index)
{
    new length = strlen(string);
    while ((index < length) && (string[index] <= ' '))
    {
        index++;
    }

    new offset = index;
    new result[20];
    while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
    {
        result[index - offset] = string[index];
        index++;
    }
    result[index - offset] = EOS;
    return result;
}