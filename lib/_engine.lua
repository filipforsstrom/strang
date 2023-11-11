local _engine = {}

engine.name = 'Strang'

local min_amp = 0.01
local max_amp = 10
local min_bend = -400
local max_bend = 400

function _engine.trig(voice, freq, amp)
    engine.trig(voice, freq, amp)
end

function _engine.amp(a)
    local amp = util.linexp(0, 1, min_amp, max_amp, a)
    if a == 0 then
        amp = 0
    end
    engine.amp('all', amp)
end

function _engine.bend_depth(b)
    local bend = util.linlin(-1, 1, min_bend, max_bend, b)
    engine.bend_depth('all', bend)
end

return _engine
