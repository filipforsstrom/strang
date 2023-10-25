Strang {

	// NEW: add local 'voiceKeys' variable to register each voice name separately
	classvar <voiceKeys;

	var distortion;
	var distortionParams;
	var filter;
	var <filterParams;
	var tremolo;
	var tremoloParams;
	var noise;
	var noiseParams;
	// NEW: establish 'globalParams' list for all voices
	var <globalParams;
	// NEW: establish 'voiceParams' to track the state of each 'globalParams' entry for each voice
	var <voiceParams;
	var <voiceGroup;
	// NEW: add 'singleVoices' variable to control + track single voices
	var <singleVoices;

	*initClass {
		// NEW: create voiceKey indices for as many voices as we want control over
		voiceKeys = [ \1, \2, \3, \4, \5, \6, \7, \8 ];
		StartUp.add {
			var s = Server.default;

			s.waitForBoot {
				SynthDef("Tremolo", {
					arg in, out = 0, freq = 1, depth = 0, amp = 1;

					var snd, mod;

					snd = In.ar(in, 2);
					mod = SinOsc.kr(freq);
					mod = mod * depth;
					snd = snd + mod;
					Out.ar(out, snd * amp);
				}).add;

				SynthDef("Filter", {
					arg in, out = 0;

					var snd, cutoff = Lag3.kr(\cutoff.kr(20000));

					snd = In.ar(in, 2);
					snd = LPF.ar(snd, cutoff);
					Out.ar(out, snd);
				}).add;

				SynthDef("Distortion", {
					arg in, out, gain, amp;

					var snd;

					snd = In.ar(in, 2);
					snd = (snd * gain).tanh;
					Out.ar(out, snd * amp);
				}).add;

				SynthDef("Noise", {
					arg in, out, amp;

					var snd;

					snd = BrownNoise.ar();
					Out.ar(out, amp * snd.tanh.dup);
				}).add;

				SynthDef("String", {
					arg out=0, amp=1, freq=220,
					noise_hz = 4000,
					tune_up = 1.01, tune_down = 0.99, string_decay=16.0,
					lpf_ratio=2.0, lpf_rq = 4.0, hpf_hz = 40, damp=0, damp_time=0.1,gate=1,
					vibrato_rate = 6, vibrato_depth = 0,
					bend_attack = 0.1, bend_release = 0.1, bend_depth = 0, bend_curve = 0,
					click_env_attack = 0.001, click_env_release = 0.07, click_freq = 200, click_feedback = 4, click_amp = 0.05,
					gain=1, pan=0;

					var
					noise, click, click_env, string, mix, delaytime, lpf, noise_env, snd, damp_mul, bend;

					damp_mul = LagUD.ar(K2A.ar(1.0 - damp), 0, damp_time);

					noise_env = Decay2.ar(Impulse.ar(0));
					noise = LFNoise2.ar(noise_hz) * noise_env;

					freq = Vibrato.kr(freq, vibrato_rate, vibrato_depth);
					bend = EnvGen.ar(Env.perc(bend_attack, bend_release, bend_depth, bend_curve));
					freq = freq + bend;
					delaytime = 1.0 / ((freq * [tune_up, tune_down])) ;
					// string = Mix.new(CombL.ar(noise, delaytime, delaytime, string_decay * damp_mul));
					string = Pluck.ar(noise, Impulse.kr(1), 1 , delaytime, string_decay * damp_mul);
					string = RLPF.ar(string, lpf_ratio * freq, lpf_rq) * amp;
					string = HPF.ar(string, hpf_hz);

					click_env = Env.perc(click_env_attack, click_env_release, 1, -4);
					click = (SinOscFB.ar(click_freq * [tune_up, tune_down], click_feedback) * EnvGen.kr(click_env)) * click_amp;

					mix = Mix.new([string, click]);
					snd = mix * EnvGen.ar(Env.adsr(), gate:gate, doneAction: 2);
					// snd = (snd * gain).tanh;

					Out.ar(out, Balance2.ar(snd[0], snd[1], pan));
					DetectSilence.ar(snd, doneAction:2);
				}).add;
			}
		}
	}

	*new {
		^super.new.init;
	}

	init {

		var s = Server.default;
		var tremoloInput = Bus.audio(s, 2);
		var filterInput = Bus.audio(s, 2);
		var distortionInput = Bus.audio(s, 2);

		tremolo = Synth.new("Tremolo", [\in, tremoloInput, \out, 0]);
		filter = Synth.new("Filter", [\in, filterInput, \out, 0]);
		distortion = Synth.new("Distortion", [\in, distortionInput, \out, filterInput, \gain, 300, \amp, 0.5]);

		noise = Synth.new("Noise", [\out, distortionInput, \amp, 0]);

		voiceGroup = Group.new(s);

		// NEW: create a 'globalParams' Dictionary to hold the parameters common to each voice
		globalParams = Dictionary.newFrom([
			\out, distortionInput,
			\amp, 0.5,
			\noise_hz, 4000,
			\string_decay, 16.0,
			\vibrato_rate, 6,
			\vibrato_depth, 0,
			\pan, 0,
			\click_env_attack, 0.001,
			\click_env_release, 0.07,
			\click_freq, 200,
			\click_amp, 0.05,
			\click_feedback, 4,
			\bend_attack, 0.1,
			\bend_release, 0.1,
			\bend_depth, 0,
			\bend_curve, 0,
		]);

		// NEW: create a 'singleVoices' Dictionary to control each voice individually
		singleVoices = Dictionary.new;
		// NEW: 'voiceParams' will hold parameters for our individual voices
		voiceParams = Dictionary.new;
		// NEW: for each of the 'voiceKeys'...
		voiceKeys.do({ arg voiceKey;
			// NEW: create a 'singleVoices' entry in the 'voiceGroup'...
			singleVoices[voiceKey] = Group.new(voiceGroup);
			// NEW: and add unique copies of the globalParams to each voice
			voiceParams[voiceKey] = Dictionary.newFrom(globalParams);
		});
	}

	// NEW: helper function to manage voices
	playVoice { arg voiceKey, freq;
		// NEW: if this voice is already playing, gracefully release it
		singleVoices[voiceKey].set(\gate, -1.05); // -1.05 is 'forced release' with 50ms (0.05s) cutoff time
		// NEW: set '\freq' parameter for this voice to incoming 'freq' value
		// voiceParams[voiceKey][\freq] = freq;
		// NEW: make sure to index each of our tables with our 'voiceKey'
		Synth.new("String", [\freq, freq] ++ voiceParams[voiceKey].getPairs, singleVoices[voiceKey]);
		/*Synth.new("Guitar", [\freq, freq - 0.2, \pan, -1] ++ voiceParams[voiceKey].getPairs, singleVoices[voiceKey]);*/
	}

	trigger { arg voiceKey, freq, amp;
		// NEW: if the voice is 'all'...
		if( voiceKey == 'all',{
		// NEW: then do the following for all of the voiceKeys:
			voiceKeys.do({ arg vK;
				// NEW: use 'this.' to call functions specific to this instance
				this.playVoice(vK, freq, amp);
			});
		}, // NEW: else, if the voice is not 'all':
		{
			// NEW: play the specified voice
			this.playVoice(voiceKey, freq, amp);
		});
	}

	adjustVoice { arg voiceKey, paramKey, paramValue;
		singleVoices[voiceKey].set(paramKey, paramValue);
		voiceParams[voiceKey][paramKey] = paramValue
	}

	setStringParam { arg voiceKey, paramKey, paramValue;
		// NEW: if the voiceKey is 'all'...
		if( voiceKey == 'all',{
			// NEW: then do the following for all of the voiceKeys:
			voiceKeys.do({ arg vK;
				this.adjustVoice(vK, paramKey, paramValue);
			});
		}, // NEW: else, if the voiceKey is not 'all':
		{
			// NEW: send changes to the correct 'singleVoices' index,
			// which will immediately affect the 'voiceKey' synth
			this.adjustVoice(voiceKey, paramKey, paramValue);
		});
	}

	setDistortionParam { arg paramKey, paramValue;
		distortion.set(paramKey, paramValue);
	}

	setFilterParam { arg paramKey, paramValue;
		filter.set(paramKey, paramValue);
	}

	setNoiseParam { arg paramKey, paramValue;
		noise.set(paramKey, paramValue);
	}

	setTremoloParam { arg paramKey, paramValue;
		tremolo.set(paramKey, paramValue);
	}

	// NEW: since each 'singleVoices' is a sub-Group of 'voiceGroup',
	//   we can simply pass a '\gate' to the 'voiceGroup' Group.
	// IMPORTANT SO OUR SYNTHS DON'T RUN PAST THE SCRIPT'S LIFE
	freeAllNotes {
		voiceGroup.set(\gate, -1.05);
	}

	free {
		// IMPORTANT
		voiceGroup.free;
		distortion.free;
		filter.free;
		tremolo.free;
		noise.free;
	}

}