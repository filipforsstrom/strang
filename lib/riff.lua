local riff = {}

local function update_trigger_sequins(triggers)
    -- collect values to pass to er.gen
    local pulses = triggers.pulses
    local steps = triggers.steps
    local rotation = triggers.rotation

    -- generate and update sequins
    local er_triggers = er.gen(pulses, steps, rotation)
    triggers.sequins:settable(er_triggers)
end

local function update_amp_sequins(r, a)
    local pulses = r.pulses
    local amps = a.data
    local amps_sequins = {}

    for i = 1, pulses do
        table.insert(amps_sequins, amps[(i - 1) % #amps + 1])
    end
    a.sequins:settable(amps_sequins)
end


function riff.new()
    local length = 8
    local r = {
        triggers = {},
        amps = {},
        freqs = {},
        mutes = {},
        bends = {},
        vibratos = {}
    }

    -- add default data
    for i = 1, length do
        table.insert(r.triggers, {
            pulses = 4,
            steps = 7,
            rotation = 0,
            sequins = s {}
        })
        table.insert(r.amps, {
            data = {100, 0.5},
            sequins = s {}
        })
        table.insert(r.freqs, s {50})
        table.insert(r.mutes, s {0.5})
        table.insert(r.bends, s {0})
        table.insert(r.vibratos, s {0})
    end

    -- generate sequins
    for i = 1, #r.triggers do
        update_trigger_sequins(r.triggers[i])
        update_amp_sequins(r.triggers[i], r.amps[i])
    end

    return setmetatable(r, {
        __index = riff
    })
end

function riff:update_all_pulses(r)
    for i = 1, #r.triggers do
        local triggers = r.triggers[i]
        local pulses = triggers.pulses
        local steps = triggers.steps
        local rotation = triggers.rotation

        local er_triggers = er.gen(pulses, steps, rotation)
        triggers.sequins:settable(er_triggers)
    end
end

function riff:set_random_freqs()
    -- loop over each item in self.freqs
    for i = 1, #self.freqs do
        -- generate a new table of random frequencies
        local random_freqs = {}
        for j = 1, #self.freqs[i] do
            -- generate a random frequency between some range
            -- adjust the range as needed
            local random_freq = math.random(50, 1000)
            table.insert(random_freqs, random_freq)
        end

        -- overwrite the current freq data with the random freqs
        self.freqs[i]:settable(random_freqs)
    end
end

function riff:set_pulses(index, new_pulses)
    if self.triggers[index] then
        self.triggers[index].pulses = new_pulses
        update_trigger_sequins(self.triggers[index])
    else
        print("Error: Invalid index")
    end
end

function riff:set_steps(index, new_steps)
    if self.triggers[index] then
        self.triggers[index].steps = new_steps
        update_trigger_sequins(self.triggers[index])
    else
        print("Error: Invalid index")
    end
end

function riff:set_rotation(index, new_rotation)
    if self.triggers[index] then
        self.triggers[index].rotation = new_rotation
        update_trigger_sequins(self.triggers[index])
    else
        print("Error: Invalid index")
    end
end

return riff
