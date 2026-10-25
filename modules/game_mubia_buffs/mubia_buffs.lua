-- Mubia Online: recuadro arriba a la izquierda con los buffs activos y cuánto les queda.
-- El servidor (opcode 89, data/scripts/mubia/npcs_mu.lua) manda la lista al recibir un buff y al entrar al juego;
-- el cliente descuenta los segundos solo.
local OPCODE = 89
local ROW_HEIGHT = 30

local panel = nil
local buffs = {} -- { name, text, endsAt }
local rows = {}
local tickEvent = nil

local function formatTime(seconds)
    seconds = math.max(0, seconds)
    return string.format('%d:%02d', math.floor(seconds / 60), seconds % 60)
end

local function clearRows()
    for _, row in ipairs(rows) do
        row:destroy()
    end
    rows = {}
end

local function refresh()
    if not panel then
        return
    end
    local now = os.time()
    local active = {}
    for _, buff in ipairs(buffs) do
        if buff.endsAt > now then
            active[#active + 1] = buff
        end
    end
    buffs = active

    if #buffs == 0 then
        clearRows()
        panel:hide()
        if tickEvent then
            removeEvent(tickEvent)
            tickEvent = nil
        end
        return
    end

    if #rows ~= #buffs then
        clearRows()
        for i = 1, #buffs do
            local row = g_ui.createWidget('MubiaBuffRow', panel)
            if i == 1 then
                row:addAnchor(AnchorTop, 'parent', AnchorTop)
            else
                row:addAnchor(AnchorTop, rows[i - 1]:getId(), AnchorBottom)
                row:setMarginTop(2)
            end
            row:setId('buff' .. i)
            rows[i] = row
        end
    end
    for i, buff in ipairs(buffs) do
        rows[i]:getChildById('name'):setText(buff.name)
        rows[i]:getChildById('text'):setText(buff.text)
        rows[i]:getChildById('time'):setText(formatTime(buff.endsAt - now))
    end
    panel:setHeight(8 + #buffs * ROW_HEIGHT)
    panel:show()
end

local function tick()
    tickEvent = nil
    refresh()
    if #buffs > 0 then
        tickEvent = scheduleEvent(tick, 1000)
    end
end

local function onBuffs(protocol, opcode, data)
    if type(data) ~= 'table' then
        return
    end
    buffs = {}
    local now = os.time()
    for _, buff in ipairs(data.buffs or {}) do
        buffs[#buffs + 1] = {
            name = buff.name or '',
            text = buff.text or '',
            endsAt = now + (tonumber(buff.seconds) or 0)
        }
    end
    if tickEvent then
        removeEvent(tickEvent)
        tickEvent = nil
    end
    tick()
end

local function onGameEnd()
    buffs = {}
    refresh()
end

function init()
    g_ui.importStyle('mubia_buffs')
    panel = g_ui.createWidget('MubiaBuffsPanel', modules.game_interface.getMapPanel())
    panel:hide()
    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onBuffs)
    connect(g_game, { onGameEnd = onGameEnd })
end

function terminate()
    disconnect(g_game, { onGameEnd = onGameEnd })
    ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)
    if tickEvent then
        removeEvent(tickEvent)
        tickEvent = nil
    end
    clearRows()
    if panel then
        panel:destroy()
        panel = nil
    end
end
