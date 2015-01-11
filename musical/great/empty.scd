// Icy chiptune piece

SynthDef(\icePick) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.1, decay=0.5, amp=0.25|
	var level, plickLevel, plick, pulse, pulse2, saw, reverb, reverb2, pan2;

	plick = 0.05;

	level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);
	plickLevel = EnvGen.kr(Env([0,amp,amp,0], [attack,plick,decay]), 1);

	saw = Saw.kr(10, 0.75);

	pulse = Pulse.ar(freq, 0.5, plickLevel);
	pulse2 = Pulse.ar(freq * 0.75, 0.5, plickLevel * saw);
	reverb = FreeVerb.ar(pulse, 0.5, 1, 1);
	reverb2 = FreeVerb.ar(pulse2, 0.5, 1, 0.5);

	pan2 = Pan2.ar(reverb + reverb2, pan);

	Out.ar(out, pan2 * level);
}.add;

SynthDef(\noiseCrash) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.1, decay=0.5, amp=0.25|
	var level, plickLevel, plick, noise, pulse, reverb, pan2;

	plick = 0.05;

	level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);
	plickLevel = EnvGen.kr(Env([0,amp,amp,0], [attack,plick,decay]), 1);

	noise = WhiteNoise.kr(1);
	pulse = Pulse.ar(freq, 0.5, noise);

	reverb = FreeVerb.ar(pulse, 0.5, 1, 1);

	pan2 = Pan2.ar(reverb, pan);

	Out.ar(out, pan2 * level);
}.add;

SynthDef(\noiseCrunch) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.1, decay=0.5, amp=0.25|
	var level, plickLevel, plick, noise, pulse, reverb, pan2;

	plick = 0.05;

	level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);
	plickLevel = EnvGen.kr(Env([0,amp,amp,0], [attack,plick,decay]), 1);

	noise = WhiteNoise.kr(1);
	pulse = Pulse.ar(freq, 0.5, noise + BrownNoise.kr(1));

	reverb = FreeVerb.ar(pulse, 0, 1, 1);

	pan2 = Pan2.ar(reverb, pan);

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

SynthDef(\chipBassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var hit_time, level, pulse1, pulse2, pan2;

	hit_time = 0.1;
	level = EnvGen.kr(Env([1, 1, 0], [hit_time, 0.05]), 1, doneAction: 2);

	pulse1 = Pulse.ar(XLine.kr(freq, freq/4, hit_time), 0.5, amp);
	pulse2 = pulse1 - Pulse.kr(freq/4/2, 0.5, 0.75);
	pan2 = Pan2.ar(pulse2, pan);

	Out.ar(out, pan2 * level);
}.add;


Routine({

	//Synth(\noiseCrash, [\freq, 600, \amp, 0.5]);
	//Synth(\noiseCrunch, [\freq, 400, \amp, 0.5]);

	// Wiiiiiiiiiiiiiiiiind
	Pbind(
		\instrument, \noiseCrash,
		\freq, Pseg(Pseq([1750, 2250], inf), Pseq([4,4], inf), \sine),
		\dur, Pseq([0.05], inf),
		\out, 0,
		\amp, 0.025
	).play;

	Pbind(
		\instrument, \noiseCrash,
		\freq, Pseg(Pseq([1500, 2000, 1750], inf), Pseq([2,2,2,2], inf), \sine),
		\dur, Pseq([0.05], inf),
		\out, 1,
		\amp, 0.0125
	).play;

	8.wait;

	Pbind(
		\instrument, \icePick,
		\freq, Pswitch(
			[
				Pseq([44, 46, 49, 47, 49, \r].midicps * 10),
				Pseq([44, 46, 49, 47, 49, \r].midicps * 10 / 2)
			],
			Pseq([0,1], inf)
		),
		\dur, Pstutter(
			Pseq([5,  1], inf),
			Pseq([0.5,1.5], inf)
		),
		\decay, Pstutter(
			Pseq([4,  1,   1], inf),
			Pseq([0.5,0.85,0], inf)
		),
		\amp, 0.5
	).play;

	8.wait;

	Pbind(
		\instrument, \chipBassDrum,
		\freq, Pseq([200], inf),
		\dur, Pswitch(
			[
				Pseq([2, 2]),
				Pseq([2, 0.5, 0.5, Rest(1)])
			],
			Pswitch(
				[
					Pseq([0, 0, 0, 1])
				],
				Pstutter(
					Pseq([inf]),
					Pseq([0])
				)
			)
		),
		\amp, 0.2
	).play;

	Pbind(
		\instrument, \noiseSnare,
		\freq, Pseq([5000], inf),
		\dur, Pswitch(
			[
				Pseq([Rest(1)]),
				Pseq([2, 1, Rest(1)]),
				Pseq([2, 0.5, 0.5, Rest(1)])
			],
			Pswitch(
				[
					Pseq([0]),
					Pseq([1, 1, 1, 2]),
				],
				Pstutter(
					Pseq([1, inf]),
					Pseq([0, 1])
				)
			)
		),
		\amp, 0.25
	).play;

	Pbind(
		\instrument, \noiseSnare,
		\freq, Pseq([15000], inf),
		\dur, Pswitch(
			[
				Pseq([Rest(0.5)]),
				Pseq([1, 1, 1, Rest(1)]),
				Pseq([1, 1, Rest(0.5), 1.5])
			],
			Pswitch(
				[
					Pseq([0]),
					Pseq([1, 1, 1, 2])
				],
				Pstutter(
					Pseq([1, inf]),
					Pseq([0, 1])
				)
			)
		),
		\amp, 0.25
	).play;

	8.wait;

	Pbind(
		\instrument, \icePick,
		\freq, Pswitch(
			[
				Pseq([44, 46, 49, 47, \r, \r].midicps * 16),
				Pseq([44, 46, 49, 47, \r, \r].midicps * 16 / 2)
			],
			Pseq([0,1], inf)
		),
		\dur, Pstutter(
			Pseq([5,  1], inf),
			Pseq([0.5,1.5] * 2, inf)
		),
		\attack, 2,
		\decay, 0.005,
		\amp, 0.25
	).play;

	// TODO Some crashes and stuff

}).play;