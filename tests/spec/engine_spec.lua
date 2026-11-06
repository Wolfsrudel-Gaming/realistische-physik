local Engine, Registry, Units = WRP.Sim.Engine, WRP.SpecRegistry, WRP.Units

local function civicEngine()
    return Engine.new(Registry.byId("honda_civic_si_2006").engine)
end

describe("Engine", function()
    it("starts from the starter and settles at idle", function()
        local e = civicEngine()
        e:startCranking()
        for _ = 1, 400 do e:step(1 / 100, 0.0, 0.0) end
        expect.truthy(e.running, "running after cranking")
        expect.near(e:rpm(), e.idleRpm, 80, "idle rpm")
    end)

    it("revs to the limiter at full throttle without load", function()
        local e = civicEngine()
        e:forceRunning()
        local maxSeen = 0
        for _ = 1, 600 do
            e:step(1 / 100, 1.0, 0.0)
            maxSeen = math.max(maxSeen, e:rpm())
        end
        expect.between(maxSeen, e.maxRpm - 50, e.maxRpm + 300)
        expect.between(e:rpm(), e.maxRpm - 400, e.maxRpm + 300)
    end)

    it("stalls under a load greater than it can produce", function()
        local e = civicEngine()
        e:forceRunning()
        for _ = 1, 300 do e:step(1 / 100, 0.0, 400.0) end
        expect.falsy(e.running)
    end)

    it("peak power matches the datasheet", function()
        local e = civicEngine()
        local p = e:peakPower()
        expect.between(Units.wToPs(p), 190, 205)
    end)

    it("engine braking decelerates a spinning engine", function()
        local e = civicEngine()
        e:forceRunning()
        e:setRpm(6000)
        e:step(0.05, 0.0, 0.0)
        expect.lt(e:rpm(), 6000)
    end)
end)
