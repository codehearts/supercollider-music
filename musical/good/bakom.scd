// Something that sounds almost like the synth work from a Coaltar of the Deepers song

SynthDef(\filteredBlip) { |out=0, freq=150, filMin=0, filMax=1, imp=0.05, pulse=5, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(
			freq,
			0,
			LFTri.kr(imp).range(filMin, filMax),
			Saw.kr(pulse).range(0, amp)
		),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

// Basses

SynthDef(\susSine) { |out=0, freq=440, amp=0.25, pan=0, sustain=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0]), 1, doneAction: 2),
		sine = SinOsc.ar(freq, 0, amp) * env,
		pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\triSaw) { |out=0, freq=150, hi=1, lo=0, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(lo, hi), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;



Routine({
	Synth(\filteredBlip, [\freq, 550, \filMax, 0.75, \imp, 0.05, \pulse, 5, \sustain, 100]);

	12.wait;

	Synth(\susSine, [\freq, 150, \amp, 0.5, \sustain, 3]);

	3.wait;

	Synth(\susSine, [\freq, 175, \amp, 0.5, \sustain, 3]);

	3.wait;

	Synth(\susSine, [\freq, 125, \amp, 0.5, \sustain, 3]);

	3.wait;

	Synth(\susSine, [\freq, 150, \amp, 0.5, \sustain, 3]);

	(3.5).wait;

	Synth(\filteredBlip, [\freq, 250, \imp, 0.05, \pulse, 10, \sustain, 100]);
}).play;