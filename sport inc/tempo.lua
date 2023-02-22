-----------------------------------------------------------------------------------------
--
-- tempo
--
-----------------------------------------------------------------------------------------

-- tempo

-- VARIABILI

local T = {}

-- LETTURA/SCRITTURA TEMPO

-- lettura del tempo
function T.readTime(self)
  local atletica = {}
  local basket = {}
  local calcio = {}
  local pallavolo = {}
  local tennis = {}
  local motorsport = {}

  local file, errorString = io.open(system.pathForFile("time.txt", system.DocumentsDirectory), "r")

  if(not file) then
    local now = os.date("*t")
    local hour = now.hour
    local min = now.min

    atletica.hour = hour
    atletica.min = min
    basket.hour = hour
    basket.min = min
    calcio.hour = hour
    calcio.min = min
    pallavolo.hour = hour
    pallavolo.min = min
    tennis.hour = hour
    tennis.min = min
    motorsport.hour = hour
    motorsport.min = min
  else
    atletica.hour = file:read("*n")
    atletica.min = file:read("*n")
    basket.hour = file:read("*n")
    basket.min = file:read("*n")
    calcio.hour = file:read("*n")
    calcio.min = file:read("*n")
    pallavolo.hour = file:read("*n")
    pallavolo.min = file:read("*n")
    tennis.hour = file:read("*n")
    tennis.min = file:read("*n")
    motorsport.hour = file:read("*n")
    motorsport.min = file:read("*n")

    io.close(file)
  end

  file = nil
  return atletica, basket, calcio, pallavolo, tennis, motorsport
end

-- scrittura del tempo
function T.writeTime(self, atletica, basket, calcio, pallavolo, tennis, motorsport)
  local file, errorString = io.open(system.pathForFile("time.txt", system.DocumentsDirectory), "w")

  if(not file) then
    print("File error: " .. errorString)
  else
    file:write(atletica.hour .. "\n")
    file:write(atletica.min .. "\n")
    file:write(basket.hour .. "\n")
    file:write(basket.min .. "\n")
    file:write(calcio.hour .. "\n")
    file:write(calcio.min .. "\n")
    file:write(pallavolo.hour .. "\n")
    file:write(pallavolo.min .. "\n")
    file:write(tennis.hour .. "\n")
    file:write(tennis.min .. "\n")
    file:write(motorsport.hour .. "\n")
    file:write(motorsport.min .. "\n")

    io.close(file)
  end

  file = nil
end

return T
