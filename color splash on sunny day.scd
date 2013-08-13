// Fairly nice granular synthesis

~kaliba = "samples/Kaliba.aiff".resolveRelative;
"Audio samples loaded";

// Random kalimba Leaves
SynthDef(\grain) { |out=0, sustain=1, attack=1, decay=1, rate=4, density=25, imp=25, amp=1, buf|
	var chan = buf.numChannels,
		samp = GrainBuf.ar(
			chan, // number of channels
			Saw.kr(density), // trigger
			//LFNoise1.kr.range(0.1, 0.25), // duration
			VarSaw.kr(density, 0, LFTri.kr(Saw.kr(imp)).range(1, 5)), // duration
			buf,
			rate, // playback rate
			VarSaw.kr(density, 0, LFTri.kr(Saw.kr(imp)).range(0, 1)), // position
			2, // interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env([0, 0.5, 1, 0.25], [0.05, 0.05, 0.1], [2.5, -2.5, -5]).discretize,
				chan
			)
		) * XLine.kr(0.005, amp, attack),
		env  = EnvGen.kr(Env([0,1,1,0], [attack,sustain,decay]), doneAction: 2) * samp,
		rvrb = FreeVerb2.ar(env, env, 0.5, 0.75, 1),
		pan2 = Pan2.ar(rvrb, LFNoise0.kr(density, -1, 2)-1);

	Out.ar(out, pan2);
}.add;

b = Buffer.readChannel(s, ~kaliba, channels: 0, action: { |kaliba_buffer|
	Routine({
		Synth(\grain, [\buf, kaliba_buffer, \sustain, 40, \attack, 1, \decay, 4, \amp, 0.5, \density, 1.618, \imp, 1.618, \rate, 2.5]);
		4.wait;
		Synth(\grain, [\buf, kaliba_buffer, \sustain, 40, \attack, 1, \decay, 4, \amp, 0.5, \density, 1, \imp, 1, \rate, 1.5]);
		4.wait;
		Synth(\grain, [\buf, kaliba_buffer, \sustain, 40, \attack, 0.05, \decay, 4, \amp, 0.5, \density, 2, \imp, 40, \rate, 0.5]);
		/*Pbind(
			\instrument, \grain,
			\buf, kaliba_buffer,
			\dur, Pseq([4, 8] / 2, inf),
			\density, Pseq([10, 20], inf),
			\rate, Pseq([2.5, 1.5], inf),
			\legato, 1.25,
			\attack, 0.05,
			\decay, 2,
			\amp, 0.5,
			\pan, 0
		).play;*/
	}).play;
});