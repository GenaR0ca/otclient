-- Mubia Online: crear personajes desde la lista de personajes (botón "Create").
-- Muestra el retrato de la clase, sus stats iniciales y pide el nombre.
-- El personaje lo crea el login-server (pedido "createcharacter").

MubiaCreate = {}

-- Mismo orden que en MU. "voc" = id de vocations.xml del servidor.
-- Las stats son las mismas que usa el servidor (Mubia.Classes en data/libs/systems/mubia.lua).
local CLASSES = {
    { key = 'dw', voc = 1, name = 'Dark Wizard', stats = { 18, 18, 15, 30 },
      text = 'Mago de la oscuridad. Poco fuerte en el cuerpo a cuerpo, pero domina hechizos de ataque muy poderosos.' },
    { key = 'dk', voc = 4, name = 'Dark Knight', stats = { 28, 20, 25, 10 },
      text = 'Caballero de Lorencia. Gran fuerza y manejo de la espada; experto en el combate cuerpo a cuerpo.' },
    { key = 'elf', voc = 3, name = 'Fairy Elf', stats = { 22, 25, 20, 15 },
      text = 'Elfa de Noria. Maestra del arco y las flechas, y de hechizos que ayudan a su grupo.' },
    { key = 'sum', voc = 13, name = 'Summoner', stats = { 21, 21, 18, 23 },
      text = 'Hechicera con gran poder mental. Lanza maldiciones e invoca criaturas de otros mundos.' },
    { gap = true },
    { key = 'rf', voc = 15, name = 'Rage Fighter', stats = { 32, 27, 25, 20 },
      text = 'Luchador de artes marciales con enorme fuerza fisica. Tambien ayuda a su grupo con buffs.' },
    { key = 'mg', voc = 11, name = 'Magic Gladiator', stats = { 26, 26, 26, 26 },
      text = 'Mezcla de Dark Knight y Dark Wizard: pelea cuerpo a cuerpo y usa hechizos a la vez.' },
    { key = 'dl', voc = 12, name = 'Dark Lord', stats = { 26, 20, 20, 15 }, command = 25,
      text = 'Comandante carismatico. Dirige a sus tropas y controla al Dark Spirit y al Dark Horse.' },
}

local STAT_NAMES = { 'Fuerza', 'Agilidad', 'Vitalidad', 'Energia' }

local window
local selected
local requestPending = false

local function buildLoginUrl()
    local host = G.host or ''
    local scheme = host:find('^https://') and 'https://' or 'http://'
    local url = host:gsub('^https?://', '')
    local hostPart, path = url:match('([^/]+)(/.*)')
    if not hostPart then
        hostPart = url
        path = '/'
    end
    hostPart = hostPart:gsub(':%d+$', '')
    local port = G.port or (scheme == 'https://' and 443 or 80)
    return scheme .. hostPart .. ':' .. port .. path
end

local function selectClass(class)
    if not window then
        return
    end
    selected = class

    for _, button in ipairs(window:getChildById('classButtons'):getChildren()) do
        button:setOn(button.mubiaClass == class)
    end

    window:getChildById('className'):setText(class.name)
    window:getChildById('description'):setText(class.text)

    local portrait = window:recursiveGetChildById('portrait')
    local path = '/images/mubia/personajes/' .. class.key
    local exists = g_resources.fileExists(path .. '.png')
    portrait:setImageSource(exists and path or '')
    window:recursiveGetChildById('portraitMissing'):setVisible(not exists)

    local stats = window:getChildById('statsPanel')
    stats:destroyChildren()
    local function addRow(label, value)
        local row = g_ui.createWidget('UIWidget', stats)
        row:setSize({ width = 130, height = 20 })
        local nameLabel = g_ui.createWidget('MubiaStatName', row)
        nameLabel:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        nameLabel:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
        nameLabel:setText(label)
        local valueLabel = g_ui.createWidget('MubiaStatValue', row)
        valueLabel:addAnchor(AnchorRight, 'parent', AnchorRight)
        valueLabel:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
        valueLabel:setText(tostring(value))
    end
    for i, label in ipairs(STAT_NAMES) do
        addRow(label, class.stats[i])
    end
    if class.command then
        addRow('Comando', class.command)
    end
end

function MubiaCreate.open()
    if not CharacterList.mubiaCanCreate() then
        displayErrorBox(tr('Crear personaje'), tr('Ya tenes 5 personajes. Es el maximo por cuenta.'))
        return
    end
    if window then
        window:show()
        window:raise()
        window:focus()
        return
    end

    window = g_ui.displayUI('mubia_create')
    local buttons = window:getChildById('classButtons')
    for _, class in ipairs(CLASSES) do
        if class.gap then
            local spacer = g_ui.createWidget('UIWidget', buttons)
            spacer:setHeight(8)
        else
            local button = g_ui.createWidget('MubiaClassButton', buttons)
            button:setText(class.name)
            button.mubiaClass = class
            button.onClick = function()
                selectClass(class)
            end
        end
    end

    selectClass(selected or CLASSES[1])
    window:show()
    window:raise()
    window:focus()
    window:getChildById('nameEdit'):focus()
end

function MubiaCreate.close()
    if window then
        window:destroy()
        window = nil
    end
    requestPending = false
end

local function onCreated(characterName)
    MubiaCreate.close()
    -- volver a pedir la lista de personajes para que aparezca el nuevo
    CharacterList.hide()
    EnterGame.tryHttpLogin(G.clientVersion or g_game.getClientVersion(), g_settings.getBoolean('httpLogin', true))
    g_logger.info('[Mubia] Personaje creado: ' .. tostring(characterName))
end

function MubiaCreate.submit()
    if not window or requestPending or not selected then
        return
    end

    local name = window:getChildById('nameEdit'):getText():gsub('^%s+', ''):gsub('%s+$', '')
    if name:len() < 3 or name:len() > 20 then
        displayErrorBox(tr('Crear personaje'), tr('El nombre debe tener entre 3 y 20 caracteres.'))
        return
    end
    if not name:match('^%a[%w ]*$') then
        displayErrorBox(tr('Crear personaje'), tr('El nombre solo puede tener letras y numeros, y debe empezar con una letra.'))
        return
    end

    requestPending = true
    window:getChildById('okButton'):setEnabled(false)

    HTTP.postJSON(buildLoginUrl(), {
        type = 'createcharacter',
        email = G.account,
        password = G.password,
        charactername = name,
        vocation = selected.voc
    }, function(data, err)
        requestPending = false
        if window then
            window:getChildById('okButton'):setEnabled(true)
        end

        if err then
            displayErrorBox(tr('Crear personaje'),
                tr('No se pudo conectar con el login-server.\nRevisa que iniciar-login.bat este abierto.\n\n%s', err))
            return
        end
        if type(data) ~= 'table' then
            displayErrorBox(tr('Crear personaje'), tr('Respuesta invalida del login-server.'))
            return
        end
        if data.errorMessage then
            local message = data.errorMessage
            if data.errorCode == nil or tostring(message):find('unsupported') then
                message = message .. '\n\n(El login-server.exe es viejo: falta instalar la version de Mubia.)'
            end
            displayErrorBox(tr('Crear personaje'), message)
            return
        end
        if data.success then
            onCreated(data.name or name)
        end
    end)
end

-- ===== Borrar personaje (boton "Delete") =====
local deleteWindow
local deleteTarget

function MubiaCreate.closeDelete()
    if deleteWindow then
        deleteWindow:destroy()
        deleteWindow = nil
    end
    deleteTarget = nil
end

function MubiaCreate.openDelete()
    local target = CharacterList.mubiaSelectedName and CharacterList.mubiaSelectedName()
    if not target then
        displayErrorBox(tr('Borrar personaje'), tr('Primero elegi el personaje que queres borrar.'))
        return
    end
    MubiaCreate.closeDelete()
    deleteTarget = target
    deleteWindow = g_ui.displayUI('mubia_delete')
    deleteWindow:getChildById('deleteInfo'):setText(tr(
        'Vas a borrar a %s para siempre (con todos sus items).\nPara confirmar, escribi su nombre exacto:', target))
    deleteWindow:show()
    deleteWindow:raise()
    deleteWindow:focus()
    deleteWindow:getChildById('deleteNameEdit'):focus()
end

function MubiaCreate.confirmDelete()
    if not deleteWindow or requestPending or not deleteTarget then
        return
    end
    local typed = deleteWindow:getChildById('deleteNameEdit'):getText()
    if typed ~= deleteTarget then
        displayErrorBox(tr('Borrar personaje'), tr('El nombre no coincide. Escribilo exacto, con mayusculas: %s', deleteTarget))
        return
    end

    requestPending = true
    deleteWindow:getChildById('deleteOkButton'):setEnabled(false)
    HTTP.postJSON(buildLoginUrl(), {
        type = 'deletecharacter',
        email = G.account,
        password = G.password,
        charactername = typed
    }, function(data, err)
        requestPending = false
        if deleteWindow then
            deleteWindow:getChildById('deleteOkButton'):setEnabled(true)
        end
        if err then
            displayErrorBox(tr('Borrar personaje'),
                tr('No se pudo conectar con el login-server.\nRevisa que iniciar-login.bat este abierto.\n\n%s', err))
            return
        end
        if type(data) ~= 'table' then
            displayErrorBox(tr('Borrar personaje'), tr('Respuesta invalida del login-server.'))
            return
        end
        if data.errorMessage then
            displayErrorBox(tr('Borrar personaje'), data.errorMessage)
            return
        end
        if data.success then
            MubiaCreate.closeDelete()
            CharacterList.hide()
            EnterGame.tryHttpLogin(G.clientVersion or g_game.getClientVersion(), g_settings.getBoolean('httpLogin', true))
        end
    end)
end

function MubiaCreate.terminate()
    MubiaCreate.close()
    MubiaCreate.closeDelete()
end
