local QBCore = exports['qb-core']:GetCoreObject()

canStart = true
ongoing = false
robberyStarted = false
robberystopped = false
noise = 0
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
    hashKey = RequestModel(GetHashKey(Config.Ped))


    while not HasModelLoaded(GetHashKey(Config.Ped)) do
        Wait(1)
    end

    local npc = CreatePed(4, Config.ModelHash, Config.PedLocation, false, true)

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
        if isNight() then
            canStart = false
            ongoing = true
            QBCore.Functions.Notify(Lang:t("notify.starting"), "success")
            local missionWait = math.random( 1000,  1001)
            Citizen.Wait(missionWait)
            SetTimeout(2000, function()
                if Config.Phone == "qb-phone" then
                    TriggerServerEvent('qb-phone:server:sendNewMail', {
                        sender =  Lang:t("mail.sender"),
                        subject = Lang:t("mail.subject"),
                        message = Lang:t("mail.message"),
                        button = {
                            enabled = true,
                            buttonEvent = "6x_houserobbery:getrandomhouseloc"
                        }
                    })
                elseif Config.Phone == "gks-phone" then
                    TriggerServerEvent('gksphone:NewMail', {
                        sender =  Lang:t("mail.sender"),
                        subject = Lang:t("mail.subject"),
                        message = Lang:t("mail.message")
                    })
                elseif Config.Phone == "qs-phone" then
                    TriggerServerEvent('qs-smartphone:server:sendNewMail', {
                        sender =  Lang:t("mail.sender"),
                        subject = Lang:t("mail.subject"),
                        message = Lang:t("mail.message"),
                        button = {
                            enabled = true,
                            buttonEvent = "6x_houserobbery:getrandomhouseloc"
                        }
                    })
                end
            end)
        else
            canStart = false
            ongoing = true
            QBCore.Functions.Notify(Lang:t("notify.starting"), "success")
            local missionWait = math.random( 1000,  1001)
            Citizen.Wait(missionWait)
            SetTimeout(2000, function()
                if Config.Phone == "qb-phone" then
                    TriggerServerEvent('qb-phone:server:sendNewMail', {
                        sender =  Lang:t("mail.sender"),
                        subject = Lang:t("mail.subject"),
                        message = Lang:t("mail.messagenotnight"),
                        button = {
                            enabled = true,
                            buttonEvent = "6x_houserobbery:getrandomhouseloc"
                        }
                    })
                elseif Config.Phone == "gks-phone" then
                    TriggerServerEvent('gksphone:NewMail', {
                        sender =  Lang:t("mail.sender"),
                        subject = Lang:t("mail.subject"),
                        message = Lang:t("mail.messagenotnight")
                    })
                elseif Config.Phone == "qs-phone" then
                    TriggerServerEvent('qs-smartphone:server:sendNewMail', {
                        sender =  Lang:t("mail.sender"),
                        subject = Lang:t("mail.subject"),
                        message = Lang:t("mail.messagenotnight"),
                        button = {
                            enabled = true,
                            buttonEvent = "6x_houserobbery:getrandomhouseloc"
                        }
                    })
                end
            end)

        end
    elseif ongoing then
        QBCore.Functions.Notify(Lang:t("notify.robberyinprogress"), "error")
    else
        QBCore.Functions.Notify(Lang:t("notify.needtowait"), "error")
    end
end)

RegisterNetEvent('6x_houserobbery:noise')
AddEventHandler('6x_houserobbery:noise', function()
	local ped = PlayerPedId()
	while ongoing do
		if IsPedShooting(ped) then
			noise = noise + 100
            QBCore.Functions.Notify('Noise: '..noise)
            Citizen.Wait(1000)
		end
		if GetEntitySpeed(ped) > 1.7 then
			noise = noise + 10
            QBCore.Functions.Notify('Noise: '..noise)
            Citizen.Wait(1000)
			if GetEntitySpeed(ped) > 2.5 then
				noise = noise + 15
                QBCore.Functions.Notify('Noise: '..noise)
                Citizen.Wait(1000)
			end
			if GetEntitySpeed(ped) > 3.0 then
				noise = noise + 20
                QBCore.Functions.Notify('Noise: '..noise)
                Citizen.Wait(1000)
			end
			Citizen.Wait(300)
		else
			noise = noise - 2
            Citizen.Wait(1000)
			if noise < 0 then
				noise = 0
			end
			Citizen.Wait(1000)
		end
		if noise > 100 then
			stopRobbery()
		end
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
	        if dist <= 3.0 then
	            wait = 5
	            inZone  = true
	            text = Lang:t("text3d.text")

	            if IsControlJustReleased(0, 23) then
                    if isNight then
                        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
                            if HasItem then
                                EntryMinigame(missionTarget)
                            else
                                QBCore.Functions.Notify(Lang:t("notify.donthaveitem"))
                            end
                        end, Config.PickItem)
                    else
                        local c = math.random(1, 2)
                        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
                            if HasItem then
                                if c == 1 then
                                    EntryMinigame(missionTarget)
                                elseif c == 2 then
                                    callPolice(missionTarget)
                                    QBCore.Functions.Notify(Lang:t('notify.alarm'), 'error')
                                end
                            else
                                QBCore.Functions.Notify(Lang:t("notify.donthaveitem"))
                            end
                        end, Config.PickItem)
                    end
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
    if Config.noise then
        TriggerEvent("6x_houserobbery:noise")
    else
    end
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
	        if dist <= 3.0 then
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
            if robberystopped == false then
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
    if Config.Progressbar == "default" then
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
    elseif Config.Progressbar == "ox_lib" then
        lib.progressBar({
            duration = 2000,
            label = Lang:t("progress.lookingforstuff"),
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
            },
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_player'
            },
            TriggerServerEvent("robbery:loot")
        })
    end
end

function cooldownNextRobbery()
    RemoveBlip(targetBlip)
    exports['qb-core']:HideText()
    Citizen.Wait(3000)
    if robberystopped == true then
        if Config.Phone == "qb-phone" then
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject2"),
                message = Lang:t("mail.message2"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        elseif Config.Phone == "gks-phone" then
            TriggerServerEvent('gksphone:NewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject2"),
                message = Lang:t("mail.message2")
            })
        elseif Config.Phone == "qs-phone" then
            TriggerServerEvent('qs-smartphone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject2"),
                message = Lang:t("mail.message2"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        end
        callPolice(missionTarget)
    elseif robberystopped == false then
        if Config.Phone == "qb-phone" then
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject2"),
                message = Lang:t("mail.message2"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        elseif Config.Phone == "gks-phone" then
            TriggerServerEvent('gksphone:NewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject2"),
                message = Lang:t("mail.message2")
            })
        elseif Config.Phone == "qs-phone" then
            TriggerServerEvent('qs-smartphone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject2"),
                message = Lang:t("mail.message2"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        end
    end
    Citizen.Wait(Config.Cooldown) -- Needs a better option. So that client cant just reconnect and reset timer that way.
    canStart = true
    robberyCreated = false
    ongoing = false
end

function cooldownNextRobberyFail()
    RemoveBlip(targetBlip)
    exports['qb-core']:HideText()
    Citizen.Wait(3000)
    if robberystopped == true then
        if Config.Phone == "qb-phone" then
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject3"),
                message = Lang:t("mail.message3"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        elseif Config.Phone == "gks-phone" then
            TriggerServerEvent('gksphone:NewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject3"),
                message = Lang:t("mail.message3")
            })
        elseif Config.Phone == "qs-phone" then
            TriggerServerEvent('qs-smartphone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject3"),
                message = Lang:t("mail.message3"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        end
        callPolice(missionTarget)
    elseif robberystopped == false then
        if Config.Phone == "qb-phone" then
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject3"),
                message = Lang:t("mail.message3"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        elseif Config.Phone == "gks-phone" then
            TriggerServerEvent('gksphone:NewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject3"),
                message = Lang:t("mail.message3")
            })
        elseif Config.Phone == "qs-phone" then
            TriggerServerEvent('qs-smartphone:server:sendNewMail', {
                sender =  Lang:t("mail.sender"),
                subject = Lang:t("mail.subject3"),
                message = Lang:t("mail.message3"),
                button = {
                    enabled = true,
                    buttonEvent = "6x_houserobbery:getrandomhouseloc"
                }
            })
        end
    end
    Citizen.Wait(Config.Cooldown) -- Needs a better option. So that client cant just reconnect and reset timer that way.
    canStart = true
    robberyCreated = false
    ongoing = false
end

function isNight()
	local hour = GetClockHours()
	if hour > Config.Night[1] or hour < Config.Night[2] then
		return true
	end
	return false
end

function stopRobbery()
    QBCore.Functions.Notify(Lang:t('notify.alarm'), 'error')
    robberystopped = true
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
                if (GetEntityModel(GetPlayerPed(-1)) == freemode) then
                    callPolice(missionTarget)
                    TriggerEvent("6x_houserobbery:goinside", missionTarget)
                    ongoing = true
                    QBCore.Functions.Notify(Lang:t("notify.gotthedoor"), "success")
                    if (GetEntityModel(GetPlayerPed(-1)) == freemode) then
                        QBCore.Functions.Notify(Lang:t("notify.donthavemask"))
                    end
                    FailedAttemps = 0
                    SucceededAttempts = 0
                    NeededAttempts = 0
                end
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
                if (GetEntityModel(GetPlayerPed(-1)) == freemode) then
                    callPolice(missionTarget)
                    TriggerEvent("6x_houserobbery:goinside", missionTarget)
                    ongoing = true
                    QBCore.Functions.Notify(Lang:t("notify.gotthedoor"), "success")
                    --if (GetEntityModel(GetPlayerPed(-1)) == freemode) then
                    if GetPedDrawableVariation(PlayerPedId(), 1) == 0 then
                        QBCore.Functions.Notify(Lang:t("notify.donthavemask"))
                    end
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

    elseif Config.Minigame == "ox_lib" then
        local success = lib.skillCheck(Config.SkillDifficulty)
        local rand = Config.SkillRepeatTimes

        if rand == 1 then
            QBCore.Functions.Notify(Lang:t("notify.messedup"), "error")
            TriggerServerEvent("6x_houserobbery:server:takeitem")
            callPolice(missionTarget)
            robberyStarted = false
            ongoing = false
            cooldownNextRobberyFail()
            Citizen.Wait(500)
            exports['qb-core']:HideText()
        end
    
        if success then
            if (GetEntityModel(GetPlayerPed(-1)) == freemode) then
                callPolice(missionTarget)
                TriggerEvent("6x_houserobbery:goinside", missionTarget)
                ongoing = true
                QBCore.Functions.Notify(Lang:t("notify.gotthedoor"), "success")
                --if (GetEntityModel(GetPlayerPed(-1)) == freemode) then
                if GetPedDrawableVariation(PlayerPedId(), 1) == 0 then
                    QBCore.Functions.Notify(Lang:t("notify.donthavemask"))
                end
            end
        end
    
    end
end

function callPolice(missionTarget)
    exports[Config.Dispatch]:HouseRobbery()
    QBCore.Functions.Notify(Lang:t('notify.alarm'), 'error')
    Citizen.Wait(15000)
end

--[[RegisterCommand('start', function()
    TriggerEvent('6x_houserobbery:startrobbery')
end)]]
