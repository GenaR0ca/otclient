-- Mubia Online: menú de ciudades (equivalente a la tecla M de MU)
local OPCODE = 81
local WINDOW_BASE_HEIGHT = 110

local window = nil
local button = nil

local function request(text)
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedOpcode(OPCODE, text)
    end
end

local function update(data)
    if not window or type(data) ~= 'table' or data.action ~= 'list' then
        return
    end

    local panel = window:getChildById('destinations')
    panel:destroyChildren()
    local level = g_game.getLocalPlayer() and g_game.getLocalPlayer():getLevel() or 0
    for _, dest in ipairs(data.destinations or {}) do
        local widget = g_ui.createWidget('WarpButton', panel)
        local price = (dest.zen or 0) > 0 and string.format('%d zen', dest.zen) or 'gratis'
        local text = string.format('%s  (%s)', dest.name, price)
        if (dest.level or 0) > 0 then
            text = string.format('%s  (nivel %d, %s)', dest.name, dest.level, price)
        end
        widget:setText(text)
        widget:setEnabled(level >= (dest.level or 0))
        widget.onClick = function()
            request('go:' .. dest.id)
            toggle()
        end
    end
    -- dos columnas de botones
    window:setHeight(WINDOW_BASE_HEIGHT + math.ceil(#panel:getChildren() / 2) * 28)
end

local function onWarp(protocol, opcode, data)
    update(data)
end

function toggle()
    if not window then
        return
    end
    if window:isVisible() then
        window:hide()
        if button then
            button:setOn(false)
        end
    else
        request('list')
        window:show()
        window:raise()
        window:focus()
        if button then
            button:setOn(true)
        end
    end
end

local function onGameEnd()
    if window then
        window:hide()
    end
    if button then
        button:setOn(false)
    end
end

function init()
    window = g_ui.displayUI('mubia_warp')
    window:hide()
    window:getChildById('titleLabel'):setText('\191A d\243nde quieres viajar?')

    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onWarp)
    button = modules.client_topmenu.addRightGameToggleButton('mubiaWarpButton', tr('Mapa') .. ' (M)', '/images/topbuttons/minimap', toggle)
    Keybind.new('Windows', 'Mubia: mapa de ciudades', { [CHAT_MODE.ON] = 'Ctrl+M', [CHAT_MODE.OFF] = 'M' }, '')
    Keybind.bind('Windows', 'Mubia: mapa de ciudades', {
        {
            type = KEY_DOWN,
            callback = toggle,
        }
    })
    connect(g_game, { onGameEnd = onGameEnd })
end

function terminate()
    disconnect(g_game, { onGameEnd = onGameEnd })
    Keybind.delete('Windows', 'Mubia: mapa de ciudades')
    ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)
    if button then
        button:destroy()
        button = nil
    end
    if window then
        window:destroy()
        window = nil
    end
end
