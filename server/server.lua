local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)
VorpInv = exports.vorp_inventory:vorp_inventoryApi()


Citizen.CreateThread(function()
	Citizen.Wait(2000)
	VorpInv.RegisterUsableItem("tamis", function(data)
		TriggerClientEvent('goldpanner:StartPaning', data.source)
		VorpInv.CloseInv(data.source)
	end)
end)

Citizen.CreateThread(function()
    VorpInv.RegisterUsableItem("seau_or", function(data)
		TriggerClientEvent('SunnyGold:startWatering', data.source)
        VorpInv.CloseInv(data.source)
	end)
end)

Citizen.CreateThread(function()
    VorpInv.RegisterUsableItem("pickaxe", function(data)
		local krompacpici = math.random(1,100)

		if krompacpici == 15 then
			TriggerClientEvent("GraveRobbing:posralsito",  data.source)
			Wait(9000)
			VorpInv.subItem(data.source, "pickaxe", 1)
			SendWebhook(Config.webhook, data.source, "pelle cassée") -- for webhook
		else
			TriggerEvent("vajco:coords", data.source)
			TriggerClientEvent('SunnyGold:startDigging', data.source)
		end
		
        VorpInv.CloseInv(data.source)
	end)
end)

RegisterNetEvent("search")
AddEventHandler("search", function(j, istable)
    local _source = source
	local playercoords = GetEntityCoords(GetPlayerPed(_source))
    local chance =  math.random(1,20)
	local reward = {}
	local multiplicator = 1 * Config.WaterTypes[j].chance

	if istable == true then
		multiplicator = multiplicator * Config.tablebuff
	end

	if GetDistanceBetweenCoords( playercoords, Config.IndianCoords, false) < Config.IndianDist then
		multiplicator = multiplicator * Config.buffIndian
	end
	
	for k,v in pairs(Config.Items) do 
		if v.id == "pepite_dor" then
			if v.chance*multiplicator >= chance then
				table.insert(reward,v)
			end
		else
			if v.chance >= chance then
				table.insert(reward,v)
			end
		end
	end

    local chance2 = math.random(1,#reward)
	if(reward[chance2].id ~= "null")then
		if VorpInv.canCarryItems(_source, reward[chance2].quantity) == true then
			if VorpInv.canCarryItem(_source, reward[chance2].id, reward[chance2].quantity)then
				VorpInv.addItem(_source, reward[chance2].id, reward[chance2].quantity)
				if reward[chance2].id == "pepite_dor" then
					TriggerClientEvent("vorp:TipBottom", _source, "Quelque chose scintille...", 3000)
				end
			else
				TriggerClientEvent("vorp:TipBottom", _source, "Tu ne peux plus porter de chose", 3000)
			end
		end
	end
end)

function GetDistanceBetweenCoords(coords1, coords2, is3D)
    if(is3D)then
        local dx = coords1.x - coords2.x
        local dy = coords1.y - coords2.y
        local dz = coords1.z - coords2.z
        return math.sqrt (dx * dx + dy * dy + dz * dz)
    else
        local dx = coords1.x - coords2.x
        local dy = coords1.y - coords2.y
        return math.sqrt (dx * dx + dy * dy)
    end
end