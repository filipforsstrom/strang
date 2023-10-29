local riff = {}

function riff.init()
    local a = {
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
    for i = 1, #a.triggers do
        local pulses = a.triggers[i].pulses
        local steps = a.triggers[i].steps
        local rotation = a.triggers[i].rotation
        local trigger = er.gen(pulses, steps, rotation)
        a.triggers[i].triggers = trigger
    end

    a.triggers[1].sequins:settable(a.triggers[1].triggers)
    a.triggers[2].sequins:settable(a.triggers[2].triggers)
    a.triggers[3].sequins:settable(a.triggers[3].triggers)
    a.triggers[4].sequins:settable(a.triggers[4].triggers)

    return a
end

return riff
