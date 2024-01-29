local entity
local Panning = false
local lastcoords = {
    {x = 0, y = 0, z = 0},
}
local Group_prompt = GetRandomIntInRange(0, 0xffffff)

RegisterNetEvent('goldpanner:StartPaning')
AddEventHandler('goldpanner:StartPaning', function()
    if not Panning then 
        Panning = true
        local ped = PlayerPedId()
        local Pcoords = GetEntityCoords(ped)
        local Water = Citizen.InvokeNative(0x5BA7A68A346A5A91,Pcoords.x, Pcoords.y, Pcoords.z)
        local foundwater = false

        if Water == nil and not IsPedOnMount(ped) and not IsPedInAnyVehicle(ped) and not IsPedDeadOrDying(ped) then
            TriggerEvent("vorp:TipBottom", "Vous n'êtes pas dans une rivière", 10000)
            TriggerEvent("goldpanner:Stop")
            return
        end

        local isFree = true
        for i,coord in pairs(lastcoords)do 
            if GetDistanceBetweenCoords(coord.x,coord.y,coord.z, Pcoords.x, Pcoords.y, Pcoords.z, false) < 1.5 then
                isFree = false
                break
            end
        end
        if isFree == true then
            table.insert(lastcoords, Pcoords)
        else
            TriggerEvent("vorp:TipBottom", "Vous avez déjà cherchez de l'or par ici", 10000)
            TriggerEvent("goldpanner:Stop")
            return
        end
        
        

        for i,water in pairs(Config.WaterTypes) do
            if Water == water.waterzone then
                if IsEntityInWater(ped) == false then
                    TriggerEvent("vorp:TipBottom", "Vous n'êtes pas dans l'eau", 10000)
                    TriggerEvent("goldpanner:Stop")
                    return
                end
                foundwater = true
                FreezeEntityPosition(PlayerPedId(), true) 
                
                
                for j=0, math.random(3,10) do
                    if Panning == false then 
                        TriggerEvent("goldpanner:Stop")
                        return
                    end

                    CrouchAnimAndAttach()
                    Wait(3000)
                    
                    local testplayer = exports["syn_minigame"]:taskBar(Config.miniGameDifficulty,7)
                    if testplayer == 100 then 
                        ClearPedTasks(ped)
                        GoldShake()
                        w = math.random(15000,20000)
                        Wait(w)
                        TriggerServerEvent("search", i, false)
                    else
                        break
                    end
                    ClearPedTasks(ped)
                    DeleteObject(entity)
                    DeleteEntity(entity)
                end
                TriggerEvent("goldpanner:Stop")
                break
            end
            foundwater = false
        end

        if foundwater == false then
            TriggerEvent("vorp:TipBottom", Config.oro_no_recoger, 10000)
            TriggerEvent("goldpanner:Stop")
            return
        end
    end
end)



RegisterNetEvent("goldpanner:Stop")
AddEventHandler("goldpanner:Stop", function()
    ClearPedTasks(PlayerPedId())
    DeleteObject(entity)
    DeleteEntity(entity)
    FreezeEntityPosition(PlayerPedId(), false)
    Panning = false
end)


function CrouchAnimAndAttach()
    local dict = "script_rc@cldn@ig@rsc2_ig1_questionshopkeeper"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end

    local ped = PlayerPedId()
    local Pcoords = GetEntityCoords(ped)
    local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_HAND")
    local modelHash = GetHashKey("P_CS_MININGPAN01X")
    LoadModel(modelHash)
    entity = CreateObject(modelHash, Pcoords.x+0.3, Pcoords.y,Pcoords.z, true, false, false)
    SetEntityVisible(entity, true)
    SetEntityAlpha(entity, 255, false)
    Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
    SetModelAsNoLongerNeeded(modelHash)
    AttachEntityToEntity(entity,ped, boneIndex, 0.2, 0.0, -0.2, -100.0, -50.0, 0.0, false, false, false, true, 2, true)

    TaskPlayAnim(ped, dict, "inspectfloor_player", 1.0, 8.0, -1, 1, 0, false, false, false)
end

function GoldShake()
    local dict = "script_re@gold_panner@gold_success"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), dict, "SEARCH02", 1.0, 8.0, -1, 1, 0, false, false, false)
end


function LoadModel(model)
    local attempts = 0
    while attempts < 100 and not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
        attempts = attempts + 1
    end
    return IsModelValid(model)
end

Citizen.CreateThread(function()
    --Creation du prompt
    Citizen.CreateThread(function()
        Prompt = PromptRegisterBegin() --Init Prompt
        PromptSetControlAction(Prompt, 0xB2F377E8) -- Set de la touche
        str = CreateVarString(10, 'LITERAL_STRING', "arrêter")

        PromptSetText(Prompt, str)
        PromptSetEnabled(Prompt, 1)
        PromptSetVisible(Prompt, 1)
        PromptSetStandardMode(Prompt,1)
        PromptSetGroup(Prompt, Group_prompt)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C,Prompt, true)
        PromptRegisterEnd(Prompt)
    end)
    
    

	while true do
        Citizen.Wait(5)
        if Panning == true then  
            --Instanciation group prompt
            local label = CreateVarString(10, 'LITERAL_STRING', "Vous cherchez de l'or ... ")
            PromptSetActiveGroupThisFrame(Group_prompt, label)

            if Citizen.InvokeNative(0xC92AC953F0A982AE,Prompt,0) then
                Panning = false
            end
        end
    end
end)    

RegisterCommand(
	"river" --[[ string ]], 
	function() 
        local Pcoords = GetEntityCoords(PlayerPedId())
        local Water = Citizen.InvokeNative(0x5BA7A68A346A5A91,Pcoords.x, Pcoords.y, Pcoords.z)
        print("River: "..Water)
    end, 
	false --[[ boolean ]]
)