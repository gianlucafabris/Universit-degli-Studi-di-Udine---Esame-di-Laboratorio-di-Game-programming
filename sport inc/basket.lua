-----------------------------------------------------------------------------------------
--
-- basket scene
--
-----------------------------------------------------------------------------------------

-- minigioco basket

-- IMPORTAZIONE LIBRERIE NECESSARIE

local informazioniMinigioco = require("informazioniMinigioco")

-- VARIABILI

-- variabili globali:
-- - schermata -> per informazioniMinigioco per bloccare gli eventListener degli elementi sottostanti

local scene = composer.newScene()

local mapBasket

local player

local ball

local basket

local scoreboard

local gameover = {}

local score = 0

schermata = false

local primoShowDid = true

local line

local lanciato = false

local ballForce = {}

local cronometro = 0
local testoCronometro
local cronometroTimer

local ballSound
local ballSoundPlay
local ballSoundChannel = 5

-- FUNZIONI LISTENER DI GIOCO

-- CRONOMETRO

function cronometroUpdate()
  cronometro = cronometro+1

  local minuti = math.floor(cronometro/60)
  local secondi = cronometro%60

  testoCronometro.text = string.format("%02d:%02d", minuti, secondi)
  testoCronometro.x = testoCronometro.contentWidth/2+125

  if(cronometro == 60) then
    local timerSpostamento = timer.performWithDelay(100,
        function()
            ball.x = 860
            ball.y = 670
            ball:setLinearVelocity(0, 0)
            physics.setGravity(0, 0)
            ball.angularVelocity = 0
            ball.rotation = 0
       end, 1)
        Runtime:removeEventListener("touch", drawTrajectory)
        for i = 1, 10, 1 do
          Runtime:removeEventListener("touch", drawTrajectory) -- perchè rimane acceso event listener
        end
    timer.cancel(cronometroTimer)
    informazioniMinigioco:show("basket", score)
  end
end

-- BASKETSHOOTING()

-- applica un impulso che simula il lancio della palla
local function basketShooting(x, y)
  lanciato = true
  physics.setGravity(0, 9.8)
  ball:applyLinearImpulse(x, y, ball.x, ball.y)
  if debug then
    audio.setVolume(0.01, {channel=ballSoundChannel})
  else
    audio.setVolume(0.25, {channel=ballSoundChannel})
  end
    ballSoundPlay = audio.play(ballSound, {channel=ballSoundChannel, loops=0})
    audio.seek( 0, { channel=ballSoundChannel } )
end

-- DRAWTRAJECTORY()

-- disegna una traiettoria fittizia del lancio della palla
local function drawTrajectory(event)
  if event.phase=="moved" then
    if(cronometro < 60) then -- per bloccare anche il caso in cui abbia iniziato a prendere la mira prima e poi sia scaduto il cronometro
      if line ~= nil then
          display.remove(line)
          line = nil
      end
      line = display.newLine(ball.x - 32, ball.y - 56, event.x, event.y)
      line.strokeWidth = 1
      line:setStrokeColor(1, 1, 1)
    else
      if line ~= nil then
          display.remove(line)
          line = nil
      end
      Runtime:removeEventListener("touch", drawTrajectory)
      for i = 1, 10, 1 do
        Runtime:removeEventListener("touch", drawTrajectory) -- perchè rimane acceso event listener
      end
    end
  end
  if event.phase=="ended" then
    if(cronometro < 60) then
      display.remove(line)
      line=nil
      ballForce.x = (event.x-ball.x+32)/70
      ballForce.y = (event.y-ball.y+56)/70

      basketShooting(ballForce.x, ballForce.y)
      Runtime:removeEventListener("touch", drawTrajectory)
      for i = 1, 10, 1 do
        Runtime:removeEventListener("touch", drawTrajectory) -- perchè rimane acceso event listener
      end
    else
      display.remove(line)
      line=nil
      Runtime:removeEventListener("touch", drawTrajectory)
      for i = 1, 10, 1 do
        Runtime:removeEventListener("touch", drawTrajectory) -- perchè rimane acceso event listener
      end
    end
  end
end
Runtime:addEventListener("touch", drawTrajectory)

-- COLLISIONHANDLER()

-- gestisce le collisioni con l'area di gioco
local function collisionHandler( event )
  if (event.phase == "began" ) then
    if (event.object1.name == "gameOverBottom" and event.object2.name == "ball") or (event.object1.name == "gameOverLeft" and event.object2.name == "ball") or (event.object1.name == "gameOverTop" and event.object2.name == "ball") or (event.object1.name == "gameOverRight" and event.object2.name == "ball") or (event.object1.name == "scorePoint" and event.object2.name == "ball")
        or
      (event.object2.name == "gameOverBottom" and event.object1.name == "ball") or (event.object2.name == "gameOverLeft" and event.object1.name == "ball") or (event.object2.name == "gameOverTop" and event.object1.name == "ball") or (event.object2.name == "gameOverRight" and event.object1.name == "ball") or (event.object2.name == "scorePoint" and event.object1.name == "ball") then
        if lanciato then
            local timerSpostamento = timer.performWithDelay(100,
        function()
            ball.x = 860
            ball.y = 670
            ball:setLinearVelocity(0, 0)
            physics.setGravity(0, 0)
            ball.angularVelocity = 0
            ball.rotation = 0
        end, 1)

        lanciato = false
            Runtime:addEventListener("touch", drawTrajectory)
        end
    end
  elseif (event.phase == "ended" ) then
    if (event.object1.name == "ball" and event.object2.name == "scorePoint")
    or
    (event.object2.name == "ball" and event.object1.name == "scorePoint")
    then
        score = score + 1
        scoreboard.text = "Punteggio: " .. score
        scoreboard.x = scoreboard.contentWidth/2+125

        local timerSpostamento = timer.performWithDelay(100,
        function()
          ball.x = 860
          ball.y = 670
          ball:setLinearVelocity(0, 0)
          physics.setGravity(0, 0)
          ball.angularVelocity = 0
          ball.rotation = 0
        end, 1)

        lanciato = false
        Runtime:addEventListener("touch", drawTrajectory)
    end
  end
end

-- FUNZIONI PER SCENA DI COMPOSER

-- CREATE()

-- inizializzazione variabili
function scene:create(event)
  local sceneGroup = self.view

  physics.start()
  if debug then
    physics.setDrawMode("hybrid")
  else
    physics.setDrawMode("normal")
  end
  physics.setGravity(0, 0)

  mapBasket = tiled.new(json.decodeFile(system.pathForFile("src/map/basket.json")), "src/map")
  sceneGroup:insert(mapBasket)

  scoreboard = display.newText({text="Punteggio: " .. score, x=0, y=100, fontSize=40, font="Arial"})
  scoreboard.x = scoreboard.contentWidth/2+125
  sceneGroup:insert(scoreboard)

  testoCronometro = display.newText({text="", x=0, y=50, fontSize=40, font="Arial"})
  testoCronometro.x = testoCronometro.contentWidth/2+125
  sceneGroup:insert(testoCronometro)

  player = mapBasket:findObject("player")
  player.outline = graphics.newOutline(1, "src/img/sports/characters extra/player.png")
  local bodyType = player.bodyType
  physics.removeBody(player)
  physics.addBody(player, bodyType, {outline=player.outline, bounce=player.bounce, density=player.density, friction=player.friction})
  player.isFixedRotation = true

  ball = mapBasket:findObject("ball")
  basket = mapBasket:findObject("scorePoint")

  gameover.bottom = mapBasket:findObject("gameOverBottom")
  gameover.left = mapBasket:findObject("gameOverLeft")
  gameover.right = mapBasket:findObject("gameOverRight")
  gameover.top = mapBasket:findObject("gameOverTop")

  ballSound = audio.loadSound("src/sfx/basket_ball.mp3")
end

-- SHOW()

-- caricamento elementi nella scena
-- - will: visualizza mappa
-- - did: aggiunta event listener
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if(phase == "will") then
    display.setStatusBar(display.HiddenStatusBar)

    mapBasket.x = mapBasket.x - 32
    mapBasket.y = mapBasket.y - 56
    if debugDragable then
      mapBasket = dragable.new(mapBasket)
    end
  elseif(phase == "did") then
    -- fix posizioni
    player.x = 816
    player.y = 667

    if primoShowDid then
      primoShowDid = false
      Runtime:addEventListener("collision", collisionHandler)
      if (cronometroTimer == nil) then
        cronometroTimer = timer.performWithDelay(1000, cronometroUpdate, cronometro)
      end
    end

    introduzione:hide(nil, false)
    informazioniPalestra:hide(nil)
  end
end

-- HIDE()

-- rimozione elementi nella scena
-- - will: rimuove event listener e pausa audio
-- - did: rimuove parte grafica della scena
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if(phase == "will") then
    Runtime:removeEventListener("touch", drawTrajectory)
    Runtime:removeEventListener("collision", collisionHandler)

    ballSoundPlay = audio.pause(ballSoundPlay)

  elseif(phase == "did") then
    display.remove(sceneGroup)

  end
end

-- DESTROY()

-- rimozione elementi dalla memoria
function scene:destroy(event)
  local sceneGroup = self.view

  event.phase = "did"
  scene:hide(event) -- perchè non viene lanciato in automatico

  for i = 1, 10, 1 do
    Runtime:removeEventListener("touch", drawTrajectory) -- perchè rimane acceso event listener
    Runtime:removeEventListener("collision", collisionHandler) -- perchè rimane acceso event listener
  end

  mapBasket = nil
  player = nil
  ball = nil
  basket = nil

  audio.stop(ballSoundPlay)
  ballSoundPlay = nil
  audio.dispose(ballSound)
  ballSound = nil
end



scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
