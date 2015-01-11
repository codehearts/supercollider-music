// Drawn out bass synth with accents and tempo changes

SynthDef(\kivBass) { |out=0, freq=100, gate=1, imp=0.125, cap=0.94 pan=0, amp=0.5|
	var sust = Linen.kr(gate, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(0.84, cap), amp),
		pan2 = Pan2.ar(vSaw, pan);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\sawBass) { |out = 0, freq = 100, gate = 1, pulse = 2, imp = 0.125, pan = 0, amp = 0.5|
	var sust, vSaw, pan2;

	sust = Linen.kr(gate, doneAction: 2);
	vSaw = VarSaw.ar(freq, 0, Saw.kr(pulse).range(0.5, 0.95), amp);
	pan2 = Pan2.ar(vSaw, pan);

	Out.ar(out, pan2 * sust);
}.add;

// Drums

SynthDef(\bassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2),
		sine = SinOsc.ar(XLine.kr(freq, freq/3, sustain), 0, amp)*env,
		sqr  = Pulse.ar(XLine.kr(freq, freq/3, sustain), 0.5)*(amp*0.25)*env,
		pan2 = Pan2.ar(sine+sqr, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\snare) { |out=0, freq=7500, decay=0.3, amp=1, pan=0|
	var aEnv = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, WhiteNoise.ar(aEnv*0.15)),
		rvrb = FreeVerb.ar(drum, 1, 1, 1) - WhiteNoise.ar(aEnv*0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;



Routine({

// 1 loop = 2s
~bassKick = { |loops=1, freq=150, amp=0.5, dur=0.5, legato=0.25, dStut1=1, dStut2=1, dStut3=4, pan=0|
	Pbind(
		\instrument, \bassDrum,
		\freq, Pseq(freq.asArray, inf),
		\dur, PdurStutter(
			Pstutter(
				Pseq(dStut1.asArray, inf),
				Pseq(dStut2.asArray, inf)
			),
			Pstutter(
				Pseq(dStut3.asArray, loops),
				Pseq(dur.asArray, loops)
			)
		),
		\legato, legato,
		\pan, pan,
		\amp, amp
	).play;
};

// 1 loop = 4 seconds
~bassKick2 = { |loops=1, freq=150, amp=0.5, legato=0.25, pan=0|
	~bassKick.value(loops, freq, amp, [0.5,0.25,0.25], legato, [7,1], [1,2], [6,1,1], pan);
};

// 1 loop = 4 seconds
~bassKick3 = { |loops=1, freq=150, amp=0.5, legato=0.25, pan=0|
	~bassKick.value(loops, freq, amp, [0.25], legato, [1,8,1,6], [2,1,2,1], [16], pan);
};

~snareDrum = { |loops=1, freq=2000 amp=0.5, dur=1, dStut1=1, dStut2=1, dStut3=4|
	Pbind(
		\instrument, \snare,
		\freq, Pseq(freq.asArray, inf),
		\dur, PdurStutter(
			Pstutter(
				Pseq(dStut1.asArray, inf),
				Pseq(dStut2.asArray, inf)
			),
			Pstutter(
				Pseq(dStut3.asArray, loops),
				Pseq(dur.asArray, loops)
			)
		),
		\amp, amp
	).play;
};

// 1 loop = 8 seconds
~snareDrum2 = { |loops=1, freq=2000, amp=0.25|
	~snareDrum.value(loops, freq, amp, [0.5], [16], [1], [16]);
};

// 1 loop = 8 seconds
~snareDrum3 = { |loops=1, freq=2000, amp=0.5|
	~snareDrum.value(loops, freq, amp, [0.25,0.5,0.25,0.5], [1,8,1,1,5], [2,1,4,2,1], [1,8,2,5]);
};

~deepBass = { |amp = 0.5, loops = inf|
	Routine({
		var freq, dur, imp, cap, osc, tempDur;

		freq = Pswitch(
			[
				Pseq([90, 75, 90, 83]),
				Pseq([90, 75, 100, 83])
			],
			Pstutter(
				Pseq([14, inf], inf),
				Pseq([0,  1], inf)
			)
		).asStream;

		dur = Pstutter(
			Pseq([20, 12, 12,  loops-44], 1),
			Pseq([4,  1,  0.5, 0.25])
		).asStream;

		imp = Pstutter(
			Pseq([4,     2, 1, 1, 1,  3], inf),
			Pseq([0.125, 2, 4, 8, 50, 0.5], inf)
		).asStream;

		cap = Pswitch(
			[
				Pseq([0.94], 1),
				Pseq([0.96], 1),
				Pseq([0.98], 1),
				Pseq([0.995], 1)
			],
			Pstutter(
				Pseq([2, 2, 2, 1, 1], inf),
				Pseq([0, 1, 2, 1, 3], inf)
			)
		).asStream;

		osc = Synth(\kivBass, [\freq, freq.next, \imp, imp.next, \cap, cap.next, \amp, amp]);

		loop({
			tempDur = dur.next;
			(tempDur/2).wait;
			osc.set(\imp, imp.next);
			(tempDur/2).wait;
			osc.set(\freq, freq.next, \cap, cap.next);
		});
	}).play;
};

// 4/speed  seconds
~summerScale = { |amp = 0.2, speed = 1|
	Pbind(
		\instrument, \sawBass,
		\freq, Pseq([400, 450, 500, 790, 500]),
		\dur,  Pseq([0.25, 0.25, 0.25, 0.25, 3] / speed),
		\legato, 1.25,
		\amp2, amp
	).play;
};

~repeatingSummerScale = { |loops = 2, wait = 1, amp = 0.2, speed = 1|
	var spd = speed.asStream,
		wt = wait.asStream;

	Routine({
		loops.do({
			~summerScale.value(amp, spd.next);
			wt.next.wait;
		});
	}).play;
};



~deepBass.value(0.5);
(3.5).wait;
~repeatingSummerScale.value(
	8,
	Pseq([8, 6, 10, 24], inf),
	0.3,
	Pseq([3, 3, 2, 1], inf)
);
12.wait;
~bassKick2.value(4); // 2s
(4.25).wait;
~snareDrum2.value(2);

}).play;