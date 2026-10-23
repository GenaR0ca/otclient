-- Mubia Online: MU Helper (caza automática, como en MU Online).
-- El cliente elige a qué monstruo atacar y camina hacia él. El servidor (opcode 86) lanza las
-- habilidades, toma pociones, usa Heal y recoge los items (data/libs/systems/mubia_helper.lua).
-- Inicio (Home) prende y apaga el Helper; H abre la ventana de configuración.
local OPCODE = 86
local THINK_INTERVAL = 250
local STUCK_TIME = 8000 -- si el monstruo no pierde vida en este tiempo, se busca otro
local IGNORE_TIME = 15000 -- y ese monstruo se ignora por un rato

local MODES = {
    { text = 'Siempre', data = 'always' },
    { text = 'Cada X seg.', data = 'timer' },
    { text = 'Con X monstr.', data = 'count' },
}

local DEFAULT_CONFIG = {
    range = 4,
    chase = true,
    returnHome = true,
    basic = '',
    s1 = '', s1mode = 'always', s1val = 3,
    s2 = '', s2mode = 'always', s2val = 3,
    buff1 = '', buff2 = '', buff3 = '',
    hp = 50, mp = 30, heal = 0,
    all = false, jewel = true, exc = true, gear = false,
    prange = 3,
    extra = '',
}

local window = nil
local button = nil
local spells = {}
local config = nil
local helperOn = false
local thinkEvent = nil
local startPosition = nil
local savedChaseMode = nil
local ignored = {} -- id de criatura -> hasta cuándo se ignora
local targetWatch = { id = nil, health = nil, since = 0 }

local function send(text)
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedOpcode(OPCODE, text)
    end
end

local function settingsKey()
    return 'mubia_helper_' .. (g_game.getCharacterName() or ''):gsub('%W', '_')
end

local function loadConfig()
    config = {}
    local stored = g_settings.getNode(settingsKey()) or {}
    -- lo guardado vuelve como texto: se convierte al tipo de cada valor
    for key, default in pairs(DEFAULT_CONFIG) do
        local value = stored[key]
        if type(default) == 'number' then
            value = tonumber(value) or default
        elseif type(default) == 'boolean' then
            if value == nil then
                value = default
            else
                value = value == true or value == 'true'
            end
        else
            value = value ~= nil and tostring(value) or default
        end
        config[key] = value
    end
end

local function saveConfig()
    g_settings.setNode(settingsKey(), config)
    g_settings.save()
end

-- La configuración viaja al servidor como "clave=valor;clave=valor"
local function configText()
    local function flag(value)
        return value and '1' or '0'
    end
    local extra = (config.extra or ''):gsub('[;=|]', '')
    local parts = {
        'basic=' .. config.basic,
        's1=' .. config.s1, 's1mode=' .. config.s1mode, 's1val=' .. config.s1val,
        's2=' .. config.s2, 's2mode=' .. config.s2mode, 's2val=' .. config.s2val,
        'buffs=' .. table.concat({ config.buff1, config.buff2, config.buff3 }, ','),
        'hp=' .. config.hp, 'mp=' .. config.mp, 'heal=' .. config.heal,
        'all=' .. flag(config.all), 'jewel=' .. flag(config.jewel), 'exc=' .. flag(config.exc), 'gear=' .. flag(config.gear),
        'prange=' .. config.prange,
        'extra=' .. extra,
    }
    return table.concat(parts, ';')
end

local function distance(a, b)
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

-- ---------------------------------------------------------------------------
-- Ventana
-- ---------------------------------------------------------------------------

local function fillSkillBox(box, kinds, selected)
    box:clearOptions()
    box:addOption('(ninguna)', '')
    for _, spell in ipairs(spells) do
        if kinds[spell.kind] then
            box:addOption(spell.name, spell.key)
        end
    end
    box:setCurrentOptionByData(selected or '', true)
    if not box:getCurrentOption() or (box:getCurrentOption().data or '') ~= (selected or '') then
        box:setCurrentOptionByData('', true)
    end
end

local function updateStatus()
    if not window then
        return
    end
    local status = window:getChildById('statusLabel')
    if helperOn then
        status:setText('MU Helper: PRENDIDO')
        status:setColor('#60ff60')
        window:getChildById('startButton'):setText('Detener (Inicio)')
    else
        status:setText('MU Helper: apagado')
        status:setColor('#ff6060')
        window:getChildById('startButton'):setText('Iniciar (Inicio)')
    end
    if button then
        button:setOn(helperOn)
    end
end

local function fillWindow()
    if not window or not config then
        return
    end
    local attack = { attack = true }
    local buffs = { buff = true, summon = true, recovery = true }
    fillSkillBox(window:getChildById('basicSkill'), attack, config.basic)
    fillSkillBox(window:getChildById('skill1'), attack, config.s1)
    fillSkillBox(window:getChildById('skill2'), attack, config.s2)
    for i = 1, 3 do
        fillSkillBox(window:getChildById('buff' .. i), buffs, config['buff' .. i])
    end
    for i = 1, 2 do
        local box = window:getChildById('skill' .. i .. 'Mode')
        box:setCurrentOptionByData(config['s' .. i .. 'mode'], true)
        window:getChildById('skill' .. i .. 'Value'):setValue(config['s' .. i .. 'val'], true)
    end
    window:getChildById('huntRange'):setValue(config.range, true)
    window:getChildById('chase'):setChecked(config.chase)
    window:getChildById('returnHome'):setChecked(config.returnHome)
    window:getChildById('hpPotion'):setValue(config.hp, true)
    window:getChildById('mpPotion'):setValue(config.mp, true)
    window:getChildById('healPercent'):setValue(config.heal, true)
    window:getChildById('pickAll'):setChecked(config.all)
    window:getChildById('pickJewels'):setChecked(config.jewel)
    window:getChildById('pickExcellent'):setChecked(config.exc)
    window:getChildById('pickGear'):setChecked(config.gear)
    window:getChildById('pickRange'):setValue(config.prange, true)
    window:getChildById('extraNames'):setText(config.extra or '')
    updateStatus()
end

local function readWindow()
    if not window or not config then
        return
    end
    local function selected(id)
        local option = window:getChildById(id):getCurrentOption()
        return option and option.data or ''
    end
    config.basic = selected('basicSkill')
    config.s1 = selected('skill1')
    config.s2 = selected('skill2')
    config.s1mode = selected('skill1Mode')
    config.s2mode = selected('skill2Mode')
    config.s1val = window:getChildById('skill1Value'):getValue()
    config.s2val = window:getChildById('skill2Value'):getValue()
    config.buff1, config.buff2, config.buff3 = selected('buff1'), selected('buff2'), selected('buff3')
    config.range = window:getChildById('huntRange'):getValue()
    config.chase = window:getChildById('chase'):isChecked()
    config.returnHome = window:getChildById('returnHome'):isChecked()
    config.hp = window:getChildById('hpPotion'):getValue()
    config.mp = window:getChildById('mpPotion'):getValue()
    config.heal = window:getChildById('healPercent'):getValue()
    config.all = window:getChildById('pickAll'):isChecked()
    config.jewel = window:getChildById('pickJewels'):isChecked()
    config.exc = window:getChildById('pickExcellent'):isChecked()
    config.gear = window:getChildById('pickGear'):isChecked()
    config.prange = window:getChildById('pickRange'):getValue()
    config.extra = window:getChildById('extraNames'):getText()
end

function saveFromWindow()
    readWindow()
    saveConfig()
    if helperOn then
        send('start|' .. configText()) -- el servidor actualiza la configuración sin volver a cobrar
    else
        modules.game_textmessage.displayStatusMessage('MU Helper: configuraci\243n guardada.')
    end
end

function toggleWindow()
    if not window then
        return
    end
    if window:isVisible() then
        window:hide()
    else
        if not config then
            loadConfig()
        end
        fillWindow()
        send('spells')
        window:show()
        window:raise()
        window:focus()
    end
end

-- ---------------------------------------------------------------------------
-- Caza: elegir monstruo, atacarlo y volver al lugar de inicio
-- ---------------------------------------------------------------------------

local function isHuntable(creature)
    return creature and creature:isMonster() and creature:getType() == CreatureTypeMonster and not creature:isDead() and creature:getHealthPercent() > 0
end

local function anchorPosition(player)
    if config.returnHome and startPosition then
        return startPosition
    end
    return player:getPosition()
end

local function findTarget(player)
    local position = player:getPosition()
    local anchor = anchorPosition(player)
    local now = g_clock.millis()
    local best, bestSteps
    for _, creature in ipairs(g_map.getSpectatorsInRange(anchor, false, config.range, config.range)) do
        local creaturePosition = creature:getPosition()
        if isHuntable(creature) and creaturePosition.z == position.z and (ignored[creature:getId()] or 0) < now and distance(anchor, creaturePosition) <= config.range then
            local steps
            if distance(position, creaturePosition) <= 1 then
                steps = 0
            else
                local path, result = g_map.findPath(position, creaturePosition, 100, PathFindFlags.AllowCreatures)
                if result == PathFindResults.Ok then
                    steps = #path
                end
            end
            if steps and (not bestSteps or steps < bestSteps) then
                best, bestSteps = creature, steps
            end
        end
    end
    return best
end

local function think()
    thinkEvent = nil
    if not helperOn or not g_game.isOnline() then
        return
    end
    thinkEvent = scheduleEvent(think, THINK_INTERVAL)

    local player = g_game.getLocalPlayer()
    if not player or player:isDead() then
        return
    end
    local now = g_clock.millis()
    local target = g_game.getAttackingCreature()

    if target and isHuntable(target) then
        -- ¿se quedó trabado? (no le llega ni le baja la vida)
        if targetWatch.id ~= target:getId() or targetWatch.health ~= target:getHealthPercent() then
            targetWatch.id, targetWatch.health, targetWatch.since = target:getId(), target:getHealthPercent(), now
        elseif now - targetWatch.since > STUCK_TIME then
            ignored[target:getId()] = now + IGNORE_TIME
            g_game.cancelAttack()
        end
        return
    end

    local nextTarget = findTarget(player)
    if nextTarget then
        targetWatch.id, targetWatch.health, targetWatch.since = nextTarget:getId(), nextTarget:getHealthPercent(), now
        g_game.attack(nextTarget)
        return
    end

    -- nada que cazar: volver al lugar donde se prendió el Helper
    if config.returnHome and startPosition and distance(player:getPosition(), startPosition) > 0 and not player:isAutoWalking() and not player:isWalking() then
        player:autoWalk(startPosition)
    end
end

local function setHelperOn(on)
    if helperOn == on then
        updateStatus()
        return
    end
    helperOn = on
    if on then
        local player = g_game.getLocalPlayer()
        startPosition = player and player:getPosition() or nil
        ignored = {}
        savedChaseMode = g_game.getChaseMode()
        if config.chase then
            g_game.setChaseMode(ChaseOpponent)
        end
        if not thinkEvent then
            thinkEvent = scheduleEvent(think, THINK_INTERVAL)
        end
    else
        if thinkEvent then
            removeEvent(thinkEvent)
            thinkEvent = nil
        end
        if savedChaseMode ~= nil and g_game.isOnline() then
            g_game.setChaseMode(savedChaseMode)
        end
        savedChaseMode = nil
        startPosition = nil
    end
    updateStatus()
end

function toggleHelper()
    if not g_game.isOnline() then
        return
    end
    if not config then
        loadConfig()
    end
    if helperOn then
        send('stop')
        setHelperOn(false)
    else
        if window and window:isVisible() then
            readWindow()
            saveConfig()
        end
        send('start|' .. configText())
    end
end

-- Respuestas del servidor: lista de habilidades, costo y si el Helper quedó prendido
local function onHelper(protocol, opcode, data)
    if type(data) ~= 'table' then
        return
    end
    if data.spells then
        spells = data.spells
        if window and window:isVisible() then
            if not config then
                loadConfig()
            end
            fillWindow()
        end
    end
    if data.cost and window then
        window:getChildById('costLabel'):setText(string.format('Prenderlo cuesta %d zen (nivel x 20).', data.cost))
    end
    if data.on ~= nil then
        setHelperOn(data.on == true)
    end
    if data.reason and data.reason ~= '' then
        modules.game_textmessage.displayFailureMessage(data.reason)
    end
end

local function onGameStart()
    config = nil
    spells = {}
end

local function onGameEnd()
    setHelperOn(false)
    if window then
        window:hide()
    end
end

local function setupTexts()
    local texts = {
        huntSection = 'Caza',
        rangeLabel = 'Rango de caza:',
        chase = 'Perseguir al monstruo',
        returnHome = 'Volver al lugar donde lo prend\237',
        skillSection = 'Habilidades',
        basicLabel = 'Habilidad b\225sica:',
        skill1Label = 'Habilidad 1:',
        skill2Label = 'Habilidad 2:',
        buffLabel = 'Buffs:',
        healSection = 'Curaci\243n',
        hpLabel = 'Poci\243n de vida si baja de %:',
        mpLabel = 'Poci\243n de mana si baja de %:',
        healLabel = 'Heal (elfa) si baja de %:',
        pickSection = 'Recoger items',
        pickAll = 'Todos los items',
        pickJewels = 'Joyas (Bless, Soul, Life, Chaos...)',
        pickExcellent = 'Items Excellent',
        pickGear = 'Sets, armas y escudos de MU',
        pickRangeLabel = 'Distancia para recoger:',
        extraLabel = 'Items extra por nombre (separados por coma):',
        zenLabel = 'El zen se junta solo. 0% = no usar.',
        saveButton = 'Guardar',
    }
    for id, text in pairs(texts) do
        window:getChildById(id):setText(text)
    end
    for i = 1, 2 do
        local box = window:getChildById('skill' .. i .. 'Mode')
        for _, mode in ipairs(MODES) do
            box:addOption(mode.text, mode.data)
        end
    end
end

function init()
    window = g_ui.displayUI('mubia_helper')
    window:hide()
    setupTexts()
    updateStatus()

    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onHelper)
    button = modules.client_topmenu.addRightGameToggleButton('mubiaHelperButton', tr('MU Helper') .. ' (H)', '/images/topbuttons/battle', toggleWindow)

    Keybind.new('Windows', 'Mubia: ventana del MU Helper', { [CHAT_MODE.ON] = 'Ctrl+Shift+H', [CHAT_MODE.OFF] = 'H' }, '')
    Keybind.bind('Windows', 'Mubia: ventana del MU Helper', {
        {
            type = KEY_DOWN,
            callback = toggleWindow,
        }
    })
    Keybind.new('Windows', 'Mubia: prender/apagar MU Helper', { [CHAT_MODE.ON] = 'Ctrl+Home', [CHAT_MODE.OFF] = 'Home' }, '')
    Keybind.bind('Windows', 'Mubia: prender/apagar MU Helper', {
        {
            type = KEY_DOWN,
            callback = toggleHelper,
        }
    })
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
end

function terminate()
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    setHelperOn(false)
    Keybind.delete('Windows', 'Mubia: ventana del MU Helper')
    Keybind.delete('Windows', 'Mubia: prender/apagar MU Helper')
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
