-- =============================================================================
-- Configuration File for TempusMUD Directions Script
-- =============================================================================
--
-- This file contains all user-configurable settings and state variables.
-- Edit this file to customize the script for your character without
-- modifying the main directions.lua file.
--
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

-- Combat state variable
isFighting = false

-- Gith search variables
githFound = 0
findGith = 0
githX = 0
githY = 0
githZ = 0
