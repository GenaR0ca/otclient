-- Mubia Online: ventana de Sebina the Priest (mision de la segunda evolucion), opcode 91.
-- El servidor (data/scripts/mubia/sebina.lua) manda el texto de Sebina, el paso, el item que hay que
-- conseguir (con su dibujo, si ya lo tienes y donde cae) y lo que desbloquea la evolucion.
-- El boton manda "accept" (aceptar la mision) o "deliver" (entregar el item).
local OPCODE = 91

local window = nil
local currentAction = nil

function hide()
    if window then
        window:hide()
    end
end

function doAction()
    local protocol = g_game.getProtocolGame()
    if protocol and currentAction then
        protocol:sendExtendedOpcode(OPCODE, currentAction)
    end
end

-- Ajusta la altura de un recuadro a lo que tiene adentro
local function fitBox(box, minHeight)
    local bottom = box:getY()
    for _, child in ipairs(box:getChildren()) do
        if child:isVisible() then
            bottom = math.max(bottom, child:getY() + child:getHeight())
        end
    end
    box:setHeight(math.max(minHeight or 0, bottom - box:getY() + box:getPaddingBottom()))
end

local function layout()
    local talkBox = window:getChildById('talkBox')
    local itemBox = window:getChildById('itemBox')
    local rewardBox = window:getChildById('rewardBox')
    fitBox(talkBox, 40)
    if itemBox:isVisible() then
        fitBox(itemBox, 100)
    end
    if rewardBox:isVisible() then
        fitBox(rewardBox, 40)
    end
    local last = rewardBox:isVisible() and rewardBox or (itemBox:isVisible() and itemBox or talkBox)
    local height = last:getY() + last:getHeight() - window:getY() + 50
    window:setHeight(height)
end

local function open(data)
    window:setText(data.npc or 'Sebina the Priest')
    window:getChildById('stepLabel'):setText(data.stepLabel or '')
    local evolution = window:getChildById('evolutionLabel')
    evolution:setText(data.evolution and data.evolution ~= '' and ('> ' .. data.evolution) or '')

    window:getChildById('talkBox'):getChildById('talkText'):setText(data.text or '')

    local itemBox = window:getChildById('itemBox')
    local item = type(data.item) == 'table' and data.item or nil
    itemBox:setVisible(item ~= nil)
    if item then
        itemBox:getChildById('itemTitle'):setText(data.itemTitle or '')
        itemBox:getChildById('itemFrame'):getChildById('questItem'):setItemId(tonumber(item.id) or 0)
        itemBox:getChildById('itemName'):setText(item.name or '')
        local status = itemBox:getChildById('itemStatus')
        status:setText(item.status or '')
        status:setColor(item.have and '#60e060' or '#e08060')
        itemBox:getChildById('itemFrame'):setBorderColor(item.have and '#60e060' or '#c08040')
        itemBox:getChildById('itemWhere'):setText(item.where or '')
    end

    local rewardBox = window:getChildById('rewardBox')
    local rewards = type(data.rewards) == 'table' and data.rewards or {}
    rewardBox:setVisible(#rewards > 0)
    rewardBox:getChildById('rewardTitle'):setText(data.rewardTitle or '')
    local list = rewardBox:getChildById('rewardList')
    list:destroyChildren()
    for _, line in ipairs(rewards) do
        local label = g_ui.createWidget('SebinaReward', list)
        label:setText('- ' .. line)
    end

    local button = window:getChildById('actionButton')
    local action = type(data.button) == 'table' and data.button or nil
    currentAction = action and action.action or nil
    button:setVisible(action ~= nil)
    if action then
        button:setText(action.label or '')
        button:setEnabled(action.enabled == true)
    end

    window:show()
    window:raise()
    window:focus()
    -- las etiquetas calculan su alto al dibujarse: se acomoda la ventana un momento despues
    layout()
    scheduleEvent(function()
        if window and window:isVisible() then
            layout()
        end
    end, 50)
end

local function onMessage(protocol, opcode, data)
    if not window or type(data) ~= 'table' then
        return
    end
    if data.action == 'open' then
        open(data)
    elseif data.action == 'close' then
        hide()
    end
end

function init()
    window = g_ui.displayUI('mubia_sebina')
    window:hide()
    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onMessage)
    connect(g_game, { onGameEnd = hide })
end

function terminate()
    disconnect(g_game, { onGameEnd = hide })
    ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)
    if window then
        window:destroy()
        window = nil
    end
end
