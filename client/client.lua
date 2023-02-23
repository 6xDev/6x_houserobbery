local QBCore = exports['qb-core']:GetCoreObject()

canStart = true
ongoing = false
robberyStarted = false
NeededAttempts = 0
SucceededAttempts = 0
FailedAttemps = 0

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    print('The resource ' .. resourceName .. ' has been started.')
end)

Citizen.CreateThread(function()
    while not HasModelLoaded(GetHashKey(Config.Ped)) do
        Wait(1)
    end

    local npc = Config.PedLocation

    SetEntityHeading(npc, Config.PedHeading)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end)

Citizen.CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.Ped, {
    	options = {
    		{
    			event = "6x_houserobbery:startrobbery",
    			icon = "far fa-clipboard",
    			label = Lang:t("label.asklocation")
    		}
    	},
    	distance = 2.5,
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    DeleteEntity(npc)
end)

RegisterNetEvent("6x_houserobbery:startrobbery")
AddEventHandler("6x_houserobbery:startrobbery", function()
    if canStart then
        canStart = false
        ongoing = true
        QBCore.Functions.Notify(Lang:t("notify.starting"), "success")
        local missionWait = math.random( 1000,  1001)
        Citizen.Wait(missionWait)
        SetTimeout(2000, function()
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject"),
                message = Lang:t("mail.message"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        end)
    elseif ongoing then
        QBCore.Functions.Notify(Lang:t("notify.robberyinprogress"), "error")
    else
        QBCore.Functions.Notify(Lang:t("notify.needtowait") ..Config.Cooldown.. Lang:t("notify.needtowait2"), "error")
    end
end)

RegisterNetEvent("6x_houserobbery:getrandomhouseloc")
AddEventHandler("6x_houserobbery:getrandomhouseloc", function()
    local missionTarget = Config.Locations[math.random(#Config.Locations)]
    TriggerEvent("6x_houserobbery:createblipandroute", missionTarget)
    TriggerEvent("6x_houserobbery:createentry", missionTarget)
end)

RegisterNetEvent("6x_houserobbery:createblipandroute")
AddEventHandler("6x_houserobbery:createblipandroute", function(missionTarget)
    QBCore.Functions.Notify(Lang:t("notify.recivedlocation"), "success")
    targetBlip = AddBlipForCoord(missionTarget.location.x, missionTarget.location.y, missionTarget.location.z)
    SetBlipSprite(targetBlip, 374)
    SetBlipColour(targetBlip, 1)
    SetBlipAlpha(targetBlip, 90)
    SetBlipScale(targetBlip, 0.5)
    SetBlipRoute(targetBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipName)
    EndTextCommandSetBlipName(targetBlip)
end)

RegisterNetEvent("6x_houserobbery:createentry")
AddEventHandler("6x_houserobbery:createentry", function(missionTarget)
    Citizen.CreateThread(function()
	    local alreadyEnteredZone = false
	    local text = nil
	    while ongoing do
	        wait = 5
	        local ped = PlayerPedId()
	        local inZone = false
	        local dist = #(GetEntityCoords(ped)-vector3(missionTarget.location.x, missionTarget.location.y, missionTarget.location.z))
	        if dist <= 5.0 then
	            wait = 5
	            inZone  = true
	            text = Lang:t("text3d.text")

	            if IsControlJustReleased(0, 23) then
                    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
                        if HasItem then
                            EntryMinigame(missionTarget)
                        else
                            QBCore.Functions.Notify(Lang:t("notify.donthaveitem"))
                        end
                    end, Config.PickItem)
	            end
	        else
	            wait = 2000
	        end

	        if inZone and not alreadyEnteredZone then
	            alreadyEnteredZone = true
                exports['qb-core']:DrawText(text)
	        end

	        if not inZone and alreadyEnteredZone then
	            alreadyEnteredZone = false
                exports['qb-core']:HideText()
	        end
	        Citizen.Wait(wait)
	    end
	end)
end)

RegisterNetEvent("6x_houserobbery:goinside")
AddEventHandler("6x_houserobbery:goinside", function(missionTarget)
    robberyStarted = true
    SetEntityCoords(PlayerPedId(), missionTarget.inside.x, missionTarget.inside.y, missionTarget.inside.z)
    TriggerEvent("6x_houserobbery:createexit", missionTarget)
    TriggerEvent("6x_houserobbery:createloot", missionTarget)
end)

RegisterNetEvent("6x_houserobbery:createexit")
AddEventHandler("6x_houserobbery:createexit", function(missionTarget)
    Citizen.CreateThread(function()
	    local alreadyEnteredZone = false
	    local text = nil
	    while ongoing do
	        wait = 5
	        local ped = PlayerPedId()
	        local inZone = false
	        local dist = #(GetEntityCoords(ped)-vector3(missionTarget.exit.x, missionTarget.exit.y, missionTarget.exit.z))
	        if dist <= 5.0 then
	            wait = 5
	            inZone  = true
	            text = Lang:t("text3d.text2")

	            if IsControlJustReleased(0, 23) then
                    Citizen.Wait(1000)
	                robberyStarted = false
                    ongoing = false
                    SetEntityCoords(PlayerPedId(), missionTarget.location.x, missionTarget.location.y, missionTarget.location.z)
                    cooldownNextRobbery()
                    Citizen.Wait(500)
                    exports['qb-core']:HideText()
	            end
	        else
	            wait = 2000
	        end

	        if inZone and not alreadyEnteredZone then
	            alreadyEnteredZone = true
                exports['qb-core']:DrawText(text)
	        end

	        if not inZone and alreadyEnteredZone then
	            alreadyEnteredZone = false
                exports['qb-core']:HideText()
	        end
	        Citizen.Wait(wait)
	    end
	end)
end)

RegisterNetEvent("6x_houserobbery:createloot")
AddEventHandler("6x_houserobbery:createloot", function(missionTarget)
    for i,v in ipairs(missionTarget.loot) do
        local looted = false
        Citizen.CreateThread(function()
            while ongoing do
                local wait = 5000
                local ped = PlayerPedId()
                local pedCoords = GetEntityCoords(ped)
                if #(v - pedCoords) < 20 then
                    wait = 1
                    if #(v - pedCoords) < 2 then
                        drawTxt3D(v.x, v.y, v.z, Lang:t("text3d.text3"))
                        if IsControlJustPressed(0, 46) then
                            if not looted then
                                beginLoot()
                                looted = true
                            else
                                QBCore.Functions.Notify(Lang:t("notify.alreadycheacked"), "error")
                            end
                        end
                    end
                end
                Wait(wait)
            end
        end)
    end
end)

function drawTxt3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

function beginLoot()
    QBCore.Functions.Progressbar("loot_house", Lang:t("progress.lookingforstuff"), math.random(6000,12000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("robbery:loot")
        ClearPedTasks(PlayerPedId())
    end, function() -- Cancel
        StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        openingDoor = false
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify(Lang:t("notify.canceled"), "error")
    end)
end

function cooldownNextRobbery()
    RemoveBlip(targetBlip)
    exports['qb-core']:HideText()
    Citizen.Wait(3000)
    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = Lang:t("mail.sender"),
        subject = Lang:t("mail.subject2"),
        message = Lang:t("mail.message2"),
            button = {
            enabled = false
        }
    })
    Citizen.Wait(Config.Cooldown) -- Needs a better option. So that client cant just reconnect and reset timer that way.
    canStart = true
    robberyCreated = false
    ongoing = false
end

function cooldownNextRobberyFail()
    RemoveBlip(targetBlip)
    exports['qb-core']:HideText()
    Citizen.Wait(3000)
    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = Lang:t("mail.sender"),
        subject = Lang:t("mail.subject3"),
        message = Lang:t("mail.message3"),
        button = {
            enabled = false
        }
    })
    Citizen.Wait(Config.Cooldown) -- Needs a better option. So that client cant just reconnect and reset timer that way.
    canStart = true
    robberyCreated = false
    ongoing = false
end

function StartAnimation()
    QBCore.Functions.PlayAnim("mp_arresting", "a_uncuff")
end

function EntryMinigame(missionTarget)
    if Config.Minigame == "qb-skillbar" then
        local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
        if NeededAttempts == 0 then
            NeededAttempts = Config.NeededAttempts
            -- NeededAttempts = 1
        end

        local maxwidth = Config.MaxWidth
        local maxduration = Config.MaxDuration

        Skillbar.Start({
            StartAnimation(),
            duration = Config.Duration,
            pos = Config.Pos,
            width = Config.Width,
        }, function()

            if SucceededAttempts + 1 >= NeededAttempts then
                TriggerEvent("6x_houserobbery:goinside", missionTarget)
                ongoing = true
                QBCore.Functions.Notify(Lang:t("notify.gotthedoor"), "success")
                if (GetEntityModel(GetPlayerPed(-1)) == freemode) then
                    QBCore.Functions.Notify(Lang:t("notify.donthavemask"))
                    callPolice(missionTarget)
                end
                FailedAttemps = 0
                SucceededAttempts = 0
                NeededAttempts = 0
            else
                SucceededAttempts = SucceededAttempts + 1
                Skillbar.Repeat({
                    duration = Config.Duration,
                    pos = Config.Pos,
                    width = Config.Width,
                })
            end


	    end, function()

                QBCore.Functions.Notify(Lang:t("notify.messedup"), "error")
                StopAnimTask(ped, "mp_arresting", "a_uncuff", 1.0)
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent("6x_houserobbery:server:takeitem")
                callPolice(missionTarget)
                FailedAttemps = 0
                SucceededAttempts = 0
                NeededAttempts = 0
                robberyStarted = false
                ongoing = false
                cooldownNextRobberyFail()
                Citizen.Wait(500)
                exports['qb-core']:HideText()

        end)

    elseif Config.Minigame == "ps-ui" then
        StartAnimation()
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerEvent("6x_houserobbery:goinside", missionTarget)
                ongoing = true
                QBCore.Functions.Notify(Lang:t("notify.gotthedoor"), "success")
                --if (GetEntityModel(GetPlayerPed(-1)) == freemode) then
                if GetPedDrawableVariation(PlayerPedId(), 1) == 0 then
                    QBCore.Functions.Notify(Lang:t("notify.donthavemask"))
                    callPolice(missionTarget)
                end
            else
                QBCore.Functions.Notify(Lang:t("notify.messedup"), "error")
                StopAnimTask(ped, "mp_arresting", "a_uncuff", 1.0)
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent("6x_houserobbery:server:takeitem")
                callPolice(missionTarget)
                robberyStarted = false
                ongoing = false
                cooldownNextRobberyFail()
                Citizen.Wait(500)
                exports['qb-core']:HideText()
            end
        end, Config.Circles, Config.MS) -- NumberOfCircles, MS
    end
end

function callPolice(missionTarget)
    exports[Config.Dispatch]:HouseRobbery()
end

RegisterCommand('start', function()
    TriggerEvent('6x_houserobbery:startrobbery')
end)
