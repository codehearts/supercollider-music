SynthDef(\square) { |out=0, freq=400, atk=0.005, sustain=1, dec=0.005, pan=0, amp=0.25|
	var env, osc, osc2, panning, reverb;

	env = EnvGen.kr(Env.linen(atk, sustain, dec, amp, 0), doneAction: 2);
	osc = Pulse.ar(freq, 0.5, 1);
	osc2 = Pulse.ar(freq*2, 0.5, 1);
	panning = Pan2.ar(osc+osc2, pan);
	reverb = FreeVerb.ar(panning, 0.5, 1, 0.5) * env;

	Out.ar(out, reverb);
}.add;

SynthDef(\chipBassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var hit_time, level, pulse1, pulse2, pan2;

	hit_time = 0.1;
	level = EnvGen.kr(Env([1, 1, 0], [hit_time, 0.05]), 1, doneAction: 2);

	pulse1 = Pulse.ar(XLine.kr(freq, freq/4, hit_time), 0.5, amp);
	pulse2 = pulse1 - Pulse.kr(freq/4/2, 0.5, 0.75);
	pan2 = Pan2.ar(pulse2, pan);

	Out.ar(out, pan2 * level);
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



Routine({

	~speed = 0.35 * 1.75;

// Drum

	// Bass Drum
	Pbind(
		\instrument, \chipBassDrum,
		\freq, Pswitch(
			[
				Pseq([\r]), // 0
				Pseq([200]), // 1
			],
			Pswitch(
				[
					Pseq([1,0,0,1,1,0,0,0]), // 0
					Pseq([0,0,0,1,0,1,0,0]), // 1
					Pseq([1,0,0,0,1,0,1,0]), // 2
					Pseq([1,0,0,0,0,0,0,0]), // 3
				],
				Pswitch(
					[
						Pseq([0,1,2,3]), // 0
					],
					Pstutter(
						Pseq([inf], inf),
						Pseq([0], inf)
					)
				)
			)
		),
		\dur, Pswitch(
			[
				Pseq(1 / [8,8,8,8,8,8,8,8]), // 0
			] / ~speed,
			Pswitch(
				[
					Pseq([0,0,0,0]), // 0
				],
				Pstutter(
					Pseq([inf], inf),
					Pseq([0])
				)
			)
		),
		\decay, 0.4,
		\amp, 0.175
	).play;

	// Snare Drum
	Pbind(
		\instrument, \noiseSnare,
		\freq, Pswitch(
			[
				Pseq([\r]), // 0
				Pseq([5000]), // 1
			],
			Pswitch(
				[
					Pseq([0,0,0,0,0,0,1,0]), // 0
					Pseq([0,0,1,0,0,0,0,1]), // 1
					Pseq([0,0,1,0,0,0,0,0]), // 2
				],
				Pswitch(
					[
						Pseq([0,0,1,1]), // 0
					],
					Pstutter(
						Pseq([inf], inf),
						Pseq([0], inf)
					)
				)
			)
		),
		\dur, Pswitch(
			[
				Pseq(1 / [8,8,8,8,8,8,8,8]), // 0
			] / ~speed,
			Pswitch(
				[
					Pseq([0,0,0,0]), // 0
				],
				Pstutter(
					Pseq([inf], inf),
					Pseq([0])
				)
			)
		),
		\decay, 0.4,
		\amp, 0.25
	).play;

	// Hi-hat
	Pbind(
		\instrument, \noiseSnare,
		\freq, Pswitch(
			[
				Pseq([\r]), // 0
				Pseq([15000]), // 1
				Pseq([22500]), // 2
			],
			Pswitch(
				[
					Pseq([1,0,1,0,1,0,1,0]), // 0
					Pseq([1,1,2,0,0,1,1,2]), // 1
					Pseq([0,0,1,1,2,0,0,1]), // 2
				],
				Pswitch(
					[
						Pseq([0,0,1,2]), // 0
					],
					Pstutter(
						Pseq([inf], inf),
						Pseq([0], inf)
					)
				)
			)
		),
		\dur, Pswitch(
			[
				Pseq(1 / [8,8,8,8,8,8,8,8]), // 0
			] / ~speed,
			Pswitch(
				[
					Pseq([0,0,0,0]), // 0
				],
				Pstutter(
					Pseq([inf], inf),
					Pseq([0])
				)
			)
		),
		\decay, 0.6,
		\amp, 0.15
	).play;

}).play;