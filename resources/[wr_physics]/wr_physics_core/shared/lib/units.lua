--- wr_physics core: unit conversions.
-- Internally everything is SI (m, kg, s, N, Nm, W, K, Pa). Convert only for display or data import.
local U = {}

-- Speed
U.KMH_PER_MS = 3.6
U.MPH_PER_MS = 2.236936
U.KN_PER_MS = 1.943844
function U.msToKmh(v) return v * U.KMH_PER_MS end
function U.kmhToMs(v) return v / U.KMH_PER_MS end
function U.msToMph(v) return v * U.MPH_PER_MS end
function U.mphToMs(v) return v / U.MPH_PER_MS end
function U.msToKn(v) return v * U.KN_PER_MS end
function U.knToMs(v) return v / U.KN_PER_MS end

-- Length
function U.mToFt(m) return m * 3.280840 end
function U.ftToM(ft) return ft / 3.280840 end
function U.mToNm(m) return m / 1852.0 end       -- nautical miles
function U.mToMi(m) return m / 1609.344 end     -- statute miles
function U.inToM(i) return i * 0.0254 end

-- Angular
U.RADS_PER_RPM = 2.0 * math.pi / 60.0
function U.rpmToRads(rpm) return rpm * U.RADS_PER_RPM end
function U.radsToRpm(w) return w / U.RADS_PER_RPM end
function U.degToRad(d) return d * math.pi / 180.0 end
function U.radToDeg(r) return r * 180.0 / math.pi end

-- Power
U.W_PER_PS = 735.49875
U.W_PER_HP = 745.69987
function U.wToKw(w) return w / 1000.0 end
function U.kwToW(kw) return kw * 1000.0 end
function U.wToPs(w) return w / U.W_PER_PS end
function U.psToW(ps) return ps * U.W_PER_PS end
function U.wToHp(w) return w / U.W_PER_HP end
function U.hpToW(hp) return hp * U.W_PER_HP end

-- Torque
function U.lbftToNm(x) return x * 1.355818 end
function U.nmToLbft(x) return x / 1.355818 end

-- Pressure
function U.barToPa(b) return b * 1e5 end
function U.paToBar(p) return p / 1e5 end
function U.psiToPa(p) return p * 6894.757 end
function U.paToPsi(p) return p / 6894.757 end
function U.hpaToInhg(h) return h * 0.02952998 end
function U.inhgToHpa(i) return i / 0.02952998 end

-- Temperature (internal: Kelvin)
function U.cToK(c) return c + 273.15 end
function U.kToC(k) return k - 273.15 end
function U.cToF(c) return c * 9.0 / 5.0 + 32.0 end
function U.fToC(f) return (f - 32.0) * 5.0 / 9.0 end
function U.kToF(k) return U.cToF(U.kToC(k)) end

-- Volume
U.L_PER_USGAL = 3.785412
function U.lToUsGal(l) return l / U.L_PER_USGAL end
function U.usGalToL(g) return g * U.L_PER_USGAL end

-- Mass
function U.kgToLb(kg) return kg * 2.204623 end
function U.lbToKg(lb) return lb / 2.204623 end

-- Fuel economy
--- l/100km -> US mpg
function U.l100ToMpg(l100)
    if l100 <= 0 then return math.huge end
    return 235.2146 / l100
end
function U.mpgToL100(mpg)
    if mpg <= 0 then return math.huge end
    return 235.2146 / mpg
end

-- Physical constants
U.G = 9.80665                 -- m/s^2
U.RHO_AIR_SEA_LEVEL = 1.225   -- kg/m^3 (ISA, 15 degC)
U.FUEL_DENSITY = {            -- kg/l
    petrol = 0.745,
    diesel = 0.832,
    avgas = 0.72,
    jeta1 = 0.80,
    e85 = 0.78,
}

WRP = WRP or {}
WRP.Units = U
return U
