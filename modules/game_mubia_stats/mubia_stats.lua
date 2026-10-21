-- Mubia Online: ventana de stats (equivalente a la tecla C de MU)
local OPCODE = 80
local STATS = {
    { id = 'str', name = 'Strength' },
    { id = 'agi', name = 'Agility' },
    { id = 'vit', name = 'Vitality' },
    { id = 'ene', name = 'Energy' },
}

local window = nil
local button = nil

local function request(text)
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedOpcode(OPCODE, text)
    end
end

local function update(data)
    if not window or type(data) ~= 'table' or data.action ~= 'stats' then
        return
    end

    window:getChildById('classLabel'):setText(data.class or '')
    window:getChildById('levelLabel'):setText(string.format('Nivel %d   Resets %d', data.level or 0, data.resets or 0))
    window:getChildById('pointsLabel'):setText(string.format('Puntos libres: %d', data.points or 0))
    for _, stat in ipairs(STATS) do
        local row = window:getChildById(stat.id .. 'Row')
        row:getChildById('value'):setText(tostring(data[stat.id] or 0))
        local hasPoints = (data.points or 0) > 0
        row:getChildById('add1'):setEnabled(hasPoints)
        row:getChildById('add10'):setEnabled((data.points or 0) >= 10)
    end
    window:getChildById('damageLabel'):setText(string.format('Da\241o: %d - %d', data.minDamage or 0, data.maxDamage or 0))
    window:getChildById('defenseLabel'):setText(string.format('Defensa: %d', data.defense or 0))
    window:getChildById('lifeLabel'):setText(string.format('Vida: %d   Mana: %d', data.maxHealth or 0, data.maxMana or 0))
end

local function onStats(protocol, opcode, data)
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
        request('get')
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
    window = g_ui.displayUI('mubia_stats')
    window:hide()

    for _, stat in ipairs(STATS) do
        local row = window:getChildById(stat.id .. 'Row')
        row:getChildById('name'):setText(stat.name)
        row:getChildById('add1').onClick = function()
            request('add:' .. stat.id .. ':1')
        end
        row:getChildById('add10').onClick = function()
            request('add:' .. stat.id .. ':10')
        end
    end

    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onStats)
    button = modules.client_topmenu.addRightGameToggleButton('mubiaStatsButton', tr('Personaje') .. ' (Ctrl+Shift+C)', '/images/topbuttons/skills', toggle)
    g_keyboard.bindKeyDown('Ctrl+Shift+C', toggle)
    connect(g_game, { onGameEnd = onGameEnd })
end

function terminate()
    disconnect(g_game, { onGameEnd = onGameEnd })
    g_keyboard.unbindKeyDown('Ctrl+Shift+C')
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
