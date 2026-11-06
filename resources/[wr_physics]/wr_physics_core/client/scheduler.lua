--- wr_physics core (client): tick scheduler with per-job profiling and budget degradation.
--
-- Jobs register with a desired rate (hz, or 0 = every frame) and a priority
-- (1 = critical, e.g. the driven vehicle's simulation; 3 = cosmetic). When the summed cost of
-- all wr_physics jobs exceeds Config.performance.frameBudgetMs, low-priority jobs are run less
-- often; priority 1 is never throttled (F6).
local Config = WRP.Config
local log = WRP.Log.tag("sched")

local Scheduler = {}
local jobs = {}
local stats = { frameMs = 0.0, avgMs = 0.0, degradeLevel = 0 }

--- Register a job. Returns a handle with :stop().
-- @param name string
-- @param hz number (0 = every frame)
-- @param priority 1..3
-- @param fn function(dt) dt = seconds since the job last ran
function Scheduler.register(name, hz, priority, fn)
    local job = {
        name = name, hz = hz or 0, priority = priority or 2, fn = fn,
        last = GetGameTimer(), nextAt = 0, costMs = 0.0, running = true,
    }
    jobs[name] = job
    return {
        stop = function() jobs[name] = nil end,
        setRate = function(_, newHz) job.hz = newHz end,
    }
end

function Scheduler.unregister(name) jobs[name] = nil end
function Scheduler.stats() return stats, jobs end

local function intervalMs(job)
    local hz = job.hz
    if hz <= 0 then
        -- every frame, unless degraded
        if job.priority >= 3 and stats.degradeLevel >= 1 then return 33 end
        if job.priority >= 2 and stats.degradeLevel >= 2 then return 33 end
        return 0
    end
    local factor = 1
    if job.priority >= 3 and stats.degradeLevel >= 1 then factor = 2 end
    if job.priority >= 2 and stats.degradeLevel >= 2 then factor = factor * 2 end
    return (1000 / hz) * factor
end

CreateThread(function()
    local budgetCheckAt = 0
    while true do
        local now = GetGameTimer()
        local frameMs = 0.0
        for _, job in pairs(jobs) do
            if now >= job.nextAt then
                local dt = (now - job.last) / 1000.0
                if dt > 0.25 then dt = 0.25 end       -- clamp after hitches
                local t0 = GetGameTimer()
                WRP.guard(job.name, job.fn, dt)
                local cost = GetGameTimer() - t0
                job.costMs = job.costMs * 0.9 + cost * 0.1
                frameMs = frameMs + cost
                job.last = now
                job.nextAt = now + intervalMs(job)
            end
        end
        stats.frameMs = frameMs
        stats.avgMs = stats.avgMs * 0.95 + frameMs * 0.05

        -- Budget check twice per second with hysteresis.
        if now >= budgetCheckAt then
            budgetCheckAt = now + 500
            local budget = Config.performance.frameBudgetMs
            if stats.avgMs > budget * 1.2 and stats.degradeLevel < 2 then
                stats.degradeLevel = stats.degradeLevel + 1
                log.warn("frame budget exceeded (%.2f ms > %.2f ms), degrade level %d", stats.avgMs, budget, stats.degradeLevel)
            elseif stats.avgMs < budget * 0.6 and stats.degradeLevel > 0 then
                stats.degradeLevel = stats.degradeLevel - 1
                log.info("frame budget recovered, degrade level %d", stats.degradeLevel)
            end
        end
        Wait(0)
    end
end)

WRP.Scheduler = Scheduler
