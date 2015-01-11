SynthDef(\vibeSpark) { |out=0, imp=5, freq=150, sustain=0.25, attack=0.75, decay=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(
			Env.linen(sustain*attack, sustain*(1-attack), decay, amp, [-2.5,0,0]),
			1,
			doneAction: 2
		),
		saw  = Saw.ar(imp, aEnv),
		sine = SinOsc.ar(freq, 0, saw).min(amp).max(0-amp),
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\fogVibe) { |out=0, imp=5, freq=150, sustain=0.25, attack=0.75, decay=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(
			Env.linen(sustain*attack, sustain*(1-attack), decay, amp),
			1,
			doneAction: 2
		),
		saw  = Saw.ar(imp).min(1),
		sine = SinOsc.ar(freq, 0, saw),
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2 * aEnv);
}.add;

// --- Percussion

SynthDef(\snare) { |out=0, freq=1250, decay=0.15, amp=0.25, pan=0|
	var sust, osc, noise, crispy, rvrb, pan2;

	sust = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2);

	osc = Pulse.ar(freq, 0.5, 1) * WhiteNoise.kr(1);
	noise = WhiteNoise.ar(1);
	crispy =  BrownNoise.ar(0.75);
	rvrb = FreeVerb.ar(osc+noise>crispy, 0, 1, 1);
	pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\bassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=0.25|
	var hit_time, sust, osc, osc2, pan2;

	hit_time = 0.15;
	sust = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2);

	osc = SinOsc.ar(XLine.kr(freq*1.618, freq/3.236, hit_time), 0, amp);
	osc2 = osc - SinOsc.kr(freq/6.472, 0, 0.25);
	pan2 = Pan2.ar(osc2, pan);

	Out.ar(out, pan2*sust);
}.add;



Routine({

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([75, 100, 75, 50] * 1.618, inf),
		\dur, Pseq([2], inf),
		\legato, 1,
		\attack, 0.25,
		\decay, 0.5,
		\imp, 0.000125,
		\amp, 0.25
	).play;

	8.wait;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 50, 75, 100] * 4),
				Pseq([75, 90, 110, 50, 75, 100] * 3.236)
			],
			Pstutter(
				Pseq([8,8], inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pseq([1/8], inf),
		\legato, 1,
		\imp, 0.025,
		\amp, 0.25
	).play;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([90, \rest, 92, \rest, 91, \rest, 93, \rest] * 1.618, inf),
		\dur, Pstutter(
			Pseq([8], inf),
			Pseq([1], 12)
		),
		\legato, 1,
		\attack, 1,
		\decay, 2,
		\imp, 100,
		\amp, 0.1,
		\out, Pseq([0,0,1,1], inf)
	).play;

	8.wait;

	// 1 loop = 8s
	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 75, 90, 100] * 4),
				Pseq([75, 90, 110, 75, 90, 100] * 3.236)
			],
			Pstutter(
				Pseq([4,4], inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pseq([1/4], inf),
		\legato, 1,
		\imp, 0.125,
		\amp, 0.1,
		\out, [0,1]
	).play;

	8.wait;

	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 75, 90, 100] * 4 * 2),
				Pseq([75, 90, 110, 75, 90, 100] * 3.236 * 2)
			],
			Pstutter(
				Pseq([4,4] * 2, inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pseq([1/4] / 2, inf),
		\legato, 1,
		\imp, 1,
		\decay, 1,
		\amp, 0.1,
		\out, 0
	).play;

	/*8.wait;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pstutter(
			Pseq([4], inf),
			Pseq([144,60,10,5] * 1.618, inf)
		),
		\dur, Pstutter(
			Pseq([4], inf),
			Pseq([0.25], 12)
		),
		\legato, 1,
		\attack, 0.5,
		\decay, 0.5,
		\imp, 100,
		\amp, 0.15
	).play;

	4.wait;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pstutter(
			Pseq([4], inf),
			Pseq([144,84,134,139] * 1.618 * 6, inf)
		),
		\dur, Pstutter(
			Pseq([4], inf),
			Pseq([0.25], 12)
		),
		\legato, 1,
		\attack, 0.5,
		\decay, 0.5,
		\imp, 100,
		\amp, 0.1,
		\out, 1
	).play;*/

	90.wait;

	/*Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([90, \rest, 92, \rest] * 1.618, inf),
		\dur, Pseq([0.5,1.5], 10),
		\legato, 1,
		\attack, 0.5,
		\decay, 0.5,
		\imp, 100,
		\amp, 0.25
	).play;*/

	(7.75).wait;

	Synth(\bassDrum, [\freq, 161.8, \sustain, 0.5, \amp, 0.5]);
	(0.25).wait;
	Synth(\snare, [\amp, 0.25]);

	(0.5).wait;
	~bassKick4.value(4, freq:161.8, dur:1, amp:0.5);

	90.wait;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([75, 70, 100, 90, 85] * 4),
		\dur, Pstutter(
			Pseq([3,2], inf),
			Pseq([4,2], 10)
		),
		\legato, 1,
		\attack, 0.15,
		\imp, 20,
		\amp, 0.5
	).play;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([\rest, 90, \rest, 85, \rest] * 4),
		\dur, Pseq([12,0.5,1.5,0.5,1.5], 10),
		\legato, 1,
		\attack, 0.25,
		\imp, 200,
		\amp, 0.25
	).play;

	90.wait;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 50, 25, 100, 50] * 4),
				Pseq([75, 90, 110, 50, 25, 100, 50] * 3.236)
			],
			Pstutter(
				Pseq([8,8], inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pswitch(
			[
				Pseq([0.7] / 10),
				Pseq([5])
			],
			Pstutter(
				Pseq([10,10], inf),
				Pseq([1 ,0 ], 10)
			)
		),
		\legato, 1,
		\imp, Pswitch(
			[
				Pseq([0.5]),
				Pseq([50])
			],
			Pstutter(
				Pseq([10,10], inf),
				Pseq([1 ,0 ], 10)
			)
		),
		\amp, 0.5
	).play;

	8.wait;

}).play;