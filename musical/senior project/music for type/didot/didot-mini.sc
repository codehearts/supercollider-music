// 7 minutes 51 seconds

"~/Music/supercollider-music/samples/samples.sc".standardizePath.loadPaths;
//"../samples/samples.sc".resolveRelative.loadPaths;

SynthDef(\brokenWub) { |out=0, freq=150, sustain=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(Env([0,amp,amp,0], [sustain*0.75, sustain*0.25, 0.05], [-2.5,0,0]), 1, doneAction: 2),
		saw  = Saw.ar(100, aEnv),
		sine = SinOsc.ar(freq, 0, saw),
		pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\humm) { |out=0, freq=440, imp=0.5, sustain=1, fadeOut=1, amp=0.25|
	var sust = EnvGen.kr(Env([1, 1, 0], [sustain, fadeOut]), 1),
		inst = Pulse.ar(freq, 0.5, FSinOsc.kr(imp, 0, amp)) * sust,
		rvrb = FreeVerb.ar(inst, 1, 1, 0.05),
		pan2 = Pan2.ar(rvrb, FSinOsc.kr(imp*1.5));

	Out.ar(out, pan2);
}.add;

SynthDef(\softTwinkle) { |out=0, sFreq=440, eFreq=660, steps=4, imp=0.5, sustain=1, fadeOut=1, amp=0.25|
	var sust = EnvGen.kr(Env([1, 1, 0], [sustain, fadeOut]), 1, doneAction: 2),
		step = abs(eFreq-sFreq)/steps,
		fStp = Stepper.kr(Impulse.kr(imp), 0, sFreq, eFreq, step),
		inst = Pulse.ar(fStp, 0.5, FSinOsc.kr(imp, 0, amp)),
		rvrb = FreeVerb.ar(inst, 1, 1, 0.05),
		pan2 = Pan2.ar(rvrb, FSinOsc.kr(imp*1.5));

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\twinkle) { |out=0, sFreq=440, eFreq=660, steps=4, imp=2.5, stepDur=2, dur=0.1, sustain=1, fadeOut=1, amp=0.25|
	var sust = EnvGen.kr(Env([1, 1, 0], [sustain, fadeOut]), 1, doneAction: 2),
		step = abs(eFreq-sFreq)/steps,
		fStp = Stepper.kr(Impulse.kr(1/stepDur), 0, sFreq, eFreq, step),
		aStp = Stepper.kr(Impulse.kr(1/dur), 1, 0, 1, step),
		inst = Pulse.ar(fStp, 0.5, FSinOsc.kr(imp, 0, amp)*aStp),
		rvrb = FreeVerb.ar(inst, 1, 1, 0.05),
		pan2 = Pan2.ar(rvrb, FSinOsc.kr(imp*2));

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\lurker) { |out=0, minF=440, maxF=1000, dur=5, sustain=15, amp=1|
	var sust = EnvGen.kr(Env([1, 1, 0], [sustain, 5]), 1, doneAction: 2),
		aEnv = EnvGen.kr(
			Env(
				[0, amp, amp, 0, 0],
				[dur*0.65, dur*0.15, dur/4, dur/4],
				[2.5, -2.5]
			).circle, 1
		),
		sine = SinOsc.ar(LFNoise0.kr(dur/2, minF, maxF), 0, Saw.kr(XLine.kr(25, 75, sustain))) * aEnv,
		rvrb = FreeVerb.ar(sine, 1, 1, 1),
		pan2 = Pan2.ar(rvrb, FSinOsc.kr(0.5/dur));

	Out.ar(out, pan2 * sust);
}.add;

SynthDef(\distantMachine) { |out=0, fSaw=300, fSin=1000, imp=25, sustain=1, fadeOut=4 amp=0.25|
	var sust = EnvGen.kr(Env([1, 1, 0], [sustain, fadeOut], [0, -5]), 1, doneAction: 2),
		cut1 = Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1),
		cut2 = Stepper.kr(Impulse.kr(imp), 1, 0, 1, -1),
		saw  = Saw.ar(fSaw, amp) * cut1,
		sine = SinOsc.ar(fSin, 0, amp) * cut2,
		pan2 = Pan2.ar(sine+saw*sust, 0),
		rvrb = FreeVerb.ar(pan2, 1, 1, 0);

	Out.ar(out, rvrb);
}.add;

SynthDef(\buzzDust) { |out=0, freq=200, imp=10, fadeIn=1, sustain=2, fadeOut=1, amp=0.25|
	var sust = EnvGen.kr(Env([0, 1, 1, 0], [fadeIn, sustain, fadeOut]), 1, doneAction: 2),
		sqr  = Pulse.ar(freq, 0.5, Saw.kr(LFNoise0.kr(10, 10, 100))*amp),
		cut  = TIRand.kr(0, 1, Impulse.kr(imp)),
		pan2 = Pan2.ar(sqr, Stepper.kr(Impulse.kr(imp), 0, -1, 1, 2));

	Out.ar(out, pan2*cut*sust);
}.add;

SynthDef(\scale) { |out=0, freq=200, start=1, end=10, sustain=0.5, fadeOut=1, amp=0.25|
	var sust = EnvGen.kr(Env([1,1,0], [sustain,fadeOut]), 1, doneAction: 2),
		blip = Blip.ar(freq, Line.kr(start, end, sustain), amp),
		pan2 = Pan2.ar(blip, FSinOsc.kr(sustain/2));

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\smoothWave) { |out=0, freq=150, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(0, 1), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

SynthDef(\straightWave) { |out=0, freq=150, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq*2, 0, LFTri.kr(imp).range(0.25, 0.5), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

SynthDef(\doubleStraightWave) { |out=0, freq=150, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq*2, 0, LFTri.kr(imp).range(0.25, 0.5), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

SynthDef(\doubleSmoothWave) { |out=0, freq=150, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq*2, 0, LFTri.kr(imp).range(0, 1), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

SynthDef(\square) { |out=0, freq=400, atk=0.25, sustain=1, dec=0.25, pan=0, amp=0.25|
	var sust = EnvGen.kr(Env([0, 1, 1, 0], [atk, sustain, dec]), 1, doneAction: 2),
		puls = Pulse.ar(freq, 0.5, amp),
		pan2 = Pan2.ar(puls, pan);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\hardBass) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2),
		sine = SinOsc.ar(XLine.kr(freq, freq/3, sustain), 0, amp)*env,
		sqr  = Pulse.ar(XLine.kr(freq, freq/3, sustain), 0.5)*(amp*0.25)*env,
		pan2 = Pan2.ar(sine+sqr, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\bass) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var hit  = 0.15,
		sust = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2),
		beat = EnvGen.kr(Env([1, 1, 0], [hit, 0.05]), 1),
		vSaw = VarSaw.ar(XLine.kr(freq*3, freq, hit), 0, 0.5, amp) * beat,
		tri  = LFTri.ar(XLine.kr(freq, freq/3, hit), 0, amp) * beat,
		pan2 = Pan2.ar(vSaw+tri, pan);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\snare) { |out=0, freq=7500, decay=0.3, amp=1, pan=0|
	var aEnv = EnvGen.kr(Env.perc(0.005, decay, amp), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, WhiteNoise.ar(aEnv*0.15)),
		rvrb = FreeVerb.ar(drum, 1, 1, 1) + WhiteNoise.ar(aEnv*0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;



SynthDef(\cutBuf) { |out=0, imp=2.5, sustain=4, amp=0.25, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			1, // trigger
			sustain, // duration
			buf,
			0.75, // playback rate
			0, // position
			0, // linear interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([0.9, 1], [1], [0]).discretize,
				buf.numChannels
			)
		),
		sEnv = EnvGen.kr(Env([amp, amp, 0], [sustain, 0.5], [0, 5]), 1, doneAction: 2),
		cStp = Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1),
		pan2 = Pan2.ar(samp * sEnv * cStp, FSinOsc.kr(0.5));

	Out.ar(out, pan2);
}.add;

SynthDef(\cutBufReverb) { |out=0, imp=2.5, sustain=4, amp=0.25, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			1, // trigger
			sustain, // duration
			buf,
			0.75, // playback rate
			0, // position
			0, // linear interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([0.9, 1], [1], [0]).discretize,
				buf.numChannels
			)
		),
		sEnv = EnvGen.kr(Env([amp, amp, 0], [sustain, 0.5], [0, 5]), 1, doneAction: 2),
		cStp = Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1),
		pan2 = Pan2.ar(samp * cStp, FSinOsc.kr(0.5)),
		rvrb = FreeVerb.ar(pan2, 0.5, 1, 0.75);

	Out.ar(out, rvrb * sEnv);
}.add;

SynthDef(\iris) { |out=0, imp=1, sustain=3, amp=0.5, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			Impulse.kr(1/sustain), // trigger
			sustain, // duration
			buf,
			1, // playback rate
			0.365, // position
			0, // linear interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([0.75, 1, 0], [3, 0], [-5, 5]).discretize,
				buf.numChannels
			)
		),
		sEnv = EnvGen.kr(Env([amp/4, amp, 0], [sustain, 0]), 1, doneAction: 2),
		pan2 = Pan2.ar(samp*sEnv, FSinOsc.kr(imp*2));

	Out.ar(out, pan2);
}.add;

SynthDef(\quickly) { |out=0, imp=1, sustain=1, grains=3, wait=0.25, amp=0.5, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			Impulse.kr(1/(sustain/grains+wait)), // trigger
			sustain/grains, // duration
			buf,
			1, // playback rate
			XLine.kr(0.8, 0.9, sustain), // position
			0, // linear interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([0.75, 1, 0], [3, 0], [-5, 5]).discretize,
				buf.numChannels
			)
		),
		sEnv = EnvGen.kr(Env([amp, amp, 0], [sustain+(grains*wait), 0]), 1, doneAction: 2),
		pan2 = Pan2.ar(samp*sEnv, FSinOsc.kr(imp*2));

	Out.ar(out, pan2);
}.add;

SynthDef(\forestNight) { |out=0, imp=1, sustain=7, amp=0.5, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			Impulse.kr(1/(sustain*2)), // trigger
			sustain, // duration
			buf,
			1, // playback rate
			0, // position
			0, // linear interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([1, 1, 0], [4, 3], [-5, 5]).discretize,
				buf.numChannels
			)
		),
		sEnv = EnvGen.kr(Env([amp, amp, 0], [5, 5]), 1, doneAction: 2),
		rvrb = FreeVerb.ar(samp*sEnv, XLine.kr(0.005, 1, 4), 1, 0.75),
		pan2 = Pan2.ar(rvrb, -1);

	Out.ar(out, pan2);
}.add;









Buffer.readChannel(s, a[11], channels: 0, action: { |hkbuf|
	"H&K II loaded".postln;
Buffer.readChannel(s, a[0], channels: 0, action: { |cbuf|
	"Cellos loaded".postln;
Buffer.readChannel(s, a[4], channels: 0, action: { |ibuf|
	"Iris loaded".postln;
Buffer.readChannel(s, a[12], channels: 0, action: { |fbuf|
	"Fru loaded".postln;
Buffer.readChannel(s, a[14], channels: 0, action: { |sbuf|
	"SVC II loaded".postln;
Routine({

	~breakBuf = { |synth, buf, amp, imps, durs, loops=1|
		var sust = loops*durs.sum,
			sImp = Pseq(imps.asArray, inf).asStream,
			sDur = Pseq(durs.asArray, inf).asStream,
			inst = Synth(synth, [\buf, buf, \sustain, sust, \amp, amp, \imp, sImp.next]);

		Routine({
			(loops*imps.size - 1).do({
				sDur.next.wait;
				inst.set(\imp, sImp.next);
			});
		}).play;
	};

	// 1 loop = 8 seconds
	~wubMelody = { |synth, loops=1, amp=0.25, imp=1|
		Pbind(
			\instrument, synth,
			\freq, Pstutter(
				Pseq([4], inf),
				Pseq([24, 27, 26, 19].midicps*2.5, loops)
			),
			\dur, 0.5,
			\legato, 0.95,
			\imp, imp,
			\amp, amp
		).play;
	};

	// 24 seconds
	~wubDrums = {
		var speed = 2;

		Routine({
			// 64 seconds
			// 1 loop = 7 seconds
			Pbind(
				\instrument, \bass,
				\freq, 250,
				\dur, Pseq(
					[
					 0.1875, 0.3125, 0.375, 0.125,
					 0.1875, 0.3125, 0.375, 0.125,
					 0.1875, 0.3125, 0.375, 0.625,
					 0.375,  0.625,  0.375, 0.125,
					 0.125,  0.375,  0.375, 0.125,
					 0.125,  0.375,  0.5
					] * speed,
					2
				),
				\pan, -1,
				\amp, 0.1
			).play;

			(8.5).wait;

			// 1 loop = 4 seconds
			Pbind(
				\instrument, \snare,
				\dur, Pstutter(
					Pseq([8], inf),
					Pseq([0.5] * speed, 2)
				),
				\amp, 0.4
			).play;

			// 1 loop = 4 seconds
			Pbind(
				\instrument, \bass,
				\freq, Pseq([250, 200, 200], inf),
				\dur, Pseq([0.125, 0.25, 0.125] * speed, 16),
				\pan, 1,
				\amp, 0.1
			).play;
		}).play;
	};

	// 8 seconds
	~wubDrums2 = {
		var speed = 2;

		Routine({
			Pbind(
				\instrument, \bass,
				\freq, Pstutter(
					Pseq([3, 2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1], inf),
					Pseq([200, 250], inf)
				),
				\dur, Pseq([
					0.125, 0.125, 0.0625, 0.125, 0.0625, 0.1875, 0.0625, 0.0625, 0.25,
					0.0625, 0.125, 0.0625, 0.25, 0.125, 0.0625, 0.0625, 0.1875,
					0.0625, 0.3125, 0.0625, 0.0625, 0.0625, 0.0625, 0.25, 0.125,
					0.125, 0.125, 0.0625, 0.125, 0.0625, 0.1875, 0.0625, 0.0625, 0.25
				] * speed, 1),
				\pan, 1,
				\amp, 0.1
			).play;

			(0.125 * speed).wait;

			Pbind(
				\instrument, \snare,
				\dur, Pseq([
					0.125, 0.1875, 0.1875, 0.3125, 0.125,
					0.0625, 0.125, 0.1875, 0.125, 0.375, 0.0625, 0.1875,
					0.125, 0.0625, 0.375, 0.125, 0.125, 0.125,
					0.125, 0.1875, 0.1875, 0.3125, 0.125
				] * speed, 1),
				\amp, 0.4
			).play;
		}).play;
	};

	~simpleBass = { |loops=1, amp=0.5, freq=150, dur=0.5, legato=0.25, dStut1=1, dStut2=1, dStut3=4, pan=0|
		Pbind(
			\instrument, \hardBass,
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

	~simpleSnare = { |loops=1, amp=0.5, dur=1, dStut1=1, dStut2=1, dStut3=4|
		Pbind(
			\instrument, \snare,
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

	// 1 loop = 8 seconds
	~melody2 = { |synth, loops=1, amp=0.25|
		var speed = 2;

		Pbind(
			\instrument, synth,
			\freq, Pseq([
				36,38,40,36,38,40,36,38,
				39,41,43,39,41,43,39,41,
				38,40,41,38,40,41,38,40,
				31,33,35,31,33,35,31,33
			].midicps * 4, loops),
			\dur, 0.125 * speed,
			\legato, 0.9,
			\amp, Pstutter(
				Pseq([8, 8, 8, 8], inf),
				Pseq([0.5, 0.65, 0.80, 1]*amp, loops)
			)
		).play;
	};

	// 1 loop = 16 seconds
	~melody3 = { |synth, loops=1, amp=0.25, imp=1|
		Pbind(
			\instrument, synth,
			\freq, Pseq([60, 64, 53, 57, 55, 52, 53, 57, 55, 50, 52].midicps, loops),
			\dur, Pseq([1.5, 0.5, 0.5, 5.5, 4, 4, 4, 4, 4, 1.5, 2.5] / 2, loops),
			\legato, 1,
			\imp, imp,
			\amp, amp
		).play;
	};

	// 1 loop = 8 seconds
	~melody4 = { |synth, loops=1, amp=0.25, imp=0.95|
		Pbind(
			\instrument, synth,
			\freq, Pseq([59, 66, 62, 60, 59, 67, 64, 59, 66, 62].midicps, loops),
			\dur, Pstutter(
				Pseq([4, 1], inf),
				Pseq([1.5, 2] / 2, inf)
			),
			\legato, 1,
			\imp, imp,
			\amp, amp
		).play;
	};



	Synth(\scale, [\freq, 100, \sustain, 1, \start, 15, \end, 1, \amp, 0.1]);
	Synth(\scale, [\freq, 250, \sustain, 1, \start, 25, \end, 1, \amp, 0.1]);
	~wubMelody.value(\brokenWub, 1, 0.25); // 8s
	Synth(\smoothWave, [\amp, 0.25, \sustain, 8, \imp, 0.03125, \freq, 250]); // 8s
	8.wait;

	~breakBuf.value(\cutBuf, hkbuf, 0.75, [2, 8, 30, 10, 60], [2, 2, 2, 2, 4], 1); // 12s
	~wubMelody.value(\smoothWave, 1, 0.3); // 8s
	8.wait;
	~wubMelody.value(\doubleSmoothWave, 1, 0.2); // 8s
	~wubMelody.value(\smoothWave, 1, 0.15, 1.5); // 8s
	~melody4.value(\doubleSmoothWave, 1, 0.15); // 8s
	8.wait;

	Synth(\scale, [\freq, 250, \sustain, 4, \start, 25, \end, 1, \amp, 0.1]);
	~melody3.value(\smoothWave, 1, 0.2, 0.5); // 16s
	~simpleBass.value(4, 0.25); // 8s
	8.wait;

	~melody2.value(\doubleStraightWave, 1, 0.1, 0.0125); // 12s
	~simpleBass.value(4, 0.25); // 8s
	(0.5).wait;
	~simpleSnare.value(1, 0.3, [1,0.25,0.75,1], 1, 1, [3,1,1,4]); // 8s
	(3.5).wait;



	"It's Over".postln;
}).play;
});
});
});
});
});

"\nNow Playing";	