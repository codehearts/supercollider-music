SynthDef(\siren) {|out=0, freq=440, mod=0.75, crushRate=100, crushStep=0.1, amp=0.5, sustain=1|
	var osc, f_mod, env, reverb;

	env = EnvGen.kr(Env.linen(0.005, 0.15, sustain), doneAction: 2);
	f_mod = EnvGen.kr(Env([freq, freq*mod], [sustain]));
	osc = Saw.ar(f_mod, env);
	reverb = FreeVerb.ar(osc, 1, 1, 0.5);

	Out.ar(out, reverb * env);
}.add;

SynthDef(\bubbleString) { |out=0, freq=250, amp=0.5, feedbackAmp=0.975, gate=1|
	var pluckAt, period, controlPeriod, block, sustain, exciter, bubble_gum, effects, synth, feedback, d1, d2;

	// Properties
	pluckAt = 0.5;
	period = freq.reciprocal;
	controlPeriod = ControlRate.ir;
   	block = controlPeriod.reciprocal;

	// Synths
	sustain = Linen.kr(gate, susLevel: amp, doneAction: 0);
	exciter = EnvGen.ar(
		Env.new(
			[0,1,0],
			[period * pluckAt + 0.01, period * (1-pluckAt) + 0.01],
			'linear'
		),
		doneAction: 0
	);
	bubble_gum = SinOsc.kr(0.5).abs().max(0.5);
	effects = bubble_gum;
	synth = (
		Pulse.ar(freq, bubble_gum) +
		VarSaw.ar(freq, 0, LFTri.kr(0.5).range(0.5,1))
	) * exciter;

	// Output
	feedback = LocalIn.ar(1);
	d1 = DelayL.ar(synth + feedback, period-block, period-block);
	d2 = DelayL.ar(synth + d1.neg, period-block, period-block) * feedbackAmp;

	LocalOut.ar(d2.neg);

	Out.ar(out, d2 * effects * sustain);
}.add;

SynthDef(\bass_drum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var hit_time, sust, osc, osc2, panning;

	hit_time = 0.15;
	sust = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), doneAction: 2);

	osc = SinOsc.ar(XLine.kr(freq*1.618, freq/3.236, hit_time), 0, amp);
	osc2 = osc - Pulse.kr(freq/6.472, 0.5, 0.25*amp);

	panning = Pan2.ar(osc2, pan);

	Out.ar(out, panning*sust);
}.add;

SynthDef(\noiseSnare) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.05, decay=0.15, amp=0.25|
	var level, hitLevel, hit_time, noise, reverb, pan2;

	hit_time = 0.05;

	level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);
	hitLevel = EnvGen.kr(Env([0,amp,amp,0], [attack,hit_time,decay]), 1);

	noise = LFNoise0.ar(freq, hitLevel) + LFNoise0.ar(freq / 1.618, hitLevel);
	reverb = FreeVerb.ar(noise, 0, 1, 0.5);

	pan2 = Pan2.ar(reverb, pan);

	Out.ar(out, pan2 * level);
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



Routine({

	// 1 loop = 8 seconds
	~bassMelody = { |synth, loops=1, amp=0.25, feedbackAmp=0.995, shift=1, speed=1, out=0|
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

	// 1 loop = 2s
	~bassKick = { |loops=1, freq=150, amp=0.5, dur=0.5, legato=0.25, dStut1=1, dStut2=1, dStut3=4, pan=0, speed=1|
		Pbind(
			\instrument, \bass_drum,
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

	// 1 loop = 2 seconds
	~snare = { |loops=1, freq=1250 amp=0.5, dur=0.5, dStut1=1, dStut2=1, dStut3=4, speed=1|
		Pbind(
			\instrument, \noiseSnare,
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

	Synth(\siren, [\freq, 75, \sustain, 10]);
	Synth(\siren, [\freq, 75/2, \sustain, 10, \amp, 0.25]);
	(5).wait;
	Synth(\siren, [\freq, 75, \mod, 5, \sustain, 10, \out, 1]);
	~bassMelody.value(\siren, loops:10, amp:0.5, shift:1.618, speed:150);
	(0.6).wait;
	~bassMelody.value(\siren, loops:5, amp:0.5, shift:4, speed:250, out:1);
	(0.25).wait;
	~bassMelody.value(\siren, loops:5, amp:0.5, shift:6, speed:300);
	~bassMelody.value(\siren, loops:15, amp:0.5, shift:1, speed:50, out:1);
	(0.6).wait;
	~bassMelody.value(\siren, loops:3, amp:0.5, shift:10, speed:350, out:1);
	(0.6).wait;
	Synth(\bubbleString, [\freq, 250, \amp, 0.5, \feedbackAmp, 0.9975]);
	(2.375).wait;
	Synth(\bubbleString, [\freq, 100, \amp, 0.5, \feedbackAmp, 0.995, \out, 1]);
	(7.5).wait;
	Synth(\bubbleString, [\freq, 90, \amp, 0.5, \feedbackAmp, 0.995, \out, 1]);

	~bassKick.value(loops:4, freq:135, speed:0.5); // 16s
	(8.5).wait;
	~snare.value(loops:4, freq:250, amp:0.4, speed:0.5); // 16s

	(2.5).wait;

	Pbind(
		\instrument, \fogVibe,
		\freq, Pseq([75, 70, 100, 90, 85] * 2 * 1.618, inf),
		\dur, Pstutter(
			Pseq([3], inf),
			Pseq([4], 100)
		),
		\legato, 1,
		\attack, 0.15,
		\imp, 60,
		\amp, 0.1
	).play;

	(16).wait;

	~bassKick.value(loops:4, freq:135, speed:0.5); // 16s
	(0.5).wait;
	~snare.value(loops:4, freq:250, amp:0.4, speed:0.5); // 16s

	(8).wait;

	/*
	~bassMelody.value(\siren, loops:3, amp:0.025, shift:10, speed:350, out:1);
	(0.05).wait;
	~bassMelody.value(\siren, loops:5, amp:0.025, shift:4, speed:250);
	(0.1).wait;
	~bassMelody.value(\siren, loops:5, amp:0.025, shift:6, speed:300, out:1);
	(0.15).wait;
	~bassMelody.value(\siren, loops:3, amp:0.025, shift:18, speed:400);
	*/

}).play;