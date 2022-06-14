local rikottu = 0
local lootattu = 0
local cuuldauni = 0
local coordsh = 27.74
local anim = false
local auki = false
local sisalla = false



local murtovaline = "WEAPON_CROWBAR" -- Esine jonka tarvitset murtoon
local tarvittavatkytat = 2 -- Kuin monta fobbaa alotukseen
local lyontimaara = 5 -- Kuin mont kertaa pitää lyödä ovea
local taimeri = 10 -- Cooldowni kauan joutuu odottaa (minuutteina)

local talli = vector3(-1096.4473, -1042.6635, 2.1565) -- Talli jonne murtaudutaan

local tutkittavat = {
	[1] = {coords=vector3(169.2650, -1005.7029, -98.9999), heading=84.2256}, -- Koordit kohdille joita voi tutkita
	[2] = {coords=vector3(169.2994, -1002.7993, -98.9999), heading=84.7548},
}

local lootit = { -- Lootit mitä voit saada
	'phone',
	'radio'
}

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
        if not anim and not auki and not sisalla then
            if (GetDistanceBetweenCoords(coords, talli.x, talli.y, talli.z, true) < 1.0) then
                DrawMarker(2, talli.x, talli.y, talli.z-0.20, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 255, 255, 255, 200, 0, 0, 0, 1, 0, 0, 0)
                if (GetDistanceBetweenCoords(coords, talli.x, talli.y, talli.z, true) < 1.0) then
                    ESX.ShowHelpNotification('~INPUT_PICKUP~ Murra')
                    if IsControlJustReleased(0, 46) then
						if GetSelectedPedWeapon(ped) == GetHashKey(murtovaline) then
                        	ESX.TriggerServerCallback('esx_autotalliryosto:policecheck', function(poliisi)
                            	if poliisi >= tarvittavatkytat then
									if cuuldauni <= 0 then
										animaatio()
										if auki then
											rikottu = rikottu - rikottu
											ESX.ShowNotification('Ovi aukesi')
											Wait(1000)
											SetEntityCoords(ped, 172.4063, -1008.4038, -98.9999)
											SetEntityHeading(ped, 357.7079)
											sisalla = true
											Wait(1000)
											auki = false
										end
									else
										ESX.ShowNotification('Autotalli on jo murrettu!')
									end
                            	else
                                	ESX.ShowNotification('Poliiseja pitää olla ~b~' .. tarvittavatkytat .. ' ~s~aloittaaksesi murto!')
                            	end
							end)
						else
							ESX.ShowNotification('Tarvitset sorkkaraudan!')
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()
	while true do
		Wait(0)
		if sisalla then
			for i=1, #tutkittavat do
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local loottipos = tutkittavat[i].coords
				if (GetDistanceBetweenCoords(coords, loottipos.x, loottipos.y, loottipos.z, true) < 1.0) then
					DrawMarker(2, loottipos.x, loottipos.y, loottipos.z-0.20, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 255, 255, 255, 200, 0, 0, 0, 1, 0, 0, 0)
					if (GetDistanceBetweenCoords(coords, loottipos.x, loottipos.y, loottipos.z, true) < 1.0) then
						ESX.ShowHelpNotification('~INPUT_PICKUP~ Tutki')
						if IsControlJustReleased(0, 46) then
							SetEntityHeading(ped, 82.2256)
							TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
							Wait(10000)
							ClearPedTasksImmediately(ped)
							if lootattu < 5 then
								TriggerServerEvent('esx_autotalliryosto:loottia', lootit)
								lootattu = lootattu + 1
							else
								ESX.ShowNotification('Et löytänyt mitään!')
							end
						end
					end
				end
			end
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			if (GetDistanceBetweenCoords(coords, 172.4063, -1008.4038, -98.9999, true) < 1.0) then
				DrawMarker(2, 172.4063, -1008.4038, -98.9999-0.20, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 255, 255, 255, 200, 0, 0, 0, 1, 0, 0, 0)
				if (GetDistanceBetweenCoords(coords, 172.4063, -1008.4038, -98.9999, true) < 1.0) then
					ESX.ShowHelpNotification('~INPUT_PICKUP~ Poistu')
					if IsControlJustReleased(0, 46) then
						SetEntityCoords(ped, talli.x, talli.y, talli.z)
						sisalla = false
						lootattu = lootattu - lootattu
						cuuldauni = taimeri * 1000 * 60
						Wait(1*1000*60)
					end
				end
			end
		end
	end
end)

CreateThread(function()
	while true do 
		Wait(5000)
		if cuuldauni > 0 then
			cuuldauni = cuuldauni - 5000
		end
	end
end)

function loadAnimDict( dict )  
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

function animaatio()
	anim = true
	local ped = GetPlayerPed(-1)
	SetEntityHeading(ped, coordsh)
	loadAnimDict( "missheist_jewel" ) 
	TaskPlayAnim(ped, "missheist_jewel", "smash_case", 8.0, 1.0, -1, 2, 0, 0, 0, 0 ) 
	Wait(1900)
	ClearPedTasksImmediately(ped)
	rikottu = rikottu + 1
	anim = false
	if rikottu >= lyontimaara then
		auki = true
	end
	if rikottu == 1 then 
		TriggerServerEvent('esx_autotalliryosto:ilmoitus', talli)
	end
end


RegisterNetEvent('esx_autotalliryosto:ilmoitus')
AddEventHandler('esx_autotalliryosto:ilmoitus', function(paikka)
    if ESX.PlayerData.job.name ~= nil and ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'tutkinta' then
        ESX.ShowAdvancedNotification('Ilmoitus', '~r~Murtohälytys', "", "CHAR_CALL911", 1)
        local copblip = AddBlipForCoord(talli)
        SetBlipSprite(copblip, 306)
        SetBlipDisplay(copblip, 4)
        SetBlipScale(copblip, 1.0)
        SetBlipColour(copblip, 1)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Murtohälytys')
        EndTextCommandSetBlipName(copblip)
        PulseBlip(copblip)
        Wait(50000)
        RemoveBlip(copblip)
    end
end)
