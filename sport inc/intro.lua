-----------------------------------------------------------------------------------------
--
-- intro scene
--
-----------------------------------------------------------------------------------------

-- scena iniziale di introduzione al gioco con immagine uniud e musica di benvenuto

-- VARIABILI

local scene = composer.newScene()

local logoUniud

local welcomeMusic
local welcomeMusicPlay
local welcomeMusicChannel = 1

-- FUNZIONI PER SCENA DI COMPOSER

-- CREATE()

-- inizializzazione variabili
function scene:create(event)
  local sceneGroup = self.view

  logoUniud = display.newImageRect("src/img/game extra/uniud_white.png", 800, 800)
  sceneGroup:insert(logoUniud)

  welcomeMusic = audio.loadSound("src/sfx/intro.mp3")
end

-- SHOW()

-- caricamento elementi nella scena
-- - will: centra logo uniud
-- - did: avvia audio
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if(phase == "will") then
    logoUniud.x = display.contentCenterX
    logoUniud.y = display.contentCenterY

  elseif(phase == "did") then
    if(debug) then
      audio.setVolume(0.01, {channel=welcomeMusicChannel})
    else
      audio.setVolume(0.25, {channel=welcomeMusicChannel})
    end
    welcomeMusicPlay = audio.play(welcomeMusic, {channel=welcomeMusicChannel, loops=0})

  end
end

-- HIDE()

-- rimozione elementi nella scena
-- - will: pausa audio
-- - did: rimuove parte grafica della scena
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if(phase == "will") then
    welcomeMusicPlay = audio.pause(welcomeMusicPlay)

  elseif(phase == "did") then
    display.remove(sceneGroup)

  end
end

-- DESTROY()

-- rimozione elementi dalla memoria
function scene:destroy(event)
  local sceneGroup = self.view

  event.phase = "did"
  scene:hide(event)

  logoUniud = nil

  audio.stop(welcomeMusicPlay)
  welcomeMusicPlay = nil
  audio.dispose(welcomeMusic)
  welcomeMusic = nil
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
