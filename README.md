# TempusMUD Travel Aliases

Easily navigate TempusMUD zones using a travel menu system. Originally written for TinTin++, now also available as a **Lua script for [Mudlet](https://www.mudlet.org/)**.

---

## Table of Contents

- [Available Clients](#available-clients)
- [Setup: TinTin++ / Tinframe](#setup-tintin--tinframe)
- [Setup: ZMud](#setup-zmud)
- [Setup: Mudlet (Lua)](#setup-mudlet-lua)
  - [Installation](#installation)
  - [Running the Script](#running-the-script)
  - [Personalization](#personalization)
  - [Registering the Aliases](#registering-the-aliases)
- [Usage](#usage)
- [Files](#files)
- [Screenshots](#screenshots)

---

## Available Clients

| Client | Script File | Status |
|---|---|---|
| TinTin++ / Tinframe | `directions.tt` | ✅ Original |
| ZMud | `directions.tt` | ✅ Compatible |
| Mudlet | `directions.lua` | ✅ Lua Port |

---

## Setup: TinTin++ / Tinframe

1. Download `directions.tt` and save it in your TinTin root directory.
2. Load the script with:
   ```
   #read directions.tt
   ```

## Setup: ZMud

1. Save `directions.tt` to your ZMud root directory.
2. Load it with:
   ```
   #read directions.tt
   ```

## Setup: Mudlet (Lua)

### Installation

1. **Download** the `directions.lua` file from this repository.
2. **Open Mudlet** and connect to TempusMUD.
3. **Load the script** using one of these methods:

#### Method A: Script Editor (Recommended)

1. Go to the **Script Editor** (click the `<>` Scripts button on the toolbar, or press `Alt+S`).
2. Click the **Scripts** icon on the left sidebar.
3. Click the **Add** button to create a new script entry.
4. Name it `TempusMUD Directions`.
5. **Paste** the entire contents of `directions.lua` into the script body.
6. Click **Save**.

**Running the script (Method A):**

Once saved, the script runs **automatically**. Mudlet executes all code in the Scripts section as soon as you save it and every time you open the profile. To verify it loaded correctly:

1. In Mudlet's main command line, type:
   ```
   lua showMainMenu()
   ```
2. You should see the colorized travel menu appear in the output window.
3. If you see an error like `showMainMenu: nil value`, the script did not load — re-open the Script Editor, make sure the script entry is checked/enabled (the checkbox next to its name), and click **Save** again.

> **Note:** Scripts in the Scripts section run once at load time. Since `directions.lua` defines global functions and registers triggers, everything is ready to use immediately after saving. You do **not** need to manually execute it each session — Mudlet will re-run it automatically every time you open the profile.

#### Method B: Lua `dofile()` (Advanced)

1. Place `directions.lua` in your Mudlet profile directory.
   - On **Windows**: `%APPDATA%\Mudlet\profiles\<profile_name>\`
   - On **macOS**: `~/.config/mudlet/profiles/<profile_name>/`
   - On **Linux**: `~/.config/mudlet/profiles/<profile_name>/`
2. In Mudlet's command line, run:
   ```
   lua dofile(getMudletHomeDir() .. "/directions.lua")
   ```

**Running the script (Method B):**

With this method, the script is **not** loaded automatically — you must execute the `dofile()` command each time you start a new session. To make it automatic:

1. Open the **Script Editor** (`Alt+S`) and click the **Scripts** icon.
2. Click **Add** to create a new script entry and name it `Auto-load Directions`.
3. Paste the following single line into the script body:
   ```lua
   dofile(getMudletHomeDir() .. "/directions.lua")
   ```
4. Click **Save**.

This tells Mudlet to execute the `dofile()` command at profile load, which reads and runs `directions.lua` from disk. The advantage of Method B is that you can edit the `.lua` file in an external text editor and simply reconnect (or type `lua dofile(getMudletHomeDir() .. "/directions.lua")` in the command line) to reload your changes without opening the Script Editor.

To verify the script is running after either approach:

1. Type in Mudlet's command line:
   ```
   lua showMainMenu()
   ```
2. You should see the colorized travel menu. If you do, the script is loaded and ready.

### Personalization

Before using the script, **you must edit the configuration section** at the very top of `directions.lua` to match your character's starting location. Look for this block:

```lua
-- =============================================
-- Configuration - EDIT THESE VARS ONLY!
-- =============================================
myStartingRoomName = "The Beginning of Misery"
```

**Change `myStartingRoomName`** to whatever room name is displayed when you type `where` at your character's recall/start location. The script uses this to verify you are in the correct room before initiating travel. If this value does not match your actual starting room, all travel commands will fail with a warning.

The four `directionsTo...()` functions below that variable control how the script navigates from your start room to each hub (Holy Square, Star Plaza, Slave Square, Astral Manse). If your starting room is different from the default, you may need to update these functions with the correct movement commands as well:

```lua
function directionsToHolySquare()
  sendAll("north", "look modrian", "north", "north")
end

function directionsToStarPlaza()
  sendAll("north", "look ec")
end

function directionsToSlaveSquare()
  sendAll("north", "look skullport")
end

function directionsToAstralManse()
  sendAll("north", "look astral")
end
```

### Registering the Aliases

After loading the script, you need to create **aliases** in Mudlet so you can type commands like `travel`, `travel 1 5`, etc. in the command line.

1. Open the **Script Editor** (`Alt+S`) and click **Aliases** on the left sidebar.
2. Create the following alias:

#### Alias: `travel` (main menu and navigation)

| Field | Value |
|---|---|
| **Name** | `travel` |
| **Pattern** | `^travel\s*(\w*)\s*(\d*)$` |
| **Type** | Regex |

**Command / Script body:**

```lua
local plane = matches[2] or ""
local zone  = matches[3] or ""

if plane == "" then
  plane = nil
end
if zone == "" then
  zone = nil
else
  zone = tonumber(zone)
end

travel(plane, zone)
```

3. Click **Save**.

The `travel()` function in the script handles all menu displays and destination routing automatically. When you type:
- `travel` — shows the main menu
- `travel 1` or `travel past` — shows the Past locations menu
- `travel 1 17` or `travel past 17` — travels to High Tower of Magic

> **Tip:** You can also create shortcut aliases for frequently visited zones. For example, create an alias with pattern `^gotoShade$` that calls `gotoShade()` in the script body.

---

## Usage

Once everything is set up, use the `travel` command in your MUD client:

| Command | Action |
|---|---|
| `travel` | Show the main travel menu |
| `travel 1` | Show Past locations |
| `travel 2` | Show Future locations |
| `travel 3` | Show Planes locations |
| `travel 4` | Show Trainers |
| `travel 5` | Show Guilds |
| `travel 6` | Show Underdark locations |
| `travel past` | Show Past locations (by name) |
| `travel future` | Show Future locations (by name) |
| `travel 1 17` | Travel to High Tower of Magic (Past #17) |
| `travel 2 5` | Travel to Cybertech Labs (Future #5) |
| `travel 3 11` | Travel to Lunia Heaven (Planes #11) |

Some zones also have dedicated helper aliases for multi-step navigation (e.g., `gotoShadeRebel`, `gotoShadeSelset`, `gotoFailFamilyLegacyFreddy`, `gotoThor`, `gotoDiancecht`, etc.). These must be called after you have already travelled to the parent zone.

---

## Files

| File | Description |
|---|---|
| `directions.tt` | Original TinTin++ script |
| `directions.lua` | Mudlet Lua port of the travel system |
| `LICENSE` | License file |
| `README.md` | This file |

---

## Screenshots

![TempusMud Aliases Main Travel Menu.](Main%20Travel%20Menu.png)

![TempusMud Aliases Past Travel Menu.](Travel%20Menu%20Past.png)

![TempusMud Aliases Future Travel Menu.](Travel%20Menu%20Future.png)