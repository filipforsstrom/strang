s = require 'sequins'
er = require 'er'
engine.name = 'Strang'

function init()
    engine.click_amp('all', 0.01)
    engine.amp('all', 10)
    riff = {{
        pulses = 4,
        steps = 8,
        rotation = 0,
        sequins = s {},
        freqs = s {100}
    }, {
        pulses = 1,
        steps = 1,
        rotation = 0,
        sequins = s {},
        freqs = s {50}
    }, {
        pulses = 3,
        steps = 16,
        rotation = 7,
        sequins = s {},
        freqs = s {100, 200, 400, 800}
    }, {
        pulses = 1,
        steps = 1,
        rotation = 0,
        sequins = s {},
        freqs = s {50}
    }}

    -- set triggers using er.gen and the values from er_tables
    for i = 1, #riff do
        local pulses = riff[i].pulses
        local steps = riff[i].steps
        local rotation = riff[i].rotation
        local trigger = er.gen(pulses, steps, rotation)
        riff[i].triggers = trigger
    end

    riff[1].sequins:settable(riff[1].triggers)
    riff[2].sequins:settable(riff[2].triggers)
    riff[3].sequins:settable(riff[3].triggers)
    riff[4].sequins:settable(riff[4].triggers)

    step = s {1, 2, 3, 4}
    current_step = 1
    mute = s {0.1, 16, 4, 1, 20}
    bend = s {0, 10, 0}
    -- vibrato = s {0, 0, 0, 0, 0.5}
    amp = s {0.1, 0.5, 1, 10, 100}

    step_clock_speed = 1
    pluck_clock_speed = 1
    mute_clock_speed = 1
    bend_clock_speed = 1
    vibrato_clock_speed = 1
    amp_clock_speed = 1
    clock.run(iter)
    clock.run(pluck)
    clock.run(mute_clock)
    clock.run(bend_clock)
    clock.run(vibrato_clock)
    clock.run(amp_clock)
end

function iter()
    while true do
        clock.sync(step_clock_speed)
        current_step = step()
        pluck_clock_speed = riff[current_step].steps
    end
end

function pluck()
    while true do
        clock.sync(1 / pluck_clock_speed)
        local trig = riff[current_step].sequins()
        if trig then
            local freq = riff[current_step].freqs()
            engine.amp('all', amp())
            engine.trig(1, freq, 1)
            -- engine.trig(2, freq * (3 / 2), 1)
            -- engine.amp(current_step, 0.5)
            -- engine.string_decay(current_step, 16)
        end
    end
end

function mute_clock()
    while true do
        clock.sync(1 / mute_clock_speed)
        engine.string_decay('all', mute())
    end
end

function bend_clock()
    while true do
        clock.sync(1 / mute_clock_speed)
        -- print(bend())
        engine.bend_depth('all', bend())
    end
end

function vibrato_clock()
    while true do
        clock.sync(1 / vibrato_clock_speed)
        engine.vibrato_depth('all', vibrato())
    end
end

function amp_clock()
    while true do
        clock.sync(1 / amp_clock_speed)
        engine.amp('all', amp())
    end
end

function cleanup()
    engine.free()
end
