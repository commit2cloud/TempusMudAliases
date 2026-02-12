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
function gotoFassanSlaveCompound() travelTo("star", "Fassan Slave Compound", "2ds2dwd27wuwu3n4w3nwun") end
function gotoGenCloneBioMechanicalLabs() travelTo("star", "GenClone BioMechanical Labs", "16w9nen4w8n") end
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
  cecho("\n<red>ZONE CLOSED<reset>\n")
end
function gotoVirtualWorldOfNETWORK() travelTo("star", "Virtual World of NETWORK", "4w4ne;open door s;3s") end
function gotoZulDane() travelTo("star", "City of Zul'Dane", "26n4e") end

-- Underdark
function gotoUndeadShark() travelTo("skull", "Undead Shark", "2es2u;open plant e;es") end
function gotoHeadShrinker() travelTo("skull", "head Shrinker", "11s2wdnund2sundwun2d3ws;open hide;1w") end
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

-- Trainers
function gotoCharismaTrainer() travelTo("star", "Charisma Trainer", "3n1e;open door s;1s1w") end
function gotoConstitutionTrainer() travelTo("hs", "Constitution Trainer", "2nunw;open tapestry;3e4ne") end
function gotoDexterityTrainer() travelTo("hs", "Dexterity Trainer", "") end
function gotoIntelligenceTrainer() travelTo("hs", "Intelligence Trainer", "2nu;open door west;w") end
function gotoStrengthTrainer() travelTo("hs", "Strength Trainer", "2nune;open tapestry;3nen") end
function gotoWisdomTrainer() travelTo("hs", "Wisdom Trainer", "6e11s;open door s;3s1u2s1e") end
function gotoWeaponEnhancer() travelTo("star", "Weapons Enhancer", "5n2w1s1e") end
function gotoWeaponSpecializer() travelTo("skull", "Weapon Specializer", "4sd2enen2e4nw3nen2w2n2e2n2e2un4eu;open ebony;ws2w") end
function gotoWeaponUnSpecializer() travelTo("star", "Weapon UNSpecializer", "3n1e;open door s;1s1u1e") end
function gotoGainer() cecho("\n<yellow>Gainer is 1w of Grand Mistress at top of HTOM\n") end

-- Guilds
function gotoBarbarianGuildmaster() travelTo("hs", "Barbarian Guildmaster", "57w11n") end
function gotoBardGuildmaster() travelTo("hs", "Bard Guildmaster", "3w2swn") end
function gotoClericEvilGuildmaster() travelTo("skull", "Evil Cleric Guildmaster", "7n2w;open door w;2w") end
function gotoClericGoodGuildmaster() travelTo("hs", "Good Cleric Guildmaster", "6e11s;open door s;3s;5u2s") end
function gotoCyborgGuildmaster() travelTo("star", "Cyborg Guildmaster", "4w2nws") end
function gotoKnightEvilGuildmaster() travelTo("skull", "Evil Knight Guildmaster", "2w2ne") end
function gotoKnightGoodGuildmaster() travelTo("hs", "Good Knight Guildmaster", "") end
function gotoMageGuildmaster() travelTo("hs", "Mage Guildmaster", "4nu;open door west;w") end
function gotoMercenaryGuildmaster() travelTo("star", "Mercenary Guildmaster", "2d4e5nes") end
function gotoMonkGuildmaster() travelTo("hs", "Monk Guildmaster", "37e41n;open gate n;4n3w") end
function gotoPhysicGuildmaster() travelTo("star", "Physics Guildmaster", "3s2uswn") end
function gotoPsionicistGuildmaster() travelTo("hs", "Psionic Guildmaster", "2nune;open tapestry;3w") end
function gotoRangerGuildmaster() travelTo("hs", "Ranger Guildmaster", "") end
function gotoThiefGuildmaster() travelTo("skull", "Thief Guildmaster", "4e;open portrait;2ene2s") end

-- Menu Functions
function travel(plane, zone)
  if not plane then
    cecho("\n<cyan>Travel Menu: Use travel <plane> <zone>\n")
    cecho("1=past 2=future 3=planes 4=trainers 5=guilds 6=underdark\n")
    return
  end
  local p = string.lower(tostring(plane))
  if not zone then
    cecho("\n<yellow>Show submenu for " .. p .. "\n")
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
    gotoWeaponSpecializer, gotoWeaponUnSpecializer, gotoGainer, gotoElectronicsSchool}
  
  local guilds = {gotoBarbarianGuildmaster, gotoBardGuildmaster, gotoClericEvilGuildmaster,
    gotoClericGoodGuildmaster, gotoCyborgGuildmaster, gotoKnightEvilGuildmaster,
    gotoKnightGoodGuildmaster, gotoMageGuildmaster, gotoMercenaryGuildmaster,
    gotoMonkGuildmaster, gotoPhysicGuildmaster, gotoPsionicistGuildmaster,
    gotoRangerGuildmaster, gotoThiefGuildmaster}
  
  local under = {gotoHeadShrinker, gotoLizardCaverns, gotoWyllowwood}
  
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
