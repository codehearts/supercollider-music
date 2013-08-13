// Mishmash of synths, with a pretty good bass line

SynthDef(\sineBell) { |out=0, pan=0, freq=100, attack=0.005, sustain=0.1, decay=0.005, amp=1|
	var sine, pan2;

	sine = SinOsc.ar(
		freq,
		0,
		EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2)
	);
	pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\hardSine) { |out=0, freq=440, gate=1, amp=1|
	var env, aEnv, sine, pan;

	env  = EnvGen.kr(Env.cutoff(0), gate, doneAction: 2);
	aEnv = EnvGen.kr(Env([0, amp, amp/2], [0.15, 0.1], [5, -10]));
	sine = SinOsc.ar(freq, 0, aEnv);
	pan  = Pan2.ar(sine*env, 0, FSinOsc.kr(2));

	Out.ar(out, pan);
}.add;

SynthDef(\bass) { |out=0, freq=440, amp=1, pan=0, sustain=1|
	var sust, osc, osc2, pan2;

	sust = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2);

	osc = SinOsc.ar(XLine.kr(freq, freq/1.05, sustain), 0, amp);
	osc2 = osc + SinOsc.kr(freq/16.18, 0, amp);
	pan2 = Pan2.ar(osc2, pan);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\beep) { |out=0, freq=440, amp=1, sustain=1|
	var sine, ring;

	sine = SinOsc.ar(
		freq,
		0,
		Trig.kr(Line.kr(1, 0, sustain), sustain)
	);
	ring = Ringz.ar(sine, 2000, sustain, amp);

	Out.ar(out, ring);
}.add;

SynthDef(\snare) { |out=0, freq=1000, decay=0.25, amp=1, pan=0|
	var aEnv = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, WhiteNoise.ar(aEnv*0.15)),
		rvrb = FreeVerb.ar(drum, 0.75, 1, 0.75) + WhiteNoise.ar(aEnv*0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;



// Effects synths

SynthDef(\guitarEdge) { |effectBus, out=0, amount=0.99|
	var in, amCoef, audio;

	in = HPF.ar(In.ar(effectBus), 400) * 5;
	amCoef= 2 * amount / (1-amount);
	audio = MidEQ.ar(LPF.ar((1+amCoef)*in/(1+(amCoef*in.abs)), [3800, 3900])*0.5, 120, 0.7, 8);

	Out.ar(out, audio);
}.add;



Routine({

	// Effects buses

	~sources = Group.new;

	/*~guitarEdgeGroup = Group.new(~sources, \addToTail);
	~guitarEdge= Bus.audio(s, numChannels: 2);*/

	// Composition

	/*Pbind(
		\instrument, \hardSine,
		\freq, Pseq([400, 500, 600, 750], inf, 1),
		\dur, Pstutter(
			Pseq([3,    7,   inf]),
			Pseq([0.75, 0.5, 0.25])
		),
		\amp, 0.1
	).play;

	(3 * 0.75 + 0.5 * 7 + 8 * 0.25).wait;

	Pbind(
		\instrument, \sineBell,
		\freq, Pswitch(
			[
				Pseq([28,35,40, 30,37,\rest, \r,\r,\r, \r,\r,\r, 31,38,43, 30,37,\r, \r,\r,\r, \r,\r,\r].midicps),
				Pseq([31, 38, 43,33, 40, 45].midicps)
			],
			Pstutter(
				Pseq([2,1], inf),
				Pseq([0,1], inf) // loops = inf
			)
		) * 8,
		\dur, Pswitch(
			[
				Pseq([0.5,0.5,1] / 2)
			],
			Pstutter(
				Pseq([14], inf),
				Pseq([0], inf) // loops = inf
			)
		),
		\legato, 0.95,
		\attack, 0.75,
		\decay, 2.5,
		\amp, 0.05,
		\imp, 0.125,
		\pan, 0
	).play;

	32.wait;*/

	Pbind(
		\instrument, \beep,
		\freq, Pswitch(
			[
				Pstutter( // 0
					Pseq([4, 1]),
					Pseq([71, 59].midicps, inf)
				),
				Pstutter( // 1
					Pseq([4, 1]),
					Pseq([59, 47].midicps, inf)
				),
				Pstutter( // 2
					Pseq([1,1,1,1,1]),
					Pseq([67, 55, 71, 60, 64].midicps, inf)
				),
				Pstutter( // 3
					Pseq([1,1,1,1,1]),
					Pseq([40, 50, 60, 70, 80].midicps, inf)
				),
				Pstutter( // 4
					Pseq([1,1,1,1,1]),
					Pseq([80, 70, 50, 60, 90].midicps, inf)
				)
			],
			Pstutter(
				Pseq([8, 4, 3, 1], inf),
				Pseq([0, 1, 2, 3], inf)
			)
		),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([0.125/2, Rest(0.125*2)], inf)
		),
		\amp, 0.1,
		\out, Pseq([0, 0, 1, 1], inf)
	).play;

	Pbind(
		\instrument, \bass,
		\freq, Pstutter(
			Pseq([16, 7, 1, 7, 1], inf),
			Pseq([44, 46, 49, 47, 49].midicps, inf)
		),
		\dur, Pstutter(
			Pseq([16], inf),
			Pseq([0.25], inf)
		),
		\amp, 0.75,
		\out, [0,1]
	).play;



	Pbind(
		\instrument, \sineBell,
		\freq, Pswitch(
			[
				Pseq([28,35,40, 30,37,\rest, \r,\r,\r, \r,\r,\r, 31,38,43, 30,37,\r, \r,\r,\r, \r,\r,\r].midicps),
				Pseq([31, 38, 43,33, 40, 45].midicps)
			],
			Pstutter(
				Pseq([2,1], inf),
				Pseq([0,1], inf) // loops = inf
			)
		) * 8*2,
		\dur, Pswitch(
			[
				Pseq([0.5,0.5,1] / 2)
			],
			Pstutter(
				Pseq([14], inf),
				Pseq([0], inf) // loops = inf
			)
		),
		\legato, 0.5,
		\attack, 0.005,
		\decay, 2,
		\amp, 0.125,
		\imp, 0.125,
		\pan, 0
	).play;

	(4.5).wait;

	Pbind(
		\instrument, \snare,
		\freq, Pseq([2000], inf),
		\dur, Pseq([1, 1], inf),
		\amp, 0.25
	).play;



	// Effects synths

	//Synth(\guitarEdge, [\effectBus, ~guitarEdge, \amount, 0.99], ~guitarEdgeGroup, \addToTail);
}).play;