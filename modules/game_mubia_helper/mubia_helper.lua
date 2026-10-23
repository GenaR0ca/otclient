-- Mubia Online: Mubia Helper (caza automática, como el MU Helper de MU Online).
-- El cliente elige a qué monstruo atacar y camina hacia él. El servidor (opcode 86) lanza las
-- habilidades, toma pociones, usa Heal, recoge los items y acepta o rechaza las parties
-- (data/libs/systems/mubia_helper.lua).
-- Inicio (Home) prende y apaga el Helper; H abre la ventana con sus 4 pestañas.
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
    -- Caster
    basic = '',
    s1 = '', s1mode = 'always', s1val = 3,
    s2 = '', s2mode = 'always', s2val = 3,
    buff1 = '', buff2 = '', buff3 = '',
    range = 4,
    returnHome = true,
    returnDelay = 3,
    chase = true,
    -- Healing
    hp = 50, mp = 30,
    healSelf = 0, healParty = 0,
    -- Loot
    lootRange = 3,
    lootAll = false,
    lootSelected = true,
    lootJewel = true, lootZen = true, lootGear = false, lootExc = true, lootScroll = true,
    lootOther = false, lootWords = '',
    -- Other Settings
    party = 'none',
}

local ATTACK_KINDS = { attack = true }
local BUFF_KINDS = { buff = true, summon = true, recovery = true }

local window = nil
local tabs = {}
local picker = nil
local button = nil
local spells = {}
local config = nil
local helperOn = false
local thinkEvent = nil
local startPosition = nil
local idleSince = nil
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
    local selected = config.lootSelected and not config.lootAll
    local words = (config.lootWords or ''):gsub('[;=|]', '')
    local parts = {
        'basic=' .. config.basic,
        's1=' .. config.s1, 's1mode=' .. config.s1mode, 's1val=' .. config.s1val,
        's2=' .. config.s2, 's2mode=' .. config.s2mode, 's2val=' .. config.s2val,
        'buffs=' .. table.concat({ config.buff1, config.buff2, config.buff3 }, ','),
        'hp=' .. config.hp, 'mp=' .. config.mp,
        'heal=' .. config.healSelf, 'hparty=' .. config.healParty,
        'all=' .. flag(config.lootAll),
        'jewel=' .. flag(selected and config.lootJewel),
        'zen=' .. flag(config.lootAll or (selected and config.lootZen)),
        'gear=' .. flag(selected and config.lootGear),
        'exc=' .. flag(selected and config.lootExc),
        'scroll=' .. flag(selected and config.lootScroll),
        'other=' .. flag(selected and config.lootOther),
        'prange=' .. config.lootRange,
        'extra=' .. words,
    }
    return table.concat(parts, ';')
end

local function sendPartyMode()
    if config then
        send('party|' .. config.party)
    end
end

local function distance(a, b)
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

local function findSpell(key)
    for _, spell in ipairs(spells) do
        if spell.key == key then
            return spell
        end
    end
    return nil
end

local function hasSpell(kind)
    for _, spell in ipairs(spells) do
        if spell.kind == kind then
            return true
        end
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Iconos de las habilidades (los mismos de la lista de magias del cliente)
-- ---------------------------------------------------------------------------

local function setSpellIcon(widget, spell)
    widget:setImageSource('')
    if not spell then
        return
    end
    local ok, info = pcall(Spells.getSpellByName, spell.name)
    if ok and info and info.clientId then
        widget:setImageSource(SpelllistSettings['Default'].iconFile)
        widget:setImageClip(Spells.getImageClip(info.clientId, 'Default'))
    end
end

local function showSlot(slot, key)
    local spell = findSpell(key)
    setSpellIcon(slot:getChildById('icon'), spell)
    slot:getChildById('name'):setText(spell and spell.name or '(ninguna)')
    slot:setTooltip(spell and spell.name or 'Click para elegir')
end

local function closePicker()
    if picker then
        picker:destroy()
        picker = nil
    end
end

-- Ventanita con las habilidades aprendidas (icono + nombre) para elegir una
local function openPicker(kinds, onChoose)
    closePicker()
    picker = g_ui.createWidget('HelperSpellPicker', rootWidget)
    picker.onDestroy = function()
        picker = nil
    end
    local list = picker:getChildById('list')
    local function addRow(spell)
        local row = g_ui.createWidget('HelperPickerRow', list)
        setSpellIcon(row:getChildById('icon'), spell)
        row:getChildById('name'):setText(spell and spell.name or '(ninguna)')
        row.onClick = function()
            onChoose(spell and spell.key or '')
            closePicker()
        end
    end
    addRow(nil)
    local count = 0
    for _, spell in ipairs(spells) do
        if kinds[spell.kind] then
            addRow(spell)
            count = count + 1
        end
    end
    if count == 0 then
        local label = g_ui.createWidget('Label', list)
        label:setText('Todav\237a no aprendiste ninguna.')
        label:setColor('#a0a0a0')
    end
    picker:show()
    picker:raise()
    picker:focus()
end

-- ---------------------------------------------------------------------------
-- Ventana
-- ---------------------------------------------------------------------------

-- Busca un widget en la ventana o en cualquiera de las pestañas (las que no se ven no están en la ventana)
local function get(id)
    if not window then
        return nil
    end
    local widget = window:recursiveGetChildById(id)
    if widget then
        return widget
    end
    for _, panel in pairs(tabs) do
        widget = panel:recursiveGetChildById(id)
        if widget then
            return widget
        end
    end
    return nil
end

local function updateStatus()
    if not window then
        return
    end
    local status = window:getChildById('statusLabel')
    if helperOn then
        status:setText('Mubia Helper: PRENDIDO')
        status:setColor('#60ff60')
        window:getChildById('startButton'):setText('Detener (Inicio)')
    else
        status:setText('Mubia Helper: apagado')
        status:setColor('#ff6060')
        window:getChildById('startButton'):setText('Iniciar (Inicio)')
    end
    if button then
        button:setOn(helperOn)
    end
end

local function updateLootChecks()
    local selected = get('lootSelected'):isChecked()
    for _, id in ipairs({ 'lootJewel', 'lootZen', 'lootGear', 'lootExc', 'lootScroll', 'lootOther' }) do
        get(id):setEnabled(selected)
    end
    get('lootWords'):setEnabled(selected and get('lootOther'):isChecked())
end

local function updateHealing()
    local canHeal = hasSpell('heal')
    for _, id in ipairs({ 'healSelf', 'healParty', 'healSelfLabel', 'healPartyLabel' }) do
        get(id):setEnabled(canHeal)
    end
    get('healNote'):setVisible(not canHeal)
end

local function fillWindow()
    if not window or not config then
        return
    end
    showSlot(get('basicSlot'), config.basic)
    for i = 1, 2 do
        local slot = get('skill' .. i .. 'Slot')
        showSlot(slot, config['s' .. i])
        slot:getChildById('mode'):setCurrentOptionByData(config['s' .. i .. 'mode'], true)
        slot:getChildById('value'):setValue(config['s' .. i .. 'val'], true)
    end
    for i = 1, 3 do
        showSlot(get('buff' .. i), config['buff' .. i])
    end
    get('range'):setValue(config.range, true)
    get('returnHome'):setChecked(config.returnHome)
    get('returnDelay'):setValue(config.returnDelay, true)
    get('chase'):setChecked(config.chase)

    get('hp'):setValue(config.hp, true)
    get('mp'):setValue(config.mp, true)
    get('healSelf'):setValue(config.healSelf, true)
    get('healParty'):setValue(config.healParty, true)
    updateHealing()

    get('lootRange'):setValue(config.lootRange, true)
    get('lootAll'):setChecked(config.lootAll)
    get('lootSelected'):setChecked(config.lootSelected and not config.lootAll)
    get('lootJewel'):setChecked(config.lootJewel)
    get('lootZen'):setChecked(config.lootZen)
    get('lootGear'):setChecked(config.lootGear)
    get('lootExc'):setChecked(config.lootExc)
    get('lootScroll'):setChecked(config.lootScroll)
    get('lootOther'):setChecked(config.lootOther)
    get('lootWords'):setText(config.lootWords or '')
    updateLootChecks()

    get('partyAccept'):setChecked(config.party == 'accept')
    get('partyReject'):setChecked(config.party == 'reject')
    updateStatus()
end

-- Lee todo lo que no se guarda al momento (números, casillas y texto)
local function readWindow()
    if not window or not config then
        return
    end
    for i = 1, 2 do
        local slot = get('skill' .. i .. 'Slot')
        local option = slot:getChildById('mode'):getCurrentOption()
        config['s' .. i .. 'mode'] = option and option.data or 'always'
        config['s' .. i .. 'val'] = slot:getChildById('value'):getValue()
    end
    config.range = get('range'):getValue()
    config.returnHome = get('returnHome'):isChecked()
    config.returnDelay = get('returnDelay'):getValue()
    config.chase = get('chase'):isChecked()
    config.hp = get('hp'):getValue()
    config.mp = get('mp'):getValue()
    config.healSelf = get('healSelf'):getValue()
    config.healParty = get('healParty'):getValue()
    config.lootRange = get('lootRange'):getValue()
    config.lootAll = get('lootAll'):isChecked()
    config.lootSelected = get('lootSelected'):isChecked()
    config.lootJewel = get('lootJewel'):isChecked()
    config.lootZen = get('lootZen'):isChecked()
    config.lootGear = get('lootGear'):isChecked()
    config.lootExc = get('lootExc'):isChecked()
    config.lootScroll = get('lootScroll'):isChecked()
    config.lootOther = get('lootOther'):isChecked()
    config.lootWords = get('lootWords'):getText()
    if get('partyAccept'):isChecked() then
        config.party = 'accept'
    elseif get('partyReject'):isChecked() then
        config.party = 'reject'
    else
        config.party = 'none'
    end
end

function saveFromWindow()
    readWindow()
    saveConfig()
    sendPartyMode()
    if helperOn then
        send('start|' .. configText()) -- el servidor actualiza la configuración sin volver a cobrar
    else
        modules.game_textmessage.displayStatusMessage('Mubia Helper: configuraci\243n guardada.')
    end
end

function toggleWindow()
    if not window then
        return
    end
    if window:isVisible() then
        closePicker()
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
        idleSince = nil
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
        idleSince = nil
        targetWatch.id, targetWatch.health, targetWatch.since = nextTarget:getId(), nextTarget:getHealthPercent(), now
        g_game.attack(nextTarget)
        return
    end

    -- nada que cazar: después de unos segundos, volver al lugar donde se prendió el Helper
    idleSince = idleSince or now
    if config.returnHome and startPosition and now - idleSince >= config.returnDelay * 1000 and distance(player:getPosition(), startPosition) > 0 and not player:isAutoWalking() and not player:isWalking() then
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
        idleSince = nil
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
            readWindow() -- no perder lo que se estaba cambiando
            fillWindow()
        end
    end
    if data.cost and window then
        local text = data.cost > 0 and string.format('Prenderlo cuesta %d zen.', data.cost) or 'Por ahora es gratis (modo prueba).'
        window:getChildById('costLabel'):setText(text)
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
    -- el servidor recuerda si aceptar o rechazar parties; se le repite por si cambió en esta PC
    scheduleEvent(function()
        if g_game.isOnline() then
            loadConfig()
            sendPartyMode()
        end
    end, 2000)
end

local function onGameEnd()
    setHelperOn(false)
    closePicker()
    if window then
        window:hide()
    end
end

-- ---------------------------------------------------------------------------
-- Armado de las pestañas
-- ---------------------------------------------------------------------------

local function setTexts(panel, texts)
    for id, text in pairs(texts) do
        panel:recursiveGetChildById(id):setText(text)
    end
end

local function setupCaster(panel)
    setTexts(panel, {
        basicTitle = 'Habilidad b\225sica (la usa siempre)',
        skill1Title = 'Habilidad 1 (tiene prioridad) y cu\225ndo usarla',
        skill2Title = 'Habilidad 2 y cu\225ndo usarla',
        buffTitle = 'Buffs (se vuelven a lanzar cuando se terminan)',
        rangeLabel = 'Rango para buscar monstruos:',
        returnHome = 'Conservar la posici\243n inicial (cazar alrededor)',
        returnDelayLabel = 'Volver despu\233s de X seg. sin monstruos:',
        chase = 'Seguir a los monstruos',
    })

    local function slotPicker(slot, key, kinds)
        local function open()
            openPicker(kinds, function(chosen)
                config[key] = chosen
                showSlot(slot, chosen)
            end)
        end
        slot.onClick = open
        slot:getChildById('icon').onClick = open
        slot:getChildById('name').onClick = open
    end

    slotPicker(panel:getChildById('basicSlot'), 'basic', ATTACK_KINDS)
    for i = 1, 2 do
        local slot = panel:getChildById('skill' .. i .. 'Slot')
        slotPicker(slot, 's' .. i, ATTACK_KINDS)
        local mode = slot:getChildById('mode')
        for _, m in ipairs(MODES) do
            mode:addOption(m.text, m.data)
        end
    end
    local buffs = panel:getChildById('buffs')
    for i = 1, 3 do
        local slot = g_ui.createWidget('HelperBuffSlot', buffs)
        slot:setId('buff' .. i)
        slotPicker(slot, 'buff' .. i, BUFF_KINDS)
    end
end

local function setupHealing(panel)
    setTexts(panel, {
        potionTitle = 'Pociones (0 = no usar)',
        hpLabel = 'Poci\243n de vida si baja de %:',
        mpLabel = 'Poci\243n de mana si baja de %:',
        healTitle = 'Heal (elfa)',
        healSelfLabel = 'Curarme a m\237 si baja de %:',
        healPartyLabel = 'Curar a un compa\241ero si baja de %:',
        healNote = 'Solo para la elfa que ya aprendi\243 Heal.',
    })
end

local function setupLoot(panel)
    setTexts(panel, {
        lootRangeLabel = 'Rango de loot (casillas):',
        lootAll = 'Agarrar absolutamente todo',
        lootSelected = 'Agarrar solo lo que selecciono:',
        lootJewel = 'Jewel / Gem',
        lootZen = 'Zen',
        lootGear = 'Set item (sets, armas y escudos)',
        lootExc = 'Excellent item',
        lootScroll = 'Habilidades (scrolls)',
        lootOther = 'Otros (palabras clave, separadas por coma):',
        lootNote = 'Ejemplo de palabras: apple, potion, ring',
    })
    local all, selected = panel:getChildById('lootAll'), panel:getChildById('lootSelected')
    all.onCheckChange = function(widget, checked)
        if checked then
            selected:setChecked(false)
        end
        updateLootChecks()
    end
    selected.onCheckChange = function(widget, checked)
        if checked then
            all:setChecked(false)
        end
        updateLootChecks()
    end
    panel:getChildById('lootOther').onCheckChange = function()
        updateLootChecks()
    end
end

local function setupOther(panel)
    setTexts(panel, {
        partyTitle = 'Invitaciones de party',
        partyAccept = 'Aceptar invitaciones autom\225ticamente',
        partyReject = 'Rechazar invitaciones autom\225ticamente',
        partyNote = 'Si no marc\225s ninguna, las invitaciones llegan como siempre. Funciona aunque el Helper est\233 apagado.',
    })
    local accept, reject = panel:getChildById('partyAccept'), panel:getChildById('partyReject')
    accept.onCheckChange = function(widget, checked)
        if checked then
            reject:setChecked(false)
        end
    end
    reject.onCheckChange = function(widget, checked)
        if checked then
            accept:setChecked(false)
        end
    end
end

function init()
    window = g_ui.displayUI('mubia_helper')
    window:hide()
    window:getChildById('saveButton'):setText('Guardar')

    local tabBar = window:getChildById('tabBar')
    tabBar:setContentWidget(window:getChildById('tabContent'))
    tabs.caster = g_ui.createWidget('HelperCasterPanel')
    tabs.healing = g_ui.createWidget('HelperHealingPanel')
    tabs.loot = g_ui.createWidget('HelperLootPanel')
    tabs.other = g_ui.createWidget('HelperOtherPanel')
    tabBar:addTab('Caster', tabs.caster)
    tabBar:addTab('Healing', tabs.healing)
    tabBar:addTab('Loot', tabs.loot)
    tabBar:addTab('Other Settings', tabs.other)
    setupCaster(tabs.caster)
    setupHealing(tabs.healing)
    setupLoot(tabs.loot)
    setupOther(tabs.other)
    updateStatus()

    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onHelper)
    button = modules.client_topmenu.addRightGameToggleButton('mubiaHelperButton', tr('Mubia Helper') .. ' (H)', '/images/topbuttons/battle', toggleWindow)

    Keybind.new('Windows', 'Mubia: ventana del Mubia Helper', { [CHAT_MODE.ON] = 'Ctrl+Shift+H', [CHAT_MODE.OFF] = 'H' }, '')
    Keybind.bind('Windows', 'Mubia: ventana del Mubia Helper', {
        {
            type = KEY_DOWN,
            callback = toggleWindow,
        }
    })
    Keybind.new('Windows', 'Mubia: prender/apagar Mubia Helper', { [CHAT_MODE.ON] = 'Ctrl+Home', [CHAT_MODE.OFF] = 'Home' }, '')
    Keybind.bind('Windows', 'Mubia: prender/apagar Mubia Helper', {
        {
            type = KEY_DOWN,
            callback = toggleHelper,
        }
    })
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    setHelperOn(false)
    closePicker()
    Keybind.delete('Windows', 'Mubia: ventana del Mubia Helper')
    Keybind.delete('Windows', 'Mubia: prender/apagar Mubia Helper')
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
