-----------------------------------------------------------------------------------------
--
-- pallavolo scene
--
-----------------------------------------------------------------------------------------

-- minigioco pallavolo

-- IMPORTAZIONE LIBRERIE NECESSARIE

local informazioniMinigioco = require("informazioniMinigioco")

-- VARIABILI

-- variabili globali:
-- - schermata -> per informazioniMinigioco per bloccare gli eventListener degli elementi sottostanti

local scene = composer.newScene()
local infoPalestra = informazioniPalestra:readData("pallavolo")

local mapPallavolo

local player

schermata = false

local lanciato = false

local score = 0

local scoreboard

local gameover = {}

local ball

local ballForce = {}

local primoShowDid = true

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
          ball.x = 990
          ball.y = 340
          physics.setGravity(0, 0)
            ball:setLinearVelocity(0, 0)
            ball.angularVelocity = 0
            ball.rotation = 0
       end, 1)
    timer.cancel(cronometroTimer)
    informazioniMinigioco:show("pallavolo", math.floor(score))
  end
end

-- VOLLEYHIT()

-- applica un impulso che simula il lancio della palla
local function volleyHit()
  if debug then
    audio.setVolume(0.04, {channel=ballSoundChannel})
  else
    audio.setVolume(1, {channel=ballSoundChannel})
  end
    ballSoundPlay = audio.play(ballSound, {channel=ballSoundChannel, loops=0})
    audio.seek( 0, { channel=ballSoundChannel } )
end

-- PLAYERMOVEMENT()

-- muove il player in base al movimento del dito sullo schermo
local function playerMovement(event)
  if (event.phase=="began") or (event.phase=="moved") or (event.phase=="ended") then
    if(cronometro < 60) then -- per bloccare anche il caso in cui abbia iniziato a prendere la mira prima e poi sia scaduto il cronometro
      player.x = event.x+32
    else
      Runtime:removeEventListener("touch", playerMovement)
    end
  end
end
Runtime:addEventListener("touch", playerMovement)

-- COLLISIONHANDLER()

-- gestisce le collisioni con l'area di gioco
local function collisionHandler( event )
  if (event.phase == "began" ) then
    if (event.object1.name == "gameOverBottom" and event.object2.name == "ball") or (event.object1.name == "gameOverLeft" and event.object2.name == "ball") or (event.object1.name == "gameOverTop" and event.object2.name == "ball") or (event.object1.name == "gameOverRight" and event.object2.name == "ball") or (event.object1.name == "scorePoint" and event.object2.name == "ball")
        or
      (event.object2.name == "gameOverBottom" and event.object1.name == "ball") or (event.object2.name == "gameOverLeft" and event.object1.name == "ball") or (event.object2.name == "gameOverTop" and event.object1.name == "ball") or (event.object2.name == "gameOverRight" and event.object1.name == "ball") or (event.object2.name == "scorePoint" and event.object1.name == "ball") then

            local timerSpostamento = timer.performWithDelay(100,
        function()
            ball.x = 990 + math.random(-200, 200)
            ball.y = 340
            ball:setLinearVelocity(0, 0)
            ball.angularVelocity = 0
            ball.rotation = 0

            if(event.object1.name == "gameOverBottom" and event.object2.name == "ball")
            or
            (event.object2.name == "gameOverBottom" and event.object1.name == "ball") then
              if score > 0 then
                score = score - 1
                scoreboard.text = "Punteggio: " .. math.floor(score)
          scoreboard.x = scoreboard.contentWidth/2+125
              end
            end

        end, 1)
    end
  elseif (event.phase == "ended" ) then
    if (event.object1.name == "ball" and event.object2.name == "player")
    or
    (event.object2.name == "ball" and event.object1.name == "player")
    then
        score = score + 1
        scoreboard.text = "Punteggio: " .. math.floor(score)
        scoreboard.x = scoreboard.contentWidth/2+125
        volleyHit()
      elseif (event.object1.name == "ball" and event.object2.name == "scorePoint")
        or
        (event.object2.name == "ball" and event.object1.name == "scorePoint")
        then
            score = score + infoPalestra.bonus
            scoreboard.text = "Punteggio: " .. math.floor(score)
            scoreboard.x = scoreboard.contentWidth/2+125
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
  physics.setGravity(0, 9.8)

  mapPallavolo = tiled.new(json.decodeFile(system.pathForFile("src/map/pallavolo.json")), "src/map")
  sceneGroup:insert(mapPallavolo)

  scoreboard = display.newText({text="Punteggio: " .. score, x=0, y=100, fontSize=40, font="Arial"})
  scoreboard.x = scoreboard.contentWidth/2+125
  sceneGroup:insert(scoreboard)

  testoCronometro = display.newText({text="", x=0, y=50, fontSize=40, font="Arial"})
  testoCronometro.x = testoCronometro.contentWidth/2+125
  sceneGroup:insert(testoCronometro)

  player = mapPallavolo:findObject("player")
  ball = mapPallavolo:findObject("ball")

  player.outline = graphics.newOutline(1, "src/img/sports/characters extra/player.png")
  local bodyType = player.bodyType
  physics.removeBody(player)
  physics.addBody(player, bodyType, {outline=player.outline, bounce=player.bounce, density=player.density, friction=player.friction})
  player.isFixedRotation = true

  gameover.bottom = mapPallavolo:findObject("gameOverBottom")
  gameover.left = mapPallavolo:findObject("gameOverLeft")
  gameover.right = mapPallavolo:findObject("gameOverRight")
  gameover.top = mapPallavolo:findObject("gameOverTop")

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

    mapPallavolo.x = mapPallavolo.x - 32
    mapPallavolo.y = mapPallavolo.y - 56
    if debugDragable then
      mapPallavolo = dragable.new(mapPallavolo)
    end
  elseif(phase == "did") then
    -- fix posizioni
    player.x = 960
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

    ballSoundPlay = audio.pause(ballSoundPlay)

    Runtime:removeEventListener("touch", playerMovement)
    Runtime:removeEventListener("collision", collisionHandler)

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

  mapPallavolo = nil
  player = nil
  ball = nil

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
