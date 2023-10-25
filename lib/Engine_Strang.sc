Engine_Strang : CroneEngine {
// All norns engines follow the 'Engine_MySynthName' convention above

	// NEW: select a variable to invoke Moonshine with
	var kernel;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc { // allocate memory to the following:

		// NEW: since Moonshine is now a supercollider Class,
		//   we can just construct an instance of it
		kernel = Strang.new(Crone.server);

		// NEW: build an 'engine.trig(x,y)' command,
		//   x: voice, y: freq
		this.addCommand(\trig, "sff", { arg msg;
			var voiceKey = msg[1].asSymbol;
			var freq = msg[2].asFloat;
            var amp = msg[3].asFloat;
			kernel.trigger(voiceKey,freq,amp);
		});

		// NEW: since each voice shares the same parameters ('globalParams'),
		//   we can define a command for each parameter that accepts a voice index
		kernel.globalParams.keysValuesDo({ arg paramKey;
			this.addCommand(paramKey, "sf", {arg msg;
				kernel.setStringParam(msg[1].asSymbol,paramKey.asSymbol,msg[2].asFloat);
			});
		});

		// NEW: add a command to free all the voices
		this.addCommand(\free_all_notes, "", {
			kernel.freeAllNotes();
		});

	} // alloc


	// NEW: when the script releases the engine,
	//   free all the currently-playing notes and groups.
	// IMPORTANT
	free {
		kernel.freeAllNotes;
		kernel.free;
	} // free


} // CroneEngine