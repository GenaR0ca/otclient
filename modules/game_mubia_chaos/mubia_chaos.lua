-- Mubia Online: Chaos Machine (se abre al hablarle al Chaos Goblin, como en MU)
-- Arrastrá items de tu inventario a los casilleros. El servidor reconoce la receta y dice el % de éxito
-- y el costo en zen. Los items no se mueven: el cliente solo recuerda dónde están en tu inventario.
-- Click derecho sobre un casillero lo vacía.
local OPCODE = 83
local SLOT_COUNT = 32

local window = nil
local helpWindow = nil
local slots = {} -- [i] = { ref = 'c0:5:60303', id = 60303, count = 5 }
local recipesText = ''

local function send(text)
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedOpcode(OPCODE, text)
    end
end

local function refs()
    local list = {}
    for i = 1, SLOT_COUNT do
        if slots[i] then
            list[#list + 1] = slots[i].ref
        end
    end
    return table.concat(list, ';')
end

local function slotWidget(i)
    return window:getChildById('slots'):getChildById('slot' .. i)
end

local function setRecipe(text, ok)
    local label = window:getChildById('recipeLabel')
    label:setText(text or '')
    label:setColor(ok and '#80ff80' or '#c0c0c0')
    window:getChildById('mixButton'):setEnabled(ok and true or false)
end

local function setZen(zen)
    if zen then
        window:getChildById('zenLabel'):setText(string.format('Tu zen: %s', comma_value and comma_value(zen) or tostring(zen)))
    end
end

local function setResult(itemId, count, text, color)
    local panel = window:getChildById('resultPanel')
    local itemWidget = panel:getChildById('resultItem')
    if itemId and itemId > 0 then
        itemWidget:setItem(Item.create(itemId, count or 1))
    else
        itemWidget:setItem(nil)
    end
    local label = panel:getChildById('resultLabel')
    label:setText(text or '')
    label:setColor(color or '#ffffff')
end

local function preview()
    if not window then
        return
    end
    if refs() == '' then
        setRecipe('Arrastr\225 items de tu inventario a la m\225quina.', false)
        return
    end
    send('preview|' .. refs())
end

function clearSlots(update)
    slots = {}
    if not window then
        return
    end
    for i = 1, SLOT_COUNT do
        slotWidget(i):setItem(nil)
    end
    if update then
        setResult(nil, 0, '')
        preview()
    end
end

local function removeSlot(i)
    if slots[i] then
        slots[i] = nil
        slotWidget(i):setItem(nil)
        preview()
    end
end

-- Dónde está el item en el inventario: "c<contenedor>:<lugar>:<id>" o "e<slot>:<id>"
local function itemRef(item)
    local pos = item:getPosition()
    if not pos or pos.x ~= 65535 then
        return nil
    end
    if pos.y >= 64 then
        return string.format('c%d:%d:%d', pos.y - 64, pos.z, item:getId())
    end
    return string.format('e%d:%d', pos.y, item:getId())
end

local function onSlotDrop(self, widget, mousePos)
    local item = widget and widget.currentDragThing
    if not item or not item:isItem() then
        return false
    end
    local ref = itemRef(item)
    if not ref then
        modules.game_textmessage.displayFailureMessage('Solo pod\233s poner items de tu inventario.')
        return false
    end
    for i = 1, SLOT_COUNT do
        if slots[i] and slots[i].ref == ref then
            return false -- ya está en la máquina
        end
    end
    local index = self.slotIndex
    if slots[index] then
        index = nil
        for i = 1, SLOT_COUNT do
            if not slots[i] then
                index = i
                break
            end
        end
        if not index then
            return false
        end
    end
    slots[index] = { ref = ref, id = item:getId(), count = item:getCountOrSubType() }
    slotWidget(index):setItem(Item.create(item:getId(), item:getCountOrSubType()))
    setResult(nil, 0, '')
    preview()
    return true
end

local function onChaos(protocol, opcode, data)
    if not window or type(data) ~= 'table' then
        return
    end
    if data.action == 'open' then
        if data.recipes then
            recipesText = '- ' .. table.concat(data.recipes, '\n- ')
            if helpWindow then
                helpWindow:getChildById('helpLabel'):setText(recipesText)
            end
        end
        clearSlots(false)
        setResult(nil, 0, '')
        setRecipe('Arrastr\225 items de tu inventario a la m\225quina.', false)
        setZen(data.zen)
        window:show()
        window:raise()
        window:focus()
    elseif data.action == 'preview' then
        setRecipe(data.text, data.ok)
        setZen(data.zen)
    elseif data.action == 'result' then
        setZen(data.zen)
        if data.keep then
            setResult(nil, 0, data.text, '#ff8080')
            return
        end
        clearSlots(false)
        setRecipe('Arrastr\225 items de tu inventario a la m\225quina.', false)
        if data.success then
            setResult(data.item, data.count, data.text, '#80ff80')
        else
            setResult(nil, 0, data.text, '#ff6060')
        end
    end
end

function mix()
    if refs() ~= '' then
        window:getChildById('mixButton'):setEnabled(false)
        send('mix|' .. refs())
    end
end

function close()
    if window and window:isVisible() then
        window:hide()
        send('close')
    end
    if helpWindow then
        helpWindow:hide()
    end
    clearSlots(false)
end

function toggleHelp()
    if not helpWindow then
        return
    end
    if helpWindow:isVisible() then
        helpWindow:hide()
    else
        helpWindow:getChildById('helpLabel'):setText(recipesText)
        helpWindow:show()
        helpWindow:raise()
        helpWindow:focus()
    end
end

local function onGameEnd()
    if window then
        window:hide()
    end
    if helpWindow then
        helpWindow:hide()
    end
    clearSlots(false)
end

function init()
    window = g_ui.displayUI('mubia_chaos')
    window:hide()
    window:getChildById('titleLabel'):setText('Chaos Goblin: \191qu\233 vas a combinar?')
    local panel = window:getChildById('slots')
    for i = 1, SLOT_COUNT do
        local widget = g_ui.createWidget('ChaosSlot', panel)
        widget:setId('slot' .. i)
        widget.slotIndex = i
        widget.onDrop = onSlotDrop
        widget.onMouseRelease = function(self, mousePos, mouseButton)
            if mouseButton == MouseRightButton then
                removeSlot(self.slotIndex)
                return true
            end
            return false
        end
    end
    helpWindow = g_ui.displayUI('mubia_chaos_help')
    helpWindow:hide()

    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onChaos)
    connect(g_game, { onGameEnd = onGameEnd })
end

function terminate()
    disconnect(g_game, { onGameEnd = onGameEnd })
    ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)
    if helpWindow then
        helpWindow:destroy()
        helpWindow = nil
    end
    if window then
        window:destroy()
        window = nil
    end
end
