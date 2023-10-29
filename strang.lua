s = require 'sequins'
er = require 'er'
riff = include 'lib/riff'
engine.name = 'Strang'

play = true
-- play = false

function init()
    engine.click_amp('all', 0.01)
    engine.amp('all', 10)
    riff1 = riff.init()

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
        pluck_clock_speed = riff1.triggers[current_trigger_step].steps
    end
end

function pluck()
    while true do
        clock.sync(1 / pluck_clock_speed)
        local trig = riff1.triggers[current_trigger_step].sequins()
        if trig then
            local freq = riff1.freqs[current_freq_step]()
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
        engine.string_decay('all', riff1.mutes[current_mute_step]())
    end
end

function bend_clock()
    while true do
        clock.sync(1 / mute_clock_speed)
        current_bend_step = bend_step()
        engine.bend_depth('all', riff1.bends[current_bend_step]())
    end
end

function vibrato_clock()
    while true do
        clock.sync(1 / vibrato_clock_speed)
        current_vibrato_step = vibrato_step()
        engine.vibrato_depth('all', riff1.vibratos[current_vibrato_step]())
    end
end

function amp_clock()
    while true do
        clock.sync(1 / amp_clock_speed)
        current_amp_step = amp_step()
        engine.amp('all', riff1.amps[current_amp_step]())
    end
end

function cleanup()
    engine.free()
end
