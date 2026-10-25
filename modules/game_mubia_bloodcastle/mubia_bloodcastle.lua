-- Mubia Online: ventanas de los eventos de MU al hacer clic en su NPC.
--   Messenger of Archangel -> Blood Castle (opcode 88), Charon -> Devil Square (opcode 90).
-- El servidor (data/scripts/mubia/npcs_mu.lua) manda el título, el texto y la lista: nivel de cada uno,
-- si puedes entrar y cuál te corresponde. Al elegir uno se manda "enter:N" por el mismo opcode.
local OPCODES = { 88, 90 }

local window = nil

function hide()
    if window then
        window:hide()
    end
end

local function open(opcode, data)
    window:setText(data.title or '')
    window:getChildById('message'):setText(data.message or '')
    local panel = window:getChildById('entries')
    panel:destroyChildren()
    for _, entry in ipairs(data.entries or {}) do
        local button = g_ui.createWidget('EventButton', panel)
        button:setText(entry.label or '')
        button:setEnabled(entry.enabled == true)
        if entry.enabled and entry.mine then
            button:setColor('#ffd866')
        end
        if entry.reason and entry.reason ~= '' then
            button:setTooltip(entry.reason)
        end
        local level = entry.level
        button.onClick = function()
            local protocol = g_game.getProtocolGame()
            if protocol then
                protocol:sendExtendedOpcode(opcode, 'enter:' .. level)
            end
        end
    end
    window:setHeight(140 + #panel:getChildren() * 36)
    window:show()
    window:raise()
    window:focus()
end

local function onMessage(protocol, opcode, data)
    if not window or type(data) ~= 'table' then
        return
    end
    if data.action == 'open' then
        open(opcode, data)
    elseif data.action == 'close' then
        hide()
    end
end

function init()
    window = g_ui.displayUI('mubia_bloodcastle')
    window:hide()
    for _, opcode in ipairs(OPCODES) do
        ProtocolGame.registerExtendedJSONOpcode(opcode, onMessage)
    end
    connect(g_game, { onGameEnd = hide })
end

function terminate()
    disconnect(g_game, { onGameEnd = hide })
    for _, opcode in ipairs(OPCODES) do
        ProtocolGame.unregisterExtendedJSONOpcode(opcode)
    end
    if window then
        window:destroy()
        window = nil
    end
end
