-----------------------------------------------------------------------------------------
--
-- salvataggio
--
-----------------------------------------------------------------------------------------

-- salvataggio

-- VARIABILI

local S = {}

-- LETTURA/SCRITTURA SALVATAGGIO

-- lettura del salvataggio
function S.readSave(self)
  local soldi
  local atletica
  local basket
  local calcio
  local pallavolo
  local tennis
  local motorsport
  local primaVolta

  local file, errorString = io.open(system.pathForFile("save.txt", system.DocumentsDirectory), "r")

  if(not file) then
    if(debug) then
      soldi = 100000
    else
      soldi = 100
    end
    atletica = 0
    basket = 0
    calcio = 0
    pallavolo = 0
    tennis = 0
    motorsport = 0
    primaVolta = true
  else
    soldi = file:read("*n")
    atletica = file:read("*n")
    basket = file:read("*n")
    calcio = file:read("*n")
    pallavolo = file:read("*n")
    tennis = file:read("*n")
    motorsport = file:read("*n")
    primaVolta = false

    io.close(file)
  end

  file = nil
  return soldi, atletica, basket, calcio, pallavolo, tennis, motorsport, primaVolta
end

-- scrittura del salvataggio
function S.writeSave(self,soldi, atletica, basket, calcio, pallavolo, tennis, motorsport)
  local file, errorString = io.open(system.pathForFile("save.txt", system.DocumentsDirectory), "w")

  if(not file) then
    print("File error: " .. errorString)
  else
    file:write(soldi .. "\n")
    file:write(atletica .. "\n")
    file:write(basket .. "\n")
    file:write(calcio .. "\n")
    file:write(pallavolo .. "\n")
    file:write(tennis .. "\n")
    file:write(motorsport .. "\n")

    io.close(file)
  end

  file = nil
end

return S
