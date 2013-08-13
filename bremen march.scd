// A very very sad attempt at a chiptune rendition of the Bremen March theme from Majora's Mask

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

SynthDef(\squareWave) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.1, decay=0.005, amp=0.25|
	var level, pulse, reverb, pan2;

	level = EnvGen.kr(Env([0,amp,amp,0], [attack, sustain, decay+0.005]), 1, doneAction: 2);

	pulse = Pulse.ar(freq, 0.5);
	reverb = FreeVerb.ar(pulse, 0.5, 1, 0.5);

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

	var staccato = 0.25;
	var normal_legato = 0.5;

	// Melody
	Pbind(
		\instrument, \squareWave,
		\freq, Pswitch(
			[
				// Wait for drum intro
				Pseq([\r]),

				Pseq([69, 65, 69, 60]), // 1
				Pseq([77, 76]),
				Pseq([76, 74, 73]),
				Pseq([74]), // 4

				Pseq([67, 64, 67, 70]), // 5
				Pseq([76, 74]),
				Pseq([74, 71, 74]),
				Pseq([72]), // 8

				// Same as 1
				Pseq([81, 79]), // 9
				Pseq([79, 77, 76]),
				Pseq([74]), // 11,

				// Same as 6
				Pseq([72, 70, 69, 67]), // 12
				Pseq([65]) // 13
			],
			Pseq([0, 1,2,3,4, 5,6,7,8, 1,9,10,11, 6,12,13])
		) * 8,
		\dur, Pswitch(
			[
				// Wait for drum intro
				Pseq([3 * 4]),

				Pseq([1, 0.5, 1, 0.5]), // 1
				Pseq([1.5, 1.5]),
				Pseq([1.5, 1, 0.5]),
				Pseq([3]) // 4
			] / 3,
			Pseq([0, 1,2,3,4, 1,2,3,4, 1,2,3,4, 2,1,4])
		),
		\legato, Pswitch(
			[
				// Wait for drum intro
				Pseq([0]),

				Pseq([staccato, normal_legato, staccato, normal_legato]), // 1
				Pseq([normal_legato, normal_legato]),
				Pseq([normal_legato, staccato, normal_legato]),
				Pseq([normal_legato * 1.5]) // 4
			],
			Pseq([0, 1,2,3,4, 1,2,3,4, 1,2,3,4, 2,1,4])
		),
		\attack, 0.005,
		\decay, 0.005,
		\amp, 0.25
	).play;

	// Bass
	Pbind(
		\instrument, \chipBassDrum,
		\freq, Pstutter(
			Pseq([5,  1,  inf]),
			Pseq([41, \r, 41 ].midicps)
		) * 2,
		\dur, Pswitch(
			[
				// Intro
				Pseq([3, 3, 1.5,1.5,1.5,1.5]),

				Pseq([1.5, 1.5]), // 1
				Pseq([3]) // 2
			] / 3,
			Pstutter(
				Pseq([1, 7, 1, 7, 1]),
				Pseq([0, 1, 2, 1, 2])
			)
		),
		\decay, 0.5,
		\amp, 0.25
	).play;

}).play;