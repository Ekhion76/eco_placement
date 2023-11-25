PL = {
    active = false,
    object = 0,
    forward = vec(0, 0, 0),
    heading = 0,
    idx = 1,
    model = '',
    offset = vec(0, 0, 0),
    deletableObject = true,
    move = true,
    pedId = 0
}

function PL:toggleMove()
    self.move = not self.move
    self:setMoveState()
end

function PL:putItInFrontOfMe()

    local pos = GetEntityCoords(self.pedId)
    self.heading = GetEntityHeading(self.pedId) - 180
    self.forward = GetEntityForwardVector(self.pedId) * Config.distance;
    SetEntityCoords(self.object, pos + self.forward)
    SetEntityHeading(self.object, self.heading)
    self:setOffset();
end

function PL:setObjectPos()
    if self.move then
        SetEntityCoords(self.object, GetEntityCoords(self.pedId) - self.offset)
        PlaceObjectOnGroundProperly(self.object)
    end

    SetEntityHeading(self.object, self.heading)
end

function PL:initPlace(obj)

    self.pedId = PlayerPedId()
    self.active = not self.active

    if self.active then

        if obj then

            if not DoesEntityExist(obj) then
                self.active = false
                print('The import object not exists!')
                return false
            end

            SetEntityNoCollisionEntity(self.pedId, obj)

            self.deletableObject = false
            self.heading = GetEntityHeading(obj)
            self.object = obj
            self:setOffset()
        else
            self.deletableObject = true
            self.idx, self.model = next(Config.models);
            self:createObject()
        end

        startControl()
        SendNUIMessage({
            subject = 'OPEN'
        })
    else

        SendNUIMessage({
            subject = 'CLOSE'
        })

        self:deleteObject()
    end
end

function PL:selectNewObject(obj)

    if DoesEntityExist(obj) then
        self.active = false
        self:setMoveState(true)
        Wait(200)
        self:initPlace(obj)
    end
end

function PL:deleteObject()
    if self.deletableObject and DoesEntityExist(self.object) then
        DeleteObject(self.object)
    end
end

function PL:createObject()

    local coords = GetEntityCoords(self.pedId)
    self.heading = GetEntityHeading(self.pedId) - 180
    self.forward = GetEntityForwardVector(self.pedId) * Config.distance;

    self:modelLoader()

    self.object = CreateObject(self.model, coords + self.forward)
    SetEntityHeading(self.object, self.heading + 180)
    PlaceObjectOnGroundProperly(self.object)
    SetEntityNoCollisionEntity(self.pedId, self.object)
    self:setOffset()
end

function PL:setMoveState(state)

    if state ~= nil then
        self.move = state
    end

    SendNUIMessage({
        subject = 'SET_MOVEMENT_STATE', state = self.move
    })
end

function PL:setOffset(obj)

    obj = obj or self.object
    if DoesEntityExist(obj) then
        local playerPos = GetEntityCoords(self.pedId)
        local objectPos = GetEntityCoords(obj)
        local xDiff = playerPos.x - objectPos.x
        local yDiff = playerPos.y - objectPos.y
        self.offset = vec3(xDiff + 0.0, yDiff + 0.0, 0)
    end
end

function PL:modelLoader()

    self.model = IsModelInCdimage(self.model) and self.model or 'v_corp_bk_bust'
    if not HasModelLoaded(self.model) then
        RequestModel(self.model)
        Wait(100)
        while not HasModelLoaded(self.model) do
            Wait(10)
        end
    end
end

function PL:decreaseHeading(v)

    self.heading = self.heading - v
end

function PL:increaseHeading(v)

    self.heading = self.heading + v
end

function PL:normalizeHeading()

    self.heading = self.heading % 360
    if self.heading < 0 then
        self.heading = self.heading + 360
    end
end

function PL:loadNextObject()

    self:deleteObject()

    self.idx = self.idx + 1
    if not Config.models[self.idx] then
        self.idx = 1
    end

    self.model = Config.models[self.idx]
    self:createObject()
end

function PL:saveCoords()

    if DoesEntityExist(self.object) then

        local coords = GetEntityCoords(self.object)

        local x = round(coords.x, 2)
        local y = round(coords.y, 2)
        local z = round(coords.z, 2)
        local h = round(GetEntityHeading(self.object), 2)

        SendNUIMessage({
            subject = 'COPY',
            --string = string.format('model = "%s", vector4(%s, %s, %s, %s)', model, x, y, z, h)
            string = string.format('vec(%s, %s, %s, %s),', x, y, z, h)
        })
    end
end