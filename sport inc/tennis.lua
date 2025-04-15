-----------------------------------------------------------------------------------------
--
-- tennis scene
--
-----------------------------------------------------------------------------------------

-- minigioco tennis

-- IMPORTAZIONE LIBRERIE NECESSARIE

local informazioniMinigioco = require("informazioniMinigioco")

-- VARIABILI

-- variabili globali:
-- - schermata -> per informazioniMinigioco per bloccare gli eventListener degli elementi sottostanti

local scene = composer.newScene()

local infoPalestra = informazioniPalestra:readData("tennis")

local mapTennis

local player

local ball

local ai

local scoreboard

local score = 0

schermata = false

local primoShowDid = true

local gameover = {}
local scorePoint = {}

local cronometro = 0
local testoCronometro
local cronometroTimer

local ballSound
local ballSoundPlay
local ballSoundChannel = 5

local playerHit = false

-- FUNZIONI UTILITY

-- funzione utility per convertire valore da un range ad un altro
local function map(value, startOld, endOld, startNew, endNew)
  return (value-startOld)/(endOld-startOld)*endNew+startNew
end

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
            ball.x = 1012
            ball.y = 388
            ball:setLinearVelocity(0, 0)
            ball.angularVelocity = 0
            ball.rotation = 0
       end, 1)
    timer.cancel(cronometroTimer)
    informazioniMinigioco:show("tennis", score)
  end
end

-- COLLISIONHANDLER()

-- gestisce le collisioni con l'area di gioco
local function collisionHandler( event )
  if (event.phase == "began" ) then
    if (event.object1.name == "gameOverBottom" and event.object2.name == "ball") or (event.object1.name == "gameOverLeft" and event.object2.name == "ball") or (event.object1.name == "gameOverTop" and event.object2.name == "ball")
      or
      (event.object2.name == "gameOverBottom" and event.object1.name == "ball") or (event.object2.name == "gameOverLeft" and event.object1.name == "ball") or (event.object2.name == "gameOverTop" and event.object1.name == "ball") then
        local timerSpostamento = timer.performWithDelay(100,
        function()
            ball.x = 1012
            ball.y = 388
            ball:setLinearVelocity(0, 0)
            ball.angularVelocity = 0
            ball.rotation = 0
            ball:applyLinearImpulse(-25,0,ball.x,ball.y) -- uguale a ballMovement()
       end, 1)

    elseif (event.object1.name == "scorePoint" and event.object2.name == "ball")
      or
      (event.object2.name == "scorePoint" and event.object1.name == "ball") then
        if playerHit then
          score = score + 1
          scoreboard.text = "Punteggio: " .. score
          scoreboard.x = scoreboard.contentWidth/2+125
        end

    elseif (event.object1.name == "scorePointBottom" and event.object2.name == "ball") or (event.object1.name == "scorePointRight" and event.object2.name == "ball") or (event.object1.name == "scorePointTop" and event.object2.name == "ball")
      or
      (event.object2.name == "scorePointBottom" and event.object1.name == "ball") or (event.object2.name == "scorePointRight" and event.object1.name == "ball") or (event.object2.name == "scorePointTop" and event.object1.name == "ball") then
        score = score + infoPalestra.bonus
        scoreboard.text = "Punteggio: " .. score
        scoreboard.x = scoreboard.contentWidth/2+125
        local timerSpostamento = timer.performWithDelay(100,
        function()
          ball.x = 1012
          ball.y = 388
          ball:setLinearVelocity(0, 0)
          ball.angularVelocity = 0
          ball.rotation = 0
          ball:applyLinearImpulse(-25,0,ball.x,ball.y) -- uguale a ballMovement()
       end, 1)
      elseif (event.object1.name == "player" and event.object2.name == "ball")
      or
      (event.object2.name == "player" and event.object1.name == "ball") then -- gestione del calcolo dei punti (+1 solo quando è il player ad aver colpito la palla)
        playerHit = true
        if debug then
          audio.setVolume(0.01, {channel=ballSoundChannel})
        else
          audio.setVolume(0.25, {channel=ballSoundChannel})
        end
          ballSoundPlay = audio.play(ballSound, {channel=ballSoundChannel, loops=0})
          audio.seek( 0, { channel=ballSoundChannel } )

      elseif (event.object1.name == "ai" and event.object2.name == "ball")
      or
      (event.object2.name == "ai" and event.object1.name == "ball") then
        playerHit = false
        if debug then
          audio.setVolume(0.01, {channel=ballSoundChannel})
        else
          audio.setVolume(0.25, {channel=ballSoundChannel})
        end
          ballSoundPlay = audio.play(ballSound, {channel=ballSoundChannel, loops=0})
          audio.seek( 0, { channel=ballSoundChannel } )

    end
  end
end

-- PLAYERMOVEMENTLISTENER()

-- gestisce il movimento del giroscopio e lo trasferisce al player
local function playerMovementListener(event)
  player.y = display.contentCenterY+map(-event.xGravity, 0, 1, 0, 243)+56
end

-- AIMOVEMENT()

-- gestisce il movimento della ai
local function aiMovement(event)
  ai.y = ball.y
end

-- BALLMOVEMENT()

-- gestisce il movimento della pallina
local function ballMovement()
  ball:applyLinearImpulse(-25, 0, ball.x, ball.y)
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

  mapTennis = tiled.new(json.decodeFile(system.pathForFile("src/map/tennis.json")), "src/map")
  sceneGroup:insert(mapTennis)
  scoreboard = display.newText({text="Punteggio: " .. score, x=0, y=100, fontSize=40, font="Arial"})
  scoreboard.x = scoreboard.contentWidth/2+125
  sceneGroup:insert(scoreboard)

  testoCronometro = display.newText({text="", x=0, y=50, fontSize=40, font="Arial"})
  testoCronometro.x = testoCronometro.contentWidth/2+125
  sceneGroup:insert(testoCronometro)

  player = mapTennis:findObject("player")

  ai = mapTennis:findObject("ai")

  ball = mapTennis:findObject("ball")

  gameover.bottom = mapTennis:findObject("gameOverBottom")
  gameover.left = mapTennis:findObject("gameOverLeft")
  gameover.top = mapTennis:findObject("gameOverTop")

  scorePoint.bottom = mapTennis:findObject("scorePointBottom")
  scorePoint.right = mapTennis:findObject("scorePointRight")
  scorePoint.top = mapTennis:findObject("scorePointTop")

  scorePoint.center = mapTennis:findObject("scorePoint")

  ballSound = audio.loadSound("src/sfx/tennis_ball.mp3")
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

    mapTennis.x = mapTennis.x - 32
    mapTennis.y = mapTennis.y - 56
    if debugDragable then
      mapTennis = dragable.new(mapTennis)
    end
  elseif(phase == "did") then
    if primoShowDid then
      primoShowDid = false
      Runtime:addEventListener("collision", collisionHandler)
      Runtime:addEventListener("accelerometer", playerMovementListener)
      Runtime:addEventListener("enterFrame", aiMovement)
      if (cronometroTimer == nil) then
        cronometroTimer = timer.performWithDelay(1000, cronometroUpdate, cronometro)
      end
      ballMovement()
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
    Runtime:removeEventListener("collision", collisionHandler)
    Runtime:removeEventListener("accelerometer", playerMovementListener)
    Runtime:removeEventListener("enterFrame", aiMovement)
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

  mapTennis = nil
  player = nil
  ball = nil
  audio.stop(ballSoundPlay)
  ballSoundPlay = nil
  audio.dispose(ballSound)
  ballSound = nil
  ai = nil
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
