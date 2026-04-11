-- =============================================================================
-- AutoPractice Module for TempusMUD Bard - Mudlet Lua
-- =============================================================================
--
-- Automatically navigates to the Bard Guildmaster and practices
-- any spells/skills that are toggled on.
--
-- USAGE:
--   autopractice()          -- start auto-practice session
--   apToggle("Sing")        -- toggle a spell/skill on or off
--   apList()                -- display current toggle state for all spells/skills
--   apReset()               -- re-enable all spells/skills
--   apStop()                -- abort a running auto-practice session
--
-- LOAD THIS FILE:
--   In the Mudlet Script Editor, paste its contents into a new script entry
--   placed BELOW the main TempusMUD Directions script entry so that the
--   gotoBardGuildmaster() function is available when this file runs.
--
--   Or load with:
--     lua dofile(getMudletHomeDir() .. "/autopractice.lua")
--
-- =============================================================================

-- =============================================
-- AutoPractice State
-- =============================================

apRunning      = false    -- true while a session is active
apCurrentIndex = 0        -- index into the practice queue
apQueue        = {}       -- ordered list of skills to practice this session

-- =============================================
-- Bard Spell / Skill List
-- =============================================
-- Each entry has:
--   name    - the exact skill/spell name passed to the 'practice' command
--   enabled - whether this item should be included in an auto-practice session
--
-- Toggle individual items with apToggle("name").
-- Add new bard spells/skills to this table as needed.

apSkills = {
  { name = "Sing",              enabled = true  },
  { name = "Play",              enabled = true  },
  { name = "Chant",             enabled = true  },
  { name = "Ventriloquate",     enabled = true  },
  { name = "Hypnotic Pattern",  enabled = true  },
  { name = "Charm Person",      enabled = true  },
  { name = "Sleep",             enabled = true  },
  { name = "Confusion",         enabled = true  },
  { name = "Cure Light",        enabled = true  },
  { name = "Cause Light",       enabled = true  },
  { name = "Detect Magic",      enabled = true  },
  { name = "Detect Invisibility", enabled = true },
  { name = "Invisibility",      enabled = true  },
  { name = "Locate Object",     enabled = true  },
  { name = "Fly",               enabled = true  },
  { name = "Identify",          enabled = true  },
  { name = "Backstab",          enabled = true  },
  { name = "Pick Lock",         enabled = true  },
  { name = "Sneak",             enabled = true  },
  { name = "Hide",              enabled = true  },
  { name = "Steal",             enabled = true  },
}

-- Delay in seconds between each 'practice' send.
-- Increase if your connection is slow.
apDelay = 0.6

-- =============================================
-- Helper: find a skill entry by name (case-insensitive)
-- =============================================
local function apFind(skillName)
  local lower = skillName:lower()
  for i, entry in ipairs(apSkills) do
    if entry.name:lower() == lower then
      return i, entry
    end
  end
  return nil, nil
end

-- =============================================
-- apToggle(name)
-- =============================================
-- Toggle one spell/skill on or off by name.
-- Example:  apToggle("Steal")  -- turns Steal off if on, on if off

function apToggle(skillName)
  local idx, entry = apFind(skillName)
  if not entry then
    cecho("\n<red>AutoPractice:<reset> Unknown skill '" .. skillName .. "'. Check apList() for valid names.\n")
    return
  end
  entry.enabled = not entry.enabled
  local state = entry.enabled and "<green>ON<reset>" or "<red>OFF<reset>"
  cecho("\n<cyan>AutoPractice:<reset> " .. entry.name .. " toggled " .. state .. "\n")
end

-- =============================================
-- apList()
-- =============================================
-- Display all spells/skills and their toggle state.

function apList()
  cecho("\n<cyan>========== AutoPractice Skill List ==========<reset>\n")
  for i, entry in ipairs(apSkills) do
    local state = entry.enabled and "<green>[ON] <reset>" or "<red>[OFF]<reset>"
    cecho(string.format("  %s %2d. %s\n", state, i, entry.name))
  end
  cecho("<cyan>=============================================<reset>\n")
end

-- =============================================
-- apReset()
-- =============================================
-- Re-enable all spells/skills.

function apReset()
  for _, entry in ipairs(apSkills) do
    entry.enabled = true
  end
  cecho("\n<cyan>AutoPractice:<reset> All skills re-enabled.\n")
end

-- =============================================
-- apStop()
-- =============================================
-- Abort a running auto-practice session.

function apStop()
  if not apRunning then
    cecho("\n<yellow>AutoPractice:<reset> No session is currently running.\n")
    return
  end
  apRunning      = false
  apCurrentIndex = 0
  apQueue        = {}
  cecho("\n<red>AutoPractice:<reset> Session stopped.\n")
end

-- =============================================
-- Internal: practice the next item in the queue
-- =============================================
local function apPracticeNext()
  if not apRunning then return end

  apCurrentIndex = apCurrentIndex + 1

  if apCurrentIndex > #apQueue then
    -- All done
    apRunning      = false
    apCurrentIndex = 0
    apQueue        = {}
    cecho("\n<green>AutoPractice:<reset> Session complete — all enabled skills sent to practice.\n")
    return
  end

  local skillName = apQueue[apCurrentIndex]
  cecho(string.format("\n<cyan>AutoPractice:<reset> Practicing (%d/%d): <yellow>%s<reset>\n",
    apCurrentIndex, #apQueue, skillName))
  send("practice " .. skillName)

  -- Schedule next skill
  tempTimer(apDelay, apPracticeNext)
end

-- =============================================
-- autopractice()
-- =============================================
-- Main entry point.  Navigates to the Bard Guildmaster then
-- iterates through all enabled spells/skills.

function autopractice()
  if apRunning then
    cecho("\n<yellow>AutoPractice:<reset> A session is already running. Use apStop() to cancel it first.\n")
    return
  end

  -- Build practice queue from enabled skills
  apQueue = {}
  for _, entry in ipairs(apSkills) do
    if entry.enabled then
      table.insert(apQueue, entry.name)
    end
  end

  if #apQueue == 0 then
    cecho("\n<red>AutoPractice:<reset> No skills are enabled! Use apToggle() or apReset() to enable some.\n")
    return
  end

  cecho(string.format("\n<cyan>AutoPractice:<reset> Starting session — <yellow>%d<reset> skill(s) queued.\n", #apQueue))
  apList()

  -- Navigate to Bard Guildmaster, then start practicing
  gotoBardGuildmaster()

  -- Wait for travel to complete before sending practice commands.
  -- We poll the 'travelling' state variable set by the travel system.
  local function waitForArrival()
    if travelling and travelling == 1 then
      -- Still travelling — check again shortly
      tempTimer(1, waitForArrival)
      return
    end
    if travelerror and travelerror ~= 0 then
      cecho("\n<red>AutoPractice:<reset> Travel failed (travelerror=" .. travelerror .. "). Aborting.\n")
      resettravel()
      apRunning      = false
      apCurrentIndex = 0
      apQueue        = {}
      return
    end
    -- Arrived — small extra pause to let the room description render
    cecho("\n<cyan>AutoPractice:<reset> Arrived at Bard Guildmaster. Beginning practice...\n")
    apRunning      = true
    apCurrentIndex = 0
    tempTimer(1, apPracticeNext)
  end

  tempTimer(2, waitForArrival)
end

-- =============================================
-- Load confirmation
-- =============================================
cecho("\n<cyan>AutoPractice loaded!<reset> Commands: autopractice(), apList(), apToggle(name), apReset(), apStop()\n")
