-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- variabili globali:
-- - debug -> abilita il debug
-- - debugDragable -> rende dragable le mappe

debug = false
debugDragable = false

-- avvio del gioco

composer = require("composer")

-- schermata di benvenuto

composer.gotoScene("intro")

-- inizio del gioco

-- avvia mappa rincipale alla fine dell'introduzione
local function game(event)
  local options = {effect="fade", time=0}
  composer.gotoScene("game", options)
  composer.removeScene("intro")
end

local timerGame = timer.performWithDelay(5500, game, 1)
