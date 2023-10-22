s = require 'sequins'
er = require 'er'
engine.name = 'Strang'

function init()
    engine.click_amp('all', 0.01)
    engine.amp('all', 1)
    er_tables = {{
        pulses = 3,
        steps = 8,
        rotation = 0,
        sequins = s {},
        freq = s {200, 1000}
    }, {
        pulses = 1,
        steps = 1,
        rotation = 0,
        sequins = s {},
        freq = s {50}
    }, {
        pulses = 8,
        steps = 8,
        rotation = 7,
        sequins = s {},
        freq = s {400, 100}
    }}

    -- set triggers using er.gen and the values from er_tables
    for i = 1, #er_tables do
        local pulses = er_tables[i].pulses
        local steps = er_tables[i].steps
        local rotation = er_tables[i].rotation
        local trigger = er.gen(pulses, steps, rotation)
        er_tables[i].triggers = trigger
    end

    er_tables[1].sequins:settable(er_tables[1].triggers)
    er_tables[2].sequins:settable(er_tables[2].triggers)
    er_tables[3].sequins:settable(er_tables[3].triggers)

    step = s {1, 2, 3}
    current_step = 1
    mute = s {0.1, 16, 4, 1, 20}
    bend = s {0, 10, 0, -10, 0}
    vibrato = s {0, 0, 0, 0, 0.05}

    step_speed = 1
    pluck_speed = 1
    mute_speed = 1
    bend_speed = 1
    vibrato_speed = 1
    clock.run(iter)
    clock.run(pluck)
    clock.run(mute_clock)
    clock.run(bend_clock)
    clock.run(vibrato_clock)
end

function concatenate_tables(t)
    local result = {}
    for i = 1, #t do
        for j = 1, #t[i] do
            table.insert(result, t[i][j])
        end
    end
    return result
end

function iter()
    while true do
        clock.sync(step_speed)
        current_step = step()
        pluck_speed = er_tables[current_step].steps
    end
end

function pluck()
    while true do
        clock.sync(1 / pluck_speed)
        local trig = er_tables[current_step].sequins()
        if trig then
            local freq = er_tables[current_step].freq()
            engine.trig(1, freq, 1)
            engine.trig(2, freq * (3 / 2), 1)
            -- engine.amp(current_step, 0.5)
            -- engine.string_decay(current_step, 16)
        end
    end
end

function mute_clock()
    while true do
        clock.sync(1 / mute_speed)
        engine.string_decay('all', mute())
    end
end

function bend_clock()
    while true do
        clock.sync(1 / mute_speed)
        -- print(bend())
        engine.bend_depth('all', bend())
    end
end

function vibrato_clock()
    while true do
        clock.sync(1 / vibrato_speed)
        engine.vibrato_depth('all', vibrato())
    end
end

function cleanup()
    engine.free()
end
