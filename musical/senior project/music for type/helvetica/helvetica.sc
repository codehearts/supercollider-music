// 3 minutes 34 seconds

"~/Music/SC/samples/samples.sc".standardizePath.loadPaths;
//"../samples/samples.sc".resolveRelative.loadPaths;

SynthDef(\sine) { |out=0, freq=440, amp=0.25, pan=0, gate=1, fadeOut=0.05|
	var env  = EnvGen.kr(Env.cutoff(fadeOut), gate, doneAction: 2),
		sine = SinOsc.ar(freq, 0, amp) * env,
		pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\square) { |out=0, freq=440, amp=0.25, pan=0, gate=1, fadeOut=0.05|
	var env  = EnvGen.kr(Env.cutoff(fadeOut), gate, doneAction: 2),
		sqr  = Pulse.ar(freq, 0.5, amp) * env,
		pan2 = Pan2.ar(sqr, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\susSine) { |out=0, freq=440, amp=0.25, pan=0, sustain=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0]), 1, doneAction: 2),
		sine = SinOsc.ar(freq, 0, amp) * env,
		pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\susSquare) { |out=0, freq=440, amp=0.25, pan=0, sustain=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0]), 1, doneAction: 2),
		sqr  = Pulse.ar(freq, 0.5, amp) * env,
		pan2 = Pan2.ar(sqr, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\envSine) { |out=0, pan=0, fadeIn=1, sustain=1, fadeOut=1, sFreq=100, eFreq=440, amp=0.25|
	var sEnv = EnvGen.kr(Env([0, 1, 1, 0], [fadeIn, sustain, fadeOut]), 1, doneAction: 2),
		fEnv = EnvGen.kr(Env([sFreq, eFreq], [fadeIn+(sustain/2)], 0, eFreq), 1),
		sine = SinOsc.ar(fEnv, 0, amp) * sEnv,
		pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\envSquare) { |out=0, pan=0, fadeIn=1, sustain=1, fadeOut=1, sFreq=100, eFreq=440, amp=0.25|
	var sEnv = EnvGen.kr(Env([0, 1, 1, 0], [fadeIn, sustain, fadeOut]), 1, doneAction: 2),
		fEnv = EnvGen.kr(Env([sFreq, eFreq], [fadeIn+(sustain/2)], 0, eFreq), 1),
		sqr  = Pulse.ar(fEnv, 0.5, amp) * sEnv,
		pan2 = Pan2.ar(sqr, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\sawStep) { |out=0, imp=10, pan=0, amp=0.5, step=1, sustain=1|
	var saw = Saw.ar(
			Stepper.kr(Impulse.kr(step), 0, 6, 10, 1)*50,
			TIRand.kr(0, 1, Impulse.kr(imp))
		),
		aEnv = EnvGen.kr(Env([amp, amp, 0], [sustain, 0]), 1, doneAction: 2),
		pan2 = Pan2.ar(saw*aEnv, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\bass) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2),
		sine = SinOsc.ar(XLine.kr(freq, freq/3, sustain), 0, amp)*env,
		sqr  = Pulse.ar(XLine.kr(freq, freq/3, sustain), 0.5)*(amp*0.25)*env,
		pan2 = Pan2.ar(sine+sqr, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\snare) { |out=0, freq=1000, decay=0.25, amp=1, pan=0|
	var aEnv = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, WhiteNoise.ar(aEnv*0.15)),
		rvrb = FreeVerb.ar(drum, 0.75, 1, 0.75) + WhiteNoise.ar(aEnv*0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\hihat) { |out=0, freq=1000, decay=0.25, amp=1, pan=0|
	var aEnv = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, WhiteNoise.ar(aEnv*0.15)) + WhiteNoise.ar(aEnv*0.5),
		rvrb = FreeVerb.ar(drum, 0.25, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\domobass) { |out=0, sFreq=50, eFreq=150, atk=0.25, atkC= -2.5, dur=0.75, dec=2, decC= -5, amp=1, panDir= -1 da=2|
	var halfTime = atk+(dur/2),
		freqEnv  = EnvGen.kr(Env([sFreq, eFreq], [atk], [atkC]), 1, 1),
		ampEnv   = EnvGen.kr(Env([amp, amp, 0], [atk+dur, dec], [decC]), 1, 1, doneAction: da),
		acmpEnv  = EnvGen.kr(Env([0, amp, amp, 0], [atk, dur, dec], [atkC, 0, decC]), 1, 1),
		sine     = SinOsc.ar(freqEnv, 0, ampEnv),
		dust     = Dust.ar(XLine.kr(100, 1000, atk+dur), acmpEnv*0.15),
		saw      = Saw.ar(freqEnv*XLine.kr(0.2, 0.5, halfTime), acmpEnv*0.5),
		pan      = Pan2.ar(sine+saw+dust, FSinOsc.kr(0.5/(atk+dur+dec), panDir), 1);

	Out.ar(out, pan);
}.add;

SynthDef(\buildup) { |out=0, dur=10, pan=0, sAmp=0.1, eAmp=0.5, curve=1, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			LFNoise0.kr(1000), // trigger
			LFNoise1.kr.range(0.1, 2), // duration
			buf,
			1, // playback rate
			XLine.kr(0.001, 0.315, dur, doneAction: 2), // position
			2, // linear interpolation
			0, // panning
			-1 // grain envelope buffer
		),
		aEnv = EnvGen.kr(Env([sAmp, eAmp, 0], [dur, 0.5], [curve]), 1, doneAction: 2),
		pan2 = Pan2.ar(samp*aEnv, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\babble) { |out=0, imp=25, sustain=1 amp=0.5, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			Impulse.kr(imp), // trigger
			LFNoise2.kr.range(0.05, 0.25), // duration
			buf,
			LFNoise2.kr.range(0.5, 1.5), // playback rate
			LFNoise1.kr.range(0, 1), // position
			2, // linear interpolation
			0, // panning
			-1 // grain envelope buffer
		),
		sEnv = EnvGen.kr(Env([amp, amp, 0], [sustain, 0]), 1, doneAction: 2),
		pan2 = Pan2.ar(samp*sEnv, Dust2.kr(imp/2));

	Out.ar(out, pan2);
}.add;

SynthDef(\sled) { |out=0, dur=10, sustain=1, fadeOut=5, amp=0.5, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			LFNoise0.kr.(150), // trigger
			XLine.kr(0.005, 0.25, dur), // duration
			buf,
			LFNoise2.kr.range(XLine.kr(1, 0.5, dur), XLine.kr(1, 1.5, dur)), // playback rate
			0.26, // position
			2, // linear interpolation
			0, // panning
			-1 // grain envelope buffer
		),
		sEnv = EnvGen.kr(Env([amp, amp, 0], [sustain, fadeOut]), 1, doneAction: 2),
		pan2 = Pan2.ar(samp*sEnv, FSinOsc.kr(2));

	Out.ar(out, pan2);
}.add;

SynthDef(\julie) { |out=0, amp=0.5, buf|
	var sustain = 2.25,
		samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			1, // trigger
			sustain, // duration
			buf,
			1, // playback rate
			0.5625, // position
			0, // linear interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([1, 1], [sustain]).discretize,
				buf.numChannels
			)
		),
		sEnv = EnvGen.kr(Env([amp, 1, 0], [sustain, 0]), 1, doneAction: 2),
		pan2 = Pan2.ar(samp*sEnv, FSinOsc.kr(1));

	Out.ar(out, pan2);
}.add;

SynthDef(\ah) { |out=0, imp=1, sustain=1, amp=0.5, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			Impulse.kr(imp), // trigger
			0.75, // duration
			buf,
			1, // playback rate
			0.59, // position
			0, // linear interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([0.75, 1, 0.25], [0.1, 0.65], [-5, 5]).discretize,
				buf.numChannels
			)
		),
		sEnv = EnvGen.kr(Env([amp, 0], [sustain], [5]), 1, doneAction: 2),
		pan2 = Pan2.ar(samp*sEnv, FSinOsc.kr(imp*2));

	Out.ar(out, pan2);
}.add;

SynthDef(\leaves) { |out=0, fadeIn=1, sustain=1, fadeOut=1, rate=4, density=25, amp=1, buf|
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
		),
		env  = EnvGen.kr(Env([0.005, amp, amp, 0], [fadeIn, sustain, fadeOut], 1), 1, doneAction: 2) * samp,
		rvrb = FreeVerb2.ar(env, env, 0.5, 1, 0),
		pan2 = Pan2.ar(rvrb, LFNoise0.kr(density, -1, 2)-1);

	Out.ar(out, pan2);
}.add;





Buffer.readChannel(s, a[3], channels: 0, action: { |dbuf|
	"Denjiha loaded".postln;

Buffer.readChannel(s, a[5], channels: 0, action: { |kbuf|
	"Kalimbas loaded".postln;

Buffer.readChannel(s, a[1], channels: 0, action: { |jbuf|
	"City of Julie loaded".postln;

Routine({
	~dots = { |synth, freq, amp=0.5, sustain=10, dur=0.5, legato=0.5, stutter=1|
		Routine({
			var freqs = Pstutter(
				Pseq(stutter.asArray, inf),
				Pseq(freq.asArray, inf)
			).asStream;

			(sustain/dur).do({ |i|
				Synth(synth, [\freq, freqs.next, \sustain, dur*legato, \amp, amp]);
				dur.wait;
			});
		}).play;
	};

	~envDots = { |synth, sFreq, eFreq amp=0.5, fadeIn=1, sustain=10, fadeOut=1, dur=0.5, legato=0.5, stutter=1|
		Routine({
			var sFreqs = Pstutter(
				Pseq(stutter.asArray, inf),
				Pseq(sFreq.asArray, inf)
			).asStream,
			eFreqs = Pstutter(
				Pseq(stutter.asArray, inf),
				Pseq(eFreq.asArray, inf)
			).asStream;

			(sustain/dur).do({ |i|
				Synth(synth, [\sFreq, sFreqs.next, \eFreq, eFreqs.next, \fadeIn, fadeIn, \sustain, dur*legato, \fadeOut, fadeOut, \amp, amp]);
				dur.wait;
			});
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

	// 20 seconds
	~curves = { |amp=0.1|
		Routine({
			Synth(\envSine, [\pan, -1, \sFreq, 100, \eFreq, 250, \fadeIn, 4, \sustain, 4, \fadeOut, 4, \amp, amp]);
			8.wait;
			Synth(\envSine, [\pan, 1, \sFreq, 323.6, \eFreq, 200, \fadeIn, 4, \sustain, 2, \fadeOut, 2, \amp, amp]);
		}).play;
	};

	// 1 loop = 4 seconds
	~danceEnvDots = { |amp=0.1, sustain=1|
		~envDots.value(\envSine,
			[3500, 3500, 2500, 10, 20, 2500, 5000, 2500, 3500, 4500, 50, 10, 0500, 4000, 2000, 0250],
			[3000, 3000, 4000, 50, 10, 4000, 2500, 3500, 4500, 3500, 100, 2500, 0100],
			amp, 0, sustain, 0.1, 0.25, 0.2
		);
	};

	// 1 loop = 16 seconds
	~melody = { |synth, loops, amp=0.5, pShift=1, speed=1, legato=1, pan=0|
		Pbind(
			\instrument, synth,
			\freq, Pseq(([48, 59, 60, 57, 48, 59, 60, 55, 48, 59, 60, 62, 48, 59, 60, 56].midicps)*pShift, loops),
			\dur, Pseq([1, 0.5, 0.5, 2]/speed, inf),
			\legato, legato,
			\pan, pan,
			\amp, amp
		).play;
	};

	// 1 loop = 8 seconds
	~harmony = { |synth, loops, amp=0.5, legato=1|
		Pbind(
			\instrument, synth,
			\freq, Pseq([48, 59, 60, 57, 48, 59, 60, 55].midicps, loops),
			\dur, Pseq([1, 0.5, 0.5, 2], loops*2),
			\legato, legato,
			\amp, amp
		).play;
	};

	// 2 seconds
	~cutOff = { |amp=0.5|
		Synth(\envSquare, [\sFreq, 161.8, \eFreq, 50, \fadeIn, 0, \sustain, 0, \fadeOut, 1, \amp, amp*0.4]); // 1s
		Synth(\envSine, [\sFreq, 161.8, \eFreq, 50, \fadeIn, 0, \sustain, 1, \fadeOut, 0.5, \amp, amp]); // 1.5s
		1.5.wait;
		Synth(\envSquare, [\sFreq, 75, \eFreq, 150, \fadeIn, 0, \sustain, 0, \fadeOut, 1.25, \amp, amp*0.4,]); // 1.25s
		Synth(\envSine, [\sFreq, 75, \eFreq, 150, \fadeIn, 0, \sustain, 1, \fadeOut, 0.25, \amp, amp,]); // 1.25s
	};

	~bass1 = { |loops=1, freq=150, amp=0.5, dur=0.5, legato=0.25, dStut1=1, dStut2=1, dStut3=4, pan=0|
		Pbind(
			\instrument, \bass,
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
	~bass2 = { |loops=1, freq=150, amp=0.5, legato=0.25, pan=0|
		~bass1.value(loops, freq, amp, [0.5, 2, 0.25, 0.5], legato, [7,1,7,1], [1,2,1,3], [16,1,2,13], pan);
	};

	// 1 loop = 4 seconds
	~bass3 = { |loops=1, freq=150, amp=0.5, legato=0.25, pan=0|
		~bass1.value(loops, freq, amp, [0.25], legato, [1,8,1,6], [2,1,2,1], [16], pan);
	};

	~snare1 = { |loops=1, freq=2000 amp=0.5, dur=1, dStut1=1, dStut2=1, dStut3=4|
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

	// 1 loop = 27 seconds
	~snare2 = { |loops=1, freq=2000, amp=0.5|
		~snare1.value(loops, freq, amp, [1,0.25,0.75,1,0.25,0.75,1,0.25,1], [7,1,7,1,7,1,7,1], [1,7,1,2,1,3,1,2], [7,1,1,5,1,1,5,4,7]);
	};

	// 1 loop = 8 seconds
	~snare3 = { |loops=1, freq=2000, amp=0.5|
		~snare1.value(loops, freq, amp, [0.25,0.5,0.25,0.5], [1,8,1,1,5], [2,1,4,2,1], [1,8,2,5]);
	};

	~hihat = { |loops=1, amp=0.25, dur=0.5, freq=500|
		Pbind(
			\instrument, \hihat,
			\freq, Pseq(freq.asArray, loops),
			\dur, dur,
			\amp, amp
		).play;
	};

	~emptyHihat = { |totalLoops=1, loops=1, amp=0.25, dur=0.5, freq=500|
		Routine({
			totalLoops.do({
				~hihat.value(loops, amp, dur, freq);
				(2*loops*dur).wait;
			});
		}).play;
	};

	// 4 seconds
	~domoFill = { |amp=0.5|
		Synth(\domobass, [\sFreq, 150, \eFreq, 50, \atk, 1.75, \dur, 1, \dec, 0.25, \amp, amp, \panDir, 1]);
		1.wait;
		Synth(\domobass, [\sFreq, 25, \eFreq, 250, \atk, 0.75, \dur, 0, \dec, 2, \amp, amp, \panDir, -1]);
		2.wait;
	Synth(\domobass, [\sFreq, 25, \eFreq, 650, \atk, 0.75, \dur, 0, \dec, 1, \amp, amp*0.7, \panDir, -1]);
		1.wait;
		Synth(\domobass, [\sFreq, 1000, \eFreq, 50, \atk, 1.75, \dur, 0, \dec, 0.25, \amp, amp*0.9, \panDir, 1]);
	};



	Synth(\buildup, [\buf, dbuf, \dur, 20, \sAmp, 0.05, \eAmp, 0.9, \curve, 25]);
	~dots.value(\susSquare, [200], 0.1, 16); // 16s
	4.wait;
	~curves.value(0.2); // 20s
	(0.25).wait;
	~dots.value(\susSquare, [323.6, 300, 250], 0.1, 12, 0.5, 0.5, 8); //12s
	(11.75).wait;
	~cutOff.value(0.5);
	(2).wait;

	~dots.value(\susSquare, [200], 0.05, 12); // 12s
	Synth(\susSine, [\freq, 100, \amp, 0.25, \sustain, 8]); // 8s
	~dots.value(\susSquare, [400], 0.05, 8); // 8s
	8.wait;
	Synth(\susSine, [\freq, 75, \amp, 0.25, \sustain, 4]); // 4s
	4.wait;

	// 1 loop = 16s
	Routine({
		2.do({ |i|
			var dur = 0.5,
				amp = 0.3,
				halfDur;

			if (i == 1, {
				dur = 0.25;
				amp = 0.5;
			});

			halfDur = dur/2;

			~susMelody.value(\susSine, 1, [100,125,75,125], 0.2, [4,4,4,4] ); // 16s
			~dots.value(\susSquare, [200], 0.075, 16, dur); // 16s
			~melody.value(\sine, 1, amp); // 16s
			~melody.value(\sine, 1, 0.1, 0.75, 1, 1, -1); // 16s
			~melody.value(\sine, 1, 0.1, 2, 1, 1, 1); // 16s
			(halfDur).wait;
			~dots.value(\susSquare, [323.6, 300, 250], 0.075, 16, dur, 0.5, 8); // 16s
			(8-halfDur).wait;

			if (i == 0, {
				~curves.value(0.2); // 20s
			}, {
				Synth(\sled, [\buf, dbuf, \sustain, 28, \fadeOut, 0, \amp, 0.1]); // 28s
			});

			8.wait;
		});
	}).play;
	32.wait;

	Synth(\babble, [\buf, jbuf, \imp, 10, \sustain, 28, \amp, 0.15]); // 28s
	~bass1.value(10, 150, 0.5); // 20s
	(8.5).wait;
	~snare1.value(5, 2000, 0.5); // 20s
	~danceEnvDots.value(0.025, 4); // 4s
	(3.25).wait;
	~emptyHihat.value(4, 4, 0.25); //16s
	(0.25).wait;
	~danceEnvDots.value(0.06, 18); // 18s
	(4).wait;
	Synth(\sawStep, [\amp, 0.15, \sustain, 4]); // 4s
	4.wait;
	Synth(\sawStep, [\amp, 0.25, \imp, 20, \sustain, 14]); // 14s
	4.wait;

	Synth(\sled, [\buf, dbuf, \sustain, 32, \fadeOut, 16, \amp, 0.1]); // 64s
	8.wait;
	~bass2.value(2, 150, 0.75); // 32s
	(0.25).wait;
	~hihat.value(4); // 2s
	(0.25).wait;
	~snare2.value(1); // 27s
	(8).wait;
	~dots.value(\susSquare, [200], 0.1, 16); // 16s
	(3.75).wait;
	~dots.value(\susSquare, [323.6, 300, 250], 0.1, 12, 0.5, 0.5, 8); //12s
	(11.75).wait;
	~cutOff.value(0.75);
	8.wait;

	Synth(\susSine, [\freq, 100, \amp, 0.25, \sustain, 16]); // 16s
	~harmony.value(\sine, 3, 0.3); // 24s
	8.wait;
	~melody.value(\sine, 1, 0.1, 2); // 16s
	8.wait;
	Synth(\susSine, [\freq, 75, \amp, 0.25, \sustain, 16]); // 16s
	~dots.value(\susSine, [323.6, 300, 250], 0.2, 10, 0.5, 0.5, 8); // 10s
	8.wait;
	~melody.value(\sine, 1, 0.3, 1, 2); // 8s
	6.wait;

	Synth(\julie, [\buf, jbuf, \amp, 0.005]); // 2.25s
	2.wait;
	~susMelody.value(\susSine, 1, [100,75,125,100], 0.4, [4,4,4,7] ); // 19s
	Synth(\babble, [\buf, jbuf, \imp, 20, \sustain, 16, \amp, 0.2]); // 16s
	Synth(\ah, [\buf, jbuf, \imp, 1.75, \sustain, 6, \amp, 0.1]); // 6s
	~bass3.value(4, 200, 0.75); // 16s
	~bass3.value(4, 7500, 0.025, 0.3, 1); // 16s
	(0.25).wait;
	~snare3.value(2, 2000, 0.5); // 16s
	(11.75).wait;

	~domoFill.value(0.5);
	4.wait;

	Synth(\domobass, [\sFreq, 0, \eFreq, 75, \atk, 0.8, \dur, 0, \dec, 0.2, \amp, 0.5, \panDir, -1]);
	Synth(\envSine, [\sFreq, 0, \eFreq, 200, \fadeIn, 0.5, \sustain, 0.5, \fadeOut, 0, \amp, 0.4, \pan, -1]);
	(0.25).wait;
	Synth(\envSine, [\sFreq, 0, \eFreq, 200, \fadeIn, 0.25, \sustain, 0.5, \fadeOut, 0, \amp, 0.4, \pan, 1]);
	(0.25).wait;
	~bass3.value(8, 200, 0.75); // 32s
	~bass3.value(8, 7500, 0.025, 0.3, 1); // 32s
	(0.25).wait;
	~snare3.value(4, 2000, 0.5); // 32s
	~susMelody.value(\susSine, 2, [200,150,250], 0.4, [4,4,4]); // 24s
	12.wait;
	~susMelody.value(\susSine, 1, [323.6,242.7,404.5], 0.2, [4,4,4]); // 12s
	Synth(\leaves, [\buf, kbuf, \fadeIn, 0.005, \sustain, 12, \fadeOut, 4, \amp, 0.15, \rate, 5]); // 12s
	8.wait;
	Synth(\envSine, [\pan, -1, \sFreq, 0, \eFreq, 200, \amp, 0.75, \fadeIn, 11.5, \sustain, 0, \fadeOut, 0]); // 11.5s
	2.wait;
	Synth(\envSine, [\pan, 1, \sFreq, 0, \eFreq, 400, \amp, 0.75, \fadeIn, 9.5, \sustain, 0, \fadeOut, 0]); // 9.5s
	10.wait;

	"It has ended.".postln;
	"".postln;
}).play;
});
});
});

"It has begun...";