-----------------------------------------------------------------------------------------
--
-- introduzioni
--
-----------------------------------------------------------------------------------------

-- introduzioni

-- VARIABILI

local I = {}

local introduzioneGroup

local bg
local close

local andrea
local titolo
local gianluca
local testo
local video

local timerVideo

-- CARICAMENTO DATI INTRODUZIONI

-- lettura del file introduzioni
local function readData(nome)
  local informazioni = {}
  informazioni.gioco = {}
  informazioni.minigioco = {}
  informazioni.atletica = {}
  informazioni.basket = {}
  informazioni.calcio = {}
  informazioni.pallavolo = {}
  informazioni.tennis = {}
  informazioni.motorsport = {}
  informazioni.fine = {}

  local file, errorString = io.open(system.pathForFile("src/text/introduzioni_formattato.txt", system.ResourceDirectory), "r")

  if(not file) then
    print("Errore: " .. errorString)
  else
    informazioni.gioco.nome = file:read("*l")
    informazioni.gioco.andrea = file:read("*l")
    informazioni.gioco.titolo = file:read("*l")
    informazioni.gioco.gianluca = file:read("*l")
    informazioni.gioco.testo = file:read("*l")
    informazioni.gioco.video = file:read("*l")

    informazioni.minigioco.nome = file:read("*l")
    informazioni.minigioco.andrea = file:read("*l")
    informazioni.minigioco.titolo = file:read("*l")
    informazioni.minigioco.gianluca = file:read("*l")
    informazioni.minigioco.testo = file:read("*l")
    informazioni.minigioco.video = file:read("*l")

    informazioni.atletica.nome = file:read("*l")
    informazioni.atletica.andrea = file:read("*l")
    informazioni.atletica.titolo = file:read("*l")
    informazioni.atletica.gianluca = file:read("*l")
    informazioni.atletica.testo = file:read("*l")
    informazioni.atletica.video = file:read("*l")

    informazioni.basket.nome = file:read("*l")
    informazioni.basket.andrea = file:read("*l")
    informazioni.basket.titolo = file:read("*l")
    informazioni.basket.gianluca = file:read("*l")
    informazioni.basket.testo = file:read("*l")
    informazioni.basket.video = file:read("*l")

    informazioni.calcio.nome = file:read("*l")
    informazioni.calcio.andrea = file:read("*l")
    informazioni.calcio.titolo = file:read("*l")
    informazioni.calcio.gianluca = file:read("*l")
    informazioni.calcio.testo = file:read("*l")
    informazioni.calcio.video = file:read("*l")

    informazioni.pallavolo.nome = file:read("*l")
    informazioni.pallavolo.andrea = file:read("*l")
    informazioni.pallavolo.titolo = file:read("*l")
    informazioni.pallavolo.gianluca = file:read("*l")
    informazioni.pallavolo.testo = file:read("*l")
    informazioni.pallavolo.video = file:read("*l")

    informazioni.tennis.nome = file:read("*l")
    informazioni.tennis.andrea = file:read("*l")
    informazioni.tennis.titolo = file:read("*l")
    informazioni.tennis.gianluca = file:read("*l")
    informazioni.tennis.testo = file:read("*l")
    informazioni.tennis.video = file:read("*l")

    informazioni.motorsport.nome = file:read("*l")
    informazioni.motorsport.andrea = file:read("*l")
    informazioni.motorsport.titolo = file:read("*l")
    informazioni.motorsport.gianluca = file:read("*l")
    informazioni.motorsport.testo = file:read("*l")
    informazioni.motorsport.video = file:read("*l")

    informazioni.fine.nome = file:read("*l")
    informazioni.fine.andrea = file:read("*l")
    informazioni.fine.titolo = file:read("*l")
    informazioni.fine.gianluca = file:read("*l")
    informazioni.fine.testo = file:read("*l")
    informazioni.fine.video = file:read("*l")

    io.close(file)
  end

  file = nil

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
  elseif(nome == "fine") then
    return informazioni.fine
  end

  return nil
end

-- VIDEO LOOP

-- manda in loop il video
local function videoLoop()
  video:seek(0)
  video:play()
  timerVideo = timer.performWithDelay(6000, videoLoop, 1)
end

-- ELIMINAZIONE INTRODUZIONE

-- chiusura della schermata
function I.hide(self, event, nome)
  display.remove(introduzioneGroup)

  if(close) then
    close:removeEventListener("tap", I.hide)
    schermata = false
  end

  if(video) then
    video:pause()
    timer.cancel(timerVideo)
  end

  close = nil
  andrea = nil
  gianluca = nil
  video = nil
  timerVideo = nil

  if(not (nome == false or nome == "gioco" or nome == "minigioco" or nome == "fine")) then
    informazioniPalestra:show(nome)
  end
end

-- INTRODUZIONE

-- apertura della schermata
function I.show(self, nome)
  I.hide(self, nil, false)
  schermata = true
  introduzioneGroup = display.newGroup()
  local informazioniSport = readData(nome)

  -- background e x per chiudere
  bg = display.newRoundedRect(display.contentCenterX, display.contentCenterY, display.contentWidth-150, display.contentHeight-150, 50)
  bg:setFillColor(0, 0, 0, 0.8)
  introduzioneGroup:insert(bg)
  close = display.newImageRect("src/img/game extra/cross.png", 64, 64)
  close.xScale = 0.5
  close.yScale = 0.5
  close.x = bg.x+bg.contentWidth/2-32
  close.y = bg.y-bg.contentHeight/2+32
  introduzioneGroup:insert(close)
  close:addEventListener("tap", function(event) I.hide(self, event, nome) end)

  -- altri elementi (informazioni dell'introduzione)
  -- ANDREA
  andrea = display.newImageRect(informazioniSport.andrea, 64, 64)
  andrea.xScale = 1.5
  andrea.yScale = 1.5
  andrea.x = bg.x-bg.contentWidth/2+98
  andrea.y = bg.y-bg.contentHeight/2+98
  introduzioneGroup:insert(andrea)
  -- TITOLO
  titolo = display.newText({text=informazioniSport.titolo, x=display.contentCenterX, y=bg.y-bg.contentHeight/2+98, width=bg.contentWidth-392, height=96, font="Arial", fontSize=60, align="center"})
  introduzioneGroup:insert(titolo)
  -- GIANLUCA
  gianluca = display.newImageRect(informazioniSport.gianluca, 64, 64)
  gianluca.xScale = 1.5
  gianluca.yScale = 1.5
  gianluca.x = bg.x+bg.contentWidth/2-98
  gianluca.y = bg.y-bg.contentHeight/2+98
  introduzioneGroup:insert(gianluca)
  -- TESTO
  local informazioniTesto, dummy = string.gsub(informazioniSport.testo, "\\n", "\n")
  testo = display.newText({text=informazioniTesto, x=bg.x-bg.contentWidth/2+(bg.contentWidth/2-75)/2+50, y=bg.y+(bg.contentHeight-246)/2-89, width=bg.contentWidth/2-75, height=bg.contentHeight-246, font="Arial", fontSize=25})
  introduzioneGroup:insert(testo)
  -- VIDEO
  video = native.newVideo(bg.x+bg.contentWidth/2-(bg.contentWidth/2-75)/2-50, bg.y+(bg.contentHeight-246)/2-89, bg.contentWidth/2-75, bg.contentHeight-246)
  video:load(informazioniSport.video)
  videoLoop()
  introduzioneGroup:insert(video)

end

return I
