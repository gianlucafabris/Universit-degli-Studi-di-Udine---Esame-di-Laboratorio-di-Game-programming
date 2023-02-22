-----------------------------------------------------------------------------------------
--
-- informazioniMinigioco
--
-----------------------------------------------------------------------------------------

-- informazioniMinigioco

-- VARIABILI

local I = {}

local informazioniMinigiocoGroup
local informazioniSport

local bg

local titolo
local testo
local immagineSoldi = {}
local pulsanti

local sound
local soundPlay
local soundChannel = 4
local timerSound

-- TORNA MAPPA PRINCIPALE

-- torna alla mappa principale se pulsante torna alla mappa viene premuto
local function tornaMappaPrincipale(event, nome, punteggio)
  soldi = soldi + punteggio
  salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  local options = {effect="fade", time=0}
  composer.gotoScene("game", options)
  composer.removeScene(nome)
end

-- RIGIOCA

-- rigioca se pulsante rigioca viene premuto
local function rigioca(event, nome, punteggio)
  soldi = soldi + punteggio
  salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  composer.gotoScene("game")
  composer.removeScene(nome)
  composer.gotoScene(nome)
  composer.removeScene("game")
end

-- AUDIO

-- riproduzione audio all'apertura della schermata
local function playAudio()
  sound = audio.loadSound("src/sfx/minigioco_win.mp3")

  if(debug) then
    audio.setVolume(0.01, {channel=soundChannel})
  else
    audio.setVolume(0.25, {channel=soundChannel})
  end

  soundPlay = audio.play(sound, {channel=soundChannel, loops=0})

  timerSound = timer.performWithDelay(2000, function() audio.stop(soundPlay) soundPlay = nil audio.dispose(sound) sound = nil timerSound = nil end, 1)
end

-- ELIMINAZIONE INTRODUZIONE

-- chiusura della schermata
function I.hide(self, event)
  display.remove(informazioniMinigiocoGroup)

  if(pulsanti) then
    pulsanti.p1:removeEventListener("tap", tornaMappaPrincipale)
    pulsanti.p2:removeEventListener("tap", rigioca)
  end

  pulsanti = nil
  immagineSoldi = {}
end

-- INTRODUZIONE

-- apertura della schermata
function I.show(self, nome, punteggio)
  I.hide(self, nil)
  schermata = true
  informazioniMinigiocoGroup = display.newGroup()
  informazioniSport = informazioniPalestra:readData(nome)

  playAudio()

  -- background e x per chiudere
  bg = display.newRoundedRect(display.contentCenterX, display.contentCenterY, display.contentWidth-150, display.contentHeight-150, 50)
  bg:setFillColor(0, 0, 0, 0.8)
  informazioniMinigiocoGroup:insert(bg)

  -- altri elementi (informazioni)
  -- TITOLO
  titolo = display.newText({text=informazioniSport.nome, x=display.contentCenterX, y=bg.y-bg.contentHeight/2+98, width=bg.contentWidth-100, height=96, font="Arial", fontSize=60, align="center"})
  informazioniMinigiocoGroup:insert(titolo)
  -- TESTO
  local informazioniTesto = ""
  if(nome == "motorsport") then
    informazioniTesto = informazioniTesto .. "Sei arrivato: " .. punteggio .. "\n"
  else
    informazioniTesto = informazioniTesto .. "Hai totalizzato: " .. punteggio .. " punti\n"
  end
  if(nome == "motorsport") then
    punteggio = 1500/punteggio
  else
    punteggio = informazioniSport.punto*punteggio
  end
  informazioniTesto = informazioniTesto .. "Hai guadagnato:      " .. punteggio .. "\n"
  testo = display.newText({text=informazioniTesto, x=bg.x-bg.contentWidth/2+(bg.contentWidth*2/3-75)/2+50, y=bg.y+(bg.contentHeight-246)/2-89, width=bg.contentWidth*2/3-75, height=bg.contentHeight-246, font="Arial", fontSize=25})
  informazioniMinigiocoGroup:insert(testo)
  immagineSoldi.guadagnato = display.newImageRect("src/img/game extra/soldi.png", 64, 64)
  immagineSoldi.guadagnato.xScale = 0.4
  immagineSoldi.guadagnato.yScale = 0.4
  immagineSoldi.guadagnato.x = testo.x-testo.contentWidth/2+206
  immagineSoldi.guadagnato.y = testo.y-testo.contentHeight/2+41.25
  informazioniMinigiocoGroup:insert(immagineSoldi.guadagnato)
  -- PULSANTI
  pulsanti = display.newRect(bg.x+bg.contentWidth/2-(bg.contentWidth/3-75)/2-50, bg.y+(bg.contentHeight-246)/2-89, bg.contentWidth/3-75, bg.contentHeight-246)
  pulsanti:setFillColor(0, 0, 0, 0)
  informazioniMinigiocoGroup:insert(pulsanti)
  -- PULSANTE TORNA MAPPA PRINCIPALE
  pulsanti.p1 = display.newRoundedRect(pulsanti.x, pulsanti.y-(pulsanti.contentHeight-100)/3-50, pulsanti.contentWidth, (pulsanti.contentHeight-100)/3, 50)
  pulsanti.p1:setFillColor(0, 0.75, 0)
  informazioniMinigiocoGroup:insert(pulsanti.p1)
  pulsanti.p1:addEventListener("tap", function(event) tornaMappaPrincipale(event, nome, punteggio) I.hide(self, nil) end)
  pulsanti.p1.text = display.newText({text="Torna alla mappa", x=pulsanti.x, y=pulsanti.y-(pulsanti.contentHeight-100)/3-50, font="Arial", fontSize=25, align="center"})
  informazioniMinigiocoGroup:insert(pulsanti.p1.text)
  -- PULSANTE RIGIOCA
  pulsanti.p2 = display.newRoundedRect(pulsanti.x, pulsanti.y, pulsanti.contentWidth, (pulsanti.contentHeight-100)/3, 50)
  pulsanti.p2:setFillColor(0, 0.75, 0)
  informazioniMinigiocoGroup:insert(pulsanti.p2)
  pulsanti.p2:addEventListener("tap", function(event) rigioca(event, nome, punteggio) I.hide(self, nil) end)
  pulsanti.p2.text = display.newText({text="Rigioca", x=pulsanti.x, y=pulsanti.y, font="Arial", fontSize=25, align="center"})
  informazioniMinigiocoGroup:insert(pulsanti.p2.text)

end

return I
