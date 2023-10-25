s = require 'sequins'
er = require 'er'
engine.name = 'Strang'

play = true
-- play = false

function init()
    engine.click_amp('all', 0.01)
    engine.amp('all', 10)
    riff = {
        triggers = {{
            pulses = 2,
            steps = 2,
            rotation = 0,
            sequins = s {}
        }, {
            pulses = 3,
            steps = 4,
            rotation = 0,
            sequins = s {}
        }, {
            pulses = 3,
            steps = 7,
            rotation = 0,
            sequins = s {}
        }, {
            pulses = 8,
            steps = 8,
            rotation = 0,
            sequins = s {}
        }},
        amps = {s {1}, s {10.1}, s {100}, s {0.1}},
        freqs = {s {50}, s {400, 300, 600}, s {50, 200, 400, 800}, s {1300, 1100, 1300, 1300}},
        mutes = {s {16}, s {0.1}, s {0.5}, s {0.1}},
        bends = {s {0}, s {10}, s {-10}, s {0}},
        vibratos = {s {0}, s {0}, s {0.01}, s {0.1}}
    }

    -- set triggers using er.gen and the values from er_tables
    for i = 1, #riff.triggers do
        local pulses = riff.triggers[i].pulses
        local steps = riff.triggers[i].steps
        local rotation = riff.triggers[i].rotation
        local trigger = er.gen(pulses, steps, rotation)
        riff.triggers[i].triggers = trigger
    end

    riff.triggers[1].sequins:settable(riff.triggers[1].triggers)
    riff.triggers[2].sequins:settable(riff.triggers[2].triggers)
    riff.triggers[3].sequins:settable(riff.triggers[3].triggers)
    riff.triggers[4].sequins:settable(riff.triggers[4].triggers)

    trigger_step = s {1, 1, 2, 4, 1, 1, 3}
    current_trigger_step = 1
    freq_step = s {1, 3, 4, 1, 2, 3}
    current_freq_step = 1
    mute_step = s {1, 1}
    current_mute_step = 1
    bend_step = s {1, 1, 1, 1, 1, 2, 1, 1, 1, 3}
    current_bend_step = 1
    vibrato_step = s {1, 1, 1, 3, 1, 1, 1, 4}
    current_vibrato_step = 1
    amp_step = s {1, 2, 1, 2, 3}
    current_amp_step = 1

    step_clock_speed = 1
    pluck_clock_speed = 1
    mute_clock_speed = 6
    bend_clock_speed = 3
    vibrato_clock_speed = 1
    amp_clock_speed = 1

    if play then
        clock.run(iter)
        clock.run(pluck)
        clock.run(mute_clock)
        clock.run(bend_clock)
        clock.run(vibrato_clock)
        clock.run(amp_clock)
    end
end

function iter()
    while true do
        clock.sync(step_clock_speed)
        current_trigger_step = trigger_step()
        current_freq_step = freq_step()
        pluck_clock_speed = riff.triggers[current_trigger_step].steps
    end
end

function pluck()
    while true do
        clock.sync(1 / pluck_clock_speed)
        local trig = riff.triggers[current_trigger_step].sequins()
        if trig then
            local freq = riff.freqs[current_freq_step]()
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
        current_mute_step = mute_step()
        engine.string_decay('all', riff.mutes[current_mute_step]())
    end
end

function bend_clock()
    while true do
        clock.sync(1 / mute_clock_speed)
        current_bend_step = bend_step()
        engine.bend_depth('all', riff.bends[current_bend_step]())
    end
end

function vibrato_clock()
    while true do
        clock.sync(1 / vibrato_clock_speed)
        current_vibrato_step = vibrato_step()
        engine.vibrato_depth('all', riff.vibratos[current_vibrato_step]())
    end
end

function amp_clock()
    while true do
        clock.sync(1 / amp_clock_speed)
        current_amp_step = amp_step()
        engine.amp('all', riff.amps[current_amp_step]())
    end
end

function cleanup()
    engine.free()
end
