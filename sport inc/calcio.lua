-----------------------------------------------------------------------------------------
--
-- calcio scene
--
-----------------------------------------------------------------------------------------

-- minigioco calcio

-- IMPORTAZIONE LIBRERIE NECESSARIE

local informazioniMinigioco = require("informazioniMinigioco")

-- VARIABILI

-- variabili globali:
-- - schermata -> per informazioniMinigioco per bloccare gli eventListener degli elementi sottostanti

local scene = composer.newScene()

local mapCalcio

local player

schermata = false

local lanciato = false

local score = 0

local scoreboard

local gameover = {}

local ball

local ballForce = {}

local footballGoal

local inizioLancio = 0

local primoShowDid = true

local cronometro = 0
local testoCronometro
local cronometroTimer

local ballSound
local ballSoundPlay
local ballSoundChannel = 5

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
          ball.x = 670
          ball.y = 420
            ball:setLinearVelocity(0, 0)
            ball.angularVelocity = 0
            ball.rotation = 0
       end, 1)
       Runtime:removeEventListener("touch", swipeTrajectory)
        for i = 1, 10, 1 do
          Runtime:removeEventListener("touch", swipeTrajectory) -- perchè rimane acceso event listener
        end
    timer.cancel(cronometroTimer)
    informazioniMinigioco:show("calcio", score)
  end
end

-- SOCCERGOALSHOT

local function soccerGoalShot(x, y)
  lanciato = true
  ball:applyLinearImpulse(x, y, ball.x, ball.y)
  if debug then
    audio.setVolume(0.04, {channel=ballSoundChannel})
  else
    audio.setVolume(1, {channel=ballSoundChannel})
  end
  ballSoundPlay = audio.play(ballSound, {channel=ballSoundChannel, loops=0})
  audio.seek( 0, { channel=ballSoundChannel } )
end

-- SWIPETRAJECTORY()
local function swipeTrajectory(event)
  if event.phase=="began" then
    inizioLancio = event.time
    if(cronometro >= 60) then -- per bloccare anche il caso in cui abbia iniziato a prendere la mira prima e poi sia scaduto il cronometro
      Runtime:removeEventListener("touch", swipeTrajectory)
      for i = 1, 10, 1 do
        Runtime:removeEventListener("touch", swipeTrajectory) -- perchè rimane acceso event listener
      end
    end
  end
  if event.phase=="ended" then
    if(cronometro < 60) then
      if(event.time-inizioLancio <= 1000) then

        ballForce.x = map(event.x-ball.x+32, 0, math.sqrt(math.pow(math.max(math.abs(event.x-ball.x+32),math.abs(event.y-ball.y+56)),2)*2), 0, 40)
        ballForce.y = map(event.y-ball.y+56, 0, math.sqrt(math.pow(math.max(math.abs(event.x-ball.x+32),math.abs(event.y-ball.y+56)),2)*2), 0, 40)

        soccerGoalShot(ballForce.x, ballForce.y)
        Runtime:removeEventListener("touch", swipeTrajectory)
        for i = 1, 10, 1 do
          Runtime:removeEventListener("touch", swipeTrajectory) -- perchè rimane acceso event listener
        end
      end
    else
        Runtime:removeEventListener("touch", swipeTrajectory)
      for i = 1, 10, 1 do
        Runtime:removeEventListener("touch", swipeTrajectory) -- perchè rimane acceso event listener
      end
    end
  end
end
Runtime:addEventListener("touch", swipeTrajectory)

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
            ball.x = 670
            ball.y = 420
            ball:setLinearVelocity(0, 0)
            ball.angularVelocity = 0
            ball.rotation = 0
        end, 1)

        lanciato = false
        Runtime:addEventListener("touch", swipeTrajectory)
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
          ball.x = 670
          ball.y = 420
          ball:setLinearVelocity(0, 0)
          ball.angularVelocity = 0
          ball.rotation = 0
        end, 1)

        lanciato = false
        Runtime:addEventListener("touch", swipeTrajectory)
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

  mapCalcio = tiled.new(json.decodeFile(system.pathForFile("src/map/calcio.json")), "src/map")
  sceneGroup:insert(mapCalcio)

  scoreboard = display.newText({text="Punteggio: " .. score, x=0, y=100, fontSize=40, font="Arial"})
  scoreboard.x = scoreboard.contentWidth/2+125
  sceneGroup:insert(scoreboard)

  testoCronometro = display.newText({text="", x=0, y=50, fontSize=40, font="Arial"})
  testoCronometro.x = testoCronometro.contentWidth/2+125
  sceneGroup:insert(testoCronometro)

  player = mapCalcio:findObject("player")
  ball = mapCalcio:findObject("ball")
  footballGoal = mapCalcio:findObject("scorePoint")

  gameover.bottom = mapCalcio:findObject("gameOverBottom")
  gameover.left = mapCalcio:findObject("gameOverLeft")
  gameover.right = mapCalcio:findObject("gameOverRight")
  gameover.top = mapCalcio:findObject("gameOverTop")

  ballSound = audio.loadSound("src/sfx/minigioco_ball.mp3")

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

    mapCalcio.x = mapCalcio.x - 32
    mapCalcio.y = mapCalcio.y - 56
    if debugDragable then
      mapCalcio = dragable.new(mapCalcio)
    end
  elseif(phase == "did") then

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
    Runtime:removeEventListener("touch", swipeTrajectory)
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

  mapCalcio = nil
  player = nil
  ball = nil
  footballGoal = nil

  audio.stop(ballSoundPlay)
  ballSoundPlay = nil
  audio.dispose(ballSound)
  ballSound = nil

  for i = 1, 10, 1 do
    Runtime:removeEventListener("collision", collisionHandler) -- perchè rimane acceso event listener
    Runtime:removeEventListener("touch", swipeTrajectory) -- perchè rimane acceso event listener
  end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
