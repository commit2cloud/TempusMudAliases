-- =============================================================================
-- AutoPractice Module for TempusMUD Bard
-- Automates practicing bard spells and skills at the Bard Guildmaster
-- =============================================================================
--
-- QUICK START
-- -----------
--   startAutoPractice()   Start a practice session (travels to Bard Guild)
--   stopAutoPractice()    Stop the current session
--   apstatus()            Show exactly what it is doing right now
--
-- TOGGLE INDIVIDUAL SKILLS
--   apToggle("backstab")          Turn a skill on or off for the session
--   apToggle("song of fear")      Works for songs too
--
-- DEBUG MODE
--   apDebug = true                Print a line for every internal step
--   apDebug = false               (default) quiet mode
--
-- ALIAS SETUP (Mudlet)
--   Create an alias with pattern:  ^apstatus$
--   Script body:                   apstatus()
--
--   Create an alias with pattern:  ^ap$
--   Script body:                   startAutoPractice()
--
-- =============================================================================

-- =============================================
-- Timing Constants
-- =============================================
local AP_PRACTICE_DELAY      = 0.5  -- seconds between consecutive practice commands
local AP_ARRIVAL_DELAY       = 1.0  -- seconds to wait after arriving at the guild
local AP_COMBAT_RESUME_DELAY = 1.5  -- seconds to wait before resuming after combat

-- =============================================
-- State Variables
-- =============================================
apRunning       = false   -- true while a session is in progress
apPracticing    = false   -- true while waiting on a single practice command
apCurrentSkill  = nil     -- name of the skill being practiced right now
apQueue         = {}      -- skills still to practice this session
apPracticed     = {}      -- skills successfully processed this session
apDebug         = false   -- verbose step-by-step output
apSessionStart  = nil     -- os.time() when session began
apXPStart       = 0       -- XP at session start (set via apSetXP before starting)
apXPGained      = 0       -- XP gained since session start (auto-tracked)
apPracticesLeft = nil     -- remaining practice sessions (updated from server messages)

-- =============================================
-- Bard Skill / Spell List
-- =============================================
-- Each entry:  {name = "...", enabled = true/false, type = "skill"|"song"|"spell"}
-- Set enabled = false to skip a skill this session.
-- You can also call apToggle("name") at runtime to flip the flag.
--
-- Edit this list to match YOUR bard's current skills and learning priorities.
apSkillList = {
  -- Songs
  {name = "song of fear",         enabled = true,  type = "song"},
  {name = "song of protection",   enabled = true,  type = "song"},
  {name = "song of speed",        enabled = true,  type = "song"},
  {name = "song of the storm",    enabled = true,  type = "song"},
  {name = "song of healing",      enabled = true,  type = "song"},
  {name = "song of battle",       enabled = true,  type = "song"},
  {name = "song of disruption",   enabled = true,  type = "song"},
  {name = "song of forgetfulness", enabled = true,  type = "song"},
  -- Skills
  {name = "play",                 enabled = true,  type = "skill"},
  {name = "backstab",             enabled = true,  type = "skill"},
  {name = "sneak",                enabled = true,  type = "skill"},
  {name = "hide",                 enabled = true,  type = "skill"},
  {name = "pick lock",            enabled = true,  type = "skill"},
  {name = "escape",               enabled = true,  type = "skill"},
  {name = "tumbling",             enabled = true,  type = "skill"},
  {name = "haggling",             enabled = true,  type = "skill"},
  -- Spells (Bard spell list – disable any you have not learned yet)
  {name = "charm person",         enabled = false, type = "spell"},
  {name = "sleep",                enabled = false, type = "spell"},
}

-- =============================================
-- Internal helpers
-- =============================================

local function apLog(msg)
  if apDebug then
    cecho("\n<cyan>[AP Debug]<reset> " .. msg .. "\n")
  end
end

local function apInfo(msg)
  cecho("\n<green>[AutoPractice]<reset> " .. msg .. "\n")
end

local function apWarn(msg)
  cecho("\n<yellow>[AutoPractice]<reset> " .. msg .. "\n")
end

local function apError(msg)
  cecho("\n<red>[AutoPractice]<reset> " .. msg .. "\n")
end

local function formatElapsed(seconds)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = seconds % 60
  if h > 0 then
    return string.format("%dh %dm %ds", h, m, s)
  elseif m > 0 then
    return string.format("%dm %ds", m, s)
  else
    return string.format("%ds", s)
  end
end

-- =============================================
-- apstatus() — "how do I see what it's doing?"
-- =============================================
function apstatus()
  cecho("\n<cyan>═══════════════════════════════════════════<reset>\n")
  cecho("<cyan>          AutoPractice  –  Status<reset>\n")
  cecho("<cyan>═══════════════════════════════════════════<reset>\n")

  -- Running / stopped
  if apRunning then
    cecho("  <green>◉ RUNNING<reset>\n")
  else
    cecho("  <red>◎ STOPPED<reset>\n")
  end

  -- Current action
  if apPracticing and apCurrentSkill then
    cecho("  <yellow>Currently practicing:<reset> " .. apCurrentSkill .. "\n")
  elseif apRunning then
    cecho("  <yellow>State:<reset> travelling / waiting\n")
  end

  -- Remaining practice sessions from server
  if apPracticesLeft then
    cecho("  <yellow>Practice sessions left:<reset> " .. apPracticesLeft .. "\n")
  end

  -- Queue progress
  local total = #apPracticed + #apQueue
  if apPracticing and apCurrentSkill then total = total + 1 end
  cecho("  <yellow>Progress:<reset> " .. #apPracticed .. " done, " ..
        #apQueue .. " remaining" ..
        (total > 0 and (" (of " .. total .. ")") or "") .. "\n")

  -- Session time
  if apSessionStart then
    local elapsed = os.time() - apSessionStart
    cecho("  <yellow>Session time:<reset> " .. formatElapsed(elapsed) .. "\n")
  end

  -- XP tracking
  if apXPGained > 0 then
    cecho("  <yellow>XP gained:<reset> " .. apXPGained .. "\n")
    if apSessionStart then
      local elapsed = os.time() - apSessionStart
      if elapsed > 0 then
        local xpPerHour = math.floor(apXPGained / elapsed * 3600)
        cecho("  <yellow>XP / hour:<reset> " .. xpPerHour .. "\n")
      end
    end
  end

  -- Practiced list
  if #apPracticed > 0 then
    cecho("  <green>Practiced this session:<reset>\n")
    for _, skill in ipairs(apPracticed) do
      cecho("    <green>✓<reset>  " .. skill .. "\n")
    end
  end

  -- Remaining queue
  if #apQueue > 0 then
    cecho("  <yellow>Still to practice:<reset>\n")
    for _, entry in ipairs(apQueue) do
      cecho("    <white>–  " .. entry.name .. "<reset>\n")
    end
  end

  -- Skill list (enabled / disabled)
  cecho("  <cyan>Skill list (apToggle to change):<reset>\n")
  for _, entry in ipairs(apSkillList) do
    if entry.enabled then
      cecho("    <green>[on ]<reset>  " .. entry.name .. "\n")
    else
      cecho("    <red>[off]<reset>  " .. entry.name .. "\n")
    end
  end

  cecho("<cyan>═══════════════════════════════════════════<reset>\n")
end

-- =============================================
-- apToggle(skillName)
-- Enable or disable a skill for the next session.
-- =============================================
function apToggle(skillName)
  for _, entry in ipairs(apSkillList) do
    if entry.name:lower() == skillName:lower() then
      entry.enabled = not entry.enabled
      if entry.enabled then
        apInfo("Enabled  <yellow>" .. entry.name .. "<reset>")
      else
        apWarn("Disabled <yellow>" .. entry.name .. "<reset>")
      end
      return
    end
  end
  apError("Skill/spell not found in list: <yellow>" .. skillName .. "<reset>")
  cecho("  <white>Check apstatus() to see the full skill list.\n")
end

-- =============================================
-- apSetXP(xp)
-- Call this before startAutoPractice() to set your current XP total
-- so the module can calculate XP earned during the session.
-- Example:  apSetXP(1234567)
-- =============================================
function apSetXP(xp)
  apXPStart  = tonumber(xp) or 0
  apXPGained = 0
  apInfo("XP baseline set to <yellow>" .. apXPStart .. "<reset>")
end

-- =============================================
-- Build the practice queue from enabled skills
-- =============================================
local function apBuildQueue()
  apQueue = {}
  for _, entry in ipairs(apSkillList) do
    if entry.enabled then
      table.insert(apQueue, {name = entry.name, type = entry.type})
    end
  end
  apLog("Queue built: " .. #apQueue .. " items")
end

-- =============================================
-- Practice the next skill in the queue
-- =============================================
local function apPracticeNext()
  if not apRunning then return end

  if #apQueue == 0 then
    apInfo("All skills practiced! Session complete.")
    apstatus()
    apRunning    = false
    apPracticing = false
    apCurrentSkill = nil
    return
  end

  local next = table.remove(apQueue, 1)
  apCurrentSkill = next.name
  apPracticing   = true

  apLog("Sending: practice " .. next.name)
  send("practice " .. next.name)
end

-- =============================================
-- startAutoPractice()
-- Travel to Bard Guildmaster and begin practicing.
-- =============================================
function startAutoPractice()
  if apRunning then
    apWarn("Already running!  Use <cyan>stopAutoPractice()<reset> to cancel first.")
    return
  end

  if isFighting then
    apError("Cannot start while in combat — wait until combat ends.")
    return
  end

  apRunning      = true
  apPracticing   = false
  apCurrentSkill = nil
  apPracticed    = {}
  apXPGained     = 0
  apSessionStart = os.time()
  apPracticesLeft = nil

  apBuildQueue()

  if #apQueue == 0 then
    apWarn("No skills are enabled.  Use <cyan>apToggle('skill name')<reset> to enable some, then try again.")
    return
  end

  apRunning = true

  cecho("\n<green>AutoPractice<reset> starting — <yellow>" .. #apQueue ..
        "<reset> skills queued.\n")
  cecho("  Type <cyan>apstatus()<reset> at any time to see what is happening.\n")
  cecho("  Type <cyan>stopAutoPractice()<reset> to cancel.\n\n")

  -- Use the existing travel system to reach the Bard Guildmaster
  gotoBardGuildmaster()
end

-- =============================================
-- stopAutoPractice()
-- =============================================
function stopAutoPractice()
  if not apRunning then
    apWarn("AutoPractice is not running.")
    return
  end
  apRunning      = false
  apPracticing   = false
  apCurrentSkill = nil
  apError("Session stopped by user.")
  apstatus()
end

-- =============================================================================
-- TRIGGERS
-- =============================================================================

-- ---- Shared helper: called by all three practice-result triggers -------------
local function apOnPracticeComplete(skillLabel, logMsg)
  apLog(logMsg)
  if apPracticing then
    table.insert(apPracticed, skillLabel)
    apPracticing   = false
    apCurrentSkill = nil
    tempTimer(AP_PRACTICE_DELAY, function()
      if apRunning and not isFighting then
        apPracticeNext()
      elseif apRunning and isFighting then
        apWarn("In combat — practice paused until fight ends.")
      end
    end)
  end
end

-- ---- XP gain -----------------------------------------------------------------
if apXPGainTrigger then killTrigger(apXPGainTrigger) end
apXPGainTrigger = tempRegexTrigger("You receive (\\d+) experience", function()
  local xp = tonumber(matches[2]) or 0
  apXPGained = apXPGained + xp
  apLog("+XP " .. xp .. " (session total: " .. apXPGained .. ")")
end)

-- ---- Remaining practice sessions reported by server -------------------------
if apPracticesLeftTrigger then killTrigger(apPracticesLeftTrigger) end
apPracticesLeftTrigger = tempRegexTrigger(
  "You have (\\d+) practice session[s]? remaining", function()
  apPracticesLeft = tonumber(matches[2])
  apLog("Practice sessions remaining: " .. apPracticesLeft)
  if apPracticesLeft == 0 and apRunning then
    apWarn("No practice sessions remaining — stopping.")
    apRunning    = false
    apPracticing = false
    apCurrentSkill = nil
    apstatus()
  end
end)

-- ---- Skill improved ---------------------------------------------------------
if apImprovedTrigger then killTrigger(apImprovedTrigger) end
apImprovedTrigger = tempRegexTrigger("^You are now better at (.+)!$", function()
  local skill = matches[2]
  local label = apCurrentSkill or skill
  apInfo("Improved <yellow>" .. skill ..
         "<reset>  (" .. (#apPracticed + 1) .. " done, " .. #apQueue .. " remaining)")
  apOnPracticeComplete(label, "Improved: " .. skill)
end)

-- ---- Already at maximum -----------------------------------------------------
if apMaxTrigger then killTrigger(apMaxTrigger) end
apMaxTrigger = tempRegexTrigger(
  "^You cannot improve (.+) at this time\\.$", function()
  local skill = matches[2]
  apInfo("<yellow>" .. skill .. "<reset> is already at maximum for this level.")
  apOnPracticeComplete((apCurrentSkill or skill) .. " (maxed)", "Already maxed: " .. skill)
end)

-- ---- No improvement this attempt --------------------------------------------
if apNoImproveTrigger then killTrigger(apNoImproveTrigger) end
apNoImproveTrigger = tempRegexTrigger(
  "^You practice (.+) for a while but don't improve\\.$", function()
  local skill = matches[2]
  apInfo("<yellow>" .. skill .. "<reset> — practiced but no improvement this time.")
  apOnPracticeComplete((apCurrentSkill or skill) .. " (no gain)", "No improvement: " .. skill)
end)

-- ---- Arrived at Bard Guild room — begin practicing --------------------------
if apGuildArrivalTrigger then killTrigger(apGuildArrivalTrigger) end
apGuildArrivalTrigger = tempRegexTrigger("^Bard Guild$", function()
  if apRunning and not apPracticing then
    apInfo("Arrived at Bard Guild — starting practice!")
    tempTimer(AP_ARRIVAL_DELAY, function()
      if apRunning then
        apPracticeNext()
      end
    end)
  end
end)

-- ---- Combat ended — resume if paused ----------------------------------------
if apCombatResumeTrigger then killTrigger(apCombatResumeTrigger) end
apCombatResumeTrigger = tempRegexTrigger("R\\.I\\.P\\.", function()
  if apRunning and not apPracticing then
    apInfo("Combat ended — resuming practice.")
    tempTimer(AP_COMBAT_RESUME_DELAY, function()
      if apRunning then
        apPracticeNext()
      end
    end)
  end
end)

-- =============================================================================
cecho("<green>AutoPractice module loaded.<reset>\n")
cecho("  <cyan>startAutoPractice()<reset>  — travel to Bard Guild and practice all enabled skills\n")
cecho("  <cyan>stopAutoPractice()<reset>   — cancel the current session\n")
cecho("  <cyan>apstatus()<reset>           — see exactly what it is doing right now\n")
cecho("  <cyan>apToggle('skill')<reset>    — enable or disable a skill\n")
cecho("  <cyan>apDebug = true<reset>       — enable verbose step-by-step output\n")
