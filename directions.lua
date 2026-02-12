-- =============================================================================
-- Directions Script for TempusMUD - Mudlet Lua Port
-- Original TinTin++ script by Dracken
-- https://github.com/dracken/TempusMudAliases/
-- =============================================================================

-- =============================================
-- Configuration - EDIT THESE VARS ONLY!
-- =============================================
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

-- =============================================
-- State Variables
-- =============================================
currentRoom = ""
travelerror = 0
travelling = 0
debug = false

-- Gith search variables
githFound = 0
findGith = 0
githX = 0
githY = 0
githZ = 0

-- =============================================
-- Helper Functions
-- =============================================

function sendDirs(dirString)
  local cmds = {}
  for cmd in dirString:gmatch("[^";]+") do
    cmd = cmd:match("^%s*(.-)%s*$")
    if cmd ~= "" then
      table.insert(cmds, cmd)
    end
  end
  if #cmds > 0 then
    sendAll(unpack(cmds))
  end
end

function resettravel()
  travelerror = 0
  travelling = 0
end

-- =============================================
-- Room Tracking Trigger
-- =============================================
if youAreLocatedTrigger then killTrigger(youAreLocatedTrigger) end
youAreLocatedTrigger = tempRegexTrigger("^You are located: (.+)$", function()
  currentRoom = matches[2]
end)

-- =============================================
-- Anchor Start Location Functions
-- =============================================

function gotohs(callback)
  send("fly")
  send("where")
  tempTimer(1, function()
    if currentRoom == myStartingRoomName then
      travelling = 1
      directionsToHolySquare()
      if callback then callback() end
    else
      cecho("\n<red>Warning!<white> The current starting room is <red>NOT<white> your default start room '" .. myStartingRoomName .. "'!\n")
      travelerror = 1
      travelling = 0
    end
  end)
end

function gotostar(callback)
  send("fly")
  send("where")
  tempTimer(1, function()
    if currentRoom == myStartingRoomName then
      travelling = 1
      directionsToStarPlaza()
      if callback then callback() end
    else
      cecho("\n<red>Warning!<white> The current starting room is <red>NOT<white> your default start room '" .. myStartingRoomName .. "'!\n")
      travelerror = 1
      travelling = 0
    end
  end)
end

function gotoskull(callback)
  send("fly")
  send("where")
  tempTimer(1, function()
    if currentRoom == myStartingRoomName then
      travelling = 1
      directionsToSlaveSquare()
      if callback then callback() end
    else
      cecho("\n<red>Warning!<white> The current starting room is <red>NOT<white> your default start room '" .. myStartingRoomName .. "'!\n")
      travelerror = 1
      travelling = 0
    end
  end)
end

function gotoastral(callback)
  send("fly")
  send("where")
  tempTimer(1, function()
    if currentRoom == myStartingRoomName then
      travelling = 1
      directionsToAstralManse()
      if callback then callback() end
    else
      cecho("\n<red>Warning!<white> The current starting room is <red>NOT<white> your default start room '" .. myStartingRoomName .. "'!\n")
      travelerror = 1
      travelling = 0
    end
  end)
end

-- =============================================
-- Travel destination helper
-- hub: "hs", "star", "skull", "astral"
-- name: display name
-- dirs: semicolon-separated directions string
-- =============================================
function travelTo(hub, name, dirs)
  local hubFunc
  if hub == "hs" then hubFunc = gotohs
  elseif hub == "star" then hubFunc = gotostar
  elseif hub == "skull" then hubFunc = gotoskull
  elseif hub == "astral" then hubFunc = gotoastral
  end

  cecho("\n<green>Okay!<reset> Travelling to the <yellow>" .. name .. "<reset>!\n")

  hubFunc(function()
    tempTimer(1, function()
      if travelerror == 0 then
        if dirs ~= "" then
          sendDirs(dirs)
        end
        send("where")
        send("challenge area")
      else
        resettravel()
      end
    end)
  end)
end

-- Highlighting some travel functions
function gotoAbandonedKeep()
  travelTo("hs", "Abandoned Keep", "21w14s2w;wind winch")
end
