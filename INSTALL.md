# Complete SAMP Server - Installation Guide

## Quick Start

1. **Download SA-MP Server Package**
   - Download from https://www.sa-mp.com/download.php
   - Extract the server files to this directory

2. **Install Required Includes**
   - Download zcmd.inc from https://github.com/Southclaws/zcmd
   - Download sscanf2.inc from https://github.com/Y-Less/sscanf
   - Place both files in your `pawno/include/` directory

3. **Compile the Gamemode**
   ```bash
   ./compile.sh
   ```

4. **Configure the Server**
   - Edit `server.cfg` and change the RCON password
   - Adjust max players, port, and hostname as needed

5. **Start the Server**
   ```bash
   ./start.sh
   ```

## Detailed Setup

### Prerequisites
- SA-MP Server 0.3.7 or later
- PAWN Compiler (pawncc)
- Required includes: zcmd, sscanf2

### Server Structure
```
SAMP-Scripts/
├── gamemode.pwn          # Main gamemode (complete server)
├── server.cfg            # Server configuration
├── admin_tools.pwn       # Additional admin filterscript
├── server_utils.inc      # Utility functions
├── compile.sh            # Compilation script
├── start.sh              # Server startup script
├── .gitignore            # Git ignore file
├── README.md             # Documentation
├── Auction-Pawn-Script   # Original auction code (integrated)
├── Lottery-Pawn-Script   # Original lottery code (integrated)
└── INSTALL.md            # This file
```

### File Descriptions

#### Core Files
- **gamemode.pwn**: Complete server implementation with all features
- **server.cfg**: Server configuration with optimized settings
- **admin_tools.pwn**: Optional filterscript with additional admin commands

#### Utility Files
- **server_utils.inc**: Common functions and utilities
- **compile.sh**: Automated compilation script
- **start.sh**: Server startup script with error checking

#### Documentation
- **README.md**: Complete feature documentation
- **INSTALL.md**: This installation guide

### First Time Setup

1. **Compile the gamemode:**
   ```bash
   chmod +x compile.sh
   ./compile.sh
   ```

2. **Set up admin account:**
   - Start the server and connect
   - Register an account
   - Stop the server
   - Edit `accounts/YourUsername.ini`
   - Change `Admin=0` to `Admin=5`
   - Restart the server

3. **Test functionality:**
   - Connect to your server
   - Test commands: `/stats`, `/auction`, `/lottery`
   - Verify player registration/login works

### Common Issues

**Compilation Errors:**
- Ensure zcmd.inc and sscanf2.inc are in pawno/include/
- Check that pawncc is in your PATH
- Verify file permissions on compile.sh

**Server Won't Start:**
- Check that gamemode.amx was created
- Verify server.cfg syntax
- Ensure SA-MP server binary is present

**Can't Connect:**
- Check firewall settings for port 7777
- Verify server is running with `netstat -an | grep 7777`
- Check server_log.txt for errors

### Security Notes

⚠️ **Important Security Steps:**
1. Change the RCON password in server.cfg
2. Don't run the server as root user
3. Keep your includes updated
4. Regular backups of accounts/ directory

### Performance Tuning

For better performance:
- Adjust `stream_distance` in server.cfg
- Monitor server_log.txt for warnings
- Use a VPS with SSD storage for better I/O

### Support

For issues or questions:
1. Check the server_log.txt file
2. Review the documentation in README.md
3. Ensure all dependencies are installed correctly