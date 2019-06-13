ESX = nil
active_cargo_scenario = -1
LastDelivery = 0.0


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetCopsOnline()

	local PoliceConnected = 0
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if xPlayer.job.name == 'police' then
			PoliceConnected = PoliceConnected + 1
		end
	end

	return PoliceConnected
end


RegisterServerEvent('esx_cargodelivery:activateCargoAllPlayers')
AddEventHandler('esx_cargodelivery:activateCargoAllPlayers', function(source, vehicle)

	ActivateCargo(source, vehicle)

end)

RegisterServerEvent('esx_cargodelivery:resetEvent')
AddEventHandler('esx_cargodelivery:resetEvent', function()
	LastDelivery = 0.0
	active_cargo_scenario = -1

	local players = ESX.GetPlayers()

	for i=1, #players, 1 do
		if players[i] ~= source then TriggerClientEvent('esx_cargodelivery:resetCargo', players[i]) end
	end
end)




ESX.RegisterServerCallback('esx_cargodelivery:getCopsOnline', function(source, cb)
	cb(GetCopsOnline())
end)






ESX.RegisterServerCallback('esx_cargodelivery:sellCargo', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.Scenarios[scenario].CargoReward

	if Config.UsesBlackMoney then
	
		xPlayer.addAccountMoney('black_money', price)
	
	else

		xPlayer.addMoney(price)

	end
	
	TriggerClientEvent('esx:showNotification', source, "You eanred ~r~" .. price .. "~w~ for delivering the cargo.")

	cb(true)

	TriggerEvent('esx_cargodelivery:resetEvent')

end)





ESX.RegisterServerCallback('esx_cargodelivery:buyCargo', function(source, cb, scenario)
	
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.Scenarios[scenario].CargoCost

	if (os.time() - LastDelivery) < 200.0 and LastDelivery ~= 0.0 then

		TriggerClientEvent('esx:showNotification', source, "Delivery in progress")
		cb(false)

	else 

		active_cargo_scenario = scenario

		police_alarm_time = os.time() + math.random(10000, 20000)

		if Config.UsesBlackMoney then

			if xPlayer.getAccount('black_money').money >= price then

				xPlayer.removeAccountMoney('black_money', price)

				LastDelivery = os.time()

				TriggerClientEvent('esx_cargodelivery:activateCargo', )

				cb(true)
			else

				TriggerClientEvent('esx:showNotification', source, "Not enough ~r~black money~w~.")
	

				cb(false)
			end

		else 

				if xPlayer.getMoney() >= price then

				xPlayer.removeMoney(price)

				LastDelivery = os.time()

				cb(true)
			else

				TriggerClientEvent('esx:showNotification', source, "Not enough ~r~money~w~.")
	
				cb(false)
			end
		end

	end

end)



function ActivateCargo(source, vehicle)

	local players = ESX.GetPlayers()

	math.random(); math.random(); math.random()
	local random_destination = math.random(1, #Config.CargoDeliveryLocations)
	local event_destination = Config.CargoDeliveryLocations[random_destination]

	for i=1, #players, 1 do
		if players[i] ~= source then TriggerClientEvent('esx_cargodelivery:activateCargo', players[i], vehicle, event_destination) end
	end

end






