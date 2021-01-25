addEvent('kills.import', true)

local guiGetScreenSize = guiGetScreenSize
local guiCreateWindow = guiCreateWindow
local guiWindowSetSizable = guiWindowSetSizable
local guiWindowSetMovable = guiWindowSetMovable
local guiSetVisible = guiSetVisible
local triggerLatentServerEvent = triggerLatentServerEvent

local sWidth, sHeight = guiGetScreenSize()
local panelW, panelH = 530, 280
local panelX, panelY = sWidth / 2 - panelW / 2, sHeight / 2 - panelH / 2

local pane = guiCreateWindow(panelX, panelY, panelW, panelH, 'Sunucu ismi - Katil Listesi', false)
if not pane then
  return false
end

guiWindowSetSizable(pane, false)
guiWindowSetMovable(pane, false)
guiSetVisible(pane, false)

local loadingText = guiCreateLabel(0, 0, panelW, panelH, 'Katil verileri yükleniyor.', false, pane)
if not loadingText then
  return false
end

local pointerCount = 0
local pointerTick = getTickCount()
addEventHandler('onClientPreRender', root, function()
    if getTickCount() - pointerTick > 1000 then
      guiSetText(loadingText, guiGetText(loadingText) .. '.')
      pointerCount = pointerCount + 1

      if pointerCount == 3 then
        guiSetText(loadingText, 'Katil verileri yükleniyor.')
        pointerCount = 0
      end
      pointerTick = getTickCount()
    end
  end
)

guiLabelSetVerticalAlign(loadingText, 'center')
guiLabelSetHorizontalAlign(loadingText, 'center')
guiLabelSetColor(loadingText, 240, 240, 240)
guiSetAlpha(loadingText, 0.8)
guiSetFont(loadingText, 'default-bold-small')

local killerList = guiCreateGridList(12, 28, panelW - 24, panelH - 39, false, pane)
if not killerList then
  return false
end

guiGridListAddColumn(killerList, 'Sıra', 0.2)
guiGridListAddColumn(killerList, 'Oyuncu Adı', 0.6)
guiGridListAddColumn(killerList, 'Öldürme', 0.15)
guiSetVisible(killerList, false)

local loadingSortedTable = false

addEventHandler('kills.import', localPlayer, function(sortedTable, clientKills)
    if loadingSortedTable then
      return false
    end

    loadingSortedTable = true

    guiGridListClear(killerList)
    guiSetVisible(loadingText, false)
    guiSetVisible(killerList, true)

    for i = 1, #sortedTable do
      guiGridListAddRow(killerList, i, sortedTable[i][2], sortedTable[i][1])
    end

    loadingSortedTable = false
  end
)

bindKey('F3', 'down', function()
    guiSetVisible(pane, not guiGetVisible(pane))
    showCursor(guiGetVisible(pane))

    if not guiGetVisible(pane) then
      guiSetVisible(loadingText, true)
      guiSetVisible(killerList, false)
      return
    end

    return triggerLatentServerEvent('kills.request.list', 5000, false, localPlayer)
  end
)