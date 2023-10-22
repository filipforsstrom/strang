-- Define the GuitarRiff class
local riff = class()

-- Define the constructor for the riff class
function riff:init(notes, tempo)
    riff.notes = notes
    riff.tempo = tempo
end

-- Define the play method for the riff class
function riff:set_position()
    for i, note in ipairs(riff.notes) do
        print(note)
        os.execute("sleep " .. (60 / riff.tempo))
    end
end

-- Return the riff class
return riff
