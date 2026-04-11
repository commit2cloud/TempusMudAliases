# TempusMUD Travel Aliases

Easily navigate TempusMUD zones using a travel menu system. Originally written for TinTin++, now also available as a **dedicated zMUD script** and a **Lua script for [Mudlet](https://www.mudlet.org/)**.

---

## Table of Contents

- [Available Clients](#available-clients)
- [Setup: TinTin++ / Tinframe](#setup-tintin--tinframe)
- [Setup: zMUD](#setup-zmud)
  - [Installation](#installation-1)
  - [Personalization](#personalization-1)
  - [Verifying the Script Loaded](#verifying-the-script-loaded)
  - [Using Travel Commands in zMUD](#using-travel-commands-in-zmud)
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
| zMUD | `directions.zmud` | ✅ Dedicated zMUD Port |
| Mudlet | `directions.lua` | ✅ Lua Port |

---

## Setup: TinTin++ / Tinframe

1. Download `directions.tt` and save it in your TinTin root directory.
2. Load the script with:
   ````
   #read directions.tt
   ````

## Setup: zMUD

`directions.zmud` is a dedicated port of the travel script adapted for zMUD's scripting syntax. It contains all the same zones and navigation logic as the TinTin++ original.

### Installation

1. **Download** `directions.zmud` from this repository.
2. **Save** it anywhere on your computer — the zMUD directory is a good choice.
3. **Connect** to TempusMUD in zMUD.
4. **Load the script** by typing this in the zMUD command line:
   ````
   #read directions.zmud
   ````
   Replace the path if you saved the file somewhere other than your zMUD directory, for example:
   ````
   #read C:\Users\YourName\Documents\zmud\directions.zmud
   ````

When the file loads successfully, you will see a banner message confirming the script is active.

> **Tip:** To reload the script automatically every time you connect, create a zMUD alias or add `#read directions.zmud` to your connection script in the zMUD Session Properties under the **Connect** tab.

### Personalization

Before using the script you must set two things: your character's **starting room name** and the **movement commands** to reach each hub from that room. These are the only values you need to edit.

Open `directions.zmud` in a text editor. Near the top of the file, between the `EDIT THESE VARS ONLY` markers, you will find:

```
#VAR {myStartingRoomName} {The Beginning of Misery}
#ALIAS {directionsToHolySquare} {north;look modrian;north;north}
#ALIAS {directionsToStarPlaza} {north;look ec}
#ALIAS {directionsToSlaveSquare} {north;look skullport}
#ALIAS {directionsToAstralManse} {north;look astral}
```

#### Step 1 — Set your starting room name

`myStartingRoomName` must exactly match the room name displayed when you type `where` at your character's recall point. The script checks this before every trip to make sure you are in the right place.

For example, if `where` shows `You are at: The Courtyard of Chaos`, change the line to:

```
#VAR {myStartingRoomName} {The Courtyard of Chaos}
```

#### Step 2 — Set your hub directions

The four `directionsTo...` aliases tell the script how to walk from your starting room to each travel hub:

| Alias | Hub | Used for |
|---|---|---|
| `directionsToHolySquare` | Holy Square (Past hub) | All Past zones, most Guild and Trainer destinations |
| `directionsToStarPlaza` | Star Plaza (Future hub) | All Future zones, some Guilds and Trainers |
| `directionsToSlaveSquare` | Slave Square (Skullport hub) | Skullport-based Guilds and Underdark zones |
| `directionsToAstralManse` | Astral Manse | All Planes/Outer Planes zones |

Replace each alias body with the semicolon-separated movement commands for your character. For example, if Holy Square is `2n;e` from your recall:

```
#ALIAS {directionsToHolySquare} {2n;e}
```

#### Step 3 — Reload the script

After saving your changes, reload the script in zMUD:

```
#read directions.zmud
```

### Verifying the Script Loaded

After loading, type the `travel` command in zMUD. If the script is working you will see the main travel menu displayed in the output window:

```
travel
```

If you see `Unknown command` or nothing happens, the script did not load. Check that the file path in your `#read` command is correct and try again.

To quickly test that your hub directions are configured correctly, type:

```
gotohs
```

Your character should cast `fly`, check your current room, and then begin moving toward Holy Square. If you see a warning that your starting room does not match, double-check the `myStartingRoomName` value.

### Using Travel Commands in zMUD

All `travel` commands work directly from the zMUD command line after loading the script — no additional alias setup is required.

| Command | Action |
|---|---|
| `travel` | Show the main travel menu |
| `travel 1` or `travel past` | Show Past locations list |
| `travel 2` or `travel future` | Show Future locations list |
| `travel 3` or `travel planes` | Show Planes locations list |
| `travel 4` or `travel trainers` | Show Trainers list |
| `travel 5` or `travel guilds` | Show Guilds list |
| `travel 6` or `travel underdark` | Show Underdark locations list |
| `travel 1 17` | Travel to High Tower of Magic (Past #17) |
| `travel past 17` | Same — named planes work too |
| `travel 2 5` | Travel to Cybertech Labs (Future #5) |
| `travel 3 11` | Travel to Lunia Heaven (Planes #11) |

The script first runs `fly`, checks you are in your starting room, then walks you to the zone hub and on to your destination.

#### Sub-zone aliases

Some zones have secondary aliases for reaching specific areas within them. These are usable after you have already arrived at the parent zone:

| Alias | Description |
|---|---|
| `gotoShadeRebel` | Rebel Leader from Tiltin (must be in Shade) |
| `gotoShadeSelset` | Selset from Rebel Leader (must be in Shade catacombs) |
| `gotoFailFamilyLegacyFreddy` | Freddy Fail (must be at Walkway to a Huge Mansion) |
| `gotoThor` | Thor, God of Lightning (must be in Lunia Silver Sea) |
| `gotoDiancecht` | Diancecht (must be Before a Palatial Estate in Lunia) |
| `gotoPtah` | Ptah (must be Before a Spiraling Tower in Lunia) |
| `gotoIxlilton` | Ixlilton (must be at A Garden Plateau in Lunia) |

#### Resetting after an error

If travel is interrupted (combat, wrong room, etc.) and the script gets stuck, use:

```
resettravel
```

This clears the `travelerror` and `travelling` flags so you can start a new trip.

#### Debug mode

To enable debug output (useful for troubleshooting), set:

```
#VAR {debug} {1}
```

To turn it off:

```
#VAR {debug} {0}
```

---

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
   ````
   lua showMainMenu()
   ````
2. You should see the colorized travel menu appear in the output window.
3. If you see an error like `showMainMenu: nil value`, the script did not load — re-open the Script Editor, make sure the script entry is checked/enabled (the checkbox next to its name), and click **Save** again.

> **Note:** Scripts in the Scripts section run once at load time. Since `directions.lua` defines global functions and registers triggers, everything is ready to use immediately after saving. You do **not** need to manually execute it each session — Mudlet will re-run it automatically every time you open the profile.

#### Method B: Lua `dofile()` (Advanced)

1. Place `directions.lua` in your Mudlet profile directory.
   - On **Windows**: `%APPDATA%\Mudlet\profiles\<profile_name>\`
   - On **macOS**: `~/.config/mudlet/profiles/<profile_name>/`
   - On **Linux**: `~/.config/mudlet/profiles/<profile_name>/`
2. In Mudlet's command line, run:
   ````
   lua dofile(getMudletHomeDir() .. "/directions.lua")
   ````

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
   ````
   lua showMainMenu()
   ````
2. You should see the colorized travel menu. If you do, the script is loaded and ready.

### Personalization

The script supports multiple ways to customize your configuration. Choose the option that best fits your workflow.

#### Option 1: Mudlet Script Editor Entry (Recommended)

This method keeps everything inside Mudlet — **no external files needed**. You create a separate script entry in the Script Editor that defines your personal configuration, and place it **below** the main `TempusMUD Directions` script entry so it runs after and overwrites the defaults.

1. Open the **Script Editor** (`Alt+S`) and click **Scripts** on the left sidebar.
2. Click **Add** to create a **new** script entry.
3. Name it `TempusMUD Config`.
4. **Paste** the following into the script body and edit the values to match your character:

   ```lua
   -- =============================================
   -- My TempusMUD Configuration
   -- =============================================
   -- This runs AFTER directions.lua loads, so these
   -- globals overwrite the defaults with your personal values.

   myStartingRoomName = "The Beginning of Misery"   -- change to your recall room

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

5. **Drag this script entry below** the `TempusMUD Directions` entry in the script list.
   - Mudlet executes scripts **top-to-bottom** in the order they appear. By placing your config below the main script, it runs second and overwrites the built-in defaults with your values.
6. Click **Save**.

> **Note:** Because no external `config.lua` file exists on disk, you will see a yellow warning message when the main script loads (`Warning: config.lua not found...`). This is **harmless** — your config script entry runs immediately after and sets all your custom values correctly. Everything will work as expected.

#### Option 2: Using config.lua (External File)

If you prefer to keep your configuration in an external file (useful if you edit with an external text editor or share configs between profiles):

1. **Copy** the `config.lua` file from this repository to your Mudlet home directory.
   - To find your Mudlet home directory, run this in Mudlet's command line:
     ````
     lua echo(getMudletHomeDir())
     ````
   - Common locations:
     - **Windows**: `C:\Users\YourName\.config\mudlet\profiles\YourProfile\`
     - **Linux**: `~/.config/mudlet/profiles/YourProfile/`
     - **macOS**: `~/Library/Application Support/Mudlet/profiles/YourProfile/`

2. **Edit** `config.lua` in your favorite text editor to customize:
   - `myStartingRoomName` - Your character's recall/start location
   - The four `directionsTo...()` functions - Navigation commands from your start room to each hub

3. **Reload** the script in Mudlet (reconnect or re-run the script).

When `config.lua` is present, you'll see: `Config loaded from: <path>`

#### Option 3: Using inline defaults (No configuration)

If no `config.lua` file is found and no config script entry exists, the script will automatically use default configuration values embedded in `directions.lua`. You'll see a warning message indicating the expected location for `config.lua`. This option works out-of-the-box with default settings.

#### Configuration Values

**Change `myStartingRoomName`** to whatever room name is displayed when you type `where` at your character's recall/start location. The script uses this to verify you are in the correct room before initiating travel. If this value does not match your actual starting room, all travel commands will fail with a warning.

The four `directionsTo...()` functions control how the script navigates from your start room to each hub (Holy Square, Star Plaza, Slave Square, Astral Manse). If your starting room is different from the default, you may need to update these functions with the correct movement commands as well:

```lua
myStartingRoomName = "The Beginning of Misery"

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
| **Pattern** | `^travel\s*(\w*)\s*(\d*)\s*(\w*)$` |
| **Type** | Regex |

**Command / Script body:**

```lua
local plane  = matches[2] or ""
local zone   = matches[3] or ""
local action = matches[4] or ""

if plane == "" then plane = nil end
if zone == "" then zone = nil else zone = tonumber(zone) end
if action == "" then action = nil end

travel(plane, zone, action)
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
| `travel 1 15 speak` | Say directions to Halfling Village in-game |
| `travel past 17 speak` | Say directions to High Tower of Magic in-game |
| `travel 2 5 speak` | Say directions to Cybertech Labs in-game |

### Speak Feature

The `speak` action allows you to share zone directions with other players by saying them aloud in-game instead of actually traveling there. This is useful for helping other players navigate to specific zones.

**Usage:** `travel <plane> <zone> speak`

**Examples:**
- `travel 1 15 speak` → Your character says: "Directions to Halfling Village: From Holy Square, go: 15e10s4e"
- `travel past 17 speak` → Your character says: "Directions to High Tower of Magic: From Holy Square, go: 34w3nw3n"
- `travel 2 5 speak` → Your character says: "Directions to Cybertech Labs: From Star Plaza, go: 5e3s2w1s"
- `travel 3 11 speak` → Your character says: "Directions to Lunia Heaven: From Astral Manse, go: 5n3d2sw;enter pool"

Some zones also have dedicated helper aliases for multi-step navigation (e.g., `gotoShadeRebel`, `gotoShadeSelset`, `gotoFailFamilyLegacyFreddy`, `gotoThor`, `gotoDiancecht`, etc.). These must be called after you have already travelled to the parent zone.

---

## AutoPractice (Bard)

`autopractice.lua` is an optional Mudlet Lua module that automatically navigates your bard to the Bard Guildmaster and practices every enabled spell/skill in sequence.

### Setup

1. **Load** `autopractice.lua` **after** `directions.lua` so that `gotoBardGuildmaster()` is available.
   - In the **Script Editor** (`Alt+S`), add a new script entry below `TempusMUD Directions`, name it `TempusMUD AutoPractice`, and paste in the contents of `autopractice.lua`.
   - Or load on demand: `lua dofile(getMudletHomeDir() .. "/autopractice.lua")`

2. Optionally edit the `apSkills` table near the top of `autopractice.lua` to add, remove, or reorder bard spells and skills for your character.

### Commands

| Command | Description |
|---|---|
| `lua autopractice()` | Navigate to Bard Guildmaster and practice all enabled skills |
| `lua apList()` | Show all spells/skills and their ON/OFF state |
| `lua apToggle("Steal")` | Toggle a single skill on or off by name |
| `lua apReset()` | Re-enable every skill |
| `lua apStop()` | Abort a running auto-practice session |

### How It Works

1. Builds a queue of every skill that is currently toggled **ON**.
2. Calls `gotoBardGuildmaster()` and waits for the travel system to signal arrival.
3. Sends `practice <skill>` for each queued skill, separated by a short configurable delay (`apDelay`, default 0.6 s).
4. Prints a confirmation when the session is complete.

---

## XP Tracking

XP-per-hour tracking is built into `directions.lua`. It listens for TempusMUD experience-gain messages and accumulates totals so you can see how efficiently you are levelling.

### Commands

| Command | Description |
|---|---|
| `lua xpStart()` | Begin a new XP tracking session |
| `lua xpStatus()` | Print current XP gained, time elapsed, and XP/hr rate |
| `lua xpStop()` | End the session and print a final summary |

### Example Output

```
========== XP Tracking Status ==========
  XP gained so far: 45820
  Session duration: 1h 12m 34s
  XP per hour     : 37992
  Last kill XP    : 1240
========================================
```

Enable `debug` mode (`debug = true` in Mudlet console) to see a running XP ticker after every kill.

---

## Files

| File | Description |
|---|---|
| `directions.tt` | Original TinTin++ script |
| `directions.zmud` | Dedicated zMUD port of the travel system |
| `directions.lua` | Mudlet Lua port of the travel system (includes XP tracking) |
| `autopractice.lua` | Optional AutoPractice module for bard characters (Mudlet) |
| `config.lua` | Configuration file (optional) - place in Mudlet home directory |
| `LICENSE` | License file |
| `README.md` | This file |

---

## Screenshots

![TempusMud Aliases Main Travel Menu.](Main%20Travel%20Menu.png)

![TempusMud Aliases Past Travel Menu.](Travel%20Menu%20Past.png)

![TempusMud Aliases Future Travel Menu.](Travel%20Menu%20Future.png)