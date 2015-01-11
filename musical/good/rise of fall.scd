// Chip tune snippet of "Fall of Fall", the stage 4 music from Touhou 10

SynthDef(\square) { |out=0, freq=400, atk=0.005, sustain=1, dec=0.005, pan=0, amp=0.25|
	var env, osc, osc2, panning, reverb;

	env = EnvGen.kr(Env.linen(atk, sustain, dec, amp, 0), doneAction: 2);
	osc = Pulse.ar(freq, 0.5, 1);
	osc2 = Pulse.ar(freq*2, 0.5, 1);
	panning = Pan2.ar(osc+osc2, pan);
	reverb = FreeVerb.ar(panning, 0.5, 1, 0.5) * env;

	Out.ar(out, reverb);
}.add;

SynthDef(\saw) { |out=0, freq=400, atk=0.005, sustain=1, dec=0.005, pan=0, amp=0.25|
	var env, osc, osc2, osc3, osc4, panning, reverb;

	env = EnvGen.kr(Env.linen(atk, sustain, dec, amp/2, 0), doneAction: 2);
	osc = Pulse.ar(freq*2, 0.5, 1).range(0.1);
	osc2 = Pulse.ar(freq*4, 0.5, 1).range(0.1);
	osc3 = Saw.ar(freq, osc);
	osc4 = Saw.ar(freq*2, osc2);
	panning = Pan2.ar(osc3+osc4, pan);
	reverb = FreeVerb.ar(panning, 0.25, 1, 0.5) * env;

	Out.ar(out, reverb);
}.add;



Routine({
	~speed = 3;

// Upper right-hand
Pbind(
	\instrument, \square,
	\freq, Pseq([59,59,  61,  62, 64,66,59,59, 68, 62,64,66,66, 69, 66,  69,  66, 63, 66, 63, 66, 59,59,57, 59, 55,64,61,61,59,61,62,64,61,66].midicps, inf),
	\dur,  Pseq([2, 0.75,0.75,0.5,1, 1, 1, 0.5,0.5,1, 1, 1, 0.5,0.5,0.25,0.25,2.5,0.5,0.5,0.5,0.5,1, 1, 0.5,0.5,1, 1, 1, 1, 1, 1, 1, 1, 2, 1] / ~speed, inf),
	\legato, 0.95,
	\amp, 0.25,
	\pan, 1
).play;

// Lower left hand
Pbind(
	\instrument, \square,
	\freq, Pswitch(
		[
			Pseq([28,35,40, 30,37,42, 31,38,43, 30,37,42].midicps),
			Pseq([31, 38, 43,33, 40, 45].midicps),
			Pseq([37].midicps)
		],
		Pstutter(
			Pseq([3,1,6], inf),
			Pseq([0,1,2], 2)
		)
	),
	\dur, Pswitch(
		[
			Pseq([0.5,0.5,1]),
			Pseq([0.5])
		],
		Pstutter(
			Pseq([14,6], inf),
			Pseq([0, 1], 2)
		)
	) / ~speed,
	\legato, 0.95,
	\amp, 0.25,
	\pan, -1
).play;

}).play;