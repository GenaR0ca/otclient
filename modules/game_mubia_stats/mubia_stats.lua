-- Mubia Online: ventana de stats (equivalente a la tecla C de MU)
local OPCODE = 80
local STATS = {
    { id = 'str', name = 'Strength' },
    { id = 'agi', name = 'Agility' },
    { id = 'vit', name = 'Vitality' },
    { id = 'ene', name = 'Energy' },
    { id = 'cmd', name = 'Command' },
}
local WINDOW_HEIGHT = 350
local COMMAND_ROW_HEIGHT = 26

local window = nil
local button = nil

local function request(text)
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedOpcode(OPCODE, text)
    end
end

-- La fila de Command solo ocupa lugar en la clase que la usa (Dark Lord)
local function showCommandRow(show)
    local row = window:getChildById('cmdRow')
    row:setHeight(show and 22 or 0)
    row:setMarginTop(show and 4 or 0)
    for _, child in ipairs(row:getChildren()) do
        child:setVisible(show)
    end
    window:setHeight(WINDOW_HEIGHT + (show and COMMAND_ROW_HEIGHT or 0))
end

local function update(data)
    if not window or type(data) ~= 'table' or data.action ~= 'stats' then
        return
    end

    showCommandRow(data.cmd ~= nil)
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
    window:getChildById('damageLabel'):setText(string.format('Da\241o f\237sico: %d - %d', data.minDamage or 0, data.maxDamage or 0))
    if (data.maxMagic or 0) > 0 then
        window:getChildById('magicLabel'):setText(string.format('Da\241o m\225gico: %d - %d', data.minMagic or 0, data.maxMagic or 0))
    else
        window:getChildById('magicLabel'):setText('Da\241o m\225gico: -')
    end
    window:getChildById('defenseLabel'):setText(string.format('Defensa: %d', data.defense or 0))
    window:getChildById('speedLabel'):setText(string.format('Vel. ataque: %.2fs   Vel. magia: %.2fs', (data.attackSpeed or 0) / 1000, (data.castSpeed or 0) / 1000))
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
    showCommandRow(false)

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
