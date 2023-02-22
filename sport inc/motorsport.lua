-----------------------------------------------------------------------------------------
--
-- motorsport scene
--
-----------------------------------------------------------------------------------------

-- minigioco motorsport

-- IMPORTAZIONE LIBRERIE NECESSARIE

local vjoy = require("com.ponywolf.vjoy")
local informazioniMinigioco = require("informazioniMinigioco")

-- VARIABILI

-- variabili globali:
-- - schermata -> per informazioniMinigioco per bloccare gli eventListener degli elementi sottostanti

local scene = composer.newScene()

local mapMotorsport
local joystick

local player
local ai1
local ai2
local ai3

local aiCheckPoint = {}

schermata = false

local primoShowDid = true

local scorePoint
local zonaScivolosa1
local zonaScivolosa2

local enginePlayerSound
local enginePlayerSoundPlay
local enginePlayerSoundChannel = 5
local engineAi1Sound
local engineAi1SoundPlay
local engineAi1SoundChannel = 6
local engineAi2Sound
local engineAi2SoundPlay
local engineAi2SoundChannel = 7
local engineAi3Sound
local engineAi3SoundPlay
local engineAi3SoundChannel = 8

local minigiocoIniziato = false
local passaggiTraguardo = 0
local posizionePlayer = 1
local testoPosizione
local cronometro = 0
local testoCronometro
local cronometroTimer

-- UTILITY

-- funzione utility per trasformare un punto in un angolo
local function pointToAngle(x,y)
  return math.atan2(x,y)*180/math.pi
end

-- funzione utility per convertire valore da un range ad un altro
local function map(value, startOld, endOld, startNew, endNew)
  return (value-startOld)/(endOld-startOld)*endNew+startNew
end

-- MOVIMENTO PLAYER E AI

-- movimento del player tramite joystick
local function movePlayer(event)
  if(not schermata) then
    if(event.axis.number == 1) then
      player.speed.x = event.normalizedValue*150*player.speedFactor
    end
    if(event.axis.number == 2) then
      player.speed.y = event.normalizedValue*150*player.speedFactor
    end
    player:setLinearVelocity(player.speed.x,player.speed.y)
  end
end

Runtime:addEventListener("axis", movePlayer)

-- movimento ai verso target
local function moveAiTo(ai)
  local normalizedValue = {}
  normalizedValue.x = 0
  normalizedValue.y = 0
  if(not schermata) then
    if(ai == 1) then
      normalizedValue.x = map(aiCheckPoint[ai1.target].x-ai1.x, 0, math.sqrt(math.pow(math.max(math.abs(aiCheckPoint[ai1.target].x-ai1.x),math.abs(aiCheckPoint[ai1.target].y-ai1.y)),2)*2), 0, 1)
      normalizedValue.y = map(aiCheckPoint[ai1.target].y-ai1.y, 0, math.sqrt(math.pow(math.max(math.abs(aiCheckPoint[ai1.target].x-ai1.x),math.abs(aiCheckPoint[ai1.target].y-ai1.y)),2)*2), 0, 1)
      ai1.speed.x = normalizedValue.x*120
      ai1.speed.y = normalizedValue.y*120
      ai1:setLinearVelocity(ai1.speed.x,ai1.speed.y)
    elseif(ai == 2) then
      normalizedValue.x = map(aiCheckPoint[ai2.target].x-ai2.x, 0, math.sqrt(math.pow(math.max(math.abs(aiCheckPoint[ai2.target].x-ai2.x),math.abs(aiCheckPoint[ai2.target].y-ai2.y)),2)*2), 0, 1)
      normalizedValue.y = map(aiCheckPoint[ai2.target].y-ai2.y, 0, math.sqrt(math.pow(math.max(math.abs(aiCheckPoint[ai2.target].x-ai2.x),math.abs(aiCheckPoint[ai2.target].y-ai2.y)),2)*2), 0, 1)
      ai2.speed.x = normalizedValue.x*120
      ai2.speed.y = normalizedValue.y*120
      ai2:setLinearVelocity(ai2.speed.x,ai2.speed.y)
    elseif(ai == 3) then
      normalizedValue.x = map(aiCheckPoint[ai3.target].x-ai3.x, 0, math.sqrt(math.pow(math.max(math.abs(aiCheckPoint[ai3.target].x-ai3.x),math.abs(aiCheckPoint[ai3.target].y-ai3.y)),2)*2), 0, 1)
      normalizedValue.y = map(aiCheckPoint[ai3.target].y-ai3.y, 0, math.sqrt(math.pow(math.max(math.abs(aiCheckPoint[ai3.target].x-ai3.x),math.abs(aiCheckPoint[ai3.target].y-ai3.y)),2)*2), 0, 1)
      ai3.speed.x = normalizedValue.x*120
      ai3.speed.y = normalizedValue.y*120
      ai3:setLinearVelocity(ai3.speed.x,ai3.speed.y)
    end
  end
end

-- funzione richiamata dall'event listener
local function moveAis(event)
  moveAiTo(1)
  moveAiTo(2)
  moveAiTo(3)
end

-- rotazione macchina in base alla direzione, per movimento più realistico
local function rotatePlayerAi(event)
  if(not (-player.previousPosition.x+player.x==0 or player.previousPosition.y-player.y==0)) then
    player.rotation = pointToAngle(-player.previousPosition.x+player.x, player.previousPosition.y-player.y)
  end
  player.previousPosition.x = player.x
  player.previousPosition.y = player.y

  if(not (-ai1.previousPosition.x+ai1.x==0 or ai1.previousPosition.y-ai1.y==0)) then
    ai1.rotation = pointToAngle(-ai1.previousPosition.x+ai1.x, ai1.previousPosition.y-ai1.y)
  end
  ai1.previousPosition.x = ai1.x
  ai1.previousPosition.y = ai1.y

  if(not (-ai2.previousPosition.x+ai2.x==0 or ai2.previousPosition.y-ai2.y==0)) then
    ai2.rotation = pointToAngle(-ai2.previousPosition.x+ai2.x, ai2.previousPosition.y-ai2.y)
  end
  ai2.previousPosition.x = ai2.x
  ai2.previousPosition.y = ai2.y

  if(not (-ai3.previousPosition.x+ai3.x==0 or ai3.previousPosition.y-ai3.y==0)) then
    ai3.rotation = pointToAngle(-ai3.previousPosition.x+ai3.x, ai3.previousPosition.y-ai3.y)
  end
  ai3.previousPosition.x = ai3.x
  ai3.previousPosition.y = ai3.y
end

Runtime:addEventListener("enterFrame", rotatePlayerAi)

-- VOLUME MOTORI IN BASE ALLA VELOCITÀ

-- regola volume audio in base alla velocità
local function engineSoundVolume()
  local playerVolume
  local Ai1Volume
  local Ai2Volume
  local Ai3Volume
  if(debug) then
    playerVolume = map((math.abs(player.speed.x)+math.abs(player.speed.y))/2, 0, math.sqrt(math.pow(150,2)*2), 0.004, 0.01)
  else
    playerVolume = map((math.abs(player.speed.x)+math.abs(player.speed.y))/2, 0, math.sqrt(math.pow(150,2)*2), 0.1, 0.25)
  end
  if(debug) then
    Ai1Volume = map((math.abs(ai1.speed.x)+math.abs(ai1.speed.y))/2, 0, math.sqrt(math.pow(150,2)*2), 0.004, 0.01)
  else
    Ai1Volume = map((math.abs(ai1.speed.x)+math.abs(ai1.speed.y))/2, 0, math.sqrt(math.pow(150,2)*2), 0.1, 0.25)
  end
  if(debug) then
    Ai2Volume = map((math.abs(ai2.speed.x)+math.abs(ai2.speed.y))/2, 0, math.sqrt(math.pow(150,2)*2), 0.004, 0.01)
  else
    Ai2Volume = map((math.abs(ai2.speed.x)+math.abs(ai2.speed.y))/2, 0, math.sqrt(math.pow(150,2)*2), 0.1, 0.25)
  end
  if(debug) then
    Ai3Volume = map((math.abs(ai3.speed.x)+math.abs(ai3.speed.y))/2, 0, math.sqrt(math.pow(150,2)*2), 0.004, 0.01)
  else
    Ai3Volume = map((math.abs(ai3.speed.x)+math.abs(ai3.speed.y))/2, 0, math.sqrt(math.pow(150,2)*2), 0.1, 0.25)
  end

  audio.setVolume(playerVolume, {channel=enginePlayerSoundChannel})
  audio.setVolume(Ai1Volume, {channel=engineAi1SoundChannel})
  audio.setVolume(Ai2Volume, {channel=engineAi2SoundChannel})
  audio.setVolume(Ai3Volume, {channel=engineAi3SoundChannel})

end

-- CRONOMETRO

function cronometroUpdate()
  cronometro = cronometro+1

  local minuti = math.floor(cronometro/60)
  local secondi = cronometro%60

  testoCronometro.text = string.format("%02d:%02d", minuti, secondi)
  testoCronometro.x = testoCronometro.contentWidth/2+125
end

-- COLLISIONHANDLER

-- funzione gestione della collisioni per:
-- - modificare velocità player se entra o esce in una delle due zone scivolose
-- - crea path da seguire per ai
-- - controlla cronometro, posizione player e informazioniMinigioco
local function collisionHandler(event)
  if (event.phase == "began") then
    -- modifica velocità player se entra o esce in una delle due zone scivolose
    if(
      (player.x > zonaScivolosa1.x-zonaScivolosa1.contentWidth/2 and player.x < zonaScivolosa1.x+zonaScivolosa1.contentWidth/2 and player.y > zonaScivolosa1.y-zonaScivolosa1.contentHeight/2 and player.y < zonaScivolosa1.y+zonaScivolosa1.contentHeight/2)
      or
      (player.x > zonaScivolosa2.x-zonaScivolosa2.contentWidth/2 and player.x < zonaScivolosa2.x+zonaScivolosa2.contentWidth/2 and player.y > zonaScivolosa2.y-zonaScivolosa2.contentHeight/2 and player.y < zonaScivolosa2.y+zonaScivolosa2.contentHeight/2)
    ) then -- player è in una delle due zone scivolose
      player.speedFactor = 2/3
    else
      player.speedFactor = 1
    end

    -- aggionamento target ai (crea path)
    if(
      (event.object1.name == "ai1" and event.object2.name == "aiCheckPoint".. ai1.target) or (event.object1.name == "ai2" and event.object2.name == "aiCheckPoint".. ai2.target) or (event.object1.name == "ai3" and event.object2.name == "aiCheckPoint".. ai3.target)
      or
      (event.object1.name == "aiCheckPoint".. ai1.target and event.object2.name == "ai1") or (event.object1.name == "aiCheckPoint".. ai2.target and event.object2.name == "ai2") or (event.object1.name == "aiCheckPoint".. ai3.target and event.object2.name == "ai3")
    ) then -- ai1, ai2 o ai3 tocca un check point
      if(event.object1.name == "ai1" or event.object2.name == "ai1") then
        ai1.target = ai1.target+1
        if(ai1.target > 26) then
          ai1.target = 1
        end
      elseif(event.object1.name == "ai2" or event.object2.name == "ai2") then
        ai2.target = ai2.target+1
        if(ai2.target > 26) then
          ai2.target = 1
        end
      elseif(event.object1.name == "ai3" or event.object2.name == "ai3") then
        ai3.target = ai3.target+1
        if(ai3.target > 26) then
          ai3.target = 1
        end
      end
    end

    -- cronometro, posizione e informazioniMinigioco
    if(
      (event.object1.name == "player" and event.object2.name == "scorePoint") or (event.object1.name == "ai1" and event.object2.name == "scorePoint") or (event.object1.name == "ai2" and event.object2.name == "scorePoint") or (event.object1.name == "ai3" and event.object2.name == "scorePoint")
      or
      (event.object1.name == "scorePoint" and event.object2.name == "player") or (event.object1.name == "scorePoint" and event.object2.name == "ai1") or (event.object1.name == "scorePoint" and event.object2.name == "ai2") or (event.object1.name == "scorePoint" and event.object2.name == "ai3")
    ) then
    passaggiTraguardo = passaggiTraguardo+1
      if(not minigiocoIniziato) then
        minigiocoIniziato = true
        testoPosizione.text = math.ceil(posizionePlayer) .."°"
        testoPosizione.x = testoPosizione.x+testoPosizione.contentWidth/2
        cronometroTimer = timer.performWithDelay(1000, cronometroUpdate, cronometro)
      elseif(passaggiTraguardo > 4) then
        if(event.object1.name == "player" or event.object2.name == "player" or posizionePlayer == 4) then
          Runtime:removeEventListener("enterFrame", moveAis)
          player:setLinearVelocity(0,0)
          ai1:setLinearVelocity(0,0)
          ai2:setLinearVelocity(0,0)
          ai3:setLinearVelocity(0,0)
          enginePlayerSoundPlay = audio.pause(enginePlayerSoundPlay)
          engineAi1SoundPlay = audio.pause(engineAi1SoundPlay)
          engineAi2SoundPlay = audio.pause(engineAi2SoundPlay)
          engineAi3SoundPlay = audio.pause(engineAi3SoundPlay)
          timer.cancel(cronometroTimer)
          informazioniMinigioco:show("motorsport", posizionePlayer)
        else
          posizionePlayer = posizionePlayer+1
          testoPosizione.text = math.ceil(posizionePlayer) .."°"
          testoPosizione.x = testoPosizione.contentWidth/2+125
        end
      end
    end

  elseif (event.phase == "ended") then

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

  mapMotorsport = tiled.new(json.decodeFile(system.pathForFile("src/map/motorsport.json")), "src/map")
  sceneGroup:insert(mapMotorsport)
  joystick = vjoy.newStick(1)
  sceneGroup:insert(joystick)

  player = mapMotorsport:findObject("player")
  player.speed = {}
  player.speed.x = 0
  player.speed.y = 0
  player.previousPosition = {}
  player.previousPosition.x = 0
  player.previousPosition.y = 0
  player.speedFactor = 1
  player.isFixedRotation = true
  ai1 = mapMotorsport:findObject("ai1")
  ai1.speed = {}
  ai1.speed.x = 0
  ai1.speed.y = 0
  ai1.previousPosition = {}
  ai1.previousPosition.x = 0
  ai1.previousPosition.y = 0
  ai1.isFixedRotation = true
  ai2 = mapMotorsport:findObject("ai2")
  ai2.speed = {}
  ai2.speed.x = 0
  ai2.speed.y = 0
  ai2.previousPosition = {}
  ai2.previousPosition.x = 0
  ai2.previousPosition.y = 0
  ai2.isFixedRotation = true
  ai3 = mapMotorsport:findObject("ai3")
  ai3.speed = {}
  ai3.speed.x = 0
  ai3.speed.y = 0
  ai3.previousPosition = {}
  ai3.previousPosition.x = 0
  ai3.previousPosition.y = 0
  ai3.isFixedRotation = true

  aiCheckPoint[1] = mapMotorsport:findObject("aiCheckPoint1")
  aiCheckPoint[2] = mapMotorsport:findObject("aiCheckPoint2")
  aiCheckPoint[3] = mapMotorsport:findObject("aiCheckPoint3")
  aiCheckPoint[4] = mapMotorsport:findObject("aiCheckPoint4")
  aiCheckPoint[5] = mapMotorsport:findObject("aiCheckPoint5")
  aiCheckPoint[6] = mapMotorsport:findObject("aiCheckPoint6")
  aiCheckPoint[7] = mapMotorsport:findObject("aiCheckPoint7")
  aiCheckPoint[8] = mapMotorsport:findObject("aiCheckPoint8")
  aiCheckPoint[9] = mapMotorsport:findObject("aiCheckPoint9")
  aiCheckPoint[10] = mapMotorsport:findObject("aiCheckPoint10")
  aiCheckPoint[11] = mapMotorsport:findObject("aiCheckPoint11")
  aiCheckPoint[12] = mapMotorsport:findObject("aiCheckPoint12")
  aiCheckPoint[13] = mapMotorsport:findObject("aiCheckPoint13")
  aiCheckPoint[14] = mapMotorsport:findObject("aiCheckPoint14")
  aiCheckPoint[15] = mapMotorsport:findObject("aiCheckPoint15")
  aiCheckPoint[16] = mapMotorsport:findObject("aiCheckPoint16")
  aiCheckPoint[17] = mapMotorsport:findObject("aiCheckPoint17")
  aiCheckPoint[18] = mapMotorsport:findObject("aiCheckPoint18")
  aiCheckPoint[19] = mapMotorsport:findObject("aiCheckPoint19")
  aiCheckPoint[20] = mapMotorsport:findObject("aiCheckPoint20")
  aiCheckPoint[21] = mapMotorsport:findObject("aiCheckPoint21")
  aiCheckPoint[22] = mapMotorsport:findObject("aiCheckPoint22")
  aiCheckPoint[23] = mapMotorsport:findObject("aiCheckPoint23")
  aiCheckPoint[24] = mapMotorsport:findObject("aiCheckPoint24")
  aiCheckPoint[25] = mapMotorsport:findObject("aiCheckPoint25")
  aiCheckPoint[26] = mapMotorsport:findObject("aiCheckPoint26")

  ai1.target = 1
  ai2.target = 1
  ai3.target = 1

  scorePoint = mapMotorsport:findObject("scorePoint")
  zonaScivolosa1 = mapMotorsport:findObject("zonaScivolosa1")
  zonaScivolosa2 = mapMotorsport:findObject("zonaScivolosa2")

  enginePlayerSound = audio.loadSound("src/sfx/motorsport_car_player.mp3")
  engineAi1Sound = audio.loadSound("src/sfx/motorsport_car_ai1.mp3")
  engineAi2Sound = audio.loadSound("src/sfx/motorsport_car_ai2.mp3")
  engineAi3Sound = audio.loadSound("src/sfx/motorsport_car_ai3.mp3")

  testoPosizione = display.newText({text="", x=0, y=100, fontSize=40, font="Arial"})
  testoPosizione.x = testoPosizione.contentWidth/2+125
  sceneGroup:insert(testoPosizione)
  testoCronometro = display.newText({text="", x=0, y=50, fontSize=40, font="Arial"})
  testoCronometro.x = testoCronometro.contentWidth/2+125
  sceneGroup:insert(testoCronometro)
end

-- SHOW()

-- caricamento elementi nella scena
-- - will: visualizza mappa
-- - did: avvia audio e aggiunta event listener
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if(phase == "will") then
    display.setStatusBar(display.HiddenStatusBar)

    mapMotorsport.x = mapMotorsport.x - 32
    mapMotorsport.y = mapMotorsport.y - 56
    if(debugDragable) then
      mapMotorsport = dragable.new(mapMotorsport)
    end
    joystick.xScale = 0.5
    joystick.yScale = 0.5
    joystick.x = joystick.width * 0.5
    joystick.y = display.contentHeight - joystick.height * 0.5
  elseif (phase == "did") then
    -- fix posizioni
    local gameOverInnerTop1 = mapMotorsport:findObject("gameOverInnerTop1")
    gameOverInnerTop1.x = 576
    gameOverInnerTop1.y = 288
    local gameOverInnerTop2 = mapMotorsport:findObject("gameOverInnerTop2")
    gameOverInnerTop2.x = 832
    gameOverInnerTop2.y = 320
    local gameOverInnerTop3 = mapMotorsport:findObject("gameOverInnerTop3")
    gameOverInnerTop3.x = 1056
    gameOverInnerTop3.y = 320
    local gameOverInnerBottom1 = mapMotorsport:findObject("gameOverInnerBottom1")
    gameOverInnerBottom1.x = 320
    gameOverInnerBottom1.y = 352
    local gameOverInnerBottom2 = mapMotorsport:findObject("gameOverInnerBottom2")
    gameOverInnerBottom2.x = 384
    gameOverInnerBottom2.y = 512
    local gameOverInnerBottom3 = mapMotorsport:findObject("gameOverInnerBottom3")
    gameOverInnerBottom3.x = 736
    gameOverInnerBottom3.y = 544
    local gameOverBottomLeft1 = mapMotorsport:findObject("gameOverBottomLeft1")
    gameOverBottomLeft1.x = 160
    gameOverBottomLeft1.y = 512
    local gameOverBottomLeft2 = mapMotorsport:findObject("gameOverBottomLeft2")
    gameOverBottomLeft2.x = 256
    gameOverBottomLeft2.y = 640
    local gameOverBottomRight1 = mapMotorsport:findObject("gameOverBottomRight1")
    gameOverBottomRight1.x = 1120
    gameOverBottomRight1.y = 669
    local gameOverBottomRight2 = mapMotorsport:findObject("gameOverBottomRight2")
    gameOverBottomRight2.x = 1248
    gameOverBottomRight2.y = 576
    player.x = 0
    player.y = 660
    player.isFixedRotation = true
    ai1.x = 0
    ai1.y = 620
    player.isFixedRotation = true
    ai2.x = 0
    ai2.y = 660
    player.isFixedRotation = true
    ai3.x = 0
    ai3.y = 620
    player.isFixedRotation = true
    zonaScivolosa2.x = 704
    zonaScivolosa2.y = 384

    -- per resettare rotazione tramite rotatePlayerAi
    local timerResetPositions = timer.performWithDelay(50, function() player.x = 964 ai1.x = 578 ai2.x = 704 ai3.x = 830 end, 1)

    if(debug) then
      audio.setVolume(0.01, {channel=enginePlayerSoundChannel})
    else
      audio.setVolume(0.25, {channel=enginePlayerSoundChannel})
    end
    enginePlayerSoundPlay = audio.play(enginePlayerSound, {channel=enginePlayerSoundChannel, loops=-1})
    if(debug) then
      audio.setVolume(0.01, {channel=engineAi1SoundChannel})
    else
      audio.setVolume(0.25, {channel=engineAi1SoundChannel})
    end
    engineAi1SoundPlay = audio.play(engineAi1Sound, {channel=engineAi1SoundChannel, loops=-1})
    if(debug) then
      audio.setVolume(0.01, {channel=engineAi2SoundChannel})
    else
      audio.setVolume(0.25, {channel=engineAi2SoundChannel})
    end
    engineAi2SoundPlay = audio.play(engineAi2Sound, {channel=engineAi2SoundChannel, loops=-1})
    if(debug) then
      audio.setVolume(0.01, {channel=engineAi3SoundChannel})
    else
      audio.setVolume(0.25, {channel=engineAi3SoundChannel})
    end
    engineAi3SoundPlay = audio.play(engineAi3Sound, {channel=engineAi3SoundChannel, loops=-1})


    if(primoShowDid) then
      primoShowDid = false
      Runtime:addEventListener("enterFrame", engineSoundVolume)
      Runtime:addEventListener("collision", collisionHandler)

      Runtime:addEventListener("enterFrame", moveAis)
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
    Runtime:removeEventListener("axis", movePlayer)
    Runtime:removeEventListener("enterFrame", rotatePlayerAi)
    Runtime:removeEventListener("enterFrame", engineSoundVolume)
    Runtime:removeEventListener("collision", collisionHandler)

    Runtime:removeEventListener("enterFrame", moveAis)

    enginePlayerSoundPlay = audio.pause(enginePlayerSoundPlay)
    engineAi1SoundPlay = audio.pause(engineAi1SoundPlay)
    engineAi2SoundPlay = audio.pause(engineAi2SoundPlay)
    engineAi3SoundPlay = audio.pause(engineAi3SoundPlay)

  elseif(phase == "did") then
    display.remove(sceneGroup)

    informazioniMinigioco:hide(nil)

  end
end

-- DESTROY()

-- rimozione elementi dalla memoria
function scene:destroy(event)
  local sceneGroup = self.view

  event.phase = "did"
  scene:hide(event) -- perchè non viene lanciato in automatico

  for i = 1, 10, 1 do
    Runtime:removeEventListener("enterFrame", engineSoundVolume) -- perchè rimane acceso event listener
    Runtime:removeEventListener("collision", collisionHandler) -- perchè rimane acceso event listener
    Runtime:removeEventListener("enterFrame", moveAis) -- perchè rimane acceso event listener
  end

  mapMotorsport = nil
  joystick = nil
  player = nil
  ai1 = nil
  ai2 = nil
  ai3 = nil

  audio.stop()
  enginePlayerSoundPlay = nil
  audio.dispose(enginePlayerSound)
  enginePlayerSound = nil
  audio.stop()
  engineAi1SoundPlay = nil
  audio.dispose(engineAi1Sound)
  engineAi1Sound = nil
  audio.stop()
  engineAi2SoundPlay = nil
  audio.dispose(engineAi2Sound)
  engineAi2Sound = nil
  audio.stop()
  engineAi3SoundPlay = nil
  audio.dispose(engineAi3Sound)
  engineAi3Sound = nil
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
