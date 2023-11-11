local riff = {}

riffs = {}
local max_phrases = 128
local max_steps = 128
local default_pulses = 4
local default_steps = 4
local default_rotation = 0

local function update_trigger_sequins(t)
    -- collect values to pass to er.gen
    local pulses = t.pulses
    local steps = t.steps
    local rotation = t.rotation

    -- generate and update sequins
    local er_triggers = er.gen(pulses, steps, rotation)
    t.sequins:settable(er_triggers)
end

local function update_sequins(t, e)
    local pulses = t.pulses
    local expression_sequins = {}
    local expressions = e.data

    for i = 1, pulses do
        local index = (i - 1) % #expressions + 1
        local value = expressions[index]
        table.insert(expression_sequins, value)
    end

    e.sequins:settable(expression_sequins)
end

function riff.new()
    local id = #riffs + 1
    local r = {
        global = {
            length = max_phrases
        },
        triggers = {},
        amps = {},
        freqs = {},
        mutes = {},
        bends = {},
        vibratos = {}
    }

    -- add default data
    for i = 1, r.global.length do
        table.insert(r.triggers, {
            pulses = default_pulses,
            steps = default_steps,
            rotation = default_rotation,
            sequins = s {}
        })
        table.insert(r.amps, {
            data = {0.5},
            sequins = s {}
        })
        table.insert(r.freqs, {
            data = {50},
            sequins = s {}
        })
        table.insert(r.mutes, {
            data = {1},
            sequins = s {}
        })
        table.insert(r.bends, {
            data = {0, 0, 0, 0},
            sequins = s {}
        })
        table.insert(r.vibratos, {
            data = {0, 0, 0, 0},
            sequins = s {}
        })
    end

    -- generate sequins
    for i = 1, r.global.length do
        update_trigger_sequins(r.triggers[i])
        update_sequins(r.triggers[i], r.amps[i])
        update_sequins(r.triggers[i], r.freqs[i])
        update_sequins(r.triggers[i], r.mutes[i])
        update_sequins(r.triggers[i], r.bends[i])
        update_sequins(r.triggers[i], r.vibratos[i])
    end

    riffs[id] = r

    return setmetatable(r, {
        __index = riff
    })
end

function riff.get_riff(id)
    return riffs[id]
end

function riff.get_max_phrases()
    return max_phrases
end

function riff.get_max_steps()
    return max_steps
end

function riff.get_default_pulses()
    return default_pulses
end

function riff.get_default_steps()
    return default_steps
end

function riff.get_default_rotation()
    return default_rotation
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

function riff:set_frequency(riff_index, freq_index, new_frequency)
    if self.freqs[riff_index] then
        self.freqs[riff_index].data[freq_index] = new_frequency
        update_sequins(self.triggers[riff_index], self.freqs[riff_index])
    else
        print("Error: Invalid index")
    end
end

function riff:set_amp(riff_index, amp_index, new_amp)
    if self.amps[riff_index] then
        self.amps[riff_index].data[amp_index] = new_amp
        update_sequins(self.triggers[riff_index], self.amps[riff_index])
    else
        print("Error: Invalid index")
    end
end

function riff:set_mute(riff_index, mute_index, new_mute)
    if self.mutes[riff_index] then
        self.mutes[riff_index].data[mute_index] = new_mute
        update_sequins(self.triggers[riff_index], self.mutes[riff_index])
    else
        print("Error: Invalid index")
    end
end

function riff:set_bend(riff_index, bend_index, new_bend)
    if self.bends[riff_index] then
        self.bends[riff_index].data[bend_index] = new_bend
        update_sequins(self.triggers[riff_index], self.bends[riff_index])
    else
        print("Error: Invalid index")
    end
end

function riff:set_vibrato(riff_index, vibrato_index, new_vibrato)
    if self.vibratos[riff_index] then
        self.vibratos[riff_index].data[vibrato_index] = new_vibrato
        update_sequins(self.triggers[riff_index], self.vibratos[riff_index])
    else
        print("Error: Invalid index")
    end
end

return riff
