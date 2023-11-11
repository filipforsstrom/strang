local parameters = {}

function parameters.init()

    local riffs = {"hej", "hopp"}

    params:add{
        type = "option",
        id = "selected_riff",
        name = "riff",
        options = riffs,
        default = 1,
        action = function(id)
            print("selected riff: " .. id)
        end
    }

    params:add_number("riff_pulses", "pulses", 0, 128, 1)

    params:default()
    params:bang()
end

return parameters
