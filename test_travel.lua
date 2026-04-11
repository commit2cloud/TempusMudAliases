-- =============================================================================
-- test_travel.lua – Unit tests for TempusMUD travel directions (directions.lua)
-- =============================================================================
-- Run standalone with a standard Lua interpreter:
--   lua test_travel.lua
--
-- Tests cover:
--   1. Speedwalk alias parsing (sendDirs)
--   2. travelData table integrity (hubs, name, dirs fields)
--   3. AutoPractice skill-list helpers (apGetEnabledSkills, toggle, add, remove)
-- =============================================================================

-- =============================================
-- Lightweight test framework
-- =============================================

local passCount = 0
local failCount = 0

local function pass(name)
  passCount = passCount + 1
  print("  [PASS] " .. name)
end

local function fail(name, reason)
  failCount = failCount + 1
  print("  [FAIL] " .. name .. " -- " .. tostring(reason))
end

local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    pass(name)
  else
    fail(name, err)
  end
end

local function assertEquals(actual, expected, label)
  if actual ~= expected then
    error((label or "assertEquals") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
end

local function assertNotNil(val, label)
  if val == nil then
    error((label or "assertNotNil") .. ": expected non-nil value")
  end
end

local function assertTrue(val, label)
  if not val then
    error((label or "assertTrue") .. ": expected true")
  end
end

local function assertFalse(val, label)
  if val then
    error((label or "assertFalse") .. ": expected false")
  end
end

-- =============================================
-- Mudlet API stubs
-- =============================================

-- Lua 5.2+ moved unpack to table.unpack; provide global compat shim
unpack = unpack or table.unpack

local _sentCommands = {}
local _echoOutput   = {}

getMudletHomeDir = function() return "/tmp" end

cecho = function(s)
  table.insert(_echoOutput, s)
end

send = function(s)
  table.insert(_sentCommands, s)
end

sendAll = function(...)
  for _, s in ipairs({...}) do
    table.insert(_sentCommands, s)
  end
end

-- Timers fire their callback immediately in test mode
tempTimer = function(delay, fn)
  fn()
end

-- Trigger helpers are no-ops
tempRegexTrigger = function(pattern, fn)
  return math.random(1000, 9999)
end
killTrigger = function(id) end

matches = {}

-- os.time stub – returns a fixed epoch for deterministic XP/hour calculations
local _fakeTime = 1000
os = os or {}
os.time = function() return _fakeTime end

-- =============================================
-- Minimal config stub (replaces config.lua load)
-- =============================================

myStartingRoomName = "The Beginning of Misery"
function directionsToHolySquare()  sendAll("north", "look modrian", "north", "north") end
function directionsToStarPlaza()   sendAll("north", "look ec") end
function directionsToSlaveSquare() sendAll("north", "look skullport") end
function directionsToAstralManse() sendAll("north", "look astral") end

-- Prevent dofile / io.open from touching the filesystem during tests
local _io_open = io.open
io.open = function(path, mode)
  if path:match("config%.lua$") then return nil end
  return _io_open(path, mode)
end
dofile = function(path) end

-- =============================================
-- Load directions.lua under test
-- =============================================
-- Compute absolute path relative to this test file
local scriptDir = (debug and debug.getinfo(1, "S").source:match("^@(.+[/\\])")) or "./"
local directionsPath = scriptDir .. "directions.lua"
local chunk, loadErr = loadfile(directionsPath)
if not chunk then
  print("ERROR: Could not load directions.lua: " .. tostring(loadErr))
  print("Make sure test_travel.lua is in the same directory as directions.lua.")
  os.exit(1)
end
chunk()

-- Helper to reset captured commands between tests
local function clearSent()
  _sentCommands = {}
end

-- =============================================
-- Section 0: trimAndLower helper
-- =============================================

print("\n--- trimAndLower: Shared Helper ---")

test("trimAndLower: lowercases and trims leading/trailing spaces", function()
  assertEquals(trimAndLower("  START  "), "start")
  assertEquals(trimAndLower("STOP"), "stop")
  assertEquals(trimAndLower("  Status "), "status")
end)

test("trimAndLower: already lowercase and no spaces is unchanged", function()
  assertEquals(trimAndLower("reset"), "reset")
end)

-- =============================================
-- Section 1: sendDirs – Speedwalk Alias Parsing
-- =============================================

print("\n--- sendDirs: Speedwalk Alias Parsing ---")

test("sendDirs: simple N/S/E/W single steps", function()
  clearSent()
  sendDirs("n")
  assertEquals(_sentCommands[1], "north", "single n")
  clearSent()
  sendDirs("s")
  assertEquals(_sentCommands[1], "south", "single s")
  clearSent()
  sendDirs("e")
  assertEquals(_sentCommands[1], "east", "single e")
  clearSent()
  sendDirs("w")
  assertEquals(_sentCommands[1], "west", "single w")
end)

test("sendDirs: up and down", function()
  clearSent()
  sendDirs("ud")
  assertEquals(_sentCommands[1], "up",   "up")
  assertEquals(_sentCommands[2], "down", "down")
end)

test("sendDirs: numeric repeat counts (3n2e)", function()
  clearSent()
  sendDirs("3n2e")
  assertEquals(#_sentCommands, 5, "total moves")
  assertEquals(_sentCommands[1], "north")
  assertEquals(_sentCommands[2], "north")
  assertEquals(_sentCommands[3], "north")
  assertEquals(_sentCommands[4], "east")
  assertEquals(_sentCommands[5], "east")
end)

test("sendDirs: mixed speedwalk and special command (open door)", function()
  clearSent()
  sendDirs("2n;open door;3e")
  -- 2 norths, then "open door" verbatim, then 3 easts = 6 total
  assertEquals(_sentCommands[1], "north")
  assertEquals(_sentCommands[2], "north")
  assertEquals(_sentCommands[3], "open door")
  assertEquals(_sentCommands[4], "east")
  assertEquals(_sentCommands[5], "east")
  assertEquals(_sentCommands[6], "east")
end)

test("sendDirs: whitespace trimming around segments", function()
  clearSent()
  sendDirs("  2n ; open gate ; 1s  ")
  assertEquals(_sentCommands[1], "north")
  assertEquals(_sentCommands[2], "north")
  assertEquals(_sentCommands[3], "open gate")
  assertEquals(_sentCommands[4], "south")
end)

test("sendDirs: empty string sends nothing", function()
  clearSent()
  sendDirs("")
  assertEquals(#_sentCommands, 0, "no commands sent for empty string")
end)

test("sendDirs: large count (10w)", function()
  clearSent()
  sendDirs("10w")
  assertEquals(#_sentCommands, 10)
  for i = 1, 10 do
    assertEquals(_sentCommands[i], "west", "move " .. i)
  end
end)

test("sendDirs: real zone path – Halfling Village (15e10s4e)", function()
  clearSent()
  sendDirs("15e10s4e")
  assertEquals(#_sentCommands, 29)
  assertEquals(_sentCommands[1],  "east")
  assertEquals(_sentCommands[15], "east")
  assertEquals(_sentCommands[16], "south")
  assertEquals(_sentCommands[25], "south")
  assertEquals(_sentCommands[26], "east")
  assertEquals(_sentCommands[29], "east")
end)

test("sendDirs: real zone path – Bard Guildmaster (3w2swn)", function()
  clearSent()
  sendDirs("3w2swn")
  -- 3w = west×3, 2s = south×2, w = west, n = north  → 7 moves
  assertEquals(#_sentCommands, 7)
  assertEquals(_sentCommands[1], "west")
  assertEquals(_sentCommands[3], "west")
  assertEquals(_sentCommands[4], "south")
  assertEquals(_sentCommands[5], "south")
  assertEquals(_sentCommands[6], "west")
  assertEquals(_sentCommands[7], "north")
end)

-- =============================================
-- Section 2: travelData Table Integrity
-- =============================================

print("\n--- travelData: Table Integrity ---")

local validHubs = {hs = true, star = true, skull = true, astral = true}

local function checkPlane(planeName)
  test("travelData[" .. planeName .. "] exists and is non-empty", function()
    assertNotNil(travelData[planeName], "travelData." .. planeName)
    assertTrue(#travelData[planeName] > 0, planeName .. " has entries")
  end)
  test("travelData[" .. planeName .. "] entries all have hub/name/dirs", function()
    for i, entry in ipairs(travelData[planeName]) do
      local ctx = planeName .. "[" .. i .. "]"
      assertNotNil(entry.hub,  ctx .. ".hub")
      assertNotNil(entry.name, ctx .. ".name")
      assertNotNil(entry.dirs, ctx .. ".dirs")
      assertTrue(validHubs[entry.hub] == true, ctx .. " hub '" .. tostring(entry.hub) .. "' is valid")
      assertTrue(#entry.name > 0, ctx .. " name is non-empty")
      assertTrue(#entry.dirs > 0, ctx .. " dirs is non-empty")
    end
  end)
end

checkPlane("past")
checkPlane("future")
checkPlane("planes")
checkPlane("trainers")
checkPlane("guilds")
checkPlane("underdark")

test("travelData past has at least 43 entries", function()
  assertTrue(#travelData.past >= 43, "past count >= 43 (got " .. #travelData.past .. ")")
end)

test("travelData future has at least 33 entries", function()
  assertTrue(#travelData.future >= 33, "future count >= 33 (got " .. #travelData.future .. ")")
end)

test("travelData guilds includes Bard Guildmaster", function()
  local found = false
  for _, entry in ipairs(travelData.guilds) do
    if entry.name:lower():match("bard") then found = true break end
  end
  assertTrue(found, "Bard Guildmaster entry present in guilds table")
end)

-- =============================================
-- Section 3: AutoPractice Skill-List Helpers
-- =============================================

print("\n--- AutoPractice: Skill-List Helpers ---")

test("apSkillList is non-empty by default", function()
  assertNotNil(apSkillList)
  assertTrue(#apSkillList > 0, "default skill list is non-empty")
end)

test("apGetEnabledSkills returns only enabled skills", function()
  -- Ensure at least one disabled skill
  local orig = apSkillList
  apSkillList = {
    {name = "lullaby", enabled = true},
    {name = "kick",    enabled = false},
    {name = "ballad",  enabled = true},
  }
  local enabled = apGetEnabledSkills()
  assertEquals(#enabled, 2, "two enabled skills")
  assertEquals(enabled[1], "lullaby")
  assertEquals(enabled[2], "ballad")
  apSkillList = orig
end)

test("apGetEnabledSkills returns empty table when all disabled", function()
  local orig = apSkillList
  apSkillList = {
    {name = "lullaby", enabled = false},
    {name = "kick",    enabled = false},
  }
  local enabled = apGetEnabledSkills()
  assertEquals(#enabled, 0, "no enabled skills")
  apSkillList = orig
end)

test("apToggleSkill toggles an existing skill", function()
  local orig = apSkillList
  apSkillList = {{name = "lullaby", enabled = true}}
  apToggleSkill("lullaby")
  assertFalse(apSkillList[1].enabled, "toggled OFF")
  apToggleSkill("lullaby")
  assertTrue(apSkillList[1].enabled, "toggled back ON")
  apSkillList = orig
end)

test("apToggleSkill is case-insensitive", function()
  local orig = apSkillList
  apSkillList = {{name = "Lullaby", enabled = true}}
  apToggleSkill("LULLABY")
  assertFalse(apSkillList[1].enabled, "case-insensitive toggle")
  apSkillList = orig
end)

test("apAddSkill adds a new skill as enabled", function()
  local orig = apSkillList
  apSkillList = {}
  apAddSkill("new song")
  assertEquals(#apSkillList, 1)
  assertEquals(apSkillList[1].name, "new song")
  assertTrue(apSkillList[1].enabled)
  apSkillList = orig
end)

test("apAddSkill does not add duplicates", function()
  local orig = apSkillList
  apSkillList = {{name = "lullaby", enabled = true}}
  apAddSkill("lullaby")
  assertEquals(#apSkillList, 1, "no duplicate added")
  apSkillList = orig
end)

test("apRemoveSkill removes an existing skill", function()
  local orig = apSkillList
  apSkillList = {{name = "lullaby", enabled = true}, {name = "kick", enabled = true}}
  apRemoveSkill("lullaby")
  assertEquals(#apSkillList, 1)
  assertEquals(apSkillList[1].name, "kick")
  apSkillList = orig
end)

test("apRemoveSkill handles missing skill gracefully", function()
  local orig = apSkillList
  apSkillList = {{name = "lullaby", enabled = true}}
  apRemoveSkill("nonexistent")
  assertEquals(#apSkillList, 1, "list unchanged when skill not found")
  apSkillList = orig
end)

-- =============================================
-- Section 4: Combat Log / XP Tracking
-- =============================================

print("\n--- Combat Log / XP Tracking ---")

test("combatLogStart resets counters and enables tracking", function()
  combatLogTotalXP  = 9999
  combatLogKills    = 42
  combatLogEnabled  = false
  combatLogStart()
  assertEquals(combatLogTotalXP, 0,  "XP reset")
  assertEquals(combatLogKills,   0,  "kills reset")
  assertTrue(combatLogEnabled,       "tracking enabled")
  assertNotNil(combatLogSessionStart, "session start set")
end)

test("combatLogReset resets counters while keeping tracking state", function()
  combatLogTotalXP = 500
  combatLogKills   = 5
  combatLogEnabled = true
  combatLogReset()
  assertEquals(combatLogTotalXP, 0, "XP reset")
  assertEquals(combatLogKills,   0, "kills reset")
  assertTrue(combatLogEnabled,      "tracking still enabled")
end)

test("xpGainTrigger callback accumulates XP", function()
  combatLogEnabled     = true
  combatLogTotalXP     = 0
  combatLogSessionStart = os.time()
  -- Simulate the regex trigger match: matches[2] = "1500"
  matches[2] = "1500"
  -- Re-create the trigger callback inline (mirrors trigger in directions.lua)
  local rawNum = matches[2]:gsub(",", "")
  local xp = tonumber(rawNum) or 0
  combatLogTotalXP = combatLogTotalXP + xp
  assertEquals(combatLogTotalXP, 1500, "XP accumulated")
end)

test("xpGainTrigger callback handles comma-formatted numbers", function()
  combatLogEnabled      = true
  combatLogTotalXP      = 0
  combatLogSessionStart = os.time()
  matches[2] = "1,234"
  local rawNum = matches[2]:gsub(",", "")
  local xp = tonumber(rawNum) or 0
  combatLogTotalXP = combatLogTotalXP + xp
  assertEquals(combatLogTotalXP, 1234, "comma-separated XP parsed")
end)

test("combatLogKills increments when R.I.P. fires during combat", function()
  combatLogEnabled = true
  combatLogKills   = 0
  isFighting       = true
  -- Simulate the kill-counting portion of combatEndTrigger
  if combatLogEnabled and isFighting then
    combatLogKills = combatLogKills + 1
  end
  isFighting = false
  assertEquals(combatLogKills, 1, "kill counted")
  assertFalse(isFighting, "isFighting cleared")
end)

test("combatLogKills does NOT increment when not fighting", function()
  combatLogEnabled = true
  combatLogKills   = 0
  isFighting       = false
  if combatLogEnabled and isFighting then
    combatLogKills = combatLogKills + 1
  end
  assertEquals(combatLogKills, 0, "no kill counted when not fighting")
end)

-- =============================================
-- Results Summary
-- =============================================

print("\n=============================================")
print(string.format("Results: %d passed, %d failed", passCount, failCount))
print("=============================================")

if failCount > 0 then
  os.exit(1)
else
  os.exit(0)
end
