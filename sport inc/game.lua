-----------------------------------------------------------------------------------------
--
-- game scene
--
-----------------------------------------------------------------------------------------

-- gioco principale

-- IMPORTAZIONE LIBRERIE NECESSARIE

physics = require("physics")
tiled = require("com.ponywolf.ponytiled")
json = require("json")
if(debugDragable) then
  dragable = require("com.ponywolf.plugins.dragable")
end
local vjoy = require("com.ponywolf.vjoy")

salvataggio = require("salvataggio")
tempo = require("tempo")
introduzione = require("introduzione")
informazioniPalestra = require("informazioniPalestra")

-- VARIABILI

-- variabili globali:
-- - soldi e sportStatus -> stato del gioco da salvare (salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport))
-- - schermata -> per introduzione e informazioniPalestra per bloccare gli eventListener degli elementi sottostanti

local scene = composer.newScene()

local mapCity
local mapScale
local joystick

local player

soldi = nil
local testoSoldi
local immagineSoldi

schermata = false
local sport = {}
sport.atletica = {}
sport.basket = {}
sport.calcio = {}
sport.pallavolo = {}
sport.tennis = {}
sport.motorsport = {}
sportStatus = {}
sportStatus.atletica = nil
sportStatus.basket = nil
sportStatus.calcio = nil
sportStatus.pallavolo = nil
sportStatus.tennis = nil
sportStatus.motorsport = nil
local primaVolta

local gameMusic
local gameMusicPlay
local gameMusicChannel = 2

-- MOVIMENTO PLAYER/MAPPA

-- movimento del player tramite joystick
local function movePlayer(event)
  if(not schermata) then
    if(event.axis.number == 1) then
      if(debug) then
        player.speed.x = event.normalizedValue * 250
      else
        player.speed.x = event.normalizedValue * 50
      end
    end
    if(event.axis.number == 2) then
      if(debug) then
        player.speed.y = event.normalizedValue * 250
      else
        player.speed.y = event.normalizedValue * 50
      end
    end
    player:setLinearVelocity(player.speed.x,player.speed.y)
  end
end

Runtime:addEventListener("axis", movePlayer)

-- movimento della mappa tramite il player, dato che la mappa è zoomata il player può vedere una parte di mappa alla volta e può esplorarla andando verso i bordi
local function moveMap(event)
  local offset = {}
  offset.x = player.margin
  offset.y = player.margin
  local nonScrolling = {}
  nonScrolling.width = display.contentWidth/mapScale - offset.x
  nonScrolling.height = display.contentHeight/mapScale - offset.y

  if(player.x >= offset.x and player.x <= mapCity.contentWidth/mapScale-offset.x) then
    if(player.x > -mapCity.x/mapScale+nonScrolling.width) then
      mapCity.x = (-player.x + nonScrolling.width)*mapScale

    elseif(player.x < -mapCity.x/mapScale+offset.x) then
      mapCity.x = (-player.x + offset.x)*mapScale

    end
  end

  if(player.y >= offset.y and player.y <= mapCity.contentHeight/mapScale-offset.y) then
    if(player.y > -mapCity.y/mapScale+nonScrolling.height) then
      mapCity.y = (-player.y + nonScrolling.height)*mapScale

    elseif(player.y < -mapCity.y/mapScale+offset.y) then
      mapCity.y = (-player.y + offset.y)*mapScale

    end
  end
end

Runtime:addEventListener("enterFrame", moveMap)

-- VISUALIZZAZIONE SCHERMATE INFORMAZIONI PALESTRA

-- apertura schermata informazioni palestra
local function informazioniPalestraShow(event, nome)
  if(not schermata) then
    informazioniPalestra:show(nome)
  end
end

-- AGGIORNAENTO VISUALIZZAZIONE SPORT

-- funzione globali:
-- - aggiornaTestoSoldi() -> per informazioniPalestra in caso di aggionamento soldi e sportStatus deve anche richiamare aggiornaTestoSoldi()
-- - aggiornaVisualizzazioneSport() -> per informazioniPalestra in caso di aggionamento soldi e sportStatus deve anche richiamare aggiornaVisualizzazioneSport()

-- aggiorna il testoSoldi in base a soldi
function aggiornaTestoSoldi()
  testoSoldi.text = soldi
end

-- aggiorna della visualizzazione delle palestre degli sport in base a sportStatus
function aggiornaVisualizzazioneSport()
  -- ATLETICA
  if(sportStatus.atletica == 0) then
    sport.atletica.lock.isVisible = true
    sport.atletica.lock.alpha = 1
    sport.atletica.unlock.isVisible = false
    sport.atletica.unlock.alpha = 0
    if(sport.atletica.upgrade) then
      sport.atletica.upgrade.isVisible = false
      sport.atletica.upgrade.alpha = 0
    end

  elseif(sportStatus.atletica == 1) then
    sport.atletica.lock.isVisible = false
    sport.atletica.lock.alpha = 0
    sport.atletica.unlock.isVisible = true
    sport.atletica.unlock.alpha = 1
    if(sport.atletica.upgrade) then
      sport.atletica.upgrade.isVisible = false
      sport.atletica.upgrade.alpha = 0
    end

  elseif(sportStatus.atletica == 2 and sport.atletica.upgrade) then
    sport.atletica.lock.isVisible = false
    sport.atletica.lock.alpha = 0
    sport.atletica.unlock.isVisible = false
    sport.atletica.unlock.alpha = 0
    sport.atletica.upgrade.isVisible = true
    sport.atletica.upgrade.alpha = 1

  else -- sportStatus > 2 o < 0 (impossibile) o sportStatus = 2 ma non upgradabile (impossibile) -> reset della palestra
    sportStatus.atletica = 0

    sport.atletica.lock.isVisible = true
    sport.atletica.lock.alpha = 1
    sport.atletica.unlock.isVisible = false
    sport.atletica.unlock.alpha = 0
    if(sport.atletica.upgrade) then
      sport.atletica.upgrade.isVisible = false
      sport.atletica.upgrade.alpha = 0
    end

    salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  end

  -- BASKET
  if(sportStatus.basket == 0) then
    sport.basket.lock.isVisible = true
    sport.basket.lock.alpha = 1
    sport.basket.unlock.isVisible = false
    sport.basket.unlock.alpha = 0
    if(sport.basket.upgrade) then
      sport.basket.upgrade.isVisible = false
      sport.basket.upgrade.alpha = 0
    end

  elseif(sportStatus.basket == 1) then
    sport.basket.lock.isVisible = false
    sport.basket.lock.alpha = 0
    sport.basket.unlock.isVisible = true
    sport.basket.unlock.alpha = 1
    if(sport.basket.upgrade) then
      sport.basket.upgrade.isVisible = false
      sport.basket.upgrade.alpha = 0
    end

  elseif(sportStatus.basket == 2 and sport.basket.upgrade) then
    sport.basket.lock.isVisible = false
    sport.basket.lock.alpha = 0
    sport.basket.unlock.isVisible = false
    sport.basket.unlock.alpha = 0
    sport.basket.upgrade.isVisible = true
    sport.basket.upgrade.alpha = 1

  else -- sportStatus > 2 o < 0 (impossibile) o sportStatus = 2 ma non upgradabile (impossibile) -> reset della palestra
    sportStatus.basket = 0

    sport.basket.lock.isVisible = true
    sport.basket.lock.alpha = 1
    sport.basket.unlock.isVisible = false
    sport.basket.unlock.alpha = 0
    if(sport.basket.upgrade) then
      sport.basket.upgrade.isVisible = false
      sport.basket.upgrade.alpha = 0
    end

    salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  end

  -- CALCIO
  if(sportStatus.calcio == 0) then
    sport.calcio.lock.isVisible = true
    sport.calcio.lock.alpha = 1
    sport.calcio.unlock.isVisible = false
    sport.calcio.unlock.alpha = 0
    if(sport.calcio.upgrade) then
      sport.calcio.upgrade.isVisible = false
      sport.calcio.upgrade.alpha = 0
    end

  elseif(sportStatus.calcio == 1) then
    sport.calcio.lock.isVisible = false
    sport.calcio.lock.alpha = 0
    sport.calcio.unlock.isVisible = true
    sport.calcio.unlock.alpha = 1
    if(sport.calcio.upgrade) then
      sport.calcio.upgrade.isVisible = false
      sport.calcio.upgrade.alpha = 0
    end

  elseif(sportStatus.calcio == 2 and sport.calcio.upgrade) then
    sport.calcio.lock.isVisible = false
    sport.calcio.lock.alpha = 0
    sport.calcio.unlock.isVisible = false
    sport.calcio.unlock.alpha = 0
    sport.calcio.upgrade.isVisible = true
    sport.calcio.upgrade.alpha = 1

  else -- sportStatus > 2 o < 0 (impossibile) o sportStatus = 2 ma non upgradabile (impossibile) -> reset della palestra
    sportStatus.calcio = 0

    sport.calcio.lock.isVisible = true
    sport.calcio.lock.alpha = 1
    sport.calcio.unlock.isVisible = false
    sport.calcio.unlock.alpha = 0
    if(sport.calcio.upgrade) then
      sport.calcio.upgrade.isVisible = false
      sport.calcio.upgrade.alpha = 0
    end

    salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  end

  -- PALLAVOLO
  if(sportStatus.pallavolo == 0) then
    sport.pallavolo.lock.isVisible = true
    sport.pallavolo.lock.alpha = 1
    sport.pallavolo.unlock.isVisible = false
    sport.pallavolo.unlock.alpha = 0
    if(sport.pallavolo.upgrade) then
      sport.pallavolo.upgrade.isVisible = false
      sport.pallavolo.upgrade.alpha = 0
    end

  elseif(sportStatus.pallavolo == 1) then
    sport.pallavolo.lock.isVisible = false
    sport.pallavolo.lock.alpha = 0
    sport.pallavolo.unlock.isVisible = true
    sport.pallavolo.unlock.alpha = 1
    if(sport.pallavolo.upgrade) then
      sport.pallavolo.upgrade.isVisible = false
      sport.pallavolo.upgrade.alpha = 0
    end

  elseif(sportStatus.pallavolo == 2 and sport.pallavolo.upgrade) then
    sport.pallavolo.lock.isVisible = false
    sport.pallavolo.lock.alpha = 0
    sport.pallavolo.unlock.isVisible = false
    sport.pallavolo.unlock.alpha = 0
    sport.pallavolo.upgrade.isVisible = true
    sport.pallavolo.upgrade.alpha = 1

  else -- sportStatus > 2 o < 0 (impossibile) o sportStatus = 2 ma non upgradabile (impossibile) -> reset della palestra
    sportStatus.pallavolo = 0

    sport.pallavolo.lock.isVisible = true
    sport.pallavolo.lock.alpha = 1
    sport.pallavolo.unlock.isVisible = false
    sport.pallavolo.unlock.alpha = 0
    if(sport.pallavolo.upgrade) then
      sport.pallavolo.upgrade.isVisible = false
      sport.pallavolo.upgrade.alpha = 0
    end

    salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  end

  -- TESNNIS
  if(sportStatus.tennis == 0) then
    sport.tennis.lock.isVisible = true
    sport.tennis.lock.alpha = 1
    sport.tennis.unlock.isVisible = false
    sport.tennis.unlock.alpha = 0
    if(sport.tennis.upgrade) then
      sport.tennis.upgrade.isVisible = false
      sport.tennis.upgrade.alpha = 0
    end

  elseif(sportStatus.tennis == 1) then
    sport.tennis.lock.isVisible = false
    sport.tennis.lock.alpha = 0
    sport.tennis.unlock.isVisible = true
    sport.tennis.unlock.alpha = 1
    if(sport.tennis.upgrade) then
      sport.tennis.upgrade.isVisible = false
      sport.tennis.upgrade.alpha = 0
    end

  elseif(sportStatus.tennis == 2 and sport.tennis.upgrade) then
    sport.tennis.lock.isVisible = false
    sport.tennis.lock.alpha = 0
    sport.tennis.unlock.isVisible = false
    sport.tennis.unlock.alpha = 0
    sport.tennis.upgrade.isVisible = true
    sport.tennis.upgrade.alpha = 1

  else -- sportStatus > 2 o < 0 (impossibile) o sportStatus = 2 ma non upgradabile (impossibile) -> reset della palestra
    sportStatus.tennis = 0

    sport.tennis.lock.isVisible = true
    sport.tennis.lock.alpha = 1
    sport.tennis.unlock.isVisible = false
    sport.tennis.unlock.alpha = 0
    if(sport.tennis.upgrade) then
      sport.tennis.upgrade.isVisible = false
      sport.tennis.upgrade.alpha = 0
    end

    salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  end

  -- MOTORSPORT
  if(sportStatus.motorsport == 0) then
    sport.motorsport.lock.isVisible = true
    sport.motorsport.lock.alpha = 1
    sport.motorsport.unlock.isVisible = false
    sport.motorsport.unlock.alpha = 0
    if(sport.motorsport.upgrade) then
      sport.motorsport.upgrade.isVisible = false
      sport.motorsport.upgrade.alpha = 0
    end

  elseif(sportStatus.motorsport == 1) then
    sport.motorsport.lock.isVisible = false
    sport.motorsport.lock.alpha = 0
    sport.motorsport.unlock.isVisible = true
    sport.motorsport.unlock.alpha = 1
    if(sport.motorsport.upgrade) then
      sport.motorsport.upgrade.isVisible = false
      sport.motorsport.upgrade.alpha = 0
    end

  elseif(sportStatus.motorsport == 2 and sport.motorsport.upgrade) then
    sport.motorsport.lock.isVisible = false
    sport.motorsport.lock.alpha = 0
    sport.motorsport.unlock.isVisible = false
    sport.motorsport.unlock.alpha = 0
    sport.motorsport.upgrade.isVisible = true
    sport.motorsport.upgrade.alpha = 1

  else -- sportStatus > 2 o < 0 (impossibile) o sportStatus = 2 ma non upgradabile (impossibile) -> reset della palestra
    sportStatus.motorsport = 0

    sport.motorsport.lock.isVisible = true
    sport.motorsport.lock.alpha = 1
    sport.motorsport.unlock.isVisible = false
    sport.motorsport.unlock.alpha = 0
    if(sport.motorsport.upgrade) then
      sport.motorsport.upgrade.isVisible = false
      sport.motorsport.upgrade.alpha = 0
    end

    salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  end

end

-- FUNZIONI PER SCENA DI COMPOSER

-- CREATE()

-- inizializzazione variabili
function scene:create(event)
  local sceneGroup = self.view

  physics.start()
  if(debug) then
    physics.setDrawMode("hybrid")
  else
    physics.setDrawMode("normal")
  end
  physics.setGravity(0, 0)

  mapCity = tiled.new(json.decodeFile(system.pathForFile("src/map/city.json")), "src/map")
  sceneGroup:insert(mapCity)
  mapScale = 2
  joystick = vjoy.newStick(1)
  sceneGroup:insert(joystick)

  player = mapCity:findObject("player")
  player.outline = graphics.newOutline(1, "src/img/sports/characters extra/player.png")
  player.margin = 50
  local bodyType = player.bodyType
  physics.removeBody(player)
  physics.addBody(player, bodyType, {outline=player.outline, bounce=player.bounce, density=player.density, friction=player.friction})
  player.isFixedRotation = true

  player.speed = {}
  player.speed.x = 0
  player.speed.y = 0

  soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport, primaVolta = salvataggio:readSave()

  -- creazione elementi gui per visualizzare i soldi
  testoSoldi = display.newText({text=soldi, x=display.contentCenterX, y=100, fontSize=40, font="Arial"})
  sceneGroup:insert(testoSoldi)
  immagineSoldi = display.newImageRect("src/img/game extra/soldi.png", 64, 64)
  sceneGroup:insert(immagineSoldi)

  -- ricerca palestre degli sport nella mappa da cambiare la visualizzazione in base a sportStatus
  sport.atletica.lock = mapCity:findObject("atleticaLock")
  sport.atletica.unlock = mapCity:findObject("atleticaUnlock")
  sport.atletica.upgrade = mapCity:findObject("atleticaUpgrade")

  sport.basket.lock = mapCity:findObject("basketLock")
  sport.basket.unlock = mapCity:findObject("basketUnlock")
  sport.basket.upgrade = mapCity:findObject("basketUpgrade")

  sport.calcio.lock = mapCity:findObject("calcioLock")
  sport.calcio.unlock = mapCity:findObject("calcioUnlock")
  sport.calcio.upgrade = mapCity:findObject("calcioUpgrade")

  sport.pallavolo.lock = mapCity:findObject("pallavoloLock")
  sport.pallavolo.unlock = mapCity:findObject("pallavoloUnlock")
  sport.pallavolo.upgrade = mapCity:findObject("pallavoloUpgrade")

  sport.tennis.lock = mapCity:findObject("tennisLock")
  sport.tennis.unlock = mapCity:findObject("tennisUnlock")
  sport.tennis.upgrade = mapCity:findObject("tennisUpgrade")

  sport.motorsport.lock = mapCity:findObject("motorsportLock")
  sport.motorsport.unlock = mapCity:findObject("motorsportUnlock")
  sport.motorsport.upgrade = mapCity:findObject("motorsportUpgrade")

  aggiornaVisualizzazioneSport()

  gameMusic = audio.loadSound("src/sfx/game.mp3")
end

-- SHOW()

-- caricamento elementi nella scena
-- - will: visualizza mappa
-- - did: visualizza scheramata di benvenuto (se prima volta), aggiunta event listener sulle palestre e avvia musica
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    display.setStatusBar(display.HiddenStatusBar)

    mapCity.xScale = mapScale
    mapCity.yScale = mapScale
    if(debugDragable) then
      mapCity = dragable.new(mapCity)
    end
    joystick.xScale = 0.5
    joystick.yScale = 0.5
    joystick.x = joystick.width * 0.5
    joystick.y = display.contentHeight - joystick.height * 0.5

    immagineSoldi.x = display.contentCenterX - testoSoldi.width/2 - 40
    immagineSoldi.y = 100
    immagineSoldi.xScale = 0.5
    immagineSoldi.yScale = 0.5

  elseif (phase == "did") then
    -- fix posizioni
    player.x = 20
    player.y = 152

    if(primaVolta) then
      -- gui di benvenuto nel gioco
      introduzione:show("gioco")

      local now = os.date("*t")
      tempo:writeTime(tempo:readTime())

      salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
    end

    -- creazione di eventListener sulle palestre degli sport per mostrare la gui delle informazioni relative alla palestra ed eventualmente dello sport
    -- ATLETICA
    sport.atletica.lock:addEventListener("tap", function(event) informazioniPalestraShow(event, "atletica") end)
    sport.atletica.unlock:addEventListener("tap", function(event) informazioniPalestraShow(event, "atletica") end)
    if(sport.atletica.upgrade) then
      sport.atletica.upgrade:addEventListener("tap", function(event) informazioniPalestraShow(event, "atletica") end)
    end

    -- BASKET
    sport.basket.lock:addEventListener("tap", function(event) informazioniPalestraShow(event, "basket") end)
    sport.basket.unlock:addEventListener("tap", function(event) informazioniPalestraShow(event, "basket") end)
    if(sport.basket.upgrade) then
      sport.basket.upgrade:addEventListener("tap", function(event) informazioniPalestraShow(event, "basket") end)
    end

    -- CALCIO
    sport.calcio.lock:addEventListener("tap", function(event) informazioniPalestraShow(event, "calcio") end)
    sport.calcio.unlock:addEventListener("tap", function(event) informazioniPalestraShow(event, "calcio") end)
    if(sport.calcio.upgrade) then
      sport.calcio.upgrade:addEventListener("tap", function(event) informazioniPalestraShow(event, "calcio") end)
    end

    -- PALLAVOLO
    sport.pallavolo.lock:addEventListener("tap", function(event) informazioniPalestraShow(event, "pallavolo") end)
    sport.pallavolo.unlock:addEventListener("tap", function(event) informazioniPalestraShow(event, "pallavolo") end)
    if(sport.pallavolo.upgrade) then
      sport.pallavolo.upgrade:addEventListener("tap", function(event) informazioniPalestraShow(event, "pallavolo") end)
    end

    -- TENNIS
    sport.tennis.lock:addEventListener("tap", function(event) informazioniPalestraShow(event, "tennis") end)
    sport.tennis.unlock:addEventListener("tap", function(event) informazioniPalestraShow(event, "tennis") end)
    if(sport.tennis.upgrade) then
      sport.tennis.upgrade:addEventListener("tap", function(event) informazioniPalestraShow(event, "tennis") end)
    end

    -- MOTORSPORT
    sport.motorsport.lock:addEventListener("tap", function(event) informazioniPalestraShow(event, "motorsport") end)
    sport.motorsport.unlock:addEventListener("tap", function(event) informazioniPalestraShow(event, "motorsport") end)
    if(sport.motorsport.upgrade) then
      sport.motorsport.upgrade:addEventListener("tap", function(event) informazioniPalestraShow(event, "motorsport") end)
    end

    if(debug) then
      audio.setVolume(0.01, {channel=gameMusicChannel})
    else
      audio.setVolume(0.25, {channel=gameMusicChannel})
    end
    gameMusicPlay = audio.play(gameMusic, {channel=gameMusicChannel, loops=-1})

  end
end

-- HIDE()

-- rimozione elementi nella scena
-- - will: rimuove event listener e pausa musica
-- - did: rimuove parte grafica della scena
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    Runtime:removeEventListener("axis", movePlayer)
    Runtime:removeEventListener("enterFrame", moveMap)
    sport.atletica.lock:removeEventListener("tap", informazioniPalestraShow)
    sport.atletica.unlock:removeEventListener("tap", informazioniPalestraShow)
    if(sport.atletica.upgrade) then
      sport.atletica.upgrade:removeEventListener("tap", informazioniPalestraShow)
    end
    sport.basket.lock:removeEventListener("tap", informazioniPalestraShow)
    sport.basket.unlock:removeEventListener("tap", informazioniPalestraShow)
    if(sport.basket.upgrade) then
      sport.basket.upgrade:removeEventListener("tap", informazioniPalestraShow)
    end
    sport.calcio.lock:removeEventListener("tap", informazioniPalestraShow)
    sport.calcio.unlock:removeEventListener("tap", informazioniPalestraShow)
    if(sport.calcio.upgrade) then
      sport.calcio.upgrade:removeEventListener("tap", informazioniPalestraShow)
    end
    sport.pallavolo.lock:removeEventListener("tap", informazioniPalestraShow)
    sport.pallavolo.unlock:removeEventListener("tap", informazioniPalestraShow)
    if(sport.pallavolo.upgrade) then
      sport.pallavolo.upgrade:removeEventListener("tap", informazioniPalestraShow)
    end
    sport.tennis.lock:removeEventListener("tap", informazioniPalestraShow)
    sport.tennis.unlock:removeEventListener("tap", informazioniPalestraShow)
    if(sport.tennis.upgrade) then
      sport.tennis.upgrade:removeEventListener("tap", informazioniPalestraShow)
    end
    sport.motorsport.lock:removeEventListener("tap", informazioniPalestraShow)
    sport.motorsport.unlock:removeEventListener("tap", informazioniPalestraShow)
    if(sport.motorsport.upgrade) then
      sport.motorsport.upgrade:removeEventListener("tap", informazioniPalestraShow)
    end

    gameMusicPlay = audio.pause(gameMusicPlay)

  elseif (phase == "did") then
    display.remove(sceneGroup)

    introduzione:hide(nil, false)
    informazioniPalestra:hide(nil)

  end
end

-- DESTROY()

-- rimozione elementi dalla memoria
function scene:destroy(event)
  local sceneGroup = self.view

  event.phase = "did"
  scene:hide(event) -- perchè non viene lanciato in automatico

  mapCity = nil
  joystick = nil
  player = nil
  testoSoldi = nil
  immagineSoldi = nil

  audio.stop()
  gameMusicPlay = nil
  audio.dispose(gameMusic)
  gameMusic = nil
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
