# Complete SAMP Server

A complete San Andreas Multiplayer server with integrated auction and lottery systems.

## Features

### Core Systems
- **Player Registration/Login System** - Secure account management with file-based storage
- **Admin System** - 5-level admin hierarchy with various permissions
- **Economy System** - Money management and transactions
- **Statistics Tracking** - Player kills, deaths, score tracking

### Integrated Systems
- **Auction System** - Admin-controlled weapon auctions with automatic bidding
- **Lottery System** - Player-operated lottery with ticket purchasing

## Server Files

### Main Files
- `gamemode.pwn` - Main gamemode script with all functionality
- `server.cfg` - Server configuration file
- `Auction-Pawn-Script` - Original auction system (integrated into main gamemode)
- `Lottery-Pawn-Script` - Original lottery system (integrated into main gamemode)

## Commands

### Player Commands
- `/stats [playerid]` - View player statistics
- `/bid` - Place a bid in an active auction
- `/buyticket [amount]` - Purchase lottery tickets (1-10)

### Admin Commands
- `/auction` - Start a weapon auction (Level 3+ Admin)
- `/lottery` - Run the lottery draw (Level 1+ Admin)
- `/setadmin [playerid] [level]` - Set player admin level (Level 5 Admin only)
- `/givemoney [playerid] [amount]` - Give money to a player (Level 3+ Admin)

## System Details

### Auction System
- **Starting Price**: $50,000
- **Price Increment**: $10,000 per bid
- **Auto-Increment**: Every 30 seconds if no bids
- **Maximum Price**: $500,000 (auction ends automatically)
- **Requirements**: Admin level 3+ to start, players need equipped weapon

### Lottery System
- **Ticket Price**: $50 each
- **Maximum Tickets per Player**: 10
- **Minimum Players**: 5 tickets total needed to run
- **Winner Selection**: Random ticket selection
- **Prize**: Total pot from all ticket sales

### Player Data
Player data is automatically saved to `/accounts/playername.ini` files including:
- Password (for login)
- Money amount
- Admin level
- Score, kills, and deaths
- Registration status

## Installation

1. Place all files in your SAMP server directory
2. Ensure you have the required includes:
   - `a_samp.inc` (standard SA-MP include)
   - `zcmd.inc` (Z Command Processor)
   - `sscanf2.inc` (String Scanner)
3. Compile `gamemode.pwn` with your PAWN compiler
4. Update `server.cfg` settings as needed (change rcon password!)
5. Create `/accounts/` directory for player data storage
6. Start your server

## Configuration

### Server Settings (server.cfg)
- **Port**: 7777 (default)
- **Max Players**: 50
- **RCON Password**: changeme123 (CHANGE THIS!)
- **Hostname**: Complete SAMP Server v1.0

### Security Notes
- Change the RCON password in server.cfg before going live
- First player to join can be given admin level 5 manually by editing their account file
- Player passwords are stored in plain text - consider implementing hashing for production

## Version History

### v1.0
- Complete server implementation
- Integrated auction and lottery systems
- Player registration and admin systems
- File-based data storage
- Comprehensive command set