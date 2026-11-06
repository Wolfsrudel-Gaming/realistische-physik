local Fuel, Engine, Registry = WRP.Sim.Fuel, WRP.Sim.Engine, WRP.SpecRegistry

describe("Fuel", function()
    local spec = Registry.byId("honda_civic_si_2006")

    it("burns idle flow at idle", function()
        local e = Engine.new(spec.engine); e:forceRunning()
        local f = Fuel.new(spec.fuel, 1.0)
        for _ = 1, 100 do e:step(0.01, 0.0, 0.0) end
        f:step(1.0, e, false)
        expect.near(f.flowLh, spec.fuel.idleFlowLh or 0.7, 1e-6)
    end)

    it("cuts fuel on overrun", function()
        local e = Engine.new(spec.engine); e:forceRunning(); e:setRpm(5000)
        e:step(0.01, 0.0, 0.0)
        local f = Fuel.new(spec.fuel, 1.0)
        f:step(1.0, e, true)
        expect.eq(f.flowLh, 0.0)
    end)

    it("full-load consumption is in the right order of magnitude", function()
        -- ~110 kW at BSFC ~250 g/kWh => 27.5 kg/h => ~37 l/h
        local e = Engine.new(spec.engine); e:forceRunning(); e:setRpm(6500)
        e:step(0.001, 1.0, 0.0)
        local f = Fuel.new(spec.fuel, 1.0)
        f:step(1.0, e, true)
        expect.between(f.flowLh, 25, 60)
    end)

    it("applies the world scale only while moving", function()
        local e = Engine.new(spec.engine); e:forceRunning(); e:setRpm(3000)
        e:step(0.001, 0.5, 0.0)
        local f1 = Fuel.new(spec.fuel, 8.0)
        local f2 = Fuel.new(spec.fuel, 8.0)
        local a = f1:step(10.0, e, true)
        local b = f2:step(10.0, e, false)
        expect.near(a / b, 8.0, 1e-6)
    end)
end)
