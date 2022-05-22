local activate, _PlayerPedId, object, forward, heading, idx, model

local models = {
    'prop_astro_table_01',
    'prop_tool_bench02_ld',
    'prop_cooker_03',
    'prop_table_08'
}

CreateThread(function()

    _PlayerPedId = PlayerPedId()


    while true do

        Citizen.Wait(0)

        if activate then

            local userCoords = GetEntityCoords(_PlayerPedId)

            SetEntityCoords(object, userCoords + forward)
            SetEntityHeading(object, heading)
            PlaceObjectOnGroundProperly(object)


            -- SHIFT
            if IsControlPressed(0, 61) then

                -- SHIFT+SCROLL
                if IsControlJustReleased(0, 16) then

                    heading = heading - 10.0
                end

                -- SHIFT+SCROLL
                if IsControlJustReleased(0, 17) then

                    heading = heading + 10.0
                end
            else

                --RIGHT CLICK
                if IsControlJustReleased(0, 25) then

                    _PlayerPedId = PlayerPedId()
                    heading = GetEntityHeading(_PlayerPedId)
                    forward = GetEntityForwardVector(_PlayerPedId) * 1.5;
                end

                --E
                if IsControlJustReleased(0, 38) then

                    idx = idx + 1

                    if not models[idx] then idx = 1 end

                    model = models[idx]

                    objectCreate(model)
                end

                --SCROLL
                if IsControlJustReleased(0, 16) then

                    heading = heading - 1.0
                end

                --SCROLL
                if IsControlJustReleased(0, 17) then

                    heading = heading + 1.0
                end


                if heading > 360 then

                    heading = heading - 360

                elseif heading < 0 then

                    heading = heading + 360
                end


                --SCROLL DOWN
                if IsControlJustReleased(1, 27) then

                    if object then

                        local coords = GetEntityCoords(object)

                        local x = round(coords.x, 2)
                        local y = round(coords.y, 2)
                        local z = round(coords.z, 2)
                        local h = round(GetEntityHeading(object), 2)

                        SendNUIMessage({
                            subject = 'COPY',
                            string = string.format('vector4(%s, %s, %s, %s)', x, y, z, h)
                        })
                    end
                end
            end
        else
            Citizen.Wait(2000)
        end
    end
end)


RegisterCommand('place', function()

    activate = not activate

    if activate then

        idx, model = next(models);
        objectCreate(model)

        SendNUIMessage({
            subject = 'OPEN'
        })
    else

        SendNUIMessage({
            subject = 'CLOSE'
        })
        DeleteObject(object)
    end
end)


function objectCreate(model)

    if DoesEntityExist(object) then

        DeleteObject(object)
    end

    _PlayerPedId = PlayerPedId()

    local coords = GetEntityCoords(_PlayerPedId)
    heading = GetEntityHeading(_PlayerPedId)

    forward = GetEntityForwardVector(_PlayerPedId) * 1.5;

    if not HasModelLoaded(model) then

        RequestModel(model)
        Wait(100)
        while not HasModelLoaded(model) do Wait(10) end
    end

    object = CreateObject(model, coords + forward)
    SetEntityHeading(object, heading + 180)
    PlaceObjectOnGroundProperly(object)
end

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

AddEventHandler('onResourceStop', function(resource)

    if resource == GetCurrentResourceName() then

        if DoesEntityExist(object) then

            DeleteObject(object)
        end
    end
end)


