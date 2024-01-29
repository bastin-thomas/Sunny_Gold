local Group_prompt = GetRandomIntInRange(0, 0xffffff)
local Group_prompt2 = GetRandomIntInRange(0, 0xffffff)
local Prompt
local Prompt2
local Prompt3
local craftingInProgress = 0
local entity
local Filling = false
local Digging = false
local stand = nil
local smoke = nil
local shovel_in_hand = nil
local bucket_in_hand = nil
local countCraft = 0
local hasWaterInside = false
local hasDirtInside = false
local _k = -1
local Cleaning = false

Citizen.CreateThread(function()
    Citizen.CreateThread(function()
        Prompt = PromptRegisterBegin() --Init Prompt
        PromptSetControlAction(Prompt, 0xE30CD707) -- Set de la touche
        str = CreateVarString(10, 'LITERAL_STRING', "Utiliser")

        PromptSetText(Prompt, str)
        PromptSetEnabled(Prompt, 1)
        PromptSetVisible(Prompt, 1)
        PromptSetStandardMode(Prompt,1)
        PromptSetGroup(Prompt, Group_prompt)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C,Prompt, true)
        PromptRegisterEnd(Prompt)
    end)

    Citizen.CreateThread(function()
        Prompt2 = PromptRegisterBegin() --Init Prompt
        PromptSetControlAction(Prompt2, 0xB2F377E8) -- Set de la touche
        str = CreateVarString(10, 'LITERAL_STRING', "arrêter")

        PromptSetText(Prompt2, str)
        PromptSetEnabled(Prompt2, 1)
        PromptSetVisible(Prompt2, 1)
        PromptSetStandardMode(Prompt2,1)
        PromptSetGroup(Prompt2, Group_prompt2)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C,Prompt2, true)
        PromptRegisterEnd(Prompt2)
    end)

	while true do
        Citizen.Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
		local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
        local isNearStill = DoesObjectOfTypeExistAtCoords(x, y, z, 1.0, GetHashKey(Config.brewPop), true)		
		
        if isNearStill then 
            local entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, GetHashKey("p_goldcradlestand01x"))
            if GetEntityAlpha(entity) == 255 then
                if Cleaning == true then
                    local label = CreateVarString(10, 'LITERAL_STRING', "Table d'orpaillage")
                    PromptSetActiveGroupThisFrame(Group_prompt2, label)
                    if Citizen.InvokeNative(0xC92AC953F0A982AE,Prompt2,0) then
                        Cleaning = false
                    end
                else
                    local label = CreateVarString(10, 'LITERAL_STRING', "Table d'orpaillage")
                    PromptSetActiveGroupThisFrame(Group_prompt, label)
                    if Citizen.InvokeNative(0xC92AC953F0A982AE,Prompt,0) then
                        TriggerEvent("SunnyGold:Craft")
                    end
                end
            end    
        end
    end
end)

RegisterNetEvent('SunnyGold:Craft')
AddEventHandler('SunnyGold:Craft', function()
    if Config.Debug == true then
        print("craftingInProgress: "..craftingInProgress)
    end

    if craftingInProgress == 0 and hasDirtInside == false then
        hasDirtInside = false
        hasWaterInside = false

        TriggerEvent("vorp:TipBottom", "Vous devez récolter de la boue", 5000)
        return
    end

    if hasDirtInside == true then
        craftingInProgress = 1
        hasDirtInside = false
        hasWaterInside = false
    end

    if craftingInProgress == 1 then
        TriggerEvent("SunnyGold:putdirtintotable")
        return
    end

    if craftingInProgress == 2 then
        if hasWaterInside == false then
            TriggerEvent("vorp:TipBottom", "Vous n'avez pas d'eau", 5000)
            return
        end

        if countCraft < 3 then
            TriggerEvent("SunnyGold:trie")
            hasWaterInside = false
            countCraft = countCraft + 1
        else
            countCraft = 0
            craftingInProgress = 0
            Digging = false
            Filling = false
            hasWaterInside = false
            hasDirtInside = false
            TriggerEvent("vorp:TipBottom", "Vous avez fini de nettoyé la boue", 5000)
        end
        return
    end
end)

-- Seau
RegisterNetEvent('SunnyGold:startDigging')
AddEventHandler('SunnyGold:startDigging', function()
    ClearPedTasks(PlayerPedId())
	DeleteObject(bucket_in_hand)
    DeleteEntity(bucket_in_hand)
    hasWaterInside = false
    hasDirtInside = false

    if IsEntityInWater(PlayerPedId()) == false then
        Digging = false
        return
    end

    if craftingInProgress > 0 then
        TriggerEvent("vorp:TipBottom", "Finissez de laver votre boue.", 5000)
        Digging = false
        return
    end

    if not Digging then 
        Digging = true
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local Water = Citizen.InvokeNative(0x5BA7A68A346A5A91,coords.x, coords.y, coords.z)

        local founddirt = false
        for k,water in pairs(Config.WaterTypes) do
            if Water == water.waterzone then
                founddirt = true                
                local pos = GetEntityCoords(PlayerPedId(), true)
                shovel_in_hand = CreateObject("p_shovel02x", pos.x, pos.y, pos.z, true, true, false)
                AttachEntityToEntity(shovel_in_hand, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "SKEL_L_Finger32"), -0.02, -0.06, -0.62, -4.5, -1.0, -79.0, false, false, true, false, 0, true, false, false)
                playCustomAnim("amb_wander@code_human_2handshovel_wander@base","base", -1, 25)

                local testplayer = exports["syn_minigame"]:taskBar(Config.miniGameDifficulty,7)
                if testplayer == 100 then 
                    digging()
                    hasDirtInside = true
                    TriggerEvent("vorp:TipBottom", "Vous récupérez de la boue", 5000)
                    Digging = false
                    _k = k
                    return
                else
                    hasDirtInside = false
                    TriggerEvent("vorp:TipBottom", "Vous n'avez pas réussi", 5000)
                end
                ClearPedTasks(PlayerPedId())
	            DeleteObject(shovel_in_hand)
                DeleteEntity(shovel_in_hand)
                break
            end
        end
        Digging = false

        if founddirt == false then
            hasDirtInside = false
            Digging = false
            TriggerEvent("vorp:TipBottom", "Il n'y a pas beaucoup d'or ici.", 5000)
        end
    end
end)

RegisterNetEvent('SunnyGold:putdirtintotable')
AddEventHandler('SunnyGold:putdirtintotable', function()
    if craftingInProgress > 1 then
        TriggerEvent("vorp:TipBottom", "Vous avez déjà mis de la boue dans la table.", 5000)
        return
    end

    TriggerEvent("vorp:TipBottom", "Vous posé la boue sur la table.", 5000)
    ClearPedTasks(PlayerPedId())
	DeleteObject(shovel_in_hand)
    DeleteEntity(shovel_in_hand)
    craftingInProgress = 2
end)


RegisterNetEvent('SunnyGold:trie')
AddEventHandler('SunnyGold:trie', function(ID)
        Cleaning = true
        putwater()
        FreezeEntityPosition(PlayerPedId(), true)
        DeleteObject(bucket_in_hand)
        DeleteEntity(bucket_in_hand) 
        DeleteObject(bucket_in_hand)
        DeleteEntity(bucket_in_hand)

        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CLEAN_TABLE'), 120000, true, false, false, false)
        Wait(2000)
        for i=1, math.random(3,9) do
            if Cleaning == false then
                ClearPedTasks(PlayerPedId())
                FreezeEntityPosition(PlayerPedId(), false)
                return
            end

            local testplayer = exports["syn_minigame"]:taskBar(Config.miniGameDifficulty,7)
            if testplayer == 100 then
                w = math.random(5000,15000)
                Wait(w)
                TriggerServerEvent("search", _k, true)
            else
                ClearPedTasks(PlayerPedId())
                FreezeEntityPosition(PlayerPedId(), false)
                Cleaning = false
                return
            end
        end
        ClearPedTasks(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
        Cleaning = false
end)


RegisterNetEvent('SunnyGold:startWatering')
AddEventHandler('SunnyGold:startWatering', function()
    hasDirtInside = false
    hasWaterInside = false

    if hasWaterInside == true then
        TriggerEvent("vorp:TipBottom", "Vous avez déjà de l'eau", 5000)
        Filling = false
        return
    end
    if IsEntityInWater(PlayerPedId()) == false then
        TriggerEvent("vorp:TipBottom", "Il n'y a pas d'eau ici.", 5000)
        Filling = false
        return
    end
    if not Filling then 
        ClearPedTasks(PlayerPedId())
	    DeleteObject(bucket_in_hand)
        DeleteEntity(bucket_in_hand)
        if IsEntityInWater(PlayerPedId()) == false then
            TriggerEvent("vorp:TipBottom", "Il n'y a pas d'eau ici.", 5000)
            Filling = false
            return
        end
        Filling = true
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local Water = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z)

        for k,water in pairs(Config.WaterTypes) do
            if Water == water.waterzone then
                Wait(1000)
                local testplayer = exports["syn_minigame"]:taskBar(Config.miniGameDifficulty,7)
                if testplayer == 100 then 
                    watering_bucket()
                    hasWaterInside = true
                    _k = k
                    break
                else
                    hasWaterInside = false
                    TriggerEvent("vorp:TipBottom", "Vous n'avez pas réussi", 5000)
                end
            end
        end
        Filling = false
    end
end)















function watering_bucket()
        FreezeEntityPosition(PlayerPedId(), true)
        ClearPedTasks(PlayerPedId())
        DeleteObject(bucket_in_hand)
        DeleteEntity(bucket_in_hand)
        ClearPedTasks(PlayerPedId())
	    DeleteObject(shovel_in_hand)
        DeleteEntity(shovel_in_hand)
        local pos = GetEntityCoords(PlayerPedId(), true)
        ClearPedTasks(PlayerPedId())
        DeleteObject(bucket_in_hand)
        playCustomAnim("amb_work@world_human_bucket_fill@female_a@stand_exit_withprop","exit_front", -1, 1)
        Citizen.Wait(100)
        bucket_in_hand = CreateObject("p_bucket03x", pos.x, pos.y, pos.z, true, true, false)
        AttachEntityToEntity(bucket_in_hand, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "SKEL_R_Finger43"), 0.01, 0.0, 0.0, 174.0, -32.0, 187.0, false, false, true, false, 0, true, false, false)
        Citizen.Wait(1300)
        DeleteObject(bucket_in_hand)
        Citizen.Wait(500)
        ClearPedTasks(PlayerPedId())
        Citizen.Wait(50)
        playCustomAnim("amb_camp@world_camp_jack_es@bucket_pickup@empty@male_a@base","base", -1, 25)
        bucket_in_hand = CreateObject("p_bucketcampmil01x", pos.x, pos.y, pos.z, true, true, false)
        AttachEntityToEntity(bucket_in_hand, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), -0.03, 0.02, -0.02, 0.0, 0.0, -94.0, false, false, true, false, 0, true, false, false)
        FreezeEntityPosition(PlayerPedId(), false)
end

function putwater()
    playAnim("amb_camp@world_camp_jack_es_bucket_pour@male_a@base", "base", -1, 25)
    Citizen.Wait(3000)
    DeleteEntity(bucket_in_hand)
    Citizen.Wait(0)

    local pos = GetEntityCoords(PlayerPedId(), true)
    playCustomAnim("mech_strafe@generic@first_person@scenarios@bucket","idle", -1, 25)
    
    Citizen.Wait(200)
    bucket_in_hand = CreateObject("p_bucketcampmil01x", pos.x, pos.y, pos.z, true, true, false)
    AttachEntityToEntity(bucket_in_hand, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), -0.04, 0.01, 0.0, 0.0, 0.0, -104.0, false, false, true, false, 0, true, false, false)
    
    water_in_bucket = false
    ClearPedTasks(PlayerPedId())
    DeleteObject(bucket_in_hand)
end

function playCustomAnim(dict,name, time, flag)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
	TaskPlayAnim(PlayerPedId(), dict, name, 1.0, 1.0, time, flag, 0, true, 0, false, 0, false)  
end


function playAnim(dict,name, time, flag)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict, name, 1.0, 1.0, time, flag, 0, true, 0, false, 0, false)  
end


function digging()
    local hold_shovel
    local pos = GetEntityCoords(PlayerPedId(), true)
	hold_shovel = false

	ClearPedTasks(PlayerPedId())
	DeleteObject(shovel_in_hand)
	playCustomAnim("amb_work@world_human_gravedig@working@male_b@base","base", -1, 1)
	Citizen.Wait(100)

	shovel_in_hand = CreateObject("p_shovel02x", pos.x, pos.y, pos.z, true, true, false)
	AttachEntityToEntity(shovel_in_hand, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
	Citizen.Wait(2500)

	ClearPedTasks(PlayerPedId())
	DeleteObject(shovel_in_hand)
	hold_shovel = true
	Citizen.Wait(50)
	shovel_in_hand = CreateObject("p_shovel02x", pos.x, pos.y, pos.z, true, true, false)
	AttachEntityToEntity(shovel_in_hand, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "SKEL_L_Finger32"), -0.02, -0.06, -0.62, -4.5, -1.0, -79.0, false, false, true, false, 0, true, false, false)
	playCustomAnim("amb_wander@code_human_2handshovel_wander@base","base", -1, 25)
end