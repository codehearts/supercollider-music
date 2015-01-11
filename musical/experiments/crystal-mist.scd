SynthDef(\crystal_mist) { |out=0, pan=0, freq=440, crunch=50, pulse=1.25, attack=0.005, sustain=1, decay=0.5, amp=0.25|
	var level, saw, reverb, pan2;

	level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);

	saw = Pulse.ar(freq, 0.5, Saw.kr(crunch, SinOsc.kr(pulse)));

	reverb = FreeVerb.ar(saw, 0.5, 1, 1);
	pan2 = Pan2.ar(saw + reverb, pan);

	Out.ar(out, pan2 * level);
}.add;





Routine({

	Pbind(
		\instrument, \crystal_mist,
		\freq, Pstutter(
			Pseq([4], inf),
			Pseq([440, 330, 440, 275] * 0.618, inf)
		),
		\dur, Pstutter(
			Pseq([1], inf),
			Pseq([1], inf)
		),
		\crunch, 20,
		\pulse, 10,
		\amp, 0.25
	).play;

	Pbind(
		\instrument, \crystal_mist,
		\freq, Pstutter(
			Pseq([4], inf),
			Pseq([440, 550, 440, 330] * 2, inf)
		),
		\dur, Pstutter(
			Pseq([1], inf),
			Pseq([0.5], inf)
		),
		\crunch, 1,
		\pulse, 1.25,
		\amp, 0.25
	).play;

}).play;