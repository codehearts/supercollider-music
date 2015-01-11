// Mishmash of various instruments and textures from other files

~kaliba = "~/Music/supercollider-music/samples/Kaliba.aiff".standardizePath;
"Audio samples loaded";

// Kalimba Ringer
SynthDef(\kring) { |out=0, dur=3, pos=0, gate=1, attack=0.005, decay=0.005, amp=0.5, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			Impulse.ar(XLine.kr(100, 10, dur)), // trigger
			XLine.kr(0.1, 1.5, dur), // duration
			buf,
			1, // playback rate
			pos, // position
			1, // no interpolation
			0, // panning
			-1 // grain envelope buffer
		) * XLine.kr(0.005, amp, attack),
		env  = EnvGen.kr(Env.cutoff(decay, 1), gate, doneAction: 2) * samp;

	Out.ar(out, env);
}.add;

// Random kalimba Leaves
SynthDef(\randomLeaves) { |out=0, gate=1, attack=1, decay=1, rate=4, density=25, amp=1, buf|
	var chan = buf.numChannels,
		samp = GrainBuf.ar(
			chan, // number of channels
			LFNoise1.kr(density), // trigger
			LFNoise1.kr.range(0.1, 0.25), // duration
			buf,
			rate, // playback rate
			LFNoise0.kr.range(0,1), // position
			2, // interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env([0, 0.5, 1, 0.25], [0.05, 0.05, 0.1], [2.5, -2.5, -5]).discretize,
				chan
			)
		) * XLine.kr(0.005, amp, attack),
		env  = EnvGen.kr(Env.cutoff(decay, 1), gate, doneAction: 2) * samp,
		rvrb = FreeVerb2.ar(env, env, 0.5, 1, 0),
		pan2 = Pan2.ar(rvrb, LFNoise0.kr(density, -1, 2)-1);

	Out.ar(out, pan2);
}.add;

SynthDef(\sineBell) { |out=0, pan=0, freq=100, attack=0.005, sustain=0.1, decay=0.005, amp=1|
	var sine = SinOsc.ar(
			freq,
			0,
			EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2)
		),
		pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
}.add;



// 1 loop = 14 seconds
~bassLine = { |synth, loops=1, legato=0.95, attack=0.005, decay=0.005, amp=0.25, imp=0.125, speed=1, scale=1|
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
		) * scale,
		\dur, Pswitch(
			[
				Pseq([0.5,0.5,1] / 2)
			],
			Pstutter(
				Pseq([14], inf),
				Pseq([0], loops)
			)
		) / speed,
		\legato, legato,
		\attack, attack,
		\decay, decay,
		\amp, amp,
		\imp, imp,
		\pan, 0
	).play;
};

~bassLineAccomp = { |synth, loops=1, legato=0.95, attack=0.005, decay=0.005, amp=0.25, imp=0.125, speed=1, scale=1|
	Pbind(
		\instrument, synth,
		\freq, Pswitch(
			[
				Pseq([28,35,40, 30,37,\rest, \r,\r,\r, \r,\r,\r, 31,38,43, 30,37,\r, \r,\r,\r, \r,\r,\r].midicps),
				Pseq([31, 38, 43,33, 40, 45].midicps)
			],
			Pstutter(
				Pseq([2,1], inf),
				Pseq([0,1], loops)
			)
		) * scale,
		\dur, Pswitch(
			[
				Pseq([0.5,0.5,1] / 2)
			],
			Pstutter(
				Pseq([14], inf),
				Pseq([0], loops)
			)
		) / speed,
		\legato, legato,
		\attack, attack,
		\decay, decay,
		\amp, amp,
		\imp, imp,
		\pan, 0
	).play;
};



b = Buffer.readChannel(s, ~kaliba, channels: 0, action: { |kaliba_buffer|
	Routine({

		var dur = 4,
		legato = 1;

		Synth(\randomLeaves, [\buf, kaliba_buffer, \attack, 1, \decay, 4, \amp, 0.5, \density, 10, \rate, 0.5]);
		Synth(\randomLeaves, [\buf, kaliba_buffer, \attack, 1, \decay, 4, \amp, 0.5, \density, 25, \rate, 0.75]);
		Synth(\randomLeaves, [\buf, kaliba_buffer, \attack, 1, \decay, 4, \amp, 0.5, \density, 5, \rate, 2]);

		~bassLine.value(\sineBell, loops:inf, amp:0.5, decay:0.75, speed:1, scale:4);
		~bassLine.value(\sineBell, loops:inf, amp:0.05, decay:0.75, speed:1, scale:4*4);
		4.wait;
		~bassLineAccomp.value(\sineBell, loops:inf, amp:0.25, attack:0.75, decay:0.75, scale:4*1.5);

		100.wait;

		Pbind(
			\instrument, \randomLeaves,
			\buf, kaliba_buffer,
			\rate, Pseq([4, 8, 10, 1], inf),
			\density, Pseq([25, 50, 75, 100, 5], inf),
			\dur,  Pseq([dur], inf),
			\attack, 0.005,
			\decay, (dur*legato) - dur,
			\legato, legato,
			\amp, 0.5
		);//.play;

		// Ringer
		Pbind(
			\instrument, \kring,
			\buf, kaliba_buffer,
			\dur, Pseq([5]),
			\decay, 5,
			\pos, 0.03,
			\amp, 0.25
		).play;

		(5).wait;

		Pbind(
			\instrument, \kring,
			\buf, kaliba_buffer,
			\dur, Pseq([5]),
			\decay, 5,
			\pos, 0.3,
			\amp, 0.25,
			\out, 1
		).play;

	}).play;
});