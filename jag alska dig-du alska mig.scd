// Cover of Concertmate's "Je t'aimes, tu m'aimes?" (http://concertmate.evenement0.net/volume_1.php)

SynthDef(\squareWave) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.1, decay=0.005, amp=0.25|
	var level, pulse, reverb, pan2;

	level = EnvGen.kr(Env([0,amp,amp,0], [attack, sustain, decay+0.005]), 1, doneAction: 2);

	pulse = Pulse.ar(freq, 0.5);
	reverb = FreeVerb.ar(pulse, 0.5, 1, 0.5);

	pan2 = Pan2.ar(reverb, pan);

	Out.ar(out, pan2 * level);
}.add;

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

SynthDef(\smoothWave) { |out=0, freq=150, impulse=1, gate=1, attack=0.005, decay=0.75, triMin=0, triMax=1, amp=0.5|
	var level, vSaw, pan2, reverb;

	level = Linen.kr(gate, attack, amp, decay, doneAction: 2);
	vSaw = VarSaw.ar(freq, 0, LFTri.kr(impulse).range(triMin, triMax));
	pan2 = Pan2.ar(vSaw, FSinOsc.kr(impulse*2) * 0.25);
	reverb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, reverb * level);
}.add;



Routine({

	Pbind(
		\instrument, \squareWave,
		\freq, Pseq([55].midicps, inf),
		\dur, Pseq([1,1], inf),
		\legato, 1,
		\amp, Pstutter(
			Pseq([4,   4*4,  inf]),
			Pseq([0.25,0.2,0.1])
		),
		\out, 0
	).play;

	Pbind(
		\instrument, \squareWave,
		\freq, Pseq([\r, 43, \r].midicps, inf),
		\dur, Pseq([0.5,1,0.5], inf),
		\legato, 1,
		\amp, Pstutter(
			Pseq([4,   4*4,  inf]),
			Pseq([0.25,0.2,0.1])
		),
		\out, 0
	).play;

	Pbind(
		\instrument, \squareWave,
		\freq, Pseq([\r, 59].midicps, inf),
		\dur, Pseq([1,1], inf),
		\legato, 1,
		\amp, Pstutter(
			Pseq([4,   4*4,  inf]),
			Pseq([0.25,0.2,0.1])
		),
		\out, 0
	).play;

	4.wait;

	Pbind(
		\instrument, \icePick,
		\freq, Pswitch(
			[
				Pseq([47,50,48,45,52]),
				Pseq([46,50,48,45,52]),
				Pseq([46,48,47,52,50,49])
			].midicps * 10,
			Pseq([0,1,0,2], inf)
		),
		\dur, Pswitch(
			[
				// 2 seconds each
				Pseq([0.5,0.25,0.25,0.5,0.5]),
				Pseq([0.5,0.25,0.25,0.25,0.25,0.5])
			],
			Pseq([0,0,0,1], inf)
		),
		\legato, 1,
		\decay, 0.5,
		\amp, 0.35,
		\out, 1
	).play;

	Pbind(
		\instrument, \squareWave,
		\freq, Pswitch(
			[
				Pseq([47,49,52,54]),
				Pseq([47,49,52,49])
			].midicps * 2.5,
			Pseq([0,1], inf)
		),
		\dur, Pseq([1], inf),
		\legato, 0.25,
		\decay, 0.5,
		\amp, 0.5,
		\out, 1
	).play;

	8.wait;

	Pbind(
		\instrument, \smoothWave,
		\freq, Pswitch(
			[
				Pseq([38,38,39,39,38,38,39,37]),
				Pseq([38,38,39,39,38,38,41,37]),
				Pseq([38,38])
			].midicps * 1.5,
			Pseq([0,1,0,2], inf)
		),
		\dur, Pswitch(
			[
				// 4 seconds each
				Pseq([0.75,0.25,0.75,0.25,0.75,0.25,0.5,0.5]),
				Pseq([0.75,Rest(0.25+0.75+0.25+0.75+0.25+0.5+0.5)]),
			],
			Pseq([0,0,0,1], inf)
		),
		\impulse, 0.25,
		\triMin, 0.75,
		\triMax, 0.95,
		\legato, 0.7,
		\amp, 0.5
	).play;

	8.wait;

	Pbind(
		\instrument, \squareWave,
		\freq, Pswitch(
			[
				Pseq([57,54,58, 58,57,58,60]),
				Pseq([52,49, 53,53,54,57]),
				Pseq([58,54,59, 52,57,54]),
				Pseq([54,54,53,56,52, 57,54]),
				Pseq([1])
			].midicps * 1.5,
			Pseq([0,1,2,3, 4], inf)
		),
		\dur, Pswitch(
			[
				// 4 seconds each
				Pseq([0.5,0.5,1.5, 0.5,0.25,0.25,0.5]),
				Pseq([0.5,0.5, 1.5,0.5,0.5,0.5]),
				Pseq([0.5,0.5,0.5, 1,0.5,1]),
				Pseq([0.25,0.25,0.5,0.5,1, 0.5,1]),
				Pseq([Rest(4*4)])
			],
			Pseq([0,1,2,3, 4], inf)
		),
		\legato, 0.9,
		\amp, 0.35
	).play;

}).play;