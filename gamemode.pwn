#include <a_samp>
#include <zcmd>
#include <sscanf2>

// Server defines
#define SERVER_NAME "Complete SAMP Server"
#define SERVER_VERSION "1.0"
#define MAX_ITEMS 100

// Player info structure
enum pInfo
{
    pPassword[129],
    pMoney,
    pAdmin,
    pScore,
    pKills,
    pDeaths,
    bool:pLogged,
    bool:pRegistered
}
new PlayerInfo[MAX_PLAYERS][pInfo];

// Auction system defines
#define AUCTION_PRICE 50000
#define AUCTION_INTERVAL 30000
#define AUCTION_INCREMENT 10000

new auction_timer;
new auction_price;
new auction_item;
new auction_player = INVALID_PLAYER_ID;
new auction_active = false;

// Lottery system defines
#define TICKET_PRICE 50
#define MIN_PLAYERS 5
#define MAX_TICKETS_PER_PLAYER 10

new ticketCount[MAX_PLAYERS];
new totalTickets;
new lotteryPot;
new lotteryTimer;
new lotteryActive = false;

// Colors
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_RED 0xFF0000FF
#define COLOR_GREEN 0x00FF00FF
#define COLOR_BLUE 0x0000FFFF
#define COLOR_YELLOW 0xFFFF00FF

// Forward declarations
forward IncreaseAuctionPrice();
forward EndAuction();
forward RunLottery();
forward SavePlayerData(playerid);
forward LoadPlayerData(playerid);

public OnGameModeInit()
{
    print("\n--------------------------------------");
    print(SERVER_NAME " v" SERVER_VERSION);
    print("--------------------------------------\n");
    
    // Set gamemode text
    SetGameModeText("Complete Roleplay");
    
    // Add player classes
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
    
    // Initialize systems
    auction_timer = -1;
    lotteryTimer = -1;
    
    // Reset all player data
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        ResetPlayerVariables(i);
    }
    
    return 1;
}

public OnGameModeExit()
{
    print("Gamemode exited.");
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
    return 1;
}

public OnPlayerConnect(playerid)
{
    new string[128], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    
    format(string, sizeof(string), "%s has joined the server. Welcome!", pname);
    SendClientMessageToAll(COLOR_GREEN, string);
    
    ResetPlayerVariables(playerid);
    
    // Check if player is registered
    if(PlayerExists(playerid))
    {
        PlayerInfo[playerid][pRegistered] = true;
        ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "Login", "This account is registered.\nPlease enter your password:", "Login", "Quit");
    }
    else
    {
        ShowPlayerDialog(playerid, 2, DIALOG_STYLE_PASSWORD, "Register", "This account is not registered.\nPlease enter a password to register:", "Register", "Quit");
    }
    
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new string[128], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    
    new reasonText[16];
    switch(reason)
    {
        case 0: reasonText = "Timeout";
        case 1: reasonText = "Leaving";
        case 2: reasonText = "Kicked/Banned";
    }
    
    format(string, sizeof(string), "%s has left the server. (%s)", pname, reasonText);
    SendClientMessageToAll(COLOR_RED, string);
    
    if(PlayerInfo[playerid][pLogged])
    {
        SavePlayerData(playerid);
    }
    
    // If player was in auction, cancel it
    if(auction_player == playerid && auction_active)
    {
        SendClientMessageToAll(COLOR_YELLOW, "Auction cancelled due to bidder leaving.");
        EndAuction();
    }
    
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(!PlayerInfo[playerid][pLogged])
    {
        SendClientMessage(playerid, COLOR_RED, "You must login first!");
        Kick(playerid);
        return 1;
    }
    
    SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
    SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);
    
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    PlayerInfo[playerid][pDeaths]++;
    
    if(killerid != INVALID_PLAYER_ID)
    {
        PlayerInfo[killerid][pKills]++;
        PlayerInfo[killerid][pScore]++;
        SetPlayerScore(killerid, PlayerInfo[killerid][pScore]);
    }
    
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case 1: // Login
        {
            if(!response) return Kick(playerid);
            
            if(!strlen(inputtext))
            {
                SendClientMessage(playerid, COLOR_RED, "You must enter a password!");
                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "Login", "This account is registered.\nPlease enter your password:", "Login", "Quit");
                return 1;
            }
            
            if(strcmp(inputtext, PlayerInfo[playerid][pPassword], false) == 0)
            {
                PlayerInfo[playerid][pLogged] = true;
                LoadPlayerData(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Successfully logged in!");
                SpawnPlayer(playerid);
            }
            else
            {
                SendClientMessage(playerid, COLOR_RED, "Incorrect password!");
                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "Login", "This account is registered.\nPlease enter your password:", "Login", "Quit");
            }
        }
        
        case 2: // Register
        {
            if(!response) return Kick(playerid);
            
            if(strlen(inputtext) < 4)
            {
                SendClientMessage(playerid, COLOR_RED, "Password must be at least 4 characters long!");
                ShowPlayerDialog(playerid, 2, DIALOG_STYLE_PASSWORD, "Register", "This account is not registered.\nPlease enter a password to register:", "Register", "Quit");
                return 1;
            }
            
            format(PlayerInfo[playerid][pPassword], 129, "%s", inputtext);
            PlayerInfo[playerid][pRegistered] = true;
            PlayerInfo[playerid][pLogged] = true;
            PlayerInfo[playerid][pMoney] = 5000; // Starting money
            
            SavePlayerData(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "Successfully registered and logged in!");
            SendClientMessage(playerid, COLOR_GREEN, "You have received $5000 as starting money!");
            SpawnPlayer(playerid);
        }
    }
    return 1;
}

// Command: /auction (Admin only)
CMD:auction(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3)
    {
        SendClientMessage(playerid, COLOR_RED, "You must be level 3+ admin to start an auction.");
        return 1;
    }
    
    if(auction_active)
    {
        SendClientMessage(playerid, COLOR_RED, "An auction is already in progress.");
        return 1;
    }
    
    new item_id = GetPlayerWeapon(playerid);
    if(item_id == 0)
    {
        SendClientMessage(playerid, COLOR_RED, "You must have a weapon equipped to start an auction.");
        return 1;
    }
    
    new item_name[64], string[128];
    GetWeaponName(item_id, item_name, sizeof(item_name));
    format(string, sizeof(string), "AUCTION: %s started for $%d! Type /bid to place a bid.", item_name, AUCTION_PRICE);
    SendClientMessageToAll(COLOR_YELLOW, string);
    
    auction_item = item_id;
    auction_price = AUCTION_PRICE;
    auction_active = true;
    auction_player = INVALID_PLAYER_ID;
    auction_timer = SetTimer("IncreaseAuctionPrice", AUCTION_INTERVAL, true);
    
    return 1;
}

// Command: /bid
CMD:bid(playerid, params[])
{
    if(!auction_active)
    {
        SendClientMessage(playerid, COLOR_RED, "There is no auction in progress.");
        return 1;
    }
    
    if(GetPlayerMoney(playerid) < auction_price)
    {
        SendClientMessage(playerid, COLOR_RED, "You do not have enough money to place a bid.");
        return 1;
    }
    
    if(auction_player == playerid)
    {
        SendClientMessage(playerid, COLOR_RED, "You are already the highest bidder.");
        return 1;
    }
    
    // Return money to previous bidder
    if(auction_player != INVALID_PLAYER_ID)
    {
        GivePlayerMoney(auction_player, auction_price - AUCTION_INCREMENT);
    }
    
    auction_player = playerid;
    GivePlayerMoney(playerid, -auction_price);
    
    new string[128], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(string, sizeof(string), "%s bid $%d on the auction!", pname, auction_price);
    SendClientMessageToAll(COLOR_YELLOW, string);
    
    auction_price += AUCTION_INCREMENT;
    
    return 1;
}

// Command: /buyticket
CMD:buyticket(playerid, params[])
{
    new amount;
    if(sscanf(params, "i", amount))
    {
        SendClientMessage(playerid, COLOR_WHITE, "Usage: /buyticket [amount]");
        return 1;
    }
    
    if(amount < 1 || amount > MAX_TICKETS_PER_PLAYER)
    {
        SendClientMessage(playerid, COLOR_RED, "You can buy between 1 and 10 tickets.");
        return 1;
    }
    
    if(ticketCount[playerid] + amount > MAX_TICKETS_PER_PLAYER)
    {
        SendClientMessage(playerid, COLOR_RED, "You cannot own more than 10 tickets.");
        return 1;
    }
    
    new cost = amount * TICKET_PRICE;
    if(GetPlayerMoney(playerid) < cost)
    {
        SendClientMessage(playerid, COLOR_RED, "You don't have enough money for that many tickets.");
        return 1;
    }
    
    GivePlayerMoney(playerid, -cost);
    ticketCount[playerid] += amount;
    totalTickets += amount;
    lotteryPot += cost;
    
    new string[128];
    format(string, sizeof(string), "You bought %d ticket(s) for $%d. You now have %d tickets.", amount, cost, ticketCount[playerid]);
    SendClientMessage(playerid, COLOR_GREEN, string);
    
    return 1;
}

// Command: /lottery (Admin only)
CMD:lottery(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1)
    {
        SendClientMessage(playerid, COLOR_RED, "You must be an admin to run the lottery.");
        return 1;
    }
    
    if(lotteryActive)
    {
        SendClientMessage(playerid, COLOR_RED, "A lottery is already scheduled.");
        return 1;
    }
    
    if(totalTickets < MIN_PLAYERS)
    {
        SendClientMessage(playerid, COLOR_RED, "Not enough tickets sold to run lottery.");
        return 1;
    }
    
    SendClientMessageToAll(COLOR_YELLOW, "LOTTERY: Drawing will happen in 30 seconds!");
    lotteryActive = true;
    lotteryTimer = SetTimer("RunLottery", 30000, false);
    
    return 1;
}

// Command: /stats
CMD:stats(playerid, params[])
{
    new target = playerid;
    if(strlen(params) > 0)
    {
        target = strval(params);
        if(!IsPlayerConnected(target))
        {
            SendClientMessage(playerid, COLOR_RED, "Player not found.");
            return 1;
        }
    }
    
    new string[256], pname[MAX_PLAYER_NAME];
    GetPlayerName(target, pname, sizeof(pname));
    
    format(string, sizeof(string), "Stats for %s | Money: $%d | Score: %d | Kills: %d | Deaths: %d | Admin: %d", 
           pname, GetPlayerMoney(target), GetPlayerScore(target), 
           PlayerInfo[target][pKills], PlayerInfo[target][pDeaths], PlayerInfo[target][pAdmin]);
    SendClientMessage(playerid, COLOR_WHITE, string);
    
    return 1;
}

// Command: /setadmin (Level 5 admin only)
CMD:setadmin(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 5)
    {
        SendClientMessage(playerid, COLOR_RED, "You don't have permission to use this command.");
        return 1;
    }
    
    new target, level;
    if(sscanf(params, "ui", target, level))
    {
        SendClientMessage(playerid, COLOR_WHITE, "Usage: /setadmin [playerid] [level]");
        return 1;
    }
    
    if(!IsPlayerConnected(target))
    {
        SendClientMessage(playerid, COLOR_RED, "Player not found.");
        return 1;
    }
    
    if(level < 0 || level > 5)
    {
        SendClientMessage(playerid, COLOR_RED, "Admin level must be between 0 and 5.");
        return 1;
    }
    
    PlayerInfo[target][pAdmin] = level;
    
    new string[128], pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(target, tname, sizeof(tname));
    
    format(string, sizeof(string), "Admin %s set %s's admin level to %d.", pname, tname, level);
    SendClientMessageToAll(COLOR_YELLOW, string);
    
    return 1;
}

// Command: /givemoney (Admin only)
CMD:givemoney(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3)
    {
        SendClientMessage(playerid, COLOR_RED, "You don't have permission to use this command.");
        return 1;
    }
    
    new target, amount;
    if(sscanf(params, "ui", target, amount))
    {
        SendClientMessage(playerid, COLOR_WHITE, "Usage: /givemoney [playerid] [amount]");
        return 1;
    }
    
    if(!IsPlayerConnected(target))
    {
        SendClientMessage(playerid, COLOR_RED, "Player not found.");
        return 1;
    }
    
    GivePlayerMoney(target, amount);
    PlayerInfo[target][pMoney] += amount;
    
    new string[128], pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(target, tname, sizeof(tname));
    
    format(string, sizeof(string), "Admin %s gave $%d to %s.", pname, amount, tname);
    SendClientMessage(playerid, COLOR_GREEN, string);
    format(string, sizeof(string), "You received $%d from admin %s.", amount, pname);
    SendClientMessage(target, COLOR_GREEN, string);
    
    return 1;
}

// Auction timer function
public IncreaseAuctionPrice()
{
    if(!auction_active) return;
    
    new string[128];
    format(string, sizeof(string), "AUCTION: No new bids. Price increased to $%d!", auction_price);
    SendClientMessageToAll(COLOR_YELLOW, string);
    
    // End auction if price gets too high
    if(auction_price > 500000)
    {
        SendClientMessageToAll(COLOR_YELLOW, "AUCTION: Maximum price reached. Auction ending...");
        SetTimer("EndAuction", 5000, false);
        KillTimer(auction_timer);
    }
}

// End auction function
public EndAuction()
{
    if(auction_player != INVALID_PLAYER_ID)
    {
        new string[128], pname[MAX_PLAYER_NAME], weapon_name[64];
        GetPlayerName(auction_player, pname, sizeof(pname));
        GetWeaponName(auction_item, weapon_name, sizeof(weapon_name));
        
        format(string, sizeof(string), "AUCTION: %s won the %s for $%d!", pname, weapon_name, auction_price - AUCTION_INCREMENT);
        SendClientMessageToAll(COLOR_GREEN, string);
        
        GivePlayerWeapon(auction_player, auction_item, 500);
    }
    else
    {
        SendClientMessageToAll(COLOR_RED, "AUCTION: No bids received. Auction cancelled.");
    }
    
    auction_active = false;
    auction_player = INVALID_PLAYER_ID;
    auction_timer = -1;
}

// Run lottery function
public RunLottery()
{
    if(totalTickets == 0)
    {
        SendClientMessageToAll(COLOR_RED, "LOTTERY: No tickets sold.");
        lotteryActive = false;
        return;
    }
    
    new winningTicket = random(totalTickets);
    new currentTicket = 0;
    new winner = INVALID_PLAYER_ID;
    
    // Find winner
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        
        currentTicket += ticketCount[i];
        if(winningTicket < currentTicket)
        {
            winner = i;
            break;
        }
    }
    
    if(winner != INVALID_PLAYER_ID)
    {
        new string[128], pname[MAX_PLAYER_NAME];
        GetPlayerName(winner, pname, sizeof(pname));
        
        format(string, sizeof(string), "LOTTERY: %s won $%d with ticket #%d!", pname, lotteryPot, winningTicket);
        SendClientMessageToAll(COLOR_GREEN, string);
        
        GivePlayerMoney(winner, lotteryPot);
        PlayerInfo[winner][pMoney] += lotteryPot;
    }
    
    // Reset lottery
    lotteryPot = 0;
    totalTickets = 0;
    lotteryActive = false;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        ticketCount[i] = 0;
    }
}

// Helper functions
stock ResetPlayerVariables(playerid)
{
    PlayerInfo[playerid][pPassword][0] = 0;
    PlayerInfo[playerid][pMoney] = 0;
    PlayerInfo[playerid][pAdmin] = 0;
    PlayerInfo[playerid][pScore] = 0;
    PlayerInfo[playerid][pKills] = 0;
    PlayerInfo[playerid][pDeaths] = 0;
    PlayerInfo[playerid][pLogged] = false;
    PlayerInfo[playerid][pRegistered] = false;
    ticketCount[playerid] = 0;
}

stock PlayerExists(playerid)
{
    new file[64], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(file, sizeof(file), "/accounts/%s.ini", pname);
    
    if(fexist(file)) return 1;
    return 0;
}

public SavePlayerData(playerid)
{
    new file[64], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(file, sizeof(file), "/accounts/%s.ini", pname);
    
    new File:handle = fopen(file, io_write);
    if(handle)
    {
        new string[128];
        format(string, sizeof(string), "Password=%s\n", PlayerInfo[playerid][pPassword]);
        fwrite(handle, string);
        format(string, sizeof(string), "Money=%d\n", GetPlayerMoney(playerid));
        fwrite(handle, string);
        format(string, sizeof(string), "Admin=%d\n", PlayerInfo[playerid][pAdmin]);
        fwrite(handle, string);
        format(string, sizeof(string), "Score=%d\n", GetPlayerScore(playerid));
        fwrite(handle, string);
        format(string, sizeof(string), "Kills=%d\n", PlayerInfo[playerid][pKills]);
        fwrite(handle, string);
        format(string, sizeof(string), "Deaths=%d\n", PlayerInfo[playerid][pDeaths]);
        fwrite(handle, string);
        fclose(handle);
    }
}

public LoadPlayerData(playerid)
{
    new file[64], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(file, sizeof(file), "/accounts/%s.ini", pname);
    
    new File:handle = fopen(file, io_read);
    if(handle)
    {
        new string[128], key[64], value[64];
        while(fread(handle, string))
        {
            sscanf(string, "p<=>s[64]s[64]", key, value);
            
            if(strcmp(key, "Password", true) == 0)
                format(PlayerInfo[playerid][pPassword], 129, "%s", value);
            else if(strcmp(key, "Money", true) == 0)
                PlayerInfo[playerid][pMoney] = strval(value);
            else if(strcmp(key, "Admin", true) == 0)
                PlayerInfo[playerid][pAdmin] = strval(value);
            else if(strcmp(key, "Score", true) == 0)
                PlayerInfo[playerid][pScore] = strval(value);
            else if(strcmp(key, "Kills", true) == 0)
                PlayerInfo[playerid][pKills] = strval(value);
            else if(strcmp(key, "Deaths", true) == 0)
                PlayerInfo[playerid][pDeaths] = strval(value);
        }
        fclose(handle);
    }
}