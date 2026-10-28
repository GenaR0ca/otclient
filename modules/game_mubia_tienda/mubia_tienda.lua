-- Mubia Online: tienda de NPC estilo MU.
-- Click derecho en un NPC: si vende algo se abre su tienda (opcode 85); si no, le dice "hi" como siempre.
-- La tienda es una grilla con todos los items a la vista (con barra para bajar si son muchos).
-- Click en un item lo elige, doble click lo compra (o lo vende). Arrastrá un item de tu inventario a la tienda para venderlo.
-- Vender: el servidor manda la lista de tu bolsa (tecla I) con el precio de cada item ({"sell":[...]}).
-- Todo NPC con tienda compra cualquier item; si es valioso (+6, Excellent o joya) pregunta antes.
-- Arriba hay un buscador que filtra los items por nombre.
local OPCODE = 85
local TALK_RANGE = 3
local MAX_AMOUNT = 100

local window = nil
local mode = 'buy'
local buyItems = {}
local sellItems = {}
local goods = {} -- ['id_subtipo'] = cantidad que tiene el jugador
local money = 0
local selected = nil
local npcName = nil
local npcId = nil
local search = ''
local walkEvent = nil

local function formatZen(value)
    local text = tostring(math.floor(value or 0))
    local result = text:reverse():gsub('(%d%d%d)', '%1.'):reverse()
    return (result:gsub('^%.', ''))
end

local function goodsKey(ptr)
    return ptr:getId() .. '_' .. ptr:getSubType()
end

local function ownedCount(entry)
    if entry.slot then
        return entry.count
    end
    return goods[goodsKey(entry.ptr)] or 0
end

local function priceText(price)
    if price <= 0 then
        return 'Gratis'
    end
    return formatZen(price) .. ' zen'
end

local function matchesSearch(entry)
    if search == '' then
        return true
    end
    return entry.name:lower():find(search, 1, true) ~= nil
end

local function currentList()
    local source = mode == 'buy' and buyItems or sellItems
    local list = {}
    for _, entry in ipairs(source) do
        if (mode == 'buy' or ownedCount(entry) > 0) and matchesSearch(entry) then
            list[#list + 1] = entry
        end
    end
    return list
end

local function getAmount()
    local amount = tonumber(window:getChildById('amount'):getText()) or 1
    return math.max(1, math.min(MAX_AMOUNT, math.floor(amount)))
end

local function updateInfo()
    if not window then
        return
    end
    local infoPanel = window:getChildById('infoPanel')
    local tradeButton = window:getChildById('tradeButton')
    window:getChildById('zenLabel'):setText('Tu zen: ' .. formatZen(money))
    if not selected then
        infoPanel:getChildById('selectedItem'):setItem(nil)
        infoPanel:getChildById('nameLabel'):setText('')
        infoPanel:getChildById('priceLabel'):setText('')
        tradeButton:setEnabled(false)
        return
    end
    infoPanel:getChildById('selectedItem'):setItem(selected.ptr)
    infoPanel:getChildById('nameLabel'):setText(selected.name)
    local amount = getAmount()
    if mode == 'buy' then
        local total = selected.price * amount
        infoPanel:getChildById('priceLabel'):setText('Precio: ' .. priceText(total))
        tradeButton:setEnabled(total <= money)
    else
        infoPanel:getChildById('priceLabel'):setText(string.format('Te pagan: %s (tienes %d)', priceText(selected.price * amount), ownedCount(selected)))
        tradeButton:setEnabled(ownedCount(selected) > 0)
    end
end

local function selectEntry(entry, widget)
    selected = entry
    local panel = window:getChildById('itemsPanel')
    for _, child in ipairs(panel:getChildren()) do
        child:setChecked(child == widget)
    end
    local amountEdit = window:getChildById('amount')
    if mode == 'sell' and entry then
        amountEdit:setText(tostring(math.max(1, math.min(MAX_AMOUNT, ownedCount(entry)))))
    else
        amountEdit:setText('1')
    end
    updateInfo()
end

-- Sets de MU: cada pieza va en su fila (casco, armadura, pantalón, guantes, botas)
local COLUMNS = 8
local SET_PIECES = { helm = 1, armor = 2, pants = 3, gloves = 4, boots = 5 }

-- "vine helm (luck)" -> "vine", 1
local function setPiece(entry)
    local name = entry.name:lower():gsub('%s*%(.-%)%s*$', '')
    local setName, piece = name:match('^(.-)%s+(%a+)$')
    if setName and SET_PIECES[piece] then
        return setName, SET_PIECES[piece]
    end
    return nil
end

-- Orden de la grilla: los sets quedan en columnas (un set por columna, cada pieza en su fila).
-- Devuelve la lista de casillas; false = casilla vacía.
local function gridCells(list)
    if mode ~= 'buy' or search ~= '' then
        return list
    end
    local cells = {}
    local function padRow()
        while #cells % COLUMNS ~= 0 do
            cells[#cells + 1] = false
        end
    end
    local i = 1
    while i <= #list do
        local setName = setPiece(list[i])
        if not setName then
            cells[#cells + 1] = list[i]
            i = i + 1
        else
            -- juntar los sets seguidos (hasta COLUMNS por bloque)
            local sets, order = {}, {}
            while i <= #list and #order <= COLUMNS do
                local name, row = setPiece(list[i])
                if not name then
                    break
                end
                if not sets[name] then
                    if #order == COLUMNS then
                        break
                    end
                    sets[name] = {}
                    order[#order + 1] = name
                end
                sets[name][row] = list[i]
                i = i + 1
            end
            padRow()
            for row = 1, 5 do
                for column = 1, COLUMNS do
                    local name = order[column]
                    cells[#cells + 1] = name and sets[name][row] or false
                end
            end
        end
    end
    return cells
end

local function buildGrid()
    if not window then
        return
    end
    local panel = window:getChildById('itemsPanel')
    panel:destroyChildren()
    local list = currentList()
    local selectedWidget = nil
    local firstWidget = nil
    for _, entry in ipairs(gridCells(list)) do
        if not entry then
            g_ui.createWidget('ShopEmpty', panel)
            goto continue
        end
        local slot = g_ui.createWidget('ShopSlot', panel)
        firstWidget = firstWidget or slot
        slot.entry = entry
        slot:setItem(entry.ptr)
        if mode == 'sell' then
            slot:setItemCount(ownedCount(entry))
        end
        slot:setTooltip(string.format('%s\n%s', entry.name, (mode == 'buy' and 'Precio: ' or 'Te pagan: ') .. priceText(entry.price)))
        slot.onClick = function(widget)
            selectEntry(entry, widget)
        end
        slot.onDoubleClick = function(widget)
            selectEntry(entry, widget)
            trade()
            return true
        end
        slot.onMouseRelease = function(widget, mousePos, mouseButton)
            if mouseButton == MouseRightButton then
                g_game.inspectNpcTrade(entry.ptr)
                return true
            end
            return false
        end
        if selected and selected.ptr:getId() == entry.ptr:getId() and selected.ptr:getSubType() == entry.ptr:getSubType() and selected.slot == entry.slot then
            selectedWidget = slot
            selected = entry
        end
        ::continue::
    end

    local emptyLabel = window:getChildById('emptyLabel')
    if #list == 0 then
        if search ~= '' then
            emptyLabel:setText('Ningun item se llama asi.')
        else
            emptyLabel:setText(mode == 'buy' and 'Este NPC no vende nada.' or 'No tienes items en tu inventario (tecla I) para vender.')
        end
        emptyLabel:show()
    else
        emptyLabel:hide()
    end
    window:getChildById('countLabel'):setText(#list == 1 and '1 item' or (#list .. ' items'))

    if selectedWidget then
        selectedWidget:setChecked(true)
        updateInfo()
    elseif list[1] then
        selectEntry(firstWidget and firstWidget.entry or list[1], firstWidget)
    else
        selectEntry(nil, nil)
    end
end

function setMode(newMode)
    if not window then
        return
    end
    mode = newMode
    selected = nil
    window:getChildById('buyTab'):setChecked(mode == 'buy')
    window:getChildById('sellTab'):setChecked(mode == 'sell')
    window:getChildById('buyTab'):setEnabled(#buyItems > 0)
    window:getChildById('tradeButton'):setText(mode == 'buy' and 'Comprar' or 'Vender')
    window:getChildById('hintLabel'):setText(mode == 'buy' and 'Doble click compra. Click derecho: ver item.' or 'Doble click vende. O arrastra items aqui.')
    buildGrid()
end

function trade()
    if not window or not selected then
        return
    end
    local amount = getAmount()
    if mode == 'buy' then
        if selected.price * amount > money then
            modules.game_textmessage.displayFailureMessage('No tienes zen suficiente.')
            return
        end
        g_game.buyItem(selected.ptr, amount, true, false)
    else
        sellEntry(selected, math.min(amount, ownedCount(selected)))
    end
end

local confirmBox = nil

local function sendSell(entry, amount, confirmed)
    local protocol = g_game.getProtocolGame()
    if protocol and npcId then
        protocol:sendExtendedOpcode(OPCODE, string.format('sell|%d|%d|%d|%d|%d', npcId, entry.slot, entry.ptr:getId(), amount, confirmed and 1 or 0))
    end
end

-- Vende un item de la bolsa. Si es valioso pregunta primero.
function sellEntry(entry, amount)
    if not entry or amount < 1 then
        return
    end
    if not entry.valuable then
        sendSell(entry, amount, false)
        return
    end
    if confirmBox then
        confirmBox:destroy()
        confirmBox = nil
    end
    local function yes()
        if confirmBox then
            confirmBox:destroy()
            confirmBox = nil
        end
        sendSell(entry, amount, true)
    end
    local function no()
        if confirmBox then
            confirmBox:destroy()
            confirmBox = nil
        end
    end
    confirmBox = displayGeneralBox('Item valioso', string.format('%s es un item valioso.\nEl NPC te paga %s.\n\nSeguro que quieres venderlo?', entry.name, priceText(entry.price * amount)), {
        { text = 'Vender', callback = yes },
        { text = 'Cancelar', callback = no },
    }, yes, no)
end

-- Arrastrar un item del inventario a la tienda lo vende
local function onDropItem(self, widget, mousePos)
    local item = widget and widget.currentDragThing
    if not item or not item:isItem() then
        return false
    end
    local pos = item:getPosition()
    if not pos or pos.x ~= 65535 then
        modules.game_textmessage.displayFailureMessage('Solo puedes vender items de tu inventario.')
        return false
    end
    -- items de la bolsa: pos.y = 64 + numero de contenedor, pos.z = casilla
    local found = nil
    for _, entry in ipairs(sellItems) do
        if entry.ptr:getId() == item:getId() then
            if pos.y >= 64 and entry.slot == pos.z then
                found = entry
                break
            end
            found = found or entry
        end
    end
    if found then
        sellEntry(found, math.min(item:getCount(), found.count))
        return true
    end
    modules.game_textmessage.displayFailureMessage('Solo puedes vender items de tu inventario (tecla I).')
    return false
end

local function show()
    if not window then
        window = g_ui.displayUI('mubia_tienda')
        local panel = window:getChildById('itemsPanel')
        panel.onDrop = onDropItem
        window.onDrop = onDropItem
        window:getChildById('amount').onTextChange = function()
            updateInfo()
        end
        window:getChildById('searchEdit').onTextChange = function(widget, text)
            search = (text or ''):lower()
            selected = nil
            buildGrid()
        end
    end
    window:setText(npcName and ('Tienda de ' .. npcName) or 'Tienda')
    window:show()
    window:raise()
    window:focus()
end

local function onOpenNpcTrade(items)
    buyItems = {}
    for _, data in ipairs(items or {}) do
        -- todo lo de la lista se compra (precio 0 = gratis); la venta la maneja el servidor
        buyItems[#buyItems + 1] = { ptr = data[1], name = data[2], price = data[4] }
    end
    local player = g_game.getLocalPlayer()
    money = player and player:getTotalMoney() or 0
    search = ''
    show()
    window:getChildById('searchEdit'):setText('')
    setMode(#buyItems > 0 and 'buy' or 'sell')
end

-- Lista de items de la bolsa que puedes vender (la manda el servidor)
local function onSellList(list)
    sellItems = {}
    for _, data in ipairs(list or {}) do
        local item = Item.create(tonumber(data.id), math.max(1, tonumber(data.count) or 1))
        sellItems[#sellItems + 1] = {
            ptr = item,
            slot = tonumber(data.slot),
            count = tonumber(data.count) or 1,
            name = tostring(data.name or ''),
            price = tonumber(data.price) or 0,
            valuable = data.valuable == true,
        }
    end
    if window and window:isVisible() and mode == 'sell' then
        buildGrid()
    end
end

local function onPlayerGoods(playerMoney, items)
    money = playerMoney or money
    goods = {}
    for _, data in ipairs(items or {}) do
        local key = goodsKey(data[1])
        goods[key] = (goods[key] or 0) + data[2]
    end
    if not window or not window:isVisible() then
        return
    end
    if mode == 'sell' then
        buildGrid()
    else
        updateInfo()
    end
end

local function hide()
    if walkEvent then
        removeEvent(walkEvent)
        walkEvent = nil
    end
    if window then
        window:destroy()
        window = nil
    end
    if confirmBox then
        confirmBox:destroy()
        confirmBox = nil
    end
    selected = nil
    sellItems = {}
end

function close()
    local wasOpen = window ~= nil
    hide()
    if wasOpen and g_game.isOnline() then
        g_game.closeNpcTrade()
    end
end

function isOpen()
    return window ~= nil
end

-- Click derecho en un NPC: acercarse si hace falta y pedir la tienda
local function distanceTo(creature)
    local player = g_game.getLocalPlayer()
    local a, b = player:getPosition(), creature:getPosition()
    if not a or not b or a.z ~= b.z then
        return nil
    end
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

-- La casilla libre al lado del NPC más cercana al jugador
local function besideNpc(creature)
    local from = g_game.getLocalPlayer():getPosition()
    local center = creature:getPosition()
    local best, bestDistance = center, nil
    for dx = -1, 1 do
        for dy = -1, 1 do
            local pos = { x = center.x + dx, y = center.y + dy, z = center.z }
            local tile = g_map.getTile(pos)
            if (dx ~= 0 or dy ~= 0) and tile and tile:isWalkable() then
                local d = math.abs(pos.x - from.x) + math.abs(pos.y - from.y)
                if not bestDistance or d < bestDistance then
                    best, bestDistance = pos, d
                end
            end
        end
    end
    return best
end

local function requestShop(creature)
    npcName = creature:getName()
    npcId = creature:getId()
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedOpcode(OPCODE, 'open|' .. creature:getId())
    end
end

function talkTo(creature)
    local player = g_game.getLocalPlayer()
    if not player or not creature then
        return false
    end
    if walkEvent then
        removeEvent(walkEvent)
        walkEvent = nil
    end
    local distance = distanceTo(creature)
    if not distance then
        return false
    end
    if distance <= TALK_RANGE then
        requestShop(creature)
        return true
    end

    -- Lejos: caminar hasta al lado del NPC y abrir la tienda al llegar (como en MU)
    player:autoWalk(besideNpc(creature))
    local creatureId = creature:getId()
    local tries = 0
    local function check()
        walkEvent = nil
        local npc = g_map.getCreatureById(creatureId)
        tries = tries + 1
        if not npc or not g_game.isOnline() or tries > 40 then
            return
        end
        local d = distanceTo(npc)
        if d and d <= TALK_RANGE then
            player:stopAutoWalk()
            requestShop(npc)
            return
        end
        walkEvent = scheduleEvent(check, 250)
    end
    walkEvent = scheduleEvent(check, 250)
    return true
end

local function onShopMessage(protocol, opcode, data)
    -- el NPC no vende nada: hablarle como siempre
    if data and data.talk then
        g_game.talk('hi')
    elseif data and data.sell then
        onSellList(data.sell)
    end
end

local function onGameEnd()
    hide()
end

function init()
    connect(g_game, {
        onOpenNpcTrade = onOpenNpcTrade,
        onPlayerGoods = onPlayerGoods,
        onCloseNpcTrade = hide,
        onGameEnd = onGameEnd,
    })
    ProtocolGame.registerExtendedJSONOpcode(OPCODE, onShopMessage)
end

function terminate()
    disconnect(g_game, {
        onOpenNpcTrade = onOpenNpcTrade,
        onPlayerGoods = onPlayerGoods,
        onCloseNpcTrade = hide,
        onGameEnd = onGameEnd,
    })
    ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)
    hide()
end
