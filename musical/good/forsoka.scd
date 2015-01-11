// Vibes/bass piece

// Leads

SynthDef(\sawSine) { |out=0, imp=5, freq=150, sustain=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(Env([0,amp,amp,0], [sustain*0.75, sustain*0.25, 0.25], [-2.5,0,0]), 1, doneAction: 2),
		saw  = Saw.ar(imp, aEnv),
		sine = SinOsc.ar(freq, 0, saw),
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
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

// Drums

SynthDef(\snare) { |out=0, freq=1250, decay=0.15, amp=1, pan=0|
	var sust, osc, noise, crispy, rvrb, pan2;

	sust = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2);

	osc = Pulse.ar(freq, 0.5, 1) * WhiteNoise.kr(1);
	noise = WhiteNoise.ar(1);
	crispy =  BrownNoise.ar(0.75);
	rvrb = FreeVerb.ar(osc+noise>crispy, 0, 1, 1);
	pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\bellHit) { |out=0, freq=1000, decay=0.15, amp=1, pan=0|
	var sust, osc, rvrb, pan2;

	sust = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2);

	osc = Pulse.ar(freq, 0.5, 1) - WhiteNoise.kr(1);
	rvrb = FreeVerb.ar(osc, 0, 1, 0.5);
	pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\bassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var hit_time, sust, osc, osc2, pan2;

	hit_time = 0.15;
	sust = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2);

	osc = SinOsc.ar(XLine.kr(freq*1.618, freq/3.236, hit_time), 0, amp);
	osc2 = osc - Pulse.kr(freq/6.472, 0.5, 0.25);
	pan2 = Pan2.ar(osc2, pan);

	Out.ar(out, pan2*sust);
}.add;



Routine({
	// 1 loop = 2s
	~bassKick = { |loops=1, freq=150, amp=0.5, dur=0.5, legato=0.25, dStut1=1, dStut2=1, dStut3=4, pan=0, speed=1|
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
					Pseq(dur.asArray/speed, loops)
				)
			),
			\legato, legato,
			\pan, pan,
			\amp, amp
		).play;
	};

	// 1 loop = 4 seconds
	~bassKick2 = { |loops=1, freq=150, amp=0.5, legato=0.25, pan=0|
		~bassKick.value(loops, freq, amp, [0.5, 2, 0.25, 0.5], legato, [7,1,7,1], [1,2,1,3], [16,1,2,13], pan);
	};

	// 1 loop = 4 seconds
	~bassKick3 = { |loops=1, freq=150, amp=0.5, legato=0.25, pan=0|
		~bassKick.value(loops, freq, amp, [0.25], legato, [1,8,1,6], [2,1,2,1], [16], pan);
	};

	// 1 loop = 2 seconds
	~bell = { |loops=1, freq=1250 amp=0.5, dur=0.5, dStut1=1, dStut2=1, dStut3=4, speed=1|
		Pbind(
			\instrument, \bellHit,
			\freq, Pseq(freq.asArray, inf),
			\dur, PdurStutter(
				Pstutter(
					Pseq(dStut1.asArray, inf),
					Pseq(dStut2.asArray, inf)
				),
				Pstutter(
					Pseq(dStut3.asArray, loops),
					Pseq(dur.asArray/speed, loops)
				)
			),
			\amp, amp
		).play;
	};

	// 1 loop = 2 seconds
	~snare = { |loops=1, freq=1250 amp=0.5, dur=0.5, dStut1=1, dStut2=1, dStut3=4, speed=1|
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
					Pseq(dur.asArray/speed, loops)
				)
			),
			\amp, amp
		).play;
	};

	// 1 loop = 27 seconds
	~snare2 = { |loops=1, freq=1250, amp=0.5|
		~snare.value(loops, freq, amp, [1,0.25,0.75,1,0.25,0.75,1,0.25,1], [7,1,7,1,7,1,7,1], [1,7,1,2,1,3,1,2], [7,1,1,5,1,1,5,4,7]);
	};

	// 1 loop = 8 seconds
	~snare3 = { |loops=1, freq=1250, amp=0.5|
		~snare.value(loops, freq, amp, [0.25,0.5,0.25,0.5], [1,8,1,1,5], [2,1,4,2,1], [1,8,2,5]);
	};

	// 1 loop = 14 seconds
	~vibes = { |loops=1, pitchShift=1, amp=0.25|
		Routine({
			var sustain, freq, dur, imp, osc;

			sustain = loops*14;

			freq = Pstutter(
				Pseq([2,  1,  1,  1  ], inf),
				Pseq([500,600,400,700]*pitchShift, inf)
			).asStream;

			dur = Pstutter(
				Pseq([2,3], inf),
				Pseq([4,2], inf)
			).asStream;

			imp = Pstutter(
				Pseq([3,1,  1], inf),
				Pseq([6,6.5,7], inf)
			).asStream;

			osc = Synth(\sawSine, [\freq, freq.next, \imp, imp.next, \sustain, sustain, \amp, amp]);

			(loops*5).do({
				dur.next.wait;
				osc.set(\freq, freq.next, \imp, imp.next);
			});
		}).play;
	};

	// 1 loop = 14 seconds
	~mainVibes = { |loops=1, amp=0.25|
		Routine({
			~vibes.value(loops: loops, amp: amp/3, pitchShift: 5);
			(0.25).wait;
			~vibes.value(loops: loops, amp: amp/3, pitchShift: 3.236);
			(0.25).wait;
			~vibes.value(loops: loops, amp: amp/3, pitchShift: 1.618);
		}).play;
	};

	~susMelody = {|synth, loops=1, freq=440, amp=0.25, dur=1, legato=1, pan=0|
		Pbind(
			\instrument, synth,
			\freq, Pseq(freq.asArray, inf),
			\dur, Pseq(dur.asArray, loops),
			\legato, legato,
			\pan, pan,
			\amp, amp
		).play;
	};

	// 1 loop = 14 seconds
	~simpleBass = { |synth=\triSaw, loops=1, legato=0.85, hi=0.85, lo=0.7, amp=0.25, imp=0.25|
		Pbind(
			\instrument, synth,
			\freq, Pseq([100,125,200,150], inf),
			\dur, Pstutter(
				Pseq([2,3], inf),
				Pseq([4,2], loops)
			),
			\legato, legato,
			\hi, hi,
			\lo, lo,
			\amp, amp,
			\imp, imp
		).play;
	};

	// 1 loop = 14 seconds
	~bassLine = { |synth=\triSaw, loops=1, legato=0.95, hi=0.95, lo=0.85, amp=0.25, imp=0.125|
		Pbind(
			\instrument, synth,
			\freq, Pswitch(
				[
					Pseq([28,35,40, 30,37,42, 31,38,43, 30,37,42].midicps),
					Pseq([31, 38, 43,33, 40, 45].midicps)
				],
				Pstutter(
					Pseq([3,1], inf),
					Pseq([0,1], loops)
				)
			) * 2,
			\dur, Pswitch(
				[
					Pseq([0.5,0.5,1])
				],
				Pstutter(
					Pseq([14], inf),
					Pseq([0], loops)
				)
			) / 2,
			\legato, legato,
			\hi, hi,
			\lo, lo,
			\amp, amp,
			\imp, imp,
			\pan, 0
		).play;
	};



	~mainVibes.value(loops: 6);
	14.wait;
	~susMelody.value(\susSine, 2, [100,75,125,75], 0.25, [8,2,2,2] ); // 14s
	~simpleBass.value(amp: 0.25);
	14.wait;
	~bassLine.value(loops: 2);
	14.wait;
	~bassKick.value(4, speed:0.5); // 16s
	(0.25).wait;
	// @TODO Needs a hihat
	~bell.value(8, 2500, 0.25); // 16s
	(0.25).wait;
	~snare.value(4, 2500, 0.35, speed: 0.5); // 16s
}).play;