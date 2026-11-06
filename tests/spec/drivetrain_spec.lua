local Drivetrain, Registry, Units, Long = WRP.Sim.Drivetrain, WRP.SpecRegistry, WRP.Units, WRP.Sim.Longitudinal

local DT = 1 / 120

--- Very small longitudinal vehicle for the tests: integrates speed from drivetrain force.
local function makeCar(id)
    local spec = Registry.byId(id)
    local dt = Drivetrain.new(spec)
    local car = { spec = spec, dt = dt, v = 0.0, t = 0.0 }
    function car:step(throttle, clutch, brakeForce)
        local wheelRadS = self.dt:wheelRadSFromSpeed(self.v)
        local torque = self.dt:step(DT, throttle, clutch, wheelRadS, self.v)
        local f = torque / spec.wheels.radius
        local limit = Long.tractionLimit(spec, spec.mass.curb, 0.0)
        if f > limit then f = limit end
        f = f - Long.dragForce(spec, self.v) - Long.rollingForce(spec, self.v) - (brakeForce or 0.0)
        self.v = math.max(0.0, self.v + f / spec.mass.curb * DT)
        self.t = self.t + DT
    end
    return car
end

describe("Drivetrain manual", function()
    it("idles in neutral with the clutch released", function()
        local car = makeCar("honda_civic_si_2006")
        car.dt.engine:forceRunning()
        for _ = 1, 240 do car:step(0.0, 0.0) end
        expect.truthy(car.dt.engine.running)
        expect.near(car.dt.engine:rpm(), car.spec.engine.idleRpm, 100)
        expect.eq(car.v, 0.0)
    end)

    it("stalls when first gear is engaged at standstill without throttle", function()
        local car = makeCar("honda_civic_si_2006")
        car.dt.engine:forceRunning()
        car.dt.gearbox:requestGear(1)
        for _ = 1, 240 do car:step(0.0, 0.0) end     -- clutch fully released, no gas
        expect.falsy(car.dt.engine.running, "engine should stall")
    end)

    it("launches with slipping clutch and reaches 100 km/h in a plausible time", function()
        local car = makeCar("honda_civic_si_2006")
        car.dt.engine:forceRunning()
        local gb = car.dt.gearbox
        gb:requestGear(1)
        local t100 = nil
        local maxSteps = 120 * 20
        for i = 1, maxSteps do
            -- Simple driver: slip the clutch for the first 0.8 s, then release; shift at 7800.
            local clutch = car.t < 0.8 and (1.0 - car.t / 0.8) * 0.7 or 0.0
            local rpm = car.dt.engine:rpm()
            if rpm > 7800 and gb.gear < gb.numGears and not gb:isShifting() then
                gb:requestGear(gb.gear + 1)
            end
            car:step(1.0, clutch)
            if not t100 and Units.msToKmh(car.v) >= 100 then t100 = car.t break end
            if i == maxSteps then break end
        end
        expect.truthy(t100, "reached 100 km/h")
        expect.truthy(car.dt.engine.running, "engine still running")
        -- Published 6.7 s; our pure drivetrain test ignores wheel slip dynamics, allow a band.
        expect.between(t100, 5.5, 9.0, "0-100 time")
    end)

    it("engine speed follows the wheels when locked in gear", function()
        local car = makeCar("toyota_ae86_1985")
        car.dt.engine:forceRunning()
        car.dt.gearbox:requestGear(3)
        car.v = 20.0
        for _ = 1, 60 do
            car.dt:step(DT, 0.3, 0.0, car.dt:wheelRadSFromSpeed(car.v), car.v)
        end
        local expected = car.dt.gearbox:rpmInGear(3, car.dt:wheelRadSFromSpeed(20.0))
        expect.near(car.dt.engine:rpm(), expected, 60)
        expect.truthy(car.dt.clutchLocked)
    end)

    it("delivers negative wheel torque on overrun (engine braking)", function()
        local car = makeCar("toyota_ae86_1985")
        car.dt.engine:forceRunning()
        car.dt.gearbox:requestGear(2)
        car.v = 15.0
        local torque
        for _ = 1, 60 do
            torque = car.dt:step(DT, 0.0, 0.0, car.dt:wheelRadSFromSpeed(car.v), car.v)
        end
        expect.lt(torque, 0.0)
    end)
end)

describe("Drivetrain automatic", function()
    it("creeps forward in D and shifts up through the gears", function()
        local car = makeCar("toyota_camry_2007")
        car.dt.engine:forceRunning()
        car.dt.gearbox:setLever("D")
        for _ = 1, 120 do car:step(0.0, 0.0) end
        expect.gt(car.v, 0.2, "creep")
        expect.truthy(car.dt.engine.running, "no stall in D")

        local maxGear = 1
        for _ = 1, 120 * 25 do
            car:step(0.8, 0.0)
            maxGear = math.max(maxGear, car.dt.gearbox.gear)
        end
        expect.gt(maxGear, 3, "upshifted")
        expect.gt(Units.msToKmh(car.v), 120)
        expect.lt(car.dt.engine:rpm(), car.spec.engine.maxRpm)
    end)

    it("does not move in P", function()
        local car = makeCar("toyota_camry_2007")
        car.dt.engine:forceRunning()
        car.dt.gearbox:setLever("P")
        for _ = 1, 120 do car:step(1.0, 0.0) end
        expect.eq(car.v, 0.0)
        expect.truthy(car.dt.engine.limiterActive or car.dt.engine:rpm() > 6000, "free revving")
    end)
end)
