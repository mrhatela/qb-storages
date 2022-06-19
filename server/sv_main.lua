local QBCore = exports['qb-core']:GetCoreObject()


AddEventHandler('qb-storages:GetStorages', function(location)
    local player=QBCore.Functions.GetPlayerData()
    local citizenid=player.citizenid
    local p = nil
    local data ={
        cid = citizenid,
        storagelocation = Config.location[location].name,
    }
    local fetchStoragePromise = function(data)
        if p then return end
        p = promise.new()
        QBCore.Functions.TriggerCallback('qb-storages:server:fetchStorage', function(result)
            p:resolve(result)
        end, data)
        return Citizen.Await(p)
    end
    
    local result = fetchStoragePromise(data)
    p = nil
    if result then
        local storagesMenu = {
            {
                header = "Your Storages in "..Config.location[location].name,
                isMenuHeader = true
            }
        }

        for k, v in pairs(result) do
            storagesMenu[#storagesMenu+1] = {
                header = v.storagename,
                txt = "Capacity : "..(v.storage_size/1000).." -- Owner : "..v.citizenid,
                params = {
                    event = "qb-storages:openStorageMenu",
                    args = {
                        storageid = v.id
                    }
                }

            }
        end

        storagesMenu[#storagesMenu+1] = {
            header = "Close Menu",
            txt = "",
            params = {
                event = "qb-menu:client:closeMenu"
            }

        }
        exports['qb-menu']:openMenu(storagesMenu)
    else
        QBCore.Functions.Notify("There is No Storage in this Location", "error")
    end
end)


AddEventHandler('qb-storages:openStorageMenu', function(data)
    local player=QBCore.Functions.GetPlayerData()
    local citizenid=player.citizenid
    -- local storagename=location.."_"..citizenid
    local dialog = exports['qb-input']:ShowInput({
        header = "Storage Password",
        submitText = "Submit",
        inputs = {
            {
                text = "Password", 
                name = "password", 
                type = "password", 
                isRequired = true
            }
        },
    })

    if dialog ~= nil then
        local p = nil
        local data ={
            password = dialog.password,
            id = data.storageid
        }
        local openStoragePromise = function(data)
            if p then return end
            p = promise.new()
            QBCore.Functions.TriggerCallback('qb-storages:server:checkThePassword', function(result)
                p:resolve(result)
            end, data)
            return Citizen.Await(p)
        end
    
        local result = openStoragePromise(data)
        p = nil
        if result then
            local v = result[1]
            local storageMenu = {
                {
                    isHeader = true,
                    header = 'Storage '..v.storagename
                },
                {
                    header = 'Open Storage',
                    txt = 'Open '..v.storagename .." Storage",
                    params = {
                        event = 'qb-storages:OpenStorg',
                        args = {
                            storagename = v.storage_location..'_'..v.storagename..'_'..v.citizenid,
                            storagesize = v.storage_size
                        }
                    }
                }
            }
            if citizenid == v.citizenid then
                local addmembermenu={
                    header = 'Add Memeber',
                    txt = 'Add Member to the '..v.storagename..' Storage',
                    params = {
                        event = 'qb-storages:addMemberToStorage',
                        args = {
                            storageid = v.id,
                        }
                    }
                }
                table.insert(storageMenu,addmembermenu)
                local removememberMenu={
                    header = 'Remove Member',
                    txt = 'Remove Member to the '..v.storagename..' Storage',
                    params = {
                        event = 'qb-storages:removeMemberFromStorage',
                        args = {
                            storageid = v.id
                        }
                    }
                }
                table.insert(storageMenu,removememberMenu)
                local addstorageMenu={
                    header = 'Add Storage',
                    txt = 'Add 200lbs to the '..v.storagename..' Storage For 7000$',
                    params = {
                        event = 'qb-storages:AddSpace',
                        args = {
                            storageid = v.id
                        }
                    }
                }
                table.insert(storageMenu,addstorageMenu) 
                local addstorageMenu={
                    header = 'Change Password',
                    txt = 'Change Storage Password',
                    params = {
                        event = 'qb-storages:ChangePass',
                        args = {
                            storageid = v.id
                        }
                    }
                }
                table.insert(storageMenu,addstorageMenu) 
            end
            local closeMenu={
                header = "Close Menu",
                txt = "",
                params = {
                    event = "qb-menu:client:closeMenu"
                }
            }
            table.insert(storageMenu,closeMenu) 
              exports['qb-menu']:openMenu(storageMenu)
            QBCore.Functions.Notify("Correct Password", "success")
        else
            QBCore.Functions.Notify("Wrong Password", "error")
        end
    end
end)

AddEventHandler('qb-storages:createStorage', function(location)
    local player=QBCore.Functions.GetPlayerData()
    local citizenid=player.citizenid
    local cpdialog = exports['qb-input']:ShowInput({
        header = "Create Password",
        submitText = "Submit",
        inputs = {
            {
                text = "Name", -
                name = "name", 
                type = "text", 
                isRequired = true 
            },
            {
                text = "Password", -
                name = "password", 
                type = "password", 
                isRequired = true 
            }
        },
    })
    if cpdialog ~= nil then
        if player.money['cash'] >= tonumber(Config.StorageCreationAmount) then
        local p = nil
        local data ={
            cid = citizenid,
            password = cpdialog.password,
            storagename = cpdialog.name,
            storagelocation = Config.location[location].name,
            storagesize = Config.StorageDefaultWeight
        }
        local createStoragePromise = function(data)
            if p then return end
            p = promise.new()
            QBCore.Functions.TriggerCallback('qb-storages:server:createStorage', function(result)
                p:resolve(result)
            end, data)
            return Citizen.Await(p)
        end
    
        local result = createStoragePromise(data)
        p = nil
        if result then
            TriggerServerEvent('qb-storages:server:removeMoney',Config.StorageCreationAmount)
            QBCore.Functions.Notify("Storage Created", "success")
        else
            QBCore.Functions.Notify("Dublicate Name For storage", "error")
        end
    else
        QBCore.Functions.Notify("You're Missing Cash", "error")
    end
    end


end)

AddEventHandler('qb-storages:UnitCreate', function(location)
    local player=QBCore.Functions.GetPlayerData()
    -- local citizenid=player.citizenid
    local cpdialog = exports['qb-input']:ShowInput({
        header = "Create Storage For",
        submitText = "Submit",
        inputs = {
            {
                text = "Name", 
                name = "name", 
                type = "text",
                isRequired = true -
            },
            {
                text = "CitizenID", -
                name = "citizenid", 
                type = "text", 
                isRequired = true 
            },
            {
                text = "Password", -
                name = "password", 
                type = "password", 
                isRequired = true 
            }
        },
    })
    if cpdialog ~= nil then
        if player.money['cash'] >= tonumber(Config.StorageCreationAmount) then
        local p = nil
        local data ={
            cid = cpdialog.citizenid,
            password = cpdialog.password,
            storagename = cpdialog.name,
            storagelocation = Config.location[location].name,
            storagesize = Config.StorageDefaultWeight
        }
        local createStoragePromise = function(data)
            if p then return end
            p = promise.new()
            QBCore.Functions.TriggerCallback('qb-storages:server:createStorage', function(result)
                p:resolve(result)
            end, data)
            return Citizen.Await(p)
        end
    
        local result = createStoragePromise(data)
        p = nil
        if result then
            TriggerServerEvent('qb-storages:server:removeMoney',Config.StorageCreationAmount)
            QBCore.Functions.Notify("Storage Created", "success")
        else
            QBCore.Functions.Notify("Dublicate Name For storage", "error")
        end
        -- return cb(result)
    else
        QBCore.Functions.Notify("You're Missing Cash.", "error")
    end
    end


end)


AddEventHandler('qb-storages:addMemberToStorage', function(data)
    local player=QBCore.Functions.GetPlayerData()
    local citizenid=player.citizenid
    local mdialog = exports['qb-input']:ShowInput({
        header = "Add Member",
        submitText = "Submit",
        inputs = {
            {
                text = "Member CitizenID", -
                name = "citizenid", 
                type = "text", 
                isRequired = true 
            }
        },
    })

    if mdialog ~= nil then
        local p = nil
        local data ={
            citizenid = mdialog.citizenid,
            id = data.storageid
        }
        local addMemberPromise = function(data)
            if p then return end
            p = promise.new()
            QBCore.Functions.TriggerCallback('qb-storages:server:addMember', function(result)
                p:resolve(result)
            end, data)
            return Citizen.Await(p)
        end
    
        local result = addMemberPromise(data)
        p = nil
        if result then
            QBCore.Functions.Notify("Member Add Sucessfuly", "success")
        else
            QBCore.Functions.Notify("Something Went Wrong", "error")
        end
    end
end)
-- EGRP
AddEventHandler('qb-storages:removeMemberFromStorage', function(data)
    local player=QBCore.Functions.GetPlayerData()
    local citizenid=player.citizenid
    local mdialog = exports['qb-input']:ShowInput({
        header = "Remove Member",
        submitText = "Submit",
        inputs = {
            {
                text = "Member CitizenID", -
                name = "citizenid", 
                type = "text", 
                isRequired = true 
            }
        },
    })

    if mdialog ~= nil then
        local p = nil
        local data ={
            citizenid = mdialog.citizenid,
            id = data.storageid
        }
        local removeMemberPromise = function(data)
            if p then return end
            p = promise.new()
            QBCore.Functions.TriggerCallback('qb-storages:server:removeMember', function(result)
                p:resolve(result)
            end, data)
            return Citizen.Await(p)
        end
    
        local result = removeMemberPromise(data)
        p = nil
        if result then
            QBCore.Functions.Notify("Member Removed Sucessfuly", "success")
        else
            QBCore.Functions.Notify("Something Went Wrong", "error")
        end
    end
end)

AddEventHandler('qb-storages:OpenStorg', function(data)
        TriggerServerEvent("inventory:server:OpenStorg", "stash", data.storagename,{
            maxweight = data.storagesize,
            slots = Config.StorageSlots,
        })
        TriggerEvent("inventory:client:SetCurrentStash", data.storagename)
        QBCore.Functions.Notify("Storage is Opening...", "success")

    
end)


AddEventHandler('qb-storages:AddSpace', function(data)
    local player=QBCore.Functions.GetPlayerData()
    if player.money['cash'] >= tonumber(Config.StorageAddPrice) then
        local p = nil
        local data ={
            id = data.storageid
        }
        local AddSpacePromise = function(data)
            if p then return end
            p = promise.new()
            QBCore.Functions.TriggerCallback('qb-storages:server:AddSpace', function(result)
                p:resolve(result)
            end, data)
            return Citizen.Await(p)
        end
        -- EGRP
        local result = AddSpacePromise(data)
        p = nil
        if result then
            TriggerServerEvent('qb-storages:server:removeMoney',Config.StorageAddPrice)
            QBCore.Functions.Notify("You Add Capacity to Your Storage", "success")
        else
            QBCore.Functions.Notify("Something Went Wrong", "error")
        end
    else
        QBCore.Functions.Notify("You're Missing Cash.", "error")
    end
end)

AddEventHandler('qb-storages:ChangePass', function(data)
    local player=QBCore.Functions.GetPlayerData()
    local citizenid=player.citizenid
    -- local storagename=location.."_"..citizenid
    local mdialog = exports['qb-input']:ShowInput({
        header = "NewPassword",
        submitText = "Submit",
        inputs = {
            {
                text = "New Password", -
                name = "password", 
                type = "password", 
                isRequired = true 
            }
        },
    })

    if mdialog ~= nil then
        local p = nil
        local data ={
            password = mdialog.password,
            id = data.storageid
        }
        local addMemberPromise = function(data)
            if p then return end
            p = promise.new()
            QBCore.Functions.TriggerCallback('qb-storages:server:ChangePass', function(result)
                p:resolve(result)
            end, data)
            return Citizen.Await(p)
        end
    
        local result = addMemberPromise(data)
        p = nil
        if result then
            QBCore.Functions.Notify("PassWord Change Sucessfuly", "success")
        else
            QBCore.Functions.Notify("Something Went Wrong", "error")
        end
    end
end)

AddEventHandler('qb-storages:GetCID', function(location)
    local player=QBCore.Functions.GetPlayerData()
    
    local mdialog = exports['qb-input']:ShowInput({
        header = "Player Citizen ID",
        submitText = "Submit",
        inputs = {
            {
                text = "CitizenID", -
                name = "citizenid", 
                type = "text", 
                isRequired = true 
            }
        },
    })

    if mdialog ~= nil then
        local p = nil
        local data ={
            cid = mdialog.citizenid,
            storagelocation = Config.location[location].name,
        }
        local fetchStoragePromise = function(data)
            if p then return end
            p = promise.new()
            QBCore.Functions.TriggerCallback('qb-storages:server:fetchStorage', function(result)
                p:resolve(result)
            end, data)
            return Citizen.Await(p)
        end
        
        local result = fetchStoragePromise(data)
            p = nil
            if result then
                local storagesMenu = {
                    {
                        header = mdialog.citizenid.." Storages in "..Config.location[location].name,
                        isMenuHeader = true
                    }
                }
        
                for k, v in pairs(result) do
                    storagesMenu[#storagesMenu+1] = {
                        header = v.storagename,
                        txt = "Owner : "..v.citizenid,
                        params = {
                            event = "qb-storages:ChangePass",
                            args = {
                                storageid = v.id
                            }
                        }
        
                    }
                end
        
                storagesMenu[#storagesMenu+1] = {
                    header = "Close Menu",
                    txt = "",
                    params = {
                        event = "qb-menu:client:closeMenu"
                    }
        
                }
                exports['qb-menu']:openMenu(storagesMenu)
            else
                QBCore.Functions.Notify("Something Went Wrong", "error")
            end
        end
end)

for k, v in pairs(Config.location) do
    exports['qb-target']:AddBoxZone(v.name, v.coords, v.length, v.width, {
        name = v.name,
        heading = v.heading,
        debugPoly = v.debug,
        minZ = v.minz,
        maxZ = v.maxz,
    }, {
        options = {
            {
              type = "client",
              action = function(entity) 
                TriggerEvent('qb-storages:GetStorages', k)
              end,
              icon = "fas fa-box-open",
              label = "View Storage",
            },
            {
                type = "client",
                action = function(entity) 
                  TriggerEvent('qb-storages:UnitCreate', k)
                end,
                icon = "fas fa-boxes",
                label = "Create A Storage (Real Estate)",
                job = {"realestate"},
            },
            {
                type = "client",
                action = function(entity) 
                TriggerEvent('qb-storages:GetCID', k)
                end,
                icon = "fas fa-key",
                label = "Change Storage Password (Police)",
                job = {"police"},
            },
        },
        distance = v.distance
    })
end

