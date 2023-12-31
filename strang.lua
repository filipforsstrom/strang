s = require 'sequins'
er = require 'er'
riff = include 'lib/riff'
_engine = include 'lib/_engine'
parameters = include 'lib/parameters'

play = true
-- play = false

function init()

    message = "sträng"
    screen_dirty = true
    redraw_clock_id = clock.run(redraw_clock)

    engine.click_amp('all', 0.008)
    -- engine.amp('all', 10)
    playing_riff = riff.new()
    riff2 = riff.new()
    riff2:set_pulses(1, 7)
    parameters.init()
    parameters.add_riff(2)

    trigger_step = s {1}
    current_trigger_step = 1
    freq_step = s {1, 2, 3, 4}
    current_freq_step = 1
    mute_step = s {1, 2, 3, 4}
    current_mute_step = 1
    bend_step = s {1, 2, 3, 4}
    current_bend_step = 1
    vibrato_step = s {1, 2, 3, 4}
    current_vibrato_step = 1
    amp_step = s {1, 2, 3, 4}
    current_amp_step = 1

    step_clock_speed = 1
    pluck_clock_speed = 1
    mute_clock_speed = 6
    bend_clock_speed = 3
    vibrato_clock_speed = 1
    amp_clock_speed = 1

    if play then
        iter_clock = clock.run(iter)
        pluck_clock = clock.run(pluck)
        -- clock.run(mute_clock)
        -- clock.run(bend_clock)
        -- clock.run(vibrato_clock)
        -- clock.run(amp_clock)
    end
end

function key(k, z)
    if z == 0 then
        return
    end
    if k == 2 then
        press_down(2)
        stop()
    end
    if k == 3 then
        press_down(3)
        start()
    end
    screen_dirty = true
end

function press_down(i)
    message = "press down " .. i
end

function start()
    stop()
    message = "start"
    iter_clock = clock.run(iter)
    pluck_clock = clock.run(pluck)
end

function stop()
    message = "stop"
    clock.cancel(iter_clock)
    clock.cancel(pluck_clock)
    engine.free_all_notes()
end

function iter()
    while true do
        local r_id = params:get("selected_riff")
        -- print("r_id: " .. r_id)
        playing_riff = riff.get_riff(r_id)

        clock.sync(step_clock_speed)
        current_trigger_step = trigger_step()
        current_freq_step = freq_step()
        current_amp_step = amp_step()
        current_mute_step = mute_step()
        current_bend_step = bend_step()
        current_vibrato_step = vibrato_step()
        pluck_clock_speed = playing_riff.triggers[current_trigger_step].steps
    end
end

function pluck()
    while true do
        clock.sync(1 / pluck_clock_speed)
        local trig = playing_riff.triggers[current_trigger_step].sequins()
        if trig then
            local freq = playing_riff.freqs[current_freq_step].sequins()
            local amp = playing_riff.amps[current_amp_step].sequins()
            local mute = playing_riff.mutes[current_mute_step].sequins()
            local bend = playing_riff.bends[current_bend_step].sequins()
            local vibrato = playing_riff.vibratos[current_vibrato_step].sequins()
            -- engine.amp('all', amp)
            engine.string_decay('all', mute)
            -- engine.bend_depth('all', bend)
            _engine.bend_depth(bend)
            engine.vibrato_depth('all', vibrato)
            -- engine.trig(1, freq, 1)
            _engine.trig(1, freq, 1)
            _engine.amp(amp)
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
        engine.string_decay('all', playing_riff.mutes[current_mute_step]())
    end
end

function bend_clock()
    while true do
        clock.sync(1 / mute_clock_speed)
        current_bend_step = bend_step()
        engine.bend_depth('all', playing_riff.bends[current_bend_step]())
    end
end

function vibrato_clock()
    while true do
        clock.sync(1 / vibrato_clock_speed)
        current_vibrato_step = vibrato_step()
        engine.vibrato_depth('all', playing_riff.vibratos[current_vibrato_step]())
    end
end

function amp_clock()
    while true do
        clock.sync(1 / amp_clock_speed)
        current_amp_step = amp_step()
        engine.amp('all', playing_riff.amps[current_amp_step].sequins())
    end
end

function cleanup()
    engine.free()
end

function redraw_clock()
    while true do
        clock.sleep(1 / 15)
        if screen_dirty then
            redraw()
            screen_dirty = false
        end
    end
end

function redraw()
    screen.clear()
    screen.aa(1)
    screen.font_face(1)
    screen.font_size(8)
    screen.level(15)
    screen.move(64, 32)
    screen.text_center(message)
    screen.pixel(0, 0)
    screen.pixel(127, 0)
    screen.pixel(127, 63)
    screen.pixel(0, 63)
    screen.fill()
    screen.update()
end
