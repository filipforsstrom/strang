local parameters = {}

local active_riff = {}
local riff_options = {}

function parameters.init()
    table.insert(riff_options, 1)

    params:add{
        type = "option",
        id = "selected_riff",
        name = "riff",
        options = riff_options,
        default = 1,
        action = function(id)
            print("selected riff: " .. riff_options[id])
            active_riff = riff.get_riff(riff_options[id])
        end
    }

    add_riff_params(1)
    params:default()
    params:bang()
end

function add_riff_params(id)
    local max_phrases = riff.get_max_phrases()
    local max_steps = riff.get_max_steps()
    local default_pulses = riff.get_default_pulses()
    local default_steps = riff.get_default_steps()
    local default_rotation = riff.get_default_rotation()
    local unique_params = 3
    local total_params = max_phrases * unique_params

    params:add_group("riff" .. id, "riff " .. id, total_params)

    for i = 1, max_phrases do
        params:add_number("riff" .. id .. "_phrase" .. i .. "_pulses", "phrase " .. i .. " pulses", 0, max_steps,
            default_pulses)
        params:set_action("riff" .. id .. "_phrase" .. i .. "_pulses", function(x)
            local steps = params:get("riff" .. id .. "_phrase" .. i .. "_steps")
            if x > steps then
                params:set("riff" .. id .. "_phrase" .. i .. "_pulses", x - 1)
            end
            active_riff:set_pulses(i, x)
        end)

        params:add_number("riff" .. id .. "_phrase" .. i .. "_steps", "phrase " .. i .. " steps", 1, max_steps,
            default_steps)
        params:set_action("riff" .. id .. "_phrase" .. i .. "_steps", function(x)
            local pulses = params:get("riff" .. id .. "_phrase" .. i .. "_pulses")
            if x < pulses then
                params:set("riff" .. id .. "_phrase" .. i .. "_pulses", x)
            end
            active_riff:set_steps(i, x)
        end)

        params:add_number("riff" .. id .. "_phrase" .. i .. "_rotation", "phrase " .. i .. " rotation", 1, max_steps,
            default_rotation)
        params:set_action("riff" .. id .. "_phrase" .. i .. "_rotation", function(x)
            active_riff:set_rotation(i, x)
        end)
    end
end

function parameters.add_riff(id)
    table.insert(riff_options, id)
    add_riff_params(id)
    local selected_riff_param = params:lookup_param("selected_riff")
    selected_riff_param.options = riff_options
    selected_riff_param.count = #riff_options
    selected_riff_param.selected = 1
end

return parameters
