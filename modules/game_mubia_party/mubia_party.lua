-- Mubia Online: vida de la party arriba a la derecha (como en MU Online).
-- El servidor (opcode 87, data/libs/systems/mubia_party.lua) manda la lista de la party
-- cada vez que cambia: nombre, clase, nivel, vida, si es el líder, si eres tú y si está cerca.
local OPCODE = 87
local ROW_HEIGHT = 29 -- alto de una fila + su margen
local BAR_WIDTH = 140 -- ancho del panel (150) menos el padding y el borde de la barra

local panel = nil
local rows = {}

local function clearRows()
    for _, row in ipairs(rows) do
        row:destroy()
    end
    rows = {}
end

local function hide()
    clearRows()
    if panel then
        panel:hide()
    end
end

local function fillRow(row, member)
    local name = member.name or ''
    if member.leader then
        name = '* ' .. name
    end
    row:getChildById('name'):setText(name)
    row:getChildById('level'):setText('Lv ' .. (member.level or 0))

    local hp = tonumber(member.hp) or 0
    local maxHp = math.max(1, tonumber(member.maxHp) or 1)
    local bar = row:getChildById('bar')
    local fill = bar:getChildById('fill')
    fill:setWidth(math.floor(BAR_WIDTH * math.min(1, hp / maxHp)))
    bar:getChildById('hp'):setText(hp .. ' / ' .. maxHp)

    local nameLabel = row:getChildById('name')
    if member.self then
        nameLabel:setColor('#9fe39f')
    elseif member.near then
        nameLabel:setColor('#ffffff')
    else
        nameLabel:setColor('#8a8a8a')
    end
    -- lejos o en otro piso: la barra se ve apagada
    fill:setBackgroundColor((member.near or member.self) and '#c81e1e' or '#6e2a2a')
    row:setTooltip((member.class or '') .. ((member.near or member.self) and '' or ' (lejos)'))
end

local function onParty(protocol, opcode, data)
    if not panel or type(data) ~= 'table' then
        return
    end
    local members = data.members or {}
    if #members == 0 then
        hide()
        return
    end

    -- las filas se rehacen solo si cambió la cantidad de miembros
    if #rows ~= #members then
        clearRows()
        local previous = panel:getChildById('title')
        for i = 1, #members do
            local row = g_ui.createWidget('MubiaPartyRow', panel)
            row:setId('member' .. i)
            row:addAnchor(AnchorTop, previous:getId(), AnchorBottom)
            rows[i] = row
            previous = row
        end
    end
    panel:getChildById('title'):setText('Party (' .. #members .. '/' .. (data.max or 5) .. ')')
    panel:setHeight(8 + 12 + #members * ROW_HEIGHT)
    panel:show()
    for i, member in ipairs(members) do
        fillRow(rows[i], member)
    end
end

function init()
    g_ui.importStyle('mubia_party')
    panel = g_ui.createWidget('MubiaPartyPanel', modules.game_interface.getMapPanel())
    panel:hide()
    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onParty)
    connect(g_game, { onGameEnd = hide })
end

function terminate()
    disconnect(g_game, { onGameEnd = hide })
    ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)
    clearRows()
    if panel then
        panel:destroy()
        panel = nil
    end
end
