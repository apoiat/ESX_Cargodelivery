ESX = nil
local PlayerData = {}

event_is_running = false
event_time_passed = 0.0
event_destination = nil
event_vehicle = nil
event_scenario = nil
police_alerted = false
event_alarm_time = 0.0
event_delivery_blip = nil
local talktodealer = true



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Create blips
Citizen.CreateThread(function()

		local blip = AddBlipForCoord(Config.CargoProviderLocation.x, Config.CargoProviderLocation.y, Config.CargoProviderLocation.z)

		SetBlipSprite (blip, 94)
		SetBlipColour(blip,1)
		--SetBlipDisplay(blip, v.Blip.Display)
		--SetBlipScale  (blip, v.Blip.Scale)
		--SetBlipColour (blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Cargo Provider')
		EndTextCommandSetBlipName(blip)
end)




local options = {
    x = 0.1,
    y = 0.2,
    width = 0.2,
    height = 0.04,
    scale = 0.4,
    font = 0,
    menu_title = "NPC",
    menu_subtitle = "Cargo Dealer",
    color_r = 0,
    color_g = 128,
    color_b = 255,
}




Citizen.CreateThread(function()

	RequestModel(Config.NPCHash)
	while not HasModelLoaded(Config.NPCHash) do
	Wait(1)

	end

	--PROVIDER
		meth_dealer_seller = CreatePed(1, Config.NPCHash, Config.CargoProviderLocation.x, Config.CargoProviderLocation.y, Config.CargoProviderLocation.z, Config.CargoProviderLocation.h, false, true)
		SetBlockingOfNonTemporaryEvents(meth_dealer_seller, true)
		SetPedDiesWhenInjured(meth_dealer_seller, false)
		SetPedCanPlayAmbientAnims(meth_dealer_seller, true)
		SetPedCanRagdollFromPlayerImpact(meth_dealer_seller, false)
		SetEntityInvincible(meth_dealer_seller, true)
		FreezeEntityPosition(meth_dealer_seller, true)
		TaskStartScenarioInPlace(meth_dealer_seller, "WORLD_HUMAN_SMOKING", 0, true);

end)





Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		local pVehicle = GetVehiclePedIsUsing(GetPlayerPed(-1))
		local v = Config.CargoProviderLocation 
			if(Vdist(v.x, v.y, v.z, pos.x, pos.y, pos.z) < 2.0)then
				DisplayHelpText("Press ~INPUT_CONTEXT~ to interact with ~y~Cargo Dealer")
				if(IsControlJustReleased(1, 38))then
						if talktodealer then
						    Citizen.Wait(500)
							CargoMenu()
							Menu.hidden = false
							talktodealer = false
						else
							talktodealer = true
						end
				end
				Menu.renderGUI(options)
			end

			if event_is_running then

				if pVehicle == event_vehicle then

					local dpos = event_destination
					local delivery_point_distance = Vdist(dpos.x, dpos.y, dpos.z, pos.x, pos.y, pos.z)
					if delivery_point_distance < 50.0 then
						DrawMarker(1, dpos.x, dpos.y, dpos.z,0, 0, 0, 0, 0, 0, 3.5, 3.5, 3.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
						if delivery_point_distance < 1.5 then
							DeliverCargo()
						end
					end
				else 
					 DrawMissionText("Get back inside the vehicle!", 1000)
				end
			end
	end
end)



-- CANCEL CHECK IN CASE PLAYER DIED OR VEHICLE DESTROYED.

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
				if event_is_running then

						if IsPedDeadOrDying(GetPlayerPed(-1)) then
							ResetCargo()
							DisplayMissionFailed('You died!')
						end

						if GetVehicleEngineHealth(event_vehicle) < 20 and event_vehicle ~= nil then
							ResetCargo()
							DisplayMissionFailed('Cargo was seriously damaged.')
						end

						if event_time_passed > 1800 then
							ResetCargo()
							DisplayMissionFailed('Cargo Delivery expired.')
						end

						event_time_passed = event_time_passed + 5
				end
		end
end)


function DrawProviderBlip()

	local blip = AddBlipForCoord(Config.CargoProviderLocation.x, Config.CargoProviderLocation.y, Config.CargoProviderLocation.z)
	SetBlipSprite(blip,94)
	SetBlipColour(blip,1)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Cargo Provider')
	EndTextCommandSetBlipName(blip)

end

function DrawMissionText(m_text, showtime)
    ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

function CargoMenu()
	ClearMenu()
    options.menu_title = "Cargo Dealer"
    for i = 1, #Config.Scenarios do
    	Menu.addButton("Buy Cargo - $" .. Config.Scenarios[i].CargoCost, "PurchaseCargo", i)
   	end
    Menu.addButton("Close","CloseMenu",nil) 
end



function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end


function AlertThePolice()
	local PlayerData = ESX.GetPlayerData()
	local playerPed = PlayerPedId()
	PedPosition		= GetEntityCoords(playerPed)
	
	if event_is_running then
		
		local vehicle_plate = string.char(math.random(65, 90), math.random(65, 90), math.random(65, 90)) .. " " .. math.random(100,999)

		SetVehicleNumberPlateText(event_vehicle, vehicle_plate)
	

		local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }

    	TriggerServerEvent('esx_addons_gcphone:startCall', 'police', ":anon: Eyes on the Prize! Ipopto oxima me pinakida [ " .. vehicle_plate .. " ] anevenei voria!", PlayerCoords, {

			PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
		})

    	for i = 1, #Config.AlertExtraSocieties do

    		if PlayerData.job.name ~= Config.AlertExtraSocieties[i] then
    	
    			TriggerServerEvent('esx_addons_gcphone:startCall', Config.AlertExtraSocieties[i], ":anon: Eyes on the Prize! Ipopto oxima me pinakida [ " .. vehicle_plate .. " ] anevenei voria!", PlayerCoords, {
				PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
				})

			end
		end
	end


end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function CloseMenu()
		Menu.hidden = true
end

function ResetCargo()

	TriggerServerEvent('esx_cargodelivery:resetEvent')
	SetEntityAsNoLongerNeeded(event_vehicle)
	SetEntityAsMissionEntity(event_vehicle,true,true)
	DeleteEntity(event_vehicle)

	RemoveBlip(event_delivery_blip)
	event_delivery_blip	= nil
	event_time_passed = 0.0
	event_is_running = false
	event_destination = nil
	event_vehicle = nil
	event_scenario = nil
	police_alerted = false
	local talktodealer = true

end

function DeliverCargo()

	ESX.TriggerServerCallback('esx_cargodelivery:sellCargo', function(sold)
			if sold then

			end
			end, Config.Scenarios[event_scenario].CargoReward)
		
	local vehicle = GetVehiclePedIsUsing(GetPlayerPed(-1))

	SetEntityAsNoLongerNeeded(vehicle)
	SetEntityAsMissionEntity(vehicle,true,true)
	DeleteEntity(vehicle)

	RemoveBlip(event_delivery_blip)
	event_delivery_blip	= nil
	
	event_is_running = false
	event_destination = nil
	event_time_passed = 0.0
	event_vehicle = nil
	event_scenario = nil
	police_alerted = false
	local talktodealer = true


end

function SpawnCargoVehicle(scenario)

	Citizen.Wait(0)
	local myPed = GetPlayerPed(-1)
	local player = PlayerId()
	local vehicle = GetHashKey(Config.Scenarios[scenario].VehicleName)

    RequestModel(vehicle)

	while not HasModelLoaded(vehicle) do
		Wait(1)
	end
	
	colors = table.pack(GetVehicleColours(veh)) 
	extra_colors = table.pack(GetVehicleExtraColours(veh))
	plate = math.random(100, 900)
	local spawned_car = CreateVehicle(vehicle, Config.Scenarios[scenario].SpawnPoint.x, Config.Scenarios[scenario].SpawnPoint.y, Config.Scenarios[scenario].SpawnPoint.z, false, true)

	SetEntityHeading(spawned_car, Config.Scenarios[scenario].SpawnPoint.h)
	SetVehicleOnGroundProperly(spawned_car)
	SetPedIntoVehicle(myPed, spawned_car, - 1)
	SetModelAsNoLongerNeeded(vehicle)
	Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
	CruiseControl = 0
	DTutOpen = false
	SetEntityVisible(myPed, true)
	FreezeEntityPosition(myPed, false)
	event_vehicle = spawned_car

end







function PurchaseCargo(scenario)

	local cops_online = 0
	event_scenario = scenario


	if event_is_running == true then
		
		drawNotification("You are already on a cargo delivery mission.")
		goto done

	end

	print("MinCopsOnline: " .. Config.Scenarios[scenario].MinCopsOnline .. " ||  CargoCost:  " .. Config.Scenarios[scenario].CargoCost .. "")
	
	ESX.TriggerServerCallback('esx_cargodelivery:getCopsOnline', function(police)

		police = police 

		if police >= Config.Scenarios[scenario].MinCopsOnline then
			
			ESX.TriggerServerCallback('esx_cargodelivery:buyCargo', function(bought)
			if bought then

				drawNotification("Succesffully purchased cargo.")

				SpawnCargoVehicle(scenario)
				
				event_is_running = true

				math.random(); math.random(); math.random()
				random_destination = math.random(1, #Config.CargoDeliveryLocations)
				event_destination = Config.CargoDeliveryLocations[random_destination]

				ESX.SetTimeout(math.random(Config.AlertCopsDelayRangeStart * 1000, Config.AlertCopsDelayRangeEnd * 1000), function()
    				AlertThePolice()
				end)

				event_delivery_blip	 = AddBlipForCoord(event_destination.x,event_destination.y,event_destination.z)
				SetBlipSprite(event_delivery_blip,94)
				SetBlipColour(event_delivery_blip,1)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString('Cargo Delivery')
				EndTextCommandSetBlipName(event_delivery_blip)
				SetBlipAsShortRange(event_delivery_blip,true)
				SetBlipAsMissionCreatorBlip(event_delivery_blip,true)
				SetBlipRoute(event_delivery_blip, 1)

			else
				
			end
			end, Config.Scenarios[scenario].CargoCost)
		

		else 
			drawNotification("You need at least ~b~" .. Config.Scenarios[scenario].MinCopsOnline .. " cops ~w~online.")
			
		end

	end)

	::done::

end



function DisplayMissionFailed(label)

	TriggerEvent('esx:showNotification', '~r~Mission Failed: ~w~' .. label)
	PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
    Citizen.Wait(300)
    PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
    Citizen.Wait(300)
    PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)

end