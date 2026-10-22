-- Mubia Online: inventario de 40 lugares (equivalente a la tecla I de MU).
-- El inventario es la bolsa que el servidor pone en el slot de la mochila (ese slot no se muestra).
local INVENTORY_BAG = 60500
local KEYBIND = 'Mubia: inventario'

local function isInventory(container)
    local item = container:getContainerItem()
    return item and item:getId() == INVENTORY_BAG and not container:hasParent()
end

function toggle()
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    for _, container in pairs(g_game.getContainers()) do
        if isInventory(container) then
            g_game.close(container)
            return
        end
    end

    local bag = player:getInventoryItem(InventorySlotBack)
    if bag then
        g_game.open(bag)
    end
end

-- Al abrirse, la ventana muestra los 40 lugares enteros
local function onOpen(container, previousContainer)
    if not isInventory(container) or not container.window or not container.itemsPanel then
        return
    end

    local window = container.window
    window:setText('Inventario')
    local layout = container.itemsPanel:getLayout()
    local step = layout:getCellSize().height + layout:getCellSpacing()
    window:setContentHeight(math.max(layout:getNumLines(), 1) * step + 31)
end

function init()
    connect(Container, { onOpen = onOpen })
    Keybind.new('Windows', KEYBIND, { [CHAT_MODE.ON] = 'Ctrl+I', [CHAT_MODE.OFF] = 'I' }, '')
    Keybind.bind('Windows', KEYBIND, {
        {
            type = KEY_DOWN,
            callback = toggle,
        }
    })
end

function terminate()
    disconnect(Container, { onOpen = onOpen })
    Keybind.delete('Windows', KEYBIND)
end
