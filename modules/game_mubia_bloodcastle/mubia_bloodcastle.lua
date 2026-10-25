-- Mubia Online: ventana del Messenger of Archangel (Blood Castle), como en MU.
-- Al hablarle al NPC el servidor manda la lista de castillos (opcode 88, data/scripts/mubia/npcs_mu.lua):
-- nivel de cada uno, si puedes entrar y cuál te corresponde. Al elegir uno se manda "enter:N".
local OPCODE = 88

local window = nil

local function send(text)
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedOpcode(OPCODE, text)
    end
end

function hide()
    if window then
        window:hide()
    end
end

local function open(castles)
    local panel = window:getChildById('castles')
    panel:destroyChildren()
    for _, castle in ipairs(castles) do
        local button = g_ui.createWidget('CastleButton', panel)
        button:setText(castle.label or '')
        button:setEnabled(castle.enabled == true)
        if castle.enabled and castle.mine then
            button:setColor('#ffd866')
        end
        if castle.reason and castle.reason ~= '' then
            button:setTooltip(castle.reason)
        end
        local level = castle.level
        button.onClick = function()
            send('enter:' .. level)
        end
    end
    window:show()
    window:raise()
    window:focus()
end

local function onMessage(protocol, opcode, data)
    if not window or type(data) ~= 'table' then
        return
    end
    if data.action == 'open' then
        open(data.castles or {})
    elseif data.action == 'close' then
        hide()
    end
end

function init()
    window = g_ui.displayUI('mubia_bloodcastle')
    window:hide()
    -- Latin-1, como el resto de los textos de Mubia en el cliente
    window:getChildById('message'):setText('Tu voluntad de ayudar al Arc\225ngel es apreciada. Pero ten cuidado, joven guerrero: Blood Castle es un lugar peligroso. Que Dios te acompa\241e.')
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
