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

SynthDef(\starBerry) { |out=0, freq=150, filMin=0.1, filMax=0.95, imp=1, gate=1, amp=0.5|
	var sust = Linen.kr(gate, releaseTime: 0.25, doneAction: 2),
		vSaw = VarSaw.ar(
			freq,
			0,
			EnvGen.kr(Env([filMin,filMax,filMin], [0.25*imp,0.75*imp], [-5,-5], 2), gate),
			amp
		),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

SynthDef(\reverseDusthumm, {|freq = 440, dur = 10, crushRate = 100, crushStep = 0.1, pan = 0, amp = 0.2, out = 0|
	var osc, env, panning, reverb;

	env = EnvGen.kr(Env.linen(dur, 0.005, 0.75, amp, 0), doneAction: 2);
	osc = Pulse.ar(freq, SinOsc.kr(crushRate, 0, 1).range(crushStep).abs, env);
	panning = Pan2.ar(osc, pan);
	reverb = FreeVerb.ar(panning, 1, 1, 0.5);

	Out.ar(out, reverb);
}).add;

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



// --- Melodies

// 1 loop = 8 seconds
	~dustLead = { |loops=1, amp=0.5, speed=0.5|
		Pbind(
			\instrument, \reverseDusthumm,
			\freq, Pstutter(
					Pseq([4,  4,  4,  3, 1], loops),
					Pseq([100,150,134,89,124], inf)
				),
			\dur, speed,
			\legato, 0.75,
			\amp, amp
		).play;
	};

~melody4 = { |synth, loops=1, amp=0.25, imp=0.95|
	Pbind(
		\instrument, synth,
		\freq, Pstutter(
			Pseq([4], inf),
			Pseq([59, 66, 62, 60, 59, 67, 64, 59, 66, 62].midicps, loops),
		),
		\dur, Pstutter(
			Pseq([8, 2], inf),
			Pseq([1.5, 2] / 8, inf)
		),
		\legato, 1,
		\imp, imp,
		\amp, amp
	).play;
};

// 1 loop = 8 seconds
~bassMelody = { |synth, loops=1, amp=0.25, imp=1|
	Pbind(
		\instrument, synth,
		\freq, Pstutter(
			Pseq([16], inf),
			Pseq([24, 24, 26, 19].midicps*4, loops)
		),
		\dur, 0.125,
		\legato, 1,
		\filMax, 0.1,
		\imp, imp,
		\amp, amp
	).play;
};



Routine({

	~dustLead.value(1, 0.5, speed: 4); // 32s

	8.wait;

	~bassMelody.value(\starBerry, 20, 0.5, 2);

	8.wait;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([90, \rest, 92, \rest, 91, \rest, 93, \rest] * 2 * 1.618, inf),
		\dur, Pstutter(
			Pseq([8], inf),
			Pseq([1], 12)
		),
		\legato, 1,
		\attack, 1,
		\decay, 2,
		\imp, 100,
		\amp, 0.2,
		\out, Pseq([0,0,1,1], inf)
	).play;

	8.wait;

	~melody4.value(\starBerry, 20, 0.25, 200);

	8.wait;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([75, 70, 100, 90, 85] * 2 * 1.618),
		\dur, Pstutter(
			Pseq([3,2], inf),
			Pseq([4,2], 10)
		),
		\legato, 1,
		\attack, 0.15,
		\imp, 60,
		\amp, 0.15
	).play;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([\rest, 90, \rest, 85, \rest] * 2 * 1.618),
		\dur, Pseq([12,0.5,1.5,0.5,1.5], 10),
		\legato, 1,
		\attack, 0.25,
		\imp, 250,
		\amp, 0.25
	).play;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([90, \rest, 92, \rest] * 1.618, inf),
		\dur, Pseq([0.5,1.5], 10),
		\legato, 1,
		\attack, 0.5,
		\decay, 0.5,
		\imp, 100,
		\amp, 0.25
	).play;

	32.wait;

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
	).play;

	/*
	Pbind(
		\instrument, \bassDrum,
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
		\amp, 0.5
	).play;
	*/

}).play;