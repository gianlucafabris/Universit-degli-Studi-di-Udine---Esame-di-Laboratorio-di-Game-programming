-----------------------------------------------------------------------------------------
--
-- atletica scene
--
-----------------------------------------------------------------------------------------

-- minigioco atletica

-- IMPORTAZIONE LIBRERIE NECESSARIE

local informazioniMinigioco = require("informazioniMinigioco")

-- VARIABILI

-- variabili globali:
-- - schermata -> per informazioniMinigioco per bloccare gli eventListener degli elementi sottostanti

local scene = composer.newScene()

local mapAtletica

local mapAtleticaNext

local player

local score = 0

local obstacles = {} -- ostacolo grafico
local obstaclesHitBox = {} -- hit box dell'ostacolo (in sovrapposizione all'ostacolo stesso)
local obstaclesScorePoint = {} -- area in cui si assegna il punto (posizzionata appena dopo la hit box)

local timeSpeed = 19000 -- tempo di scroll

local speed = 1.25 -- velocità di scroll degli ostacoli

local ballSound
local ballSoundPlay
local ballSoundChannel = 5

local floorMovement
local floorNextMovement

schermata = false

local primoShowDid = true

local generationTimer

-- FUNZIONI LISTENER DI GIOCO

-- JUMPPLAYER

-- simula il salto dell'atleta applicando un impulso lineare verso l'alto

local function jumpPlayer( event)
  if player.y >= 660 then
    player:applyLinearImpulse(0,-12, player.x, player.y)

    if debug then
      audio.setVolume(0.01, {channel=ballSoundChannel})
    else
      audio.setVolume(0.25, {channel=ballSoundChannel})
    end

    ballSoundPlay = audio.play(ballSound, {channel=ballSoundChannel, loops=0})
    audio.seek( 0, { channel=ballSoundChannel } )
  end
  return true
end

-- CREATEOBSTACLE

-- genera dinamicamente gli sotacoli da saltare

function scene.createObstacle(self)
  sceneGroup = self.view
  local obstacle = mapAtleticaNext:findObject("obstacleN")
  local gameOver = mapAtleticaNext:findObject("gameOverN")
  local scorePoint = mapAtleticaNext:findObject("scorePointN")

  local randomDistance = math.random(-100, 100)

  local new_obstacle = display.newImageRect("src/img/sports/map extra/ostacolo atletica.png", 64, 64)
  new_obstacle.x = - 32 + 1344 + randomDistance
  new_obstacle.y = obstacle.y-56
  new_obstacle.name = obstacle.name
  sceneGroup:insert(new_obstacle)

  local new_gameOver = display.newRect( 1344 + randomDistance, gameOver.y, 12, 38)
  new_gameOver.name = gameOver.name
  new_gameOver.alpha = gameOver.alpha
  new_gameOver.isVisible = gameOver.isVisible
  physics.addBody(new_gameOver,gameOver.bodyType, { bounce = gameOver.bounce, density = gameOver.density, friction = gameOver.friction })
  sceneGroup:insert(new_gameOver)

  local new_scorePoint = display.newRect(scorePoint.x - obstacle.x + 1344 + randomDistance, scorePoint.y, 64, 32)
  new_scorePoint.name = scorePoint.name
  new_scorePoint.alpha = scorePoint.alpha
  new_scorePoint.isVisible = scorePoint.isVisible
  physics.addBody(new_scorePoint,scorePoint.bodyType)
  new_scorePoint.isSensor = true
  sceneGroup:insert(new_scorePoint)

  table.insert(obstacles, new_obstacle)
  table.insert(obstaclesHitBox, new_gameOver)
  table.insert(obstaclesScorePoint, new_scorePoint)

end


-- SCROLLOBSTACLES

-- simula il movimento in avanti (da SX verso DX) degli ostacoli

local function scrollObstacles()
  for i=1, #obstacles, 1 do
    obstacles[i].x = obstacles[i].x - speed
    obstaclesHitBox[i].x = obstaclesHitBox[i].x - speed
    obstaclesScorePoint[i].x = obstaclesScorePoint[i].x - speed
  end

  -- rimuove gli ostacoli che sono usciti di 100 unità dalla visualizzazione
  for i=1, #obstacles, 1 do
    if obstacles[i].x < -100 then
      table.remove(obstacles, i)
      table.remove(obstaclesHitBox, i)
      table.remove(obstaclesScorePoint, i)
    end
  end
end

-- SCROLLGAME

-- simula il movimento in avanti (da SX verso DX) del gioco

local function scrollGame()
  local floor = mapAtletica:findLayer("map")
  local floorNext = mapAtleticaNext:findLayer("map")

  floorMovement = transition.to(floor, {time=timeSpeed, x=-1344})
  floorNextMovement = transition.to(floorNext, {time=timeSpeed, x=-1344})
end

-- COLLISIONHANDLER()

-- gestisce le collisioni con l'area di gioco

function scene.collisionHandler( self, event )
  if (event.phase == "began") then
    if (event.object1.name == "gameOver1" and event.object2.name == "player")
    or
    (event.object1.name == "player" and event.object2.name == "gameOver1")
    or
    (event.object1.name == "gameOver2" and event.object2.name == "player")
    or
    (event.object1.name == "player" and event.object2.name == "gameOver2")
    or
    (event.object1.name == "gameOverN" and event.object2.name == "player")
    or
    (event.object1.name == "player" and event.object2.name == "gameOverN") then
      informazioniMinigioco:show("atletica", score)

      Runtime:removeEventListener("enterFrame", scrollObstacles)

      Runtime:removeEventListener("tap", jumpPlayer)
      Runtime:removeEventListener("collision", scene.collisionHandler)

    elseif (event.object1.name == "scorePoint1" and event.object2.name == "player")
      or
      (event.object1.name == "player" and event.object2.name == "scorePoint1")
      or
      (event.object1.name == "scorePoint2" and event.object2.name == "player")
      or
      (event.object1.name == "player" and event.object2.name == "scorePoint2")
      or
    (event.object1.name == "scorePointN" and event.object2.name == "player")
    or
    (event.object1.name == "player" and event.object2.name == "scorePointN") then
        score = score + 1
        scoreboard.text = "Punteggio: " .. score
        scoreboard.x = scoreboard.contentWidth/2+125

        local timerGenerator = timer.performWithDelay(100, function() scene.createObstacle(self) end, 1)
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

  mapAtletica = tiled.new(json.decodeFile(system.pathForFile("src/map/atletica.json")), "src/map")
  sceneGroup:insert(mapAtletica)

  mapAtleticaNext = tiled.new(json.decodeFile(system.pathForFile("src/map/atletica_next.json")), "src/map")
  sceneGroup:insert(mapAtleticaNext)

  scoreboard = display.newText({text="Punteggio: " .. score, x=0, y=100, fontSize=40, font="Arial"})
  scoreboard.x = scoreboard.contentWidth/2+125
  sceneGroup:insert(scoreboard)

  player = mapAtletica:findObject("player")
  player.outline = graphics.newOutline(1, "src/img/sports/characters extra/player.png")
  local bodyType = player.bodyType
  physics.removeBody(player)
  physics.addBody(player, bodyType, {outline=player.outline, bounce=player.bounce, density=player.density, friction=player.friction})
  player.isFixedRotation = true

  obstacles[1] = mapAtletica:findObject("obstacle1")
  obstaclesHitBox[1] = mapAtletica:findObject("gameOver1")
  obstaclesScorePoint[1] = mapAtletica:findObject("scorePoint1")

  obstacles[2] = mapAtletica:findObject("obstacle2")
  obstaclesHitBox[2] = mapAtletica:findObject("gameOver2")
  obstaclesScorePoint[2] = mapAtletica:findObject("scorePoint2")

  ballSound = audio.loadSound("src/sfx/atletica_jump.mp3")
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

    mapAtletica.x = mapAtletica.x - 32
    mapAtletica.y = mapAtletica.y - 56
    if debugDragable then
      mapAtletica = dragable.new(mapAtletica)
    end

    mapAtleticaNext.x = mapAtleticaNext.x - 32 + 1344
    mapAtleticaNext.y = mapAtleticaNext.y - 56
    if debugDragable then
      mapAtleticaNext = dragable.new(mapAtletica)
    end

  elseif(phase == "did") then
    -- fix posizioni
    player.x = 142
    player.y = 680

    scrollGame()
    if primoShowDid then
      primoShowDid = false

      scene.createObstacle(self)

      Runtime:addEventListener("enterFrame", scrollObstacles)

      Runtime:addEventListener("tap", jumpPlayer)
      Runtime:addEventListener("collision", function(event) scene.collisionHandler(self, event) end)
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

    Runtime:removeEventListener("enterFrame", scrollObstacles)

    Runtime:removeEventListener("tap", jumpPlayer)
    Runtime:removeEventListener("collision", scene.collisionHandler)

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

  mapAtletica = nil
  mapAtleticaNext = nil
  player = nil

  obstacles = {}
  obstaclesHitBox = {}
  obstaclesScorePoint = {}

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
