local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("robbery:loot")
AddEventHandler("robbery:loot", function()
    local src = source
    local winNumber = math.random( 0, 100)
    if winNumber >= 30 then
        print(winNumber)
        addNormal(src)

    elseif winNumber < 30 and winNumber > 2 then
        print(winNumber)
        addRare(src)
    else
        print(winNumber)
        addVeryRare(src)
    end
end)

function addNormal(src)
    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Normal', })
    local item = Config.Items.normalItems[math.random(#Config.Items.normalItems)]
    print(item)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
end

function addRare(src)
    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Rare', })
    local item = Config.Items.rareItems[math.random(#Config.Items.rareItems)]
    print(item)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
end

function addVeryRare(src)
    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Very Rare', })
    local item = Config.Items.veryRareItems[math.random(#Config.Items.veryRareItems)]
    print(item)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
end

RegisterServerEvent('6x_houserobbery:server:takeitem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    Player.Functions.RemoveItem(Config.PickItem, 1)
end)

RegisterServerEvent('6x_houserobbery:server:takeitem2', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    Player.Functions.RemoveItem(Config.StartItem, 1)
end)