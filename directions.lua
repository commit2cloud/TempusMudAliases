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

-- Combat state variable
isFighting = false

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
-- Combat Detection Helper
-- =============================================
-- Helper function to check if player is in combat
-- Combat state is tracked via triggers that detect TempusMUD combat messages
-- Combat end is detected by "R.I.P." message when a mob dies
-- Note: This may not work perfectly when fighting multiple mobs simultaneously
function isInFight()
  return isFighting
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

-- ============================================= 
-- PAST DESTINATIONS (43 locations)
-- =============================================

function gotoOldMonastery() travelTo("hs", "Old Monastery", "12n7en") end
function gotoCastleSlivendark() travelTo("hs", "Castle Slivendark", "32w4sw2s2w3sese3sw3sd") end
function gotoChessboardOfAraken() travelTo("hs", "Chessboard of Araken", "9w8s;open porticullis;s;open door;2swsw2se") end
function gotoCrystalFortress() travelTo("hs", "Crystal Fortress", "46w24su5s10w3s4d2en2n2wn2w2s;open rock;2se2swswsese;pull lever;2w3s") end
function gotoDismalDelve() travelTo("hs", "Dismal Delve", "67w12seseds6wndnd;enter portal;nw2n2ed") end
function gotoDraconiansAndDragonHighlord() travelTo("hs", "Draconians and Dragon Highlords", "32wswsw2se2s2w2sw2sws2w4sws2w") end
function gotoDukeAraken() travelTo("hs", "Duke Araken", "9w8s;open porticullis;s;open door;2sese4sw2se3sw3u3s") end
function gotoElvenVillage() travelTo("hs", "Elven Village", "22n4e5n") end
function gotoForgottenValley() travelTo("hs", "Forgotten Valley", "60n2e3nwnwn3e4s2d") end
function gotoFontOfModrian() travelTo("hs", "Font of Modrian", "7e4ne;enter font") end
function gotoFrozenTundras() travelTo("hs", "Frozen Tundras", "37e41n;open gate;8n;open gate;17n3w2nw9n7e3nw2ue2wunwndw2nwue3n3w5ne2n") end
function gotoGlacialRift() travelTo("hs", "Glacial Rift", "37e41n;open gate;8n;open gate;17n3w2nw9n7e3nw2ue2wunwndw2nwue3n3w5ne2n4n2wnwn2w3nd") end

-- Standalone navigation to Paingiver in Glacial Rift
function gotoGlaicialRiftPaingiver()
  cecho("\n<green>Okay!<reset> Travelling to the <yellow>Glacial Rift Paingiver<reset>!\n")
  sendDirs("n;n;u;n;e;open tapestry;n;n;n;n;open gate n;n;n;n;n;n;n;n;n;n;n;n;n;n;n;n;n;n;w;w;w;n;n;w;n;n;n;n;n;n;n;n;n;e;e;e;e;e;e;e;n;n;n;w;u;u;e;w;w;u;n;w;n;d;w;n;n;w;u;e;n;n;n;w;w;w;n;n;n;n;n;e;n;n;n;n;n;n;w;w;w;n;n;w;w;w;n;n;n;d;w;w;n;n;n;u;e;e;u;n;e;s;s;e;e;n;n;n;e;e;s;s;s;s;s;s;s;s;w;w;w;w;w;w;s;s;e;e;n;e;e;e;s;s;s;e")
end

function gotoGreatPyramid() travelTo("hs", "Great Pyramid", "74w7s3e9s3wuenu") end
function gotoGuiharianFestivalOfLights() travelTo("hs", "Guiharian Festival of Lights", "4w3se4s") end
function gotoHalflingVillage() travelTo("hs", "Halfling Village", "15e10s4e") end
function gotoHarpellHouse() travelTo("hs", "Harpell House", "19e2n;enter house") end
function gotoHighTowerOfMagic() travelTo("hs", "High Tower of Magic", "34w3nw3n") end
function gotoHillGiantSteading() travelTo("hs", "Hill Giant Steading", "37e41n;open gate;8n;open gate;17nenw;open door w;w") end
function gotoHobgoblins() travelTo("hs", "Hobgoblin Tunnels", "15n2ese;open door n;n") end
function gotoHolyGrail() travelTo("hs", "Holy Grail", "38w2nw3nw8nw3n2wn3ed2nednd2ndn2e3n2e3nwu") end
function gotoIstan() travelTo("hs", "City of Istan", "37e41n") end
function gotoKoboldTunnels() travelTo("hs", "Kobold Tunnels", "3w8swse10s3e2s4en") end
function gotoLearander() travelTo("hs", "Caves of Learander", "56w27s6ws10w3s4d2e") end
function gotoMalevolentCircle() travelTo("hs", "Malevolent Circle", "39e21s3es3es2eswses2e") end
function gotoMavernal() travelTo("hs", "City of Mavernal", "26n15e1n3e1n1e2n5es;open gate e") end
function gotoNeverwhere() travelTo("hs", "Realm of Neverwhere", "50w9s4w2s6w11s3e2s2e2und") end
function gotoOgreEncampment() travelTo("hs", "Ogre Encampment", "7w4n17ws3w3ne2nene2nw3n7e5nw2n2w") end
function gotoOldThalos() travelTo("hs", "City of Old Thalos", "67w22s12w") end
function gotoPitFiend() travelTo("hs", "Pit Fiend", "13w4s2w2s3w") end
function gotoPoolOfEvil() travelTo("hs", "Pool of Evil", "3w8swse10s3e2s4e5nw3n2es") end
function gotoReedSwamp() travelTo("hs", "Reed Swamp", "32w4sws") end
function gotoSewersOfModrian() travelTo("hs", "Sewers of Modrian", "2n3w;open grate;d") end

function gotoShade() 
  gotohs(function()
    tempTimer(1, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Shadow City of Shade<reset>!\n")
        sendDirs("61n2e2n8e")
        send("where")
        send("challenge area")
        helpShade()
      else
        resettravel()
      end
    end)
  end)
end

function helpShade()
  cecho("\n<magenta>Help Shade<cyan>: gotoShadeRebel and gotoShadeSelset available\n")
end

function gotoShadeRebel()
  send("where")
  tempTimer(1, function()
    if currentRoom == "The Top of the Tower" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>Shade Rebel<reset>!\n")
      sendAll("fly", "d", "e", "s", "d", "d", "d", "s", "e", "n", "n", "n", "n", "bash stone d", "d", "s", "w", "w", "d", "w", "n", "n", "w", "w", "n", "d", "w", "s", "d", "s", "u", "w")
    else
      cecho("\n<red>Error: Not in correct room!\n")
    end
  end)
end

function gotoShadeSelset()
  send("where")
  tempTimer(1, function()
    if currentRoom == "In the Catacombs" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>Shade Selset<reset>!\n")
      sendAll("fly", "e", "d", "n", "u", "e", "bash cage n")
    else
      cecho("\n<red>Error: Not in correct room!\n")
    end
  end)
end

function gotoSilverTower() travelTo("hs", "Silver Tower", "7e11s") end
function gotoSolaceCove() travelTo("hs", "City of Solace Cove", "104w") end
function gotoSkullport() travelTo("hs", "City of Skullport", "17e7s2w8sd6e7nen2e2nw3ne6ne6n4e7nw3n2wne5nse9n") end
function gotoTempleOfAncients() travelTo("hs", "Temple of Ancients", "39e25s") end
function gotoTowerOfTheRenegadeMage() travelTo("hs", "Tower of the Renegade Mage", "125w3n9ws4e") end

-- Sub-destination within Tower of Renegade Mage
function gotoTowerOfTheRenegadeMageBlue()
  sendAll("enter blue", "3w3s3ewwsw", "pull lever", "push blue library", "where")
end
function gotoTheTreetopsOfArachna() travelTo("hs", "Treetops of Arachna", "7w2n2w2n13w2s2wn3wu;2w2n1e1n1e1n1e1u") end
function gotoUndermountain() travelTo("hs", "Undermountain", "37e41n;open gate;3nesend") end
function gotoVaporRats() travelTo("hs", "Vapor Rats of EPOW", "8e4ne;enter font;3u") end
function gotoWemicPlains() travelTo("hs", "Wemic Plains", "81wn") end
function gotoZhengisCastle() travelTo("hs", "Zhengi's Castle", "39w3s3w4s1u2w2s9w") end

-- Future Destinations
function gotoAPollutedVillage() travelTo("star", "Polluted Village", "10w2sw2s5w") end
function gotoArcheologicalDig() travelTo("star", "Archeological Dig", "22n8e5s") end
function gotoBlastedSwamp() travelTo("star", "Blasted Swamp", "16w8n") end
function gotoColony() travelTo("star", "Colony", "e4swe7s2e4sd13e2n") end
function gotoCybertechLabs() travelTo("star", "Cybertech Labs", "5e3s2w1s") end
function gotoCybertechPreparatorySchool() travelTo("star", "Cybertech Preparatory School", "5e3s2w4n") end
function gotoDeathRow() travelTo("star", "Death Row", "8n;w;du") end
function gotoDracharnos()
  gotostar(function()
    tempTimer(1, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Dracharnos<reset>!\n")
        sendDirs("25wnuwununend2n3ed2nw;open grate;u")
        send("where")
        send("challenge area")
        helpDracharnos()
      else
        resettravel()
      end
    end)
  end)
end
function helpDracharnos()
  cecho("<yellow>To Aged Dragon: enter tube n of Wzu; w;4n;drink stream;2swsw\n")
end
function gotoDrugDealer() travelTo("star", "Drug Dealer", "8w5n4w;enter door") end
function gotoECJunkyard() travelTo("star", "Junk Yard", "8w2n") end
function gotoECMilitary() travelTo("star", "E.C. Military", "9w3sw;push button;e2se") end
function gotoECVamps() travelTo("star", "E.C. Vampires", "5e11n;open door e;6es") end
function gotoECNuclearPower() travelTo("star", "E.C. Nuclear Power Plant", "17n3e;open gate e;e") end
function gotoECPowerAndPlumbing() travelTo("star", "E.C. Power and Plumbing", "10en") end
function gotoECSecurityCompound() travelTo("star", "E.C. Security Compound", "4n7e6n2en") end
function gotoECUniversity() travelTo("star", "E.C. University", "4w6s2ws") end
function gotoElectronicsSchool() travelTo("star", "Electronics School", "4w4n1w1n") end
function gotoElectronicsShop() travelTo("star", "Electronics Shop", "5nes") end
function gotoFailFamilyLegacy() travelTo("star", "Fail Family Legacy", "e9s3e") end

-- Navigate to Freddy Fail from Fail Family Legacy mansion
function gotoFailFamilyLegacyFreddy()
  send("where")
  tempTimer(2, function()
    if currentRoom == "Walkway to a Huge Mansion" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>Freddy Fail<reset>!\n")
      sendDirs("e;e;n;n;n;open door n;n;search coat;s;d;unlock door w;open door w;w;n;e;n;e;e;n;w;push button;n;n;w;u;push 11;listen;e;s;s;w;n;enter tube;push blue")
    else
      cecho("\n<red>Error<reset>: You're not in the correct room 'Walkway to a Huge Mansion'!\n")
    end
  end)
end

function gotoFassanSlaveCompound() travelTo("star", "Fassan Slave Compound", "2ds2dwd27wuwu3n4w3nwun") end
function gotoGenCloneBioMechanicalLabs() travelTo("star", "GenClone BioMechanical Labs", "16w9nen4w8n") end

function gotoHitpointIncreaser()
  gotostar(function()
    tempTimer(2, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Hitpoints Increaser<reset>!\n")
        sendDirs("3n1e;open door s;1s1u")
        send("where")
        send("challenge area")
      else
        resettravel()
      end
    end)
  end)
end

function gotoImplantChamber()
  gotostar(function()
    tempTimer(2, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Implant Chamber<reset>!\n")
        sendDirs("4w3n3w")
        send("where")
        send("challenge area")
      else
        resettravel()
      end
    end)
  end)
end

function gotoKiddieKandy() travelTo("star", "Kiddie Kandy Incorporated", "4n2wn;open gate n;n") end
function gotoKromguard() travelTo("star", "Kromguard", "19w3n;enter fortress") end
function gotoLuxare() travelTo("star", "Luxare", "4w4nen") end
function gotoMerquryCity() travelTo("star", "Merqury City", "19w3n;enter fortress") end
function gotoNETWORKCommunicationsTower() travelTo("star", "NETWORK Communications Tower", "4w4ne;open door s;s") end
function gotoReinforcer() travelTo("star", "Reinforcer", "4w5n2w") end
function gotoRuinsOfHTOM() travelTo("star", "Ruins of the High Tower of Magic", "34w3n2w7n") end
function gotoRuinsOfTheSilverTower() travelTo("star", "Ruins of the Silver Tower", "9e11s") end
function gotoSimeonTheCybernetic() travelTo("star", "Simeon the Cybernetic", "4w3n1e") end
function gotoTriskinAsylum()
  cecho("\n<red>Note: Triskin Asylum zone is currently CLOSED<reset>\n")
  -- Kept for reference in case zone reopens in future
end
function gotoVirtualWorldOfNETWORK() travelTo("star", "Virtual World of NETWORK", "4w4ne;open door s;3s") end
function gotoZulDane() travelTo("star", "City of Zul'Dane", "26n4e") end

-- Underdark
function gotoUndeadShark() travelTo("skull", "Undead Shark", "2es2u;open plant e;es") end
function gotoHeadShrinker() travelTo("skull", "Head Shrinker", "11s2wdnund2sundwun2d3ws;open hide;1w") end
function gotoLizardCaverns() travelTo("skull", "Lizard Caverns", "11s2wdnund2sundwun2dw4n") end
function gotoWyllowwood() travelTo("skull", "Wyllowwood", "6s2w4sedwun2dw4n") end

-- Planes
function gotoAbyssUnholyModrian() travelTo("astral", "City of Unholy Modrian", "5nu3w;enter void") end
function gotoAmoria() travelTo("astral", "Amoria", "5n3u2n3e;enter light") end
function gotoAvernusHell() travelTo("astral", "Level 1 Hell: Avernus", "5wdes;enter flame") end
function gotoElementalPlaneOfAir() travelTo("hs", "Elemental Plane of Air", "7e4ne;enter font;3u;enter portal") end
function gotoElementalPlaneOfEarth() travelTo("hs", "Elemental Plane of Earth", "67w12seseds6wndnd;enter portal;nw2n2ed;enter portal") end
function gotoElementalPlaneOfFire() travelTo("hs", "Elemental Plane of Fire", "7e4ne;enter font;3u;enter portal") end
function gotoElementalPlaneOfIce() travelTo("hs", "Elemental Plane of Ice", "7e4ne;enter font;3u;enter portal") end
function gotoElementalPlaneOfOoze() travelTo("hs", "Elemental Plane of Ooze", "7e4ne;enter font;3u;enter portal") end
function gotoElementalPlaneOfSmoke() travelTo("hs", "Elemental Plane of Smoke", "7e4ne;enter font;3u;enter portal") end
function gotoElementalPlaneOfWater() travelTo("hs", "Elemental Plane of Water", "7e3n2enw;enter portal") end
function gotoLuniaHeaven()
  gotoastral(function()
    tempTimer(1, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Lunia Heaven 1<reset>!\n")
        sendDirs("5n3d2sw;enter pool")
        send("where")
        send("challenge area")
        -- Trigger to show help when entering Heaven
        if heavenHelpTrigger then
          killTrigger(heavenHelpTrigger)
        end
        heavenHelpTrigger = tempRegexTrigger("^You step into a gold color pool", helpHeaven)
      else
        resettravel()
      end
    end)
  end)
end
function gotoImmoth() travelTo("hs", "Immoth Hallow", "2nu;open door west;w") end
function gotoCastleMahlhevik() travelTo("astral", "Castle Mahlhevik", "5n3u2n3e;enter light;e3s2enuseuene") end
function gotoGith()
  githFound = 0
  findGith = 1
  githX = 0
  githY = 0
  githZ = 0
  gotoastral(function()
    tempTimer(1, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to <yellow>Githyanki Fortress<reset>!\n")
        for i=1,5 do send("north") end
        send("exits")
      else
        resettravel()
      end
    end)
  end)
end

-- Heaven Helper Functions
function helpHeaven()
  cecho("\n<magenta>------------------------<magenta>Help Heaven<magenta>---------------------------------<cyan>\n")
  cecho("<magenta>To Thor<cyan>: nenenu5wn2wse - Use gotoThor\n")
  cecho("<magenta>To Diancecht<cyan>: 2w2n4esene3ne3nws - Use gotoDiancecht\n")
  cecho("<magenta>To Ptah<cyan>: ne7s2edeu4w2n4u - Use gotoPtah\n")
  cecho("<magenta>To Ixlilton<cyan>: 4d2s4edsu2e4n - Use gotoIxlilton\n")
  cecho("<magenta>To Ushas<cyan>: 4s2wdwu3ws3w3sw3sw - Use gotoUshas\n")
  cecho("<magenta>To Fu-Hsiing<cyan>: e3nenene - Use gotoFu\n")
  cecho("<magenta>To Ebisu<cyan>: unnww - Use gotoEbisu\n")
  cecho("<magenta>To Castle Mahlhevik<cyan>: e3s2enuseuene - Use gotoMahlhevik\n")
  cecho("<magenta>--------------------------------------------------------------------<cyan>\n")
end

function gotoThor()
  send("where")
  tempTimer(1, function()
    if currentRoom == "In the Silver Sea" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>Thor, God of Lightning<reset>!\n")
      sendDirs("nenenu5wn2wse")
    else
      cecho("\n<red>Error<cyan>: You're not in the correct room 'In the Silver Sea'!\n")
    end
  end)
end

function gotoDiancecht()
  send("where")
  tempTimer(1, function()
    if currentRoom == "Before a Palatial Estate" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>Diancecht<reset>!\n")
      sendDirs("2w2n4esene3ne3nws")
    else
      cecho("\n<red>Error<cyan>: You're not in the correct room 'Before a Palatial Estate'!\n")
    end
  end)
end

function gotoPtah()
  send("where")
  tempTimer(1, function()
    if currentRoom == "Before a Spiraling Tower" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>Ptah<reset>!\n")
      sendDirs("ne7s2edeu4w2n4u")
    else
      cecho("\n<red>Error<cyan>: You're not in the correct room 'Before a Spiraling Tower'!\n")
    end
  end)
end

function gotoIxlilton()
  send("where")
  tempTimer(1, function()
    if currentRoom == "A Garden Plateau" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>Ixlilton<reset>!\n")
      sendDirs("4d2s4edsu2e4n")
    else
      cecho("\n<red>Error<cyan>: You're not in the correct room 'A Garden Plateau'!\n")
    end
  end)
end

-- EPOS Helper Functions  
function helpEPOS()
  cecho("\n<magenta>--------------<magenta>Help Elemental Plane of Smoke<magenta>-----------------------<cyan>\n")
  cecho("<magenta>Start All directions from<cyan>: 'Pitch Black'\n")
  cecho("<magenta>To Choking Palace<cyan>: 2dn;enter palace - Use gotoEPOSPalace\n")
  cecho("<magenta>To The Fortress<cyan>: 3d2se;enter cloud - Use gotoEPOSFortress\n")
  cecho("<magenta>To The Camp<cyan>: dwn;enter cloud - Use gotoEPOSCamp\n")
  cecho("<magenta>--------------------------------------------------------------------<cyan>\n")
end

function gotoEPOSPalace()
  send("where")
  tempTimer(1, function()
    if currentRoom == "Pitch Black" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>EPOS Palace<reset>!\n")
      sendDirs("2dn;enter palace")
    else
      cecho("\n<red>Error<cyan>: You're not in the correct room 'Pitch Black'!\n")
    end
  end)
end

function gotoEPOSFortress()
  send("where")
  tempTimer(1, function()
    if currentRoom == "Pitch Black" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>EPOS Fortress<reset>!\n")
      sendDirs("3d2se;enter cloud")
    else
      cecho("\n<red>Error<cyan>: You're not in the correct room 'Pitch Black'!\n")
    end
  end)
end

function gotoEPOSCamp()
  send("where")
  tempTimer(1, function()
    if currentRoom == "Pitch Black" then
      cecho("\n<green>Okay!<reset> Travelling to <yellow>EPOS Camp<reset>!\n")
      sendDirs("dwn;enter cloud")
    else
      cecho("\n<red>Error<cyan>: You're not in the correct room 'Pitch Black'!\n")
    end
  end)
end

function helpEPOSCraftsman()
  cecho("\n<magenta>--------------<magenta>Elemental Plane of Smoke Craftsman<magenta>-----------------------<cyan>\n")
  cecho("<magenta>A smoking helm<cyan>: some smoke dragon scales + a smokey potion\n")
  cecho("<magenta>Some scale-plated gauntlets<cyan>: some smoke dragon scales + gauntlets of ogre power (Ogre Village)\n")
  cecho("<magenta>Some smoky colored scalemail<cyan>: some smoke dragon scales + scalemail jacket\n")
  cecho("<magenta>Some scaled leggings<cyan>: some smoke dragon scales + jeweled leggings (Malevolent Circle)\n")
  cecho("<magenta>A dragonshaped shield<cyan>: some smoke dragon scales + heavy metal shield\n")
  cecho("<magenta>--------------------------------------------------------------------<cyan>\n")
end

-- Trainers
function gotoCharismaTrainer() travelTo("star", "Charisma Trainer", "3n1e;open door s;1s1w") end
function gotoConstitutionTrainer() travelTo("hs", "Constitution Trainer", "2nunw;open tapestry;3e4ne") end
function gotoDexterityTrainer()
  gotohs(function()
    tempTimer(1, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Dexterity Trainer<reset>!\n")
        sendDirs("nnwwww;open grate;dessesusseuswnw")
        cecho("<cyan>Kill the Assassin and go two west!\n")
        send("where")
        send("challenge area")
      else
        resettravel()
      end
    end)
  end)
end
function gotoIntelligenceTrainer() travelTo("hs", "Intelligence Trainer", "2nu;open door west;w") end
function gotoStrengthTrainer() travelTo("hs", "Strength Trainer", "2nune;open tapestry;3nen") end
function gotoWisdomTrainer() travelTo("hs", "Wisdom Trainer", "6e11s;open door s;3s1u2s1e") end
function gotoWeaponEnhancer() travelTo("star", "Weapons Enhancer", "5n2w1s1e") end
function gotoWeaponSpecializer() travelTo("skull", "Weapon Specializer", "4sd2enen2e4nw3nen2w2n2e2n2e2un4eu;open ebony;ws2w") end
function gotoWeaponUnSpecializer() travelTo("star", "Weapon UNSpecializer", "3n1e;open door s;1s1u1e") end
function gotoGainer()
  cecho("\n<yellow>Note: Gainer (Nohunger & Nothirst) is 1w of Grand Mistress at top of HTOM\n")
  cecho("Portal to him is at the top of High Tower of Magic\n")
end

-- Language Trainers
function gotoModriadicTrainer()
  gotohs(function()
    tempTimer(2, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Modriadic Trainer<reset>!\n")
        send("where")
        send("challenge area")
      else
        resettravel()
      end
    end)
  end)
end

function gotoElvishTrainer()
  gotohs(function()
    tempTimer(2, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Elvish Trainer<reset>!\n")
        sendDirs("22n4e9n3w;offer elvish")
        send("where")
        send("challenge area")
      else
        resettravel()
      end
    end)
  end)
end

function gotoOrcishTrainer()
  gotostar(function()
    tempTimer(2, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Orcish Trainer<reset>!\n")
        send("where")
        send("challenge area")
      else
        resettravel()
      end
    end)
  end)
end

function gotoHobbishTrainer()
  gotohs(function()
    tempTimer(2, function()
      if travelerror == 0 then
        cecho("\n<green>Okay!<reset> Travelling to the <yellow>Hobbish Trainer<reset>!\n")
        sendDirs("15e10s6e3n;open door north;2n;offer hobbish")
        send("where")
        send("challenge area")
      else
        resettravel()
      end
    end)
  end)
end

-- Guilds
function gotoBarbarianGuildmaster() travelTo("hs", "Barbarian Guildmaster", "57w11n") end
function gotoBardGuildmaster() travelTo("hs", "Bard Guildmaster", "3w2swn") end
function gotoClericEvilGuildmaster() travelTo("skull", "Evil Cleric Guildmaster", "7n2w;open door w;2w") end
function gotoClericGoodGuildmaster() travelTo("hs", "Good Cleric Guildmaster", "6e11s;open door s;3s;5u2s") end
function gotoCyborgGuildmaster() travelTo("star", "Cyborg Guildmaster", "4w2nws") end
function gotoKnightEvilGuildmaster() travelTo("skull", "Evil Knight Guildmaster", "2w2ne") end
function gotoKnightGoodGuildmaster() travelTo("hs", "Good Knight Guildmaster", "2nunw;open tap;4wn3e") end
function gotoMageGuildmaster() travelTo("hs", "Mage Guildmaster", "4nu;open door west;w") end
function gotoMercenaryGuildmaster() travelTo("star", "Mercenary Guildmaster", "2d4e5nes") end
function gotoMonkGuildmaster() travelTo("hs", "Monk Guildmaster", "37e41n;open gate n;4n3w") end
function gotoPhysicGuildmaster() travelTo("star", "Physics Guildmaster", "3s2uswn") end
function gotoPsionicistGuildmaster() travelTo("hs", "Psionic Guildmaster", "2nune;open tapestry;3w") end
function gotoRangerGuildmaster() travelTo("hs", "Ranger Guildmaster", "nnune;open tapestry;ssswwse") end
function gotoThiefGuildmaster() travelTo("skull", "Thief Guildmaster", "4e;open portrait;2ene2s") end

-- =============================================
-- Menu Display Functions
-- =============================================

function showMainMenu()
  cecho("\n<cyan>┌------------------------------------------------------------------------------┐\n")
  cecho("<cyan>|                          <orange> Where To Travel                                    <cyan>|\n")
  cecho("<cyan>├------------------------------------------------------------------------------┤\n")
  cecho("<cyan>|                                                                              |\n")
  cecho("<cyan>|               1) <magenta>Past      <cyan>2) <yellow>Future      <cyan>3) <orange>Planes                          <cyan>|\n")
  cecho("<cyan>|               4) <white>Trainers  <cyan>5) <red>Guilds      <cyan>6) <dark_gray>Underdark                       <cyan>|\n")
  cecho("<cyan>|                               7) <brown>All                                         <cyan>|\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>└------------------------------------------------------------------------------┘\n")
end

function showHelpMenu()
  cecho("\n<yellow>******************************************************************************************\n")
  cecho("<yellow>*                                Directions Help!                                        *\n")
  cecho("<yellow>******************************************************************************************\n")
  cecho("<yellow>*                                                                                        *\n")
  cecho("<yellow>* <magenta>Usage: <reset>travel <plane> <zone>                                                           <yellow>*\n")
  cecho("<yellow>* <white>Example: <reset>travel planes 9                                                               <yellow>*\n")
  cecho("<yellow>*      Travel to the Elemental Plane of Smoke                                            <yellow>*\n")
  cecho("<yellow>* <white>Example: <reset>travel 2 15                                                                   <yellow>*\n")
  cecho("<yellow>*      Travel to the Future's EC University                                              <yellow>*\n")
  cecho("<yellow>*                                                                                        *\n")
  cecho("<yellow>* <red>Recommendations: <reset>Make an alias in your own scripting config for locations you use       <yellow>*\n")
  cecho("<yellow>*    regularly!                                                                          <yellow>*\n")
  cecho("<yellow>******************************************************************************************\n")
end

function showPastMenu()
  cecho("\n<cyan>┌------------------------------------------------------------------------------┐\n")
  cecho("<cyan>|                           <magenta>Past Locations                                     <cyan>|\n")
  cecho("<cyan>├------------------------------------------------------------------------------┤\n")
  cecho("<cyan>|  <magenta>1) <reset>Abandoned Keep       <magenta>2) <reset>Old Monastery        <magenta>3) <reset>Castle Slivendark        <cyan>|\n")
  cecho("<cyan>|  <magenta>4) <reset>Chessboard of Araken <magenta>5) <reset>Dismal Delve         <magenta>6) <reset>Draconians and Highlords <cyan>|\n")
  cecho("<cyan>|  <magenta>7) <reset>Duke Araken          <magenta>8) <reset>Elven Village        <magenta>9) <reset>Forgotten Valley         <cyan>|\n")
  cecho("<cyan>| <magenta>10) <reset>Font of Modrian     <magenta>11) <reset>Frozen Tundras      <magenta>12) <reset>Glacial Rift             <cyan>|\n")
  cecho("<cyan>| <magenta>13) <reset>Great Pyramid       <magenta>14) <reset>Guiharian Festival  <magenta>15) <reset>Halfling Village         <cyan>|\n")
  cecho("<cyan>| <magenta>16) <reset>Harpell House       <magenta>17) <reset>High Tower of Magic <magenta>18) <reset>Hill Giant Steading      <cyan>|\n")
  cecho("<cyan>| <magenta>19) <reset>Hobgoblins          <magenta>20) <reset>Holy Grail          <magenta>21) <reset>Istan                    <cyan>|\n")
  cecho("<cyan>| <magenta>22) <reset>Kobold Tunnels      <magenta>23) <reset>Caves of Learander  <magenta>24) <reset>Crystal Fortress         <cyan>|\n")
  cecho("<cyan>| <magenta>25) <reset>Malevolent Circle   <magenta>26) <reset>Mavernal            <magenta>27) <reset>Neverwhere               <cyan>|\n")
  cecho("<cyan>| <magenta>28) <reset>Ogre Encampment     <magenta>29) <reset>Old Thalos          <magenta>30) <reset>Pit Fiend                <cyan>|\n")
  cecho("<cyan>| <magenta>31) <reset>Pool of Evil        <magenta>32) <reset>Reed Swamp/Lizards  <magenta>33) <reset>Sewers of Modrian        <cyan>|\n")
  cecho("<cyan>| <magenta>34) <reset>Shade               <magenta>35) <reset>Silver Tower        <magenta>36) <reset>Solace Cove              <cyan>|\n")
  cecho("<cyan>| <magenta>37) <reset>Skullport (River)   <magenta>38) <reset>Temple of Ancients  <magenta>39) <reset>Tower of Renegade Mage   <cyan>|\n")
  cecho("<cyan>| <magenta>40) <reset>Treetops of Arachna <magenta>41) <reset>Undermountain       <magenta>42) <reset>Wemic Plains             <cyan>|\n")
  cecho("<cyan>| <magenta>43) <reset>Zhengi's Castle                                                          <cyan>|\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>└------------------------------------------------------------------------------┘\n")
end

function showFutureMenu()
  cecho("\n<cyan>┌------------------------------------------------------------------------------┐\n")
  cecho("<cyan>|                           <yellow>Future Locations                                   <cyan>|\n")
  cecho("<cyan>├------------------------------------------------------------------------------┤\n")
  cecho("<cyan>|  <magenta>1) <reset>Polluted Village    <magenta>2) <reset>Archaeological Dig      <magenta>3) <reset>Blasted Swamp             <cyan>|\n")
  cecho("<cyan>|  <magenta>4) <reset>Colony              <magenta>5) <reset>Cybertech Labs       <magenta>6) <reset>Cybertech Preparatory     <cyan>|\n")
  cecho("<cyan>|  <magenta>7) <reset>Death Row           <magenta>8) <reset>Dracharnos           <magenta>9) <reset>Drug Dealer               <cyan>|\n")
  cecho("<cyan>| <magenta>10) <reset>EC Junkyard        <magenta>11) <reset>EC Military          <magenta>12) <reset>EC Vampires              <cyan>|\n")
  cecho("<cyan>| <magenta>13) <reset>EC Nuclear Power   <magenta>14) <reset>EC Power & Plumbing  <magenta>15) <reset>EC Security Compound     <cyan>|\n")
  cecho("<cyan>| <magenta>16) <reset>EC University      <magenta>17) <reset>Electronics School   <magenta>18) <reset>Electronics Shop         <cyan>|\n")
  cecho("<cyan>| <magenta>19) <reset>Fail Family Legacy <magenta>20) <reset>Fassan Slave Compound<magenta>21) <reset>GenClone Bio Labs        <cyan>|\n")
  cecho("<cyan>| <magenta>22) <reset>Kiddie Kandy, Inc. <magenta>23) <reset>Kromguard            <magenta>24) <reset>Luxare                   <cyan>|\n")
  cecho("<cyan>| <magenta>25) <reset>Merqury City       <magenta>26) <reset>NETWORK  Tower       <magenta>27) <reset>Equipment Reinforcer     <cyan>|\n")
  cecho("<cyan>| <magenta>28) <reset>Ruins of HTOM      <magenta>29) <reset>Silver Tower  Ruins  <magenta>30) <reset>Simeon the Cybernetic     <cyan>|\n")
  cecho("<cyan>| <magenta>31) <red>Triskin Asylum     <magenta>32) <reset>Virtual  World       <magenta>33) <reset>Zul'Dane                  <cyan>|\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>└------------------------------------------------------------------------------┘\n")
end

function showPlanesMenu()
  cecho("\n<cyan>┌------------------------------------------------------------------------------┐\n")
  cecho("<cyan>|                           <orange>Planes Locations                                   <cyan>|\n")
  cecho("<cyan>├------------------------------------------------------------------------------┤\n")
  cecho("<cyan>|  <magenta>1) <reset>Abyss/Unholy Mod    <magenta>2) <reset>Amoria                <magenta>3) <reset>Avernus, Hell Level 1    <cyan>|\n")
  cecho("<cyan>|  <magenta>4) <reset>Plane of Air        <magenta>5) <reset>Plane of Earth        <magenta>6) <reset>Plane of Fire            <cyan>|\n")
  cecho("<cyan>|  <magenta>7) <reset>Plane of Ice        <magenta>8) <reset>Plane of Ooze         <magenta>9) <reset>Plane of Smoke           <cyan>|\n")
  cecho("<cyan>| <magenta>10) <reset>Plane of Water     <magenta>11) <reset>Lunia, Heaven Level 1<magenta>12) <reset>Immoth                    <cyan>|\n")
  cecho("<cyan>| <magenta>13) <reset>Castle Mahlhevik   <magenta>14) <reset>Githyanki Fortress                                 <cyan>|\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>└------------------------------------------------------------------------------┘\n")
end

function showTrainersMenu()
  cecho("\n<cyan>┌------------------------------------------------------------------------------┐\n")
  cecho("<cyan>|                          <white>Trainers Locations                                  <cyan>|\n")
  cecho("<cyan>├------------------------------------------------------------------------------┤\n")
  cecho("<cyan>|  <magenta>1) <reset>Charisma           <magenta>2) <reset>Constitution           <magenta>3) <reset>Dexterity                <cyan>|\n")
  cecho("<cyan>|  <magenta>4) <reset>Intelligence       <magenta>5) <reset>Strength               <magenta>6) <reset>Wisdom                   <cyan>|\n")
  cecho("<cyan>|  <magenta>7) <reset>Weapon Enhancer    <magenta>8) <reset>Weapon Specializer     <magenta>9) <reset>Weapon Un-Specializer    <cyan>|\n")
  cecho("<cyan>| <magenta>10) <reset>The Gainer                                                                   <cyan>|\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>└------------------------------------------------------------------------------┘\n")
end

function showGuildsMenu()
  cecho("\n<cyan>┌------------------------------------------------------------------------------┐\n")
  cecho("<cyan>|                          <red>Guilds Locations                                    <cyan>|\n")
  cecho("<cyan>├------------------------------------------------------------------------------┤\n")
  cecho("<cyan>|  <magenta>1) <reset>Barbarian         <magenta>2) <reset>Bard                    <magenta>3) <reset>Cleric (<red>Evil<reset>)            <cyan>|\n")
  cecho("<cyan>|  <magenta>4) <reset>Cleric (<green>Good<reset>)     <magenta>5) <reset>Cyborg                  <magenta>6) <reset>Knight (<red>Evil<reset>)            <cyan>|\n")
  cecho("<cyan>|  <magenta>7) <reset>Knight (<green>Good<reset>)     <magenta>8) <reset>Mage                    <magenta>9) <reset>Mercenary                <cyan>|\n")
  cecho("<cyan>| <magenta>10) <reset>Monk             <magenta>11) <reset>Physic                 <magenta>12) <reset>Psionicist               <cyan>|\n")
  cecho("<cyan>| <magenta>13) <reset>Ranger           <magenta>14) <reset>Thief                                                  <cyan>|\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>└------------------------------------------------------------------------------┘\n")
end

function showUnderdarkMenu()
  cecho("\n<cyan>┌------------------------------------------------------------------------------┐\n")
  cecho("<cyan>|                        <dark_gray>Underdark                                              <cyan>|\n")
  cecho("<cyan>├------------------------------------------------------------------------------┤\n")
  cecho("<cyan>|  <magenta>1) <reset>Head Shrinker <magenta>2) <reset>Lizard Caverns  <magenta>3) <reset>Wyllowwood\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>└------------------------------------------------------------------------------┘\n")
end

function showAllMenu()
  cecho("\n<cyan>┌------------------------------------------------------------------------------┐\n")
  cecho("<cyan>|                          <brown> ALL Locations                                      <cyan>|\n")
  cecho("<cyan>├------------------------------------------------------------------------------┤\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>|                          <red>Under Construction                                  <cyan>|\n")
  cecho("<cyan>|                                                                              <cyan>|\n")
  cecho("<cyan>└------------------------------------------------------------------------------┘\n")
end

-- =============================================
-- Main Travel Command Function
-- =============================================

function travel(plane, zone)
  if not plane then
    showMainMenu()
    return
  end
  
  local p = string.lower(tostring(plane))
  
  -- Check for help request
  if p == "help" or p == "?" then
    showHelpMenu()
    return
  end
  
  if not zone then
    if p == "past" or p == "1" then
      showPastMenu()
    elseif p == "future" or p == "2" then
      showFutureMenu()
    elseif p == "planes" or p == "3" then
      showPlanesMenu()
    elseif p == "trainers" or p == "4" then
      showTrainersMenu()
    elseif p == "guilds" or p == "5" then
      showGuildsMenu()
    elseif p == "underdark" or p == "6" then
      showUnderdarkMenu()
    elseif p == "all" or p == "7" then
      showAllMenu()
    else
      cecho("\n<red>Travel Warning: <reset>The value '<cyan>" .. tostring(plane) .. "<reset>' is not a valid travel destination.\n")
    end
    return
  end
  local z = tonumber(zone)
  if not z then return end
  
  local past = {gotoAbandonedKeep, gotoOldMonastery, gotoCastleSlivendark, gotoChessboardOfAraken,
    gotoDismalDelve, gotoDraconiansAndDragonHighlord, gotoDukeAraken, gotoElvenVillage,
    gotoForgottenValley, gotoFontOfModrian, gotoFrozenTundras, gotoGlacialRift, gotoGreatPyramid,
    gotoGuiharianFestivalOfLights, gotoHalflingVillage, gotoHarpellHouse, gotoHighTowerOfMagic,
    gotoHillGiantSteading, gotoHobgoblins, gotoHolyGrail, gotoIstan, gotoKoboldTunnels,
    gotoLearander, gotoCrystalFortress, gotoMalevolentCircle, gotoMavernal, gotoNeverwhere,
    gotoOgreEncampment, gotoOldThalos, gotoPitFiend, gotoPoolOfEvil, gotoReedSwamp,
    gotoSewersOfModrian, gotoShade, gotoSilverTower, gotoSolaceCove, gotoSkullport,
    gotoTempleOfAncients, gotoTowerOfTheRenegadeMage, gotoTheTreetopsOfArachna,
    gotoUndermountain, gotoWemicPlains, gotoZhengisCastle}
  
  local future = {gotoAPollutedVillage, gotoArcheologicalDig, gotoBlastedSwamp, gotoColony,
    gotoCybertechLabs, gotoCybertechPreparatorySchool, gotoDeathRow, gotoDracharnos,
    gotoDrugDealer, gotoECJunkyard, gotoECMilitary, gotoECVamps, gotoECNuclearPower,
    gotoECPowerAndPlumbing, gotoECSecurityCompound, gotoECUniversity, gotoElectronicsSchool,
    gotoElectronicsShop, gotoFailFamilyLegacy, gotoFassanSlaveCompound,
    gotoGenCloneBioMechanicalLabs, gotoKiddieKandy, gotoKromguard, gotoLuxare,
    gotoMerquryCity, gotoNETWORKCommunicationsTower, gotoReinforcer, gotoRuinsOfHTOM,
    gotoRuinsOfTheSilverTower, gotoSimeonTheCybernetic, gotoTriskinAsylum,
    gotoVirtualWorldOfNETWORK, gotoZulDane}
  
  local planes = {gotoAbyssUnholyModrian, gotoAmoria, gotoAvernusHell, gotoElementalPlaneOfAir,
    gotoElementalPlaneOfEarth, gotoElementalPlaneOfFire, gotoElementalPlaneOfIce,
    gotoElementalPlaneOfOoze, gotoElementalPlaneOfSmoke, gotoElementalPlaneOfWater,
    gotoLuniaHeaven, gotoImmoth, gotoCastleMahlhevik, gotoGith}
  
  local trainers = {gotoCharismaTrainer, gotoConstitutionTrainer, gotoDexterityTrainer,
    gotoIntelligenceTrainer, gotoStrengthTrainer, gotoWisdomTrainer, gotoWeaponEnhancer,
    gotoWeaponSpecializer, gotoWeaponUnSpecializer, gotoGainer}
  
  local guilds = {gotoBarbarianGuildmaster, gotoBardGuildmaster, gotoClericEvilGuildmaster,
    gotoClericGoodGuildmaster, gotoCyborgGuildmaster, gotoKnightEvilGuildmaster,
    gotoKnightGoodGuildmaster, gotoMageGuildmaster, gotoMercenaryGuildmaster,
    gotoMonkGuildmaster, gotoPhysicGuildmaster, gotoPsionicistGuildmaster,
    gotoRangerGuildmaster, gotoThiefGuildmaster}
  
  local under = {gotoHeadShrinker, gotoLizardCaverns, gotoWyllowwood, gotoUndeadShark}
  
  if p == "past" or p == "1" then
    if past[z] then past[z]() end
  elseif p == "future" or p == "2" then
    if future[z] then future[z]() end
  elseif p == "planes" or p == "3" then
    if planes[z] then planes[z]() end
  elseif p == "trainers" or p == "4" then
    if trainers[z] then trainers[z]() end
  elseif p == "guilds" or p == "5" then
    if guilds[z] then guilds[z]() end
  elseif p == "underdark" or p == "6" then
    if under[z] then under[z]() end
  end
end

cecho("\n<cyan>Directions Script Loaded! Use: travel <plane> <zone>\n")

-- =============================================
-- Additional Triggers
-- =============================================

-- Trigger for Shade Tiltin's room
if shadeTiltinTrigger then killTrigger(shadeTiltinTrigger) end
shadeTiltinTrigger = tempRegexTrigger("^This is the room of Tiltin, the Mage of Shade", function()
  cecho("\n<orange>************************ <magenta>Help Shade <orange>************************\n")
  cecho("<orange>gotoShadeRebel: <reset>To Rebel Leader From Tiltin\n")
  cecho("<orange>gotoShadeSelset: <reset>To Selset from Rebel Leader\n")
  cecho("<orange>************************************************************\n")
end)

-- Trigger for Gith Island Detection
if githIslandTrigger then killTrigger(githIslandTrigger) end
githIslandTrigger = tempRegexTrigger("^A huge island of matter is floating here\\.$", function()
  if findGith == 1 then
    cecho("\n<white>***** GITH FOUND! *****\n")
    send("revoke")
    send("revoke")
    githFound = 1
    findGith = 0
    send("enter island")
    send("challenge area")
  end
end)

-- Trigger for Astral Plane Gith Search
if astralPlaneGithTrigger then killTrigger(astralPlaneGithTrigger) end
astralPlaneGithTrigger = tempRegexTrigger("^The Astral Plane$", function()
  if findGith == 1 and not isInFight() then
    if debug then cecho("\n<magenta>Debug: <reset>Astral Plane Action triggered.\n") end
    
    if githX < 8 then
      if debug then cecho("\n<magenta>Debug: <reset>Gith X = " .. githX .. "\n") end
      if githFound == 0 then
        send("north")
        githX = githX + 1
      else
        send("enter island")
        send("challenge area")
      end
      
      if githY < 8 and githX == 8 then
        githX = 0
        if debug then cecho("\n<magenta>Debug: <reset>Gith Y = " .. githY .. "\n") end
        if githFound == 0 then
          send("west")
          githY = githY + 1
        else
          send("enter island")
          send("challenge area")
        end
        
        if githZ < 8 and githY == 8 then
          if debug then cecho("\n<magenta>Debug: <reset>Gith Z = " .. githZ .. "\n") end
          if githFound == 0 then
            send("up")
            githZ = githZ + 1
            githY = 0
            githX = 0
          else
            send("enter island")
            send("challenge area")
          end
        end
      end
    end
    
    if githZ == 8 then
      cecho("\n<red>Warning! <reset>Unable to locate the Githyanki Fortress!\n")
      findGith = 0
    end
  end
end)

-- Trigger for "In the area" (resets travelling flag)
if inAreaTrigger then killTrigger(inAreaTrigger) end
inAreaTrigger = tempRegexTrigger("^In the area: (.+)$", function()
  travelling = 0
end)

-- Trigger for EPOS Craftsman workshop
if eposCraftsmanTrigger then killTrigger(eposCraftsmanTrigger) end
eposCraftsmanTrigger = tempRegexTrigger("^A Large Workshop$", helpEPOSCraftsman)

-- Trigger for Combat Start Detection
-- Detects when combat begins based on common TempusMUD combat messages
-- You may need to adjust these patterns based on your specific combat messages
if combatStartTrigger then killTrigger(combatStartTrigger) end
combatStartTrigger = tempRegexTrigger("^You (attack|massacre|hit|miss|pierce|slash|crush) ", function()
  isFighting = true
  if debug then
    cecho("\n<cyan>Debug: Combat started (attack detected)\n")
  end
end)

-- Additional combat start trigger for being attacked
if combatAttackedTrigger then killTrigger(combatAttackedTrigger) end
combatAttackedTrigger = tempRegexTrigger("^.+ (attacks|hits|misses|pierces|slashes|crushes) you", function()
  isFighting = true
  if debug then
    cecho("\n<cyan>Debug: Combat started (being attacked)\n")
  end
end)

-- Trigger for Combat End Detection (R.I.P. message)
-- Uses R.I.P. as the most reliable indicator that combat has ended
-- This detects when any mob dies in TempusMUD (e.g., "A little boy is dead!  R.I.P.")
-- R.I.P. is the keyword that definitively indicates a death occurred
if combatEndTrigger then killTrigger(combatEndTrigger) end
combatEndTrigger = tempRegexTrigger("R\\.I\\.P\\.", function()
  isFighting = false
  if debug then
    cecho("\n<cyan>Debug: Combat ended (R.I.P. detected)\n")
  end
end)

