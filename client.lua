function startControl()

    CreateThread(function()

        while PL.active do

            Wait(0)

            PL:setObjectPos()

            -- SHIFT
            if IsControlPressed(0, 61) then

                -- SHIFT+SCROLL
                if IsControlJustReleased(0, 14) then
                    PL:decreaseHeading(10.0)
                    PL:normalizeHeading()
                end

                -- SHIFT+SCROLL
                if IsControlJustReleased(0, 15) then
                    PL:increaseHeading(10.0)
                    PL:normalizeHeading()
                end
            else

                -- X toggle move
                if IsControlJustReleased(0, 120) then
                    PL:toggleMove()
                    PL:setOffset()
                end

                --RIGHT CLICK
                if IsControlJustReleased(0, 25) then
                    PL:putItInFrontOfMe()
                end

                --E
                if IsControlJustReleased(0, 38) then
                    PL:loadNextObject()
                end

                --SCROLL
                if IsControlJustReleased(0, 14) then
                    PL:decreaseHeading(1.0)
                    PL:normalizeHeading()
                end

                --SCROLL
                if IsControlJustReleased(0, 15) then
                    PL:increaseHeading(1.0)
                    PL:normalizeHeading()
                end

                --SCROLL DOWN
                if IsControlJustReleased(1, 27) then
                    PL:saveCoords()
                end
            end
        end
    end)
end

RegisterCommand(Config.on_off_command, function()
    PL:initPlace()
end)

AddEventHandler('eco_placement:moveObject', function(obj)

    if PL.object ~= obj and DoesEntityExist(obj) then
        PL.active = false
        Wait(500)
        PL:initPlace(obj)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PL:deleteObject()
    end
end)

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

RegisterNUICallback('nuiSync', function(data, cb)
    cb(Config.on_off_command)
end)