-----------------------------------------------------------------------------------------
--
-- informazioniSport
--
-----------------------------------------------------------------------------------------

-- informazioniSport

-- IMPORTAZIONE LIBRERIE NECESSARIE

tempo = require("tempo")

-- VARIABILI

local I = {}

local informazioniPalestraGroup
local informazioniSport

local bg
local close

local titolo
local testo
local immagineSoldi
local pulsanti

local sound
local soundPlay
local soundChannel = 3
local timerSound

local tempoEP = {}
local entrataPassivaDisponibile = false

-- CARICAMENTO DATI INTRODUZIONI

-- lettura del file soldi
function I.readData(self, nome)
  local informazioni = {}
  informazioni.atletica = {}
  informazioni.basket = {}
  informazioni.calcio = {}
  informazioni.pallavolo = {}
  informazioni.tennis = {}
  informazioni.motorsport = {}

  local file, errorString = io.open(system.pathForFile("src/text/soldi_formattato.txt", system.ResourceDirectory), "r")

  if(not file) then
    print("Errore: " .. errorString)
  else
    informazioni.atletica.nome = file:read("*l")
    informazioni.atletica.acquisto = file:read("*l")
    informazioni.atletica.tassaIngresso = file:read("*l")
    informazioni.atletica.punto = file:read("*l")
    informazioni.atletica.bonus = file:read("*l")
    informazioni.atletica.miglioramento = file:read("*l")
    informazioni.atletica.entrataPassiva = file:read("*l")

    informazioni.basket.nome = file:read("*l")
    informazioni.basket.acquisto = file:read("*l")
    informazioni.basket.tassaIngresso = file:read("*l")
    informazioni.basket.punto = file:read("*l")
    informazioni.basket.bonus = file:read("*l")
    informazioni.basket.miglioramento = file:read("*l")
    informazioni.basket.entrataPassiva = file:read("*l")

    informazioni.calcio.nome = file:read("*l")
    informazioni.calcio.acquisto = file:read("*l")
    informazioni.calcio.tassaIngresso = file:read("*l")
    informazioni.calcio.punto = file:read("*l")
    informazioni.calcio.bonus = file:read("*l")
    informazioni.calcio.miglioramento = file:read("*l")
    informazioni.calcio.entrataPassiva = file:read("*l")

    informazioni.pallavolo.nome = file:read("*l")
    informazioni.pallavolo.acquisto = file:read("*l")
    informazioni.pallavolo.tassaIngresso = file:read("*l")
    informazioni.pallavolo.punto = file:read("*l")
    informazioni.pallavolo.bonus = file:read("*l")
    informazioni.pallavolo.miglioramento = file:read("*l")
    informazioni.pallavolo.entrataPassiva = file:read("*l")

    informazioni.tennis.nome = file:read("*l")
    informazioni.tennis.acquisto = file:read("*l")
    informazioni.tennis.tassaIngresso = file:read("*l")
    informazioni.tennis.punto = file:read("*l")
    informazioni.tennis.bonus = file:read("*l")
    informazioni.tennis.miglioramento = file:read("*l")
    informazioni.tennis.entrataPassiva = file:read("*l")

    informazioni.motorsport.nome = file:read("*l")
    informazioni.motorsport.acquisto = file:read("*l")
    informazioni.motorsport.tassaIngresso = file:read("*l")
    informazioni.motorsport.punto = file:read("*l")
    informazioni.motorsport.bonus = file:read("*l")
    informazioni.motorsport.miglioramento = file:read("*l")
    informazioni.motorsport.entrataPassiva = file:read("*l")

    io.close(file)
  end

  file = nil

  -- typecasting delle informazioni
  -- ATLETICA
  informazioni.atletica.acquisto = tonumber(informazioni.atletica.acquisto)
  if(informazioni.atletica.tassaIngresso == "false") then
    informazioni.atletica.tassaIngresso = false
  else
    informazioni.atletica.tassaIngresso = tonumber(informazioni.atletica.tassaIngresso)
  end
  informazioni.atletica.punto = tonumber(informazioni.atletica.punto)
  if(informazioni.atletica.bonus == "false") then
    informazioni.atletica.bonus = false
  else
    informazioni.atletica.bonus = tonumber(informazioni.atletica.bonus)
  end
  if(informazioni.atletica.miglioramento == "false") then
    informazioni.atletica.miglioramento = false
  else
    informazioni.atletica.miglioramento = tonumber(informazioni.atletica.miglioramento)
  end
  if(informazioni.atletica.entrataPassiva == "false") then
    informazioni.atletica.entrataPassiva = false
  else
    informazioni.atletica.entrataPassiva = tonumber(informazioni.atletica.entrataPassiva)
  end

  -- BASKET
  informazioni.basket.acquisto = tonumber(informazioni.basket.acquisto)
  if(informazioni.basket.tassaIngresso == "false") then
    informazioni.basket.tassaIngresso = false
  else
    informazioni.basket.tassaIngresso = tonumber(informazioni.basket.tassaIngresso)
  end
  informazioni.basket.punto = tonumber(informazioni.basket.punto)
  if(informazioni.basket.bonus == "false") then
    informazioni.basket.bonus = false
  else
    informazioni.basket.bonus = tonumber(informazioni.basket.bonus)
  end
  if(informazioni.basket.miglioramento == "false") then
    informazioni.basket.miglioramento = false
  else
    informazioni.basket.miglioramento = tonumber(informazioni.basket.miglioramento)
  end
  if(informazioni.basket.entrataPassiva == "false") then
    informazioni.basket.entrataPassiva = false
  else
    informazioni.basket.entrataPassiva = tonumber(informazioni.basket.entrataPassiva)
  end

  -- CALCIO
  informazioni.calcio.acquisto = tonumber(informazioni.calcio.acquisto)
  if(informazioni.calcio.tassaIngresso == "false") then
    informazioni.calcio.tassaIngresso = false
  else
    informazioni.calcio.tassaIngresso = tonumber(informazioni.calcio.tassaIngresso)
  end
  informazioni.calcio.punto = tonumber(informazioni.calcio.punto)
  if(informazioni.calcio.bonus == "false") then
    informazioni.calcio.bonus = false
  else
    informazioni.calcio.bonus = tonumber(informazioni.calcio.bonus)
  end
  if(informazioni.calcio.miglioramento == "false") then
    informazioni.calcio.miglioramento = false
  else
    informazioni.calcio.miglioramento = tonumber(informazioni.calcio.miglioramento)
  end
  if(informazioni.calcio.entrataPassiva == "false") then
    informazioni.calcio.entrataPassiva = false
  else
    informazioni.calcio.entrataPassiva = tonumber(informazioni.calcio.entrataPassiva)
  end

  -- PALLAVOLO
  informazioni.pallavolo.acquisto = tonumber(informazioni.pallavolo.acquisto)
  if(informazioni.pallavolo.tassaIngresso == "false") then
    informazioni.pallavolo.tassaIngresso = false
  else
    informazioni.pallavolo.tassaIngresso = tonumber(informazioni.pallavolo.tassaIngresso)
  end
  informazioni.pallavolo.punto = tonumber(informazioni.pallavolo.punto)
  if(informazioni.pallavolo.bonus == "false") then
    informazioni.pallavolo.bonus = false
  else
    informazioni.pallavolo.bonus = tonumber(informazioni.pallavolo.bonus)
  end
  if(informazioni.pallavolo.miglioramento == "false") then
    informazioni.pallavolo.miglioramento = false
  else
    informazioni.pallavolo.miglioramento = tonumber(informazioni.pallavolo.miglioramento)
  end
  if(informazioni.pallavolo.entrataPassiva == "false") then
    informazioni.pallavolo.entrataPassiva = false
  else
    informazioni.pallavolo.entrataPassiva = tonumber(informazioni.pallavolo.entrataPassiva)
  end

  -- TENNIS
  informazioni.tennis.acquisto = tonumber(informazioni.tennis.acquisto)
  if(informazioni.tennis.tassaIngresso == "false") then
    informazioni.tennis.tassaIngresso = false
  else
    informazioni.tennis.tassaIngresso = tonumber(informazioni.tennis.tassaIngresso)
  end
  informazioni.tennis.punto = tonumber(informazioni.tennis.punto)
  if(informazioni.tennis.bonus == "false") then
    informazioni.tennis.bonus = false
  else
    informazioni.tennis.bonus = tonumber(informazioni.tennis.bonus)
  end
  if(informazioni.tennis.miglioramento == "false") then
    informazioni.tennis.miglioramento = false
  else
    informazioni.tennis.miglioramento = tonumber(informazioni.tennis.miglioramento)
  end
  if(informazioni.tennis.entrataPassiva == "false") then
    informazioni.tennis.entrataPassiva = false
  else
    informazioni.tennis.entrataPassiva = tonumber(informazioni.tennis.entrataPassiva)
  end

  -- MOTORSPORT
  informazioni.motorsport.acquisto = tonumber(informazioni.motorsport.acquisto)
  if(informazioni.motorsport.tassaIngresso == "false") then
    informazioni.motorsport.tassaIngresso = false
  else
    informazioni.motorsport.tassaIngresso = tonumber(informazioni.motorsport.tassaIngresso)
  end
  -- informazioni.motorsport.punto = tonumber(informazioni.motorsport.punto)
  if(informazioni.motorsport.bonus == "false") then
    informazioni.motorsport.bonus = false
  else
    informazioni.motorsport.bonus = tonumber(informazioni.motorsport.bonus)
  end
  if(informazioni.motorsport.miglioramento == "false") then
    informazioni.motorsport.miglioramento = false
  else
    informazioni.motorsport.miglioramento = tonumber(informazioni.motorsport.miglioramento)
  end
  if(informazioni.motorsport.entrataPassiva == "false") then
    informazioni.motorsport.entrataPassiva = false
  else
    informazioni.motorsport.entrataPassiva = tonumber(informazioni.motorsport.entrataPassiva)
  end

  if(nome == "gioco") then
    return informazioni.gioco
  elseif(nome == "minigioco") then
    return informazioni.minigioco
  elseif(nome == "atletica") then
    return informazioni.atletica
  elseif(nome == "basket") then
    return informazioni.basket
  elseif(nome == "calcio") then
    return informazioni.calcio
  elseif(nome == "pallavolo") then
    return informazioni.pallavolo
  elseif(nome == "tennis") then
    return informazioni.tennis
  elseif(nome == "motorsport") then
    return informazioni.motorsport
  end

  return nil
end

-- TEMPOENTRATAPASSIVA
local function tempoEntrataPassiva(nome)
  tempoEP.atletica, tempoEP.basket, tempoEP.calcio, tempoEP.pallavolo, tempoEP.tennis, tempoEP.motorsport = tempo:readTime()

  local hour, min
  if(nome == "atletica") then
    hour = tempoEP.atletica.hour
    min = tempoEP.atletica.min
  elseif(nome == "basket") then
    hour = tempoEP.basket.hour
    min = tempoEP.basket.min
  elseif(nome == "calcio") then
    hour = tempoEP.calcio.hour
    min = tempoEP.calcio.min
  elseif(nome == "pallavolo") then
    hour = tempoEP.pallavolo.hour
    min = tempoEP.pallavolo.min
  elseif(nome == "tennis") then
    hour = tempoEP.tennis.hour
    min = tempoEP.tennis.min
  elseif(nome == "motorsport") then
    hour = tempoEP.motorsport.hour
    min = tempoEP.motorsport.min
  end

  local now = os.date("*t")
  if((now.hour == hour and now.min >= min) or (now.hour == hour+1 and now.min < min)) then
    entrataPassivaDisponibile = false
  else
    entrataPassivaDisponibile = true
  end
end

-- MAGGIORI INFORMAZIONI

-- richiama introduzione per visualizzare maggiori informazioni
local function maggioriInformazioni(event, nome)
  introduzione:show(nome)
end

-- GIOCA

-- avvia minigioco
local function gioca(event, nome)
  if(informazioniSport.tassaIngresso) then
    soldi = soldi - informazioniSport.tassaIngresso
    aggiornaTestoSoldi()
    salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  end
  local options = {effect="fade", time=0}
  composer.gotoScene(nome, options)
  composer.removeScene("game")
end

-- SPENDI E GUADAGNA

-- aggiorna stato gioco se pulsante acquista/migliora viene premuto
local function spendi(event, nome)
  local primoAcquisto = sportStatus.atletica == 0 and sportStatus.basket == 0 and sportStatus.calcio == 0 and sportStatus.pallavolo == 0 and sportStatus.tennis == 0 and sportStatus.motorsport == 0

  if(sportStatus[nome] == 0) then
    spesa = informazioniSport.acquisto
  elseif(sportStatus[nome] == 1) then
    spesa = informazioniSport.miglioramento
  end
  soldi = soldi - spesa
  sportStatus[nome] = sportStatus[nome] + 1
  aggiornaTestoSoldi()
  aggiornaVisualizzazioneSport()

  local ultimoAcquisto = ((I:readData("atletica").miglioramento and sportStatus.atletica == 2) or (not I:readData("atletica").miglioramento and sportStatus.atletica == 1)) and ((I:readData("basket").miglioramento and sportStatus.basket == 2) or (not I:readData("basket").miglioramento and sportStatus.basket == 1)) and ((I:readData("calcio").miglioramento and sportStatus.calcio == 2) or (not I:readData("calcio").miglioramento and sportStatus.calcio == 1)) and ((I:readData("pallavolo").miglioramento and sportStatus.pallavolo == 2) or (not I:readData("pallavolo").miglioramento and sportStatus.pallavolo == 1)) and ((I:readData("tennis").miglioramento and sportStatus.tennis == 2) or (not I:readData("tennis").miglioramento and sportStatus.tennis == 1)) and ((I:readData("motorsport").miglioramento and sportStatus.motorsport == 2) or (not I:readData("motorsport").miglioramento and sportStatus.motorsport == 1))

  salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
  if(primoAcquisto) then
    introduzione:show("minigioco")
  elseif(ultimoAcquisto) then
    introduzione:show("fine")
  end
end

-- aggiorna stato gioco se pulsante riscuoti entrata passiva viene premuto
local function guadagna(event, nome)
  local now = os.date("*t")
  local nuovoTempo = {}
  nuovoTempo.hour = now.hour
  nuovoTempo.min = now.min
  if(nome == "atletica") then
    tempo:writeTime(nuovoTempo, tempoEP.basket, tempoEP.calcio, tempoEP.pallavolo, tempoEP.tennis, tempoEP.motorsport)
  elseif(nome == "basket") then
    tempo:writeTime(tempoEP.atletica, nuovoTempo, tempoEP.calcio, tempoEP.pallavolo, tempoEP.tennis, tempoEP.motorsport)
  elseif(nome == "calcio") then
    tempo:writeTime(tempoEP.atletica, tempoEP.basket, nuovoTempo, tempoEP.pallavolo, tempoEP.tennis, tempoEP.motorsport)
  elseif(nome == "pallavolo") then
    tempo:writeTime(tempoEP.atletica, tempoEP.basket, tempoEP.calcio, nuovoTempo, tempoEP.tennis, tempoEP.motorsport)
  elseif(nome == "tennis") then
    tempo:writeTime(tempoEP.atletica, tempoEP.basket, tempoEP.calcio, tempoEP.pallavolo, nuovoTempo, tempoEP.motorsport)
  elseif(nome == "motorsport") then
    tempo:writeTime(tempoEP.atletica, tempoEP.basket, tempoEP.calcio, tempoEP.pallavolo, tempoEP.tennis, nuovoTempo)
  end

  soldi = soldi + informazioniSport.entrataPassiva
  aggiornaTestoSoldi()
  salvataggio:writeSave(soldi, sportStatus.atletica, sportStatus.basket, sportStatus.calcio, sportStatus.pallavolo, sportStatus.tennis, sportStatus.motorsport)
end

-- AUDIO

-- riproduzione audio se pulsante acquista/migliora/riscuoti entrata passiva viene premuto
local function playAudio(event, nome)
  sound = audio.loadSound("src/sfx/game_palestra_".. nome ..".mp3")

  if(nome == "unlock") then
    if(debug) then
      audio.setVolume(0.01, {channel=soundChannel})
    else
      audio.setVolume(0.25, {channel=soundChannel})
    end
  elseif(nome == "upgrade") then
    if(debug) then
      audio.setVolume(0.04, {channel=soundChannel})
    else
      audio.setVolume(1, {channel=soundChannel})
    end
  elseif(nome == "cash") then
    if(debug) then
      audio.setVolume(0.008, {channel=soundChannel})
    else
      audio.setVolume(0.2, {channel=soundChannel})
    end
  end
  soundPlay = audio.play(sound, {channel=soundChannel, loops=0})

  timerSound = timer.performWithDelay(1500, function() audio.stop(soundPlay) soundPlay = nil audio.dispose(sound) sound = nil timerSound = nil end, 1)
end

-- ELIMINAZIONE INTRODUZIONE

-- chiusura della schermata
function I.hide(self, event)
  display.remove(informazioniPalestraGroup)

  if(close) then
    close:removeEventListener("tap", I.hide)
    local timerSchermata = timer.performWithDelay(100, function() schermata = false end, 1) -- per evitare che l'evento si propaghi agli eventListener degli elementi sottostanti
  end
  if(pulsanti) then
    pulsanti.p1:removeEventListener("tap", maggioriInformazioni)
    pulsanti.p2:removeEventListener("tap", gioca)
    if(sportStatus[nome] == 0 or informazioniSport.miglioramento) then
      if(sportStatus[nome] == 0 or sportStatus[nome] == 1) then
        pulsanti.p3:removeEventListener("tap", spedi)
      elseif(sportStatus[nome] == 2) then
        pulsanti.p3:removeEventListener("tap", guadagna)
      end
    end
  end

  close = nil
  pulsanti = nil
  immagineSoldi = {}
end

-- INTRODUZIONE

-- apertura della schermata
function I.show(self, nome)
  I.hide(self, nil)
  tempoEntrataPassiva(nome)
  schermata = true
  informazioniPalestraGroup = display.newGroup()
  informazioniSport = I:readData(nome)

  -- background e x per chiudere
  bg = display.newRoundedRect(display.contentCenterX, display.contentCenterY, display.contentWidth-150, display.contentHeight-150, 50)
  bg:setFillColor(0, 0, 0, 0.8)
  informazioniPalestraGroup:insert(bg)
  close = display.newImageRect("src/img/game extra/cross.png", 64, 64)
  close.xScale = 0.5
  close.yScale = 0.5
  close.x = bg.x+bg.contentWidth/2-32
  close.y = bg.y-bg.contentHeight/2+32
  informazioniPalestraGroup:insert(close)
  close:addEventListener("tap", I.hide)

  -- altri elementi (informazioni)
  -- TITOLO
  titolo = display.newText({text=informazioniSport.nome, x=display.contentCenterX, y=bg.y-bg.contentHeight/2+98, width=bg.contentWidth-100, height=96, font="Arial", fontSize=60, align="center"})
  informazioniPalestraGroup:insert(titolo)
  -- TESTO
  local informazioniTesto = "Acquisto:      " .. informazioniSport.acquisto .. "\n"
  if(informazioniSport.tassaIngresso) then
    informazioniTesto = informazioniTesto .. "Tassa di ingresso:      " .. informazioniSport.tassaIngresso .. "\n"
  else
    informazioniTesto = informazioniTesto .. "Tassa di ingresso: no\n"
  end
  informazioniTesto = informazioniTesto .. "Ogni punto vale:      " .. informazioniSport.punto .. "\n"
  if(informazioniSport.bonus) then
    informazioniTesto = informazioniTesto .. "Bonus: " .. informazioniSport.bonus .. " punti\n"
  else
    informazioniTesto = informazioniTesto .. "Bonus: no\n"
  end
  if(informazioniSport.miglioramento) then
    informazioniTesto = informazioniTesto .. "Miglioramento:      " .. informazioniSport.miglioramento .. "\n" .. "Entrata passiva:      " .. informazioniSport.entrataPassiva .. "/h"
  else
    informazioniTesto = informazioniTesto .. "Miglioramento: no\n"
  end
  testo = display.newText({text=informazioniTesto, x=bg.x-bg.contentWidth/2+(bg.contentWidth*2/3-75)/2+50, y=bg.y+(bg.contentHeight-246)/2-89, width=bg.contentWidth*2/3-75, height=bg.contentHeight-246, font="Arial", fontSize=25})
  informazioniPalestraGroup:insert(testo)
  immagineSoldi.acquisto = display.newImageRect("src/img/game extra/soldi.png", 64, 64)
  immagineSoldi.acquisto.xScale = 0.4
  immagineSoldi.acquisto.yScale = 0.4
  immagineSoldi.acquisto.x = testo.x-testo.contentWidth/2+125
  immagineSoldi.acquisto.y = testo.y-testo.contentHeight/2+12.5
  informazioniPalestraGroup:insert(immagineSoldi.acquisto)
  if(informazioniSport.tassaIngresso) then
    immagineSoldi.tassaIngresso = display.newImageRect("src/img/game extra/soldi.png", 64, 64)
    immagineSoldi.tassaIngresso.xScale = 0.4
    immagineSoldi.tassaIngresso.yScale = 0.4
    immagineSoldi.tassaIngresso.x = testo.x-testo.contentWidth/2+220
    immagineSoldi.tassaIngresso.y = testo.y-testo.contentHeight/2+41.25
    informazioniPalestraGroup:insert(immagineSoldi.tassaIngresso)
  end
  immagineSoldi.punto = display.newImageRect("src/img/game extra/soldi.png", 64, 64)
  immagineSoldi.punto.xScale = 0.4
  immagineSoldi.punto.yScale = 0.4
  immagineSoldi.punto.x = testo.x-testo.contentWidth/2+205
  immagineSoldi.punto.y = testo.y-testo.contentHeight/2+70
  informazioniPalestraGroup:insert(immagineSoldi.punto)
  if(informazioniSport.miglioramento) then
    immagineSoldi.miglioramento = display.newImageRect("src/img/game extra/soldi.png", 64, 64)
    immagineSoldi.miglioramento.xScale = 0.4
    immagineSoldi.miglioramento.yScale = 0.4
    immagineSoldi.miglioramento.x = testo.x-testo.contentWidth/2+185
    immagineSoldi.miglioramento.y = testo.y-testo.contentHeight/2+127.5
    informazioniPalestraGroup:insert(immagineSoldi.miglioramento)
    immagineSoldi.entrataPassiva = display.newImageRect("src/img/game extra/soldi.png", 64, 64)
    immagineSoldi.entrataPassiva.xScale = 0.4
    immagineSoldi.entrataPassiva.yScale = 0.4
    immagineSoldi.entrataPassiva.x = testo.x-testo.contentWidth/2+200
    immagineSoldi.entrataPassiva.y = testo.y-testo.contentHeight/2+156.25
    informazioniPalestraGroup:insert(immagineSoldi.entrataPassiva)
  end
  -- PULSANTI
  pulsanti = display.newRect(bg.x+bg.contentWidth/2-(bg.contentWidth/3-75)/2-50, bg.y+(bg.contentHeight-246)/2-89, bg.contentWidth/3-75, bg.contentHeight-246)
  pulsanti:setFillColor(0, 0, 0, 0)
  informazioniPalestraGroup:insert(pulsanti)
  -- PULSANTE MAGGIORI INFORMAZIONI
  pulsanti.p1 = display.newRoundedRect(pulsanti.x, pulsanti.y-(pulsanti.contentHeight-100)/3-50, pulsanti.contentWidth, (pulsanti.contentHeight-100)/3, 50)
  pulsanti.p1:setFillColor(0, 0.75, 0)
  informazioniPalestraGroup:insert(pulsanti.p1)
  pulsanti.p1:addEventListener("tap", function(event) maggioriInformazioni(event, nome) I.hide(self, nil) end)
  pulsanti.p1.text = display.newText({text="Maggiori informazioni", x=pulsanti.x, y=pulsanti.y-(pulsanti.contentHeight-100)/3-50, font="Arial", fontSize=25, align="center"})
  informazioniPalestraGroup:insert(pulsanti.p1.text)
  -- PULSANTE GIOCA
  pulsanti.p2 = display.newRoundedRect(pulsanti.x, pulsanti.y, pulsanti.contentWidth, (pulsanti.contentHeight-100)/3, 50)
  if(sportStatus[nome] == 0) then
    pulsanti.p2:setFillColor(0.25, 0.25, 0.25)
  else
    pulsanti.p2:setFillColor(0, 0.75, 0)
  end
  informazioniPalestraGroup:insert(pulsanti.p2)
  if(not (sportStatus[nome] == 0)) then
    pulsanti.p2:addEventListener("tap", function(event) gioca(event, nome) I.hide(self, nil) end)
  end
  pulsanti.p2.text = display.newText({text="Gioca", x=pulsanti.x, y=pulsanti.y, font="Arial", fontSize=25, align="center"})
  informazioniPalestraGroup:insert(pulsanti.p2.text)
  -- PULSANTE ACQUISTA/MIGLIORA/RACCOGLI ENTRATA PASSIVA
  if(sportStatus[nome] == 0 or informazioniSport.miglioramento) then
    pulsanti.p3 = display.newRoundedRect(pulsanti.x, pulsanti.y+(pulsanti.contentHeight-100)/3+50, pulsanti.contentWidth, (pulsanti.contentHeight-100)/3, 50)
    if((sportStatus[nome] == 0 and soldi >= informazioniSport.acquisto) or (sportStatus[nome] == 1 and informazioniSport.miglioramento and soldi >= informazioniSport.miglioramento) or (sportStatus[nome] == 2 and informazioniSport.miglioramento and entrataPassivaDisponibile)) then -- stato lock e ha abbastanza soldi, stato unlock e ha abbastanza soldi, stato upgrade
      pulsanti.p3:setFillColor(0, 0.75, 0)
    else
      pulsanti.p3:setFillColor(0.25, 0.25, 0.25)
    end
    informazioniPalestraGroup:insert(pulsanti.p3)
    if(sportStatus[nome] == 0) then
      pulsanti.p3:addEventListener("tap", function(event) spendi(event, nome) playAudio(event, "unlock") I.hide(self, nil) end)
      pulsanti.p3.text = display.newText({text="Acquista", x=pulsanti.x, y=pulsanti.y+(pulsanti.contentHeight-100)/3+50, font="Arial", fontSize=25, align="center"})
    elseif(sportStatus[nome] == 1) then
      pulsanti.p3:addEventListener("tap", function(event) spendi(event, nome) playAudio(event, "upgrade") I.hide(self, nil) end)
      pulsanti.p3.text = display.newText({text="Migliora", x=pulsanti.x, y=pulsanti.y+(pulsanti.contentHeight-100)/3+50, font="Arial", fontSize=25, align="center"})
    elseif(sportStatus[nome] == 2) then
      if(entrataPassivaDisponibile) then
        pulsanti.p3:addEventListener("tap", function(event) guadagna(event, nome) playAudio(event, "cash") I.hide(self, nil) end)
      end
      pulsanti.p3.text = display.newText({text=informazioniSport.entrataPassiva, x=pulsanti.x, y=pulsanti.y+(pulsanti.contentHeight-100)/3+50, font="Arial", fontSize=25, align="center"})
    end
    informazioniPalestraGroup:insert(pulsanti.p3.text)
    if(sportStatus[nome] == 2) then
      pulsanti.p3.text.immagineSoldi = display.newImageRect("src/img/game extra/soldi.png", 64, 64)
      pulsanti.p3.text.immagineSoldi.xScale = 0.4
      pulsanti.p3.text.immagineSoldi.yScale = 0.4
      pulsanti.p3.text.immagineSoldi.x = pulsanti.p3.text.x-pulsanti.p3.text.contentWidth/2-pulsanti.p3.text.immagineSoldi.contentWidth
      pulsanti.p3.text.immagineSoldi.y = pulsanti.p3.text.y
      informazioniPalestraGroup:insert(pulsanti.p3.text.immagineSoldi)
    end
  end

end

return I
