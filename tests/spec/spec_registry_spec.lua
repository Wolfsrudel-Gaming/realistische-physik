local Spec, Registry, Units = WRP.Spec, WRP.SpecRegistry, WRP.Units

describe("Spec", function()
    it("parses tyre sizes", function()
        -- 215/45R17: sidewall 96.75 mm, rim radius 215.9 mm -> 0.3127 m
        expect.near(Spec.tyreRadius("215/45R17"), 0.3127, 1e-3)
        expect.near(Spec.tyreRadius("315/80R22.5"), 0.5378, 1e-3)
        expect.errors(function() Spec.tyreRadius("huge") end)
    end)

    it("synthesises a torque curve with the right peaks", function()
        local e = { idleRpm = 800, torquePeakNm = 200, torquePeakRpm = 4000, powerPeakW = 110000,
            powerPeakRpm = 6000, redlineRpm = 6500, aspiration = "na" }
        local pts = Spec.synthTorqueCurve(e)
        local maxT = 0
        for _, p in ipairs(pts) do maxT = math.max(maxT, p[2]) end
        expect.near(maxT, 200)
        -- torque at power peak must give the published power
        for _, p in ipairs(pts) do
            if p[1] == 6000 then expect.near(p[2] * 6000 * Units.RADS_PER_RPM, 110000, 1) end
        end
    end)

    it("rejects incomplete sheets", function()
        expect.errors(function() Spec.resolve({ id = "x", name = "x", year = 2000 }) end)
    end)
end)

describe("Registry", function()
    it("resolves all reference sheets", function()
        local ids = Registry.ids()
        expect.gt(#ids, 3)
        for _, id in ipairs(ids) do
            local s = Registry.byId(id)
            expect.truthy(s, id)
            expect.gt(s.wheels.radius, 0.2, id .. " radius")
            expect.gt(#s.engine.torqueCurve, 3, id .. " curve")
            expect.gt(s.derived.powerPeakPS, 50, id .. " power")
        end
    end)

    it("civic derived values are plausible", function()
        local s = Registry.byId("honda_civic_si_2006")
        expect.between(s.derived.powerPeakPS, 190, 205)
        -- Theoretical redline speed in 6th (overdrive); the real car is drag-limited to 217 km/h.
        expect.between(Units.msToKmh(s.derived.vRedlineTop), 280, 320)
        expect.eq(s.derived.numGears, 6)
    end)

    it("maps vanilla models and falls back to classes", function()
        local s, fb = Registry.forModel("blista", 0)
        expect.eq(s.id, "honda_civic_si_2006"); expect.falsy(fb)
        local c, fb2 = Registry.forModel("unknownmodel", 7)
        expect.truthy(fb2)
        expect.truthy(c.name:find("Super"))
        expect.eq(c.gearbox.type, "dct")
    end)
end)
