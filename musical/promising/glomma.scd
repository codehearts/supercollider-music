// Spacious synth blips

// ---------
// TODO This sounds really cool with a reverse reverb and tape delay
// ---------

SynthDef(\deadVibe) { |out=0, imp=5, freq=150, sustain=0.25, attack=0.75, decay=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(
			Env.linen(sustain*attack, sustain*(1-attack), decay, amp, [-2.5,0,0]),
			1,
			doneAction: 2
		),
		saw  = Saw.ar(imp, aEnv),
		sine = SinOsc.ar(freq, 0, saw).min(amp).max(0),
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

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

SynthDef(\bubbleString) { |out=0, freq=250, amp=0.5, feedbackAmp=0.975, gate=1|
		// Properties
	var pluckAt = 0.5,
		period = freq.reciprocal,
		controlPeriod = ControlRate.ir,
   		block = controlPeriod.reciprocal,
		// Synths
		sustain = Linen.kr(gate, susLevel: amp, doneAction: 0),
		exciter = EnvGen.ar(
			Env.new(
				[0,1,0],
				[period * pluckAt + 0.01, period * (1-pluckAt) + 0.01],
				'linear'
			),
			doneAction: 0
		),
		bubble_gum = SinOsc.kr(0.5).abs().max(0.5),
		effects = bubble_gum,
		synth = (
			Pulse.ar(freq, bubble_gum) +
			VarSaw.ar(freq, 0, LFTri.kr(0.5).range(0.5,1))
		) * exciter,
		// Output
		feedback = LocalIn.ar(1),
		d1 = DelayL.ar(synth + feedback, period-block, period-block),
		d2 = DelayL.ar(synth + d1.neg, period-block, period-block) * feedbackAmp;

	LocalOut.ar(d2.neg);

	Out.ar(out, d2 * effects * sustain);
}.add;

SynthDef(\siren) {|out=0, freq=440, mod=0.75, crushRate=100, crushStep=0.1, amp=0.5, sustain=1|
	var osc, f_mod, env, reverb;

	env = EnvGen.kr(Env.linen(0.005, 0.15, sustain, 1, 0), doneAction: 2);
	f_mod = EnvGen.kr(Env([freq, freq*mod], [sustain]), 1);
	osc = Saw.ar(f_mod, env);
	reverb = FreeVerb.ar(osc, 1, 1, 0.5);

	Out.ar(out, reverb * env);
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
	osc2 = osc - SinOsc.kr(freq/6.472, 0, 0.25);
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

	~bassKick4 = { |loops=1, freq=150, amp=0.5, legato=0.25, dur=1, pan=0|
		~bassKick.value(loops, freq, amp, [dur, dur/4, dur/8, dur/2, dur/8], legato, [1], [1], [3,1,1,1,1], pan);
	};

	~bassKick5 = { |loops=1, freq=150, amp=0.5, legato=0.25, dur=1, pan=0|
		~bassKick.value(loops, freq, amp, [dur/16, dur/4], legato, [1], [1], [8,4], pan);
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



	// 1 loop = 8 seconds
	~bassMelody = { |synth, loops=1, amp=0.25, feedbackAmp=0.995 shift=1, speed=1, out=0|
		Pbind(
			\instrument, synth,
			\freq, Pseq([75, 90, 110, 50, 25, 100] * shift, loops),
			\dur, Pseq([0.75] / speed, inf),
			\legato, 1,
			\amp, amp,
			\feedbackAmp, feedbackAmp,
			\out, out
		).play;
	};





	// Music

	/*Pbind(
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
		\dur, Pseq([0.7] / 10, inf),
		\legato, 1,
		\imp, 0.5,
		\amp, 0.5
	).play;

	8.wait;*/

	Pbind(
		\instrument, \fogVibe,
		\freq, Pswitch(
			[
				Pseq([50,25,50,75] * 6.472),
				Pseq([50,25,50,75] * 4.854),
				Pseq([50,25,100,125] * 4.854)
			],
			Pstutter(
				Pseq([4,3,1], inf),
				Pseq([0,1,2], 10)
			)
		),
		\dur, Pseq([1] / 4, inf),
		\legato, 0.95,
		\imp, 0.000125,
		\amp, 0.25,
		\out, 0
	).play;


	//8.wait;

	~bassKick4.value(4, freq:200, dur:2, amp:0.25);

	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([75, 50, 80, 50, 30, 60, 50] * 16.18),
				Pseq([75, 50, 80, 50, 30, 60, 50] * 8.09),
			],
			Pstutter(
				Pseq([1,1], inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pseq([4     ,4     ,2       ,4     ,2       ] / 2, inf),
		\legato, 1,
		\imp, Pseq([0.0625,0.0625,0.0625*2,0.0625,0.0625*2] * 2, inf),
		\amp, 0.25,
		\out, Pseq([0,1], inf)
	).play;

	1.wait;

	~snare.value(8, freq:2500, dur:2, amp:0.15);

	35.wait;

	~bassKick5.value(1, freq:200, dur:2, amp:0.25);

	4.wait;

	~bassKick4.value(4, freq:200, dur:2, amp:0.25);

	/*Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 50, 25, 100, 110] * 1),
				Pseq([75, 90, 110, 50, 25, 100, 110] * 3.236)
			],
			Pstutter(
				Pseq([8,8] / 2, inf),
				Pseq([0,0], 10)
			)
		),
		\dur, Pseq([0.7] / 10, inf),
		\legato, 1,
		\imp, 0.125,
		\amp, 0.1,
		\out, 1
	).play;*/

	/*Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 75, 90, 100] * 4),
				Pseq([75, 90, 110, 75, 90, 100] * 3.236)
			],
			Pstutter(
				Pseq([8,8] / 2, inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pseq([0.7] / 5, inf),
		\legato, 1,
		\imp, 0.125,
		\amp, 0.1,
		\out, 1
	).play;*/

	/*Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([14,16,18].midicps * 4),
				Pseq([90, 75, 50, 25, 110, 90, 100] * 4),
				Pseq([75, 90, 110, 50, 25, 100, 90] * 3.236)
			],
			Pstutter(
				Pseq([8,8]/2, inf),
				Pseq([0,0], 10)
			)
		),
		\dur, Pseq([0.7] / 5, inf),
		\legato, 1,
		\imp, 0.125,
		\amp, 0.1,
		\out, 1
	).play;*/

	/*Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 50, \rest, 100, 110, \rest] * 4),
				Pseq([75, 90, 110, 50, \rest, 100, 110, \rest] * 3.236)
			],
			Pstutter(
				Pseq([8,8]/2, inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pseq([0.7] / 0.5, inf),
		\legato, 1,
		\imp, 0.0125,
		\amp, 0.1,
		\out, Pseq([0,1], inf)
	).play;*/

	90.wait;

	Synth(\fogVibe, [\freq, 770, \imp, 0.0625, \sustain, 64, \amp, 0.5, \attack, 0.005, \out, 1]);
	2.wait;
	Synth(\fogVibe, [\freq, 880, \imp, 0.0625, \sustain, 64, \amp, 0.5, \attack, 0.005]);
	2.wait;

	Synth(\vibeSpark, [\freq, 440, \imp, 1, \sustain, 64, \amp, 0.25, \attack, 0.05]);
	8.wait;
	Synth(\vibeSpark, [\freq, 220, \imp, 2.5, \sustain, 64, \amp, 0.25, \attack, 0.05]);
	8.wait;

	90.wait;
	Synth(\siren, [\freq, 75, \sustain, 10]);
	(5).wait;
	~bassMelody.value(\siren, 10, 0.5, 0.9925, 1.618, 150);
	(0.5).wait;
	~bassMelody.value(\siren, 5, 0.5, 0.9925, 4, 250, 1);
	(0.25).wait;
	~bassMelody.value(\siren, 5, 0.5, 0.9925, 6, 300);
	~bassMelody.value(\siren, 15, 0.5, 0.9925, 1, 50, 1);
	(0.25).wait;
	~bassMelody.value(\siren, 3, 0.5, 0.9925, 10, 350, 1);

	~bassKick.value(4, speed:0.5); // 16s
	(8.25).wait;
	// @TODO Needs a hihat
	~bell.value(8, 2500, 0.25); // 16s
	(0.25).wait;
	~snare.value(4, 2500, 0.35, speed: 0.5); // 16s




	(90).wait;





	// MESSING AROUND

	Synth(\siren, [\freq, 75, \sustain, 10]);
	(5).wait;
	Synth(\siren, [\freq, 75, \mod, 5, \sustain, 10, \out, 1]);
	~bassMelody.value(\siren, 10, 0.5, 0.9925, 1.618, 150);
	(0.6).wait;
	~bassMelody.value(\siren, 5, 0.5, 0.9925, 4, 250, 1);
	(0.25).wait;
	~bassMelody.value(\siren, 5, 0.5, 0.9925, 6, 300);
	~bassMelody.value(\siren, 15, 0.5, 0.9925, 1, 50, 1);
	(0.6).wait;
	~bassMelody.value(\siren, 3, 0.5, 0.9925, 10, 350, 1);
	(0.6).wait;
	Synth(\bubbleString, [\freq, 440, \amp, 0.5, \feedbackAmp, 0.995]);
	(2.375).wait;
	Synth(\bubbleString, [\freq, 100, \amp, 0.5, \feedbackAmp, 0.995, \out, 1]);
	(7.5).wait;
	Synth(\bubbleString, [\freq, 90, \amp, 0.5, \feedbackAmp, 0.995, \out, 1]);

	~bassKick.value(4, speed:0.5); // 16s
	(8.25).wait;
	// @TODO Needs a hihat
	~bell.value(8, 2500, 0.25); // 16s
	(0.25).wait;
	~snare.value(4, 2500, 0.35, speed: 0.5); // 16s

	(2.5).wait;
	Synth(\bubbleString, [\freq, 110, \amp, 0.25, \feedbackAmp, 0.999]);
	(2.5).wait;
	Synth(\bubbleString, [\freq, 220, \amp, 0.25, \feedbackAmp, 0.998, \out, 1]);
	(2.5).wait;


}).play;