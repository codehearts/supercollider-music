SynthDef(\reverseDusthumm, {|freq = 440, dur = 10, crushRate = 100, crushStep = 0.1, pan = 0, amp = 0.2, out = 0|
	var osc, env, panning, reverb;

	env = EnvGen.kr(Env.linen(dur, 0.005, 0.1, amp, 0), doneAction: 2);
	osc = Pulse.ar(freq, SinOsc.kr(crushRate, 0, 1).range(crushStep).abs, env);
	panning = Pan2.ar(osc, pan);
	reverb = FreeVerb.ar(panning, 1, 1, 0.5);
	
	Out.ar(out, reverb);
}).add;

SynthDef(\envSine) { |out=0, pan=0, fadeIn=1, sustain=1, fadeOut=1, sFreq=100, eFreq=440, amp=0.25|
	var sEnv = EnvGen.kr(Env([0, 1, 1, 0], [fadeIn, sustain, fadeOut]), 1, doneAction: 2),
		fEnv = EnvGen.kr(Env([sFreq, eFreq], [fadeIn+(sustain/2)], 0, eFreq), 1),
		sine = SinOsc.ar(fEnv, 0, amp) * sEnv,
		pan2 = Pan2.ar(sine, pan);
	
	Out.ar(out, pan2);
}.add;

SynthDef(\brokenWub) { |out=0, freq=150, sustain=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(Env([0,amp,amp,0], [sustain*0.75, sustain*0.25, 0.05], [-2.5,0,0]), 1, doneAction: 2),
		saw  = Saw.ar(100, aEnv),
		sine = SinOsc.ar(freq, 0, saw),
		pan2 = Pan2.ar(sine, pan);
	
	Out.ar(out, pan2);
}.add;

SynthDef(\sawSine) { |out=0, imp=5, freq=150, sustain=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(Env([0,amp,amp,0], [sustain*0.75, sustain*0.25, 0.25], [-2.5,0,0]), 1, doneAction: 2),
		saw  = Saw.ar(imp, aEnv),
		sine = SinOsc.ar(freq, 0, saw),
		rvrb = sine + FreeVerb.ar(sine, 0.25, 0.5, 0.25),
		pan2 = Pan2.ar(rvrb, pan);
	
	Out.ar(out, pan2);
}.add;

SynthDef(\fadeGuitar) { |out=0, freq=150, sustain=1.5, panS = -1, panE=1, amp=0.5|
	var aEnv = EnvGen.kr(Env([0,amp,0], [sustain,sustain*0.1], [2.5,0]), 1, doneAction: 2),
		pEnv = EnvGen.kr(Env([panS,panE], [sustain]), 1),
		saw  = Saw.ar(300, aEnv),
		sine = SinOsc.ar(freq, 0, saw),
		pan2 = Pan2.ar(sine, pEnv);
	
	Out.ar(out, pan2);
}.add;

// Leads

SynthDef(\fragileSquare) { |out=0, freq=400, atk=0.005, sustain=1, dec=0.005, imp=1, pan=0, amp=0.25|
	var env, saw, osc, osc2, panning, reverb;
	
	env = EnvGen.kr(Env.linen(atk, sustain, dec, amp, 0), doneAction: 2);
	saw  = Saw.ar(imp, 1);
	osc = Pulse.ar(freq, 0.5, saw);
	osc2 = Pulse.ar(freq*2, 0.5, saw);
	panning = Pan2.ar(osc+osc2, pan);
	reverb = FreeVerb.ar(panning, 0.5, 1, 0.5) * env;
	
	Out.ar(out, reverb);
}.add;

// Basses

SynthDef(\triSaw) { |out=0, freq=150, hi=1, lo=0, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(lo, hi), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);
	
	Out.ar(out, rvrb*sust);
}.add;

// Drums

SynthDef(\bassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2),
		sine = SinOsc.ar(XLine.kr(freq, freq/3, sustain), 0, amp)*env,
		sqr  = Pulse.ar(XLine.kr(freq, freq/3, sustain), 0.5)*(amp*0.25)*env,
		pan2 = Pan2.ar(sine+sqr, pan);
	
	Out.ar(out, pan2);
}.add;



Routine({
	// 1 loop = 8 seconds
	~dustLead = { |loops=1, amp=0.5, speed=0.5|
		Pbind(
			\instrument, \reverseDusthumm,
			\freq, Pstutter(
					Pseq([4,  4,  4,  3, 1], loops),
					Pseq([100,150,134,89,124], inf)
				),
			\dur, speed,
			\legato, 0.75,
			\amp, amp
		).play;
	};
	
	// 1 loop = 4 seconds
	~guitarBits = { |loops=1, amp=0.25|
		Pbind(
			\instrument, \fadeGuitar,
			\freq, Pseq([50, 140, 150, 100, 240, 250]*5, loops),
			\dur, Pseq([2, 1, 1]/2, inf),
			\legato, 0.75,
			\panS, Pseq([-1, 1], inf),
			\panE, Pseq([1, -1], inf),
			\amp, amp
		).play;
	};
	
	// 4 movements, 1 loop = 3 seconds
	~shapeBits = { |synth, loops=inf, amp=0.1, speed=1|
		Pbind(
			\instrument, synth,
			\freq, Pstutter(
				Pseq([1], inf),
				Pseq([750, 500, 250, 1000]*1.618, inf)
			),
			\dur, 0.125*speed,
			\legato, 0.75,
			\imp, Pstutter(
				Pseq([2, 2, 4, 1, 0,  0, 1, 0,  0, 2, 4, 0, 4, 0, 2, 10], inf),
				Pseq([1, 2, 4, 6, 10, 8, 2, 50, 1, 3, 5, 175], loops)
			),
			\pan, Pseq([-1, 0, 1], inf),
			\amp, amp
		).play;
	};
	
	// 1 loop = 2s
	~bassKick = { |loops=1, freq=150, amp=0.5, dur=0.5, legato=0.25, dStut1=1, dStut2=1, dStut3=4, pan=0|
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
		~bassKick.value(loops, freq, amp, [0.5, 2, 0.25, 0.5], legato, [7,1,7,1], [1,2,1,3], [16,1,2,13], pan);
	};
	
	// 1 loop = 4 seconds
	~bass3 = { |loops=1, freq=150, amp=0.5, legato=0.25, pan=0|
		~bassKick.value(loops, freq, amp, [0.25], legato, [1,8,1,6], [2,1,2,1], [16], pan);
	};
	
	
	// 1 loop = 8 seconds
	~simpleBassLine = { |synth, loops=4, amp=0.25, pitchShift=1, imp=1|
		Pbind(
			\instrument, synth,
			\freq, Pstutter(
				Pseq([6, 2, 6, 2], inf),
				Pseq([75,92,75,96]*pitchShift, loops)
			),
			\dur, 0.5,
			\legato, 0.75,
			\imp, imp,
			\amp, amp
		).play;
	};
	
	
	
	~dustLead.value(2); // 16s
	8.wait;
	~simpleBassLine.value(\triSaw, 2, 0.15, pitchShift: 1.618, imp: 0.5); // 16s
	8.wait;
	~dustLead.value(1, 0.4); // 8s
	~guitarBits.value(4); // 16s
	8.wait;
	~dustLead.value(1, 0.15); // 8s
	~simpleBassLine.value(\triSaw, 1, 0.025, pitchShift: 5, imp: 0.5); // 8s
	~simpleBassLine.value(\triSaw, 1, 0.025, pitchShift: 10, imp: 0.25); // 8s
	~shapeBits.value(\fragileSquare, 2, 0.025); // 6s
	6.wait;
	~dustLead.value(1, 0.75, speed: 0.125); // 1s
	2.wait;
	~simpleBassLine.value(\triSaw, 1, 0.15, pitchShift: 2, imp: 0.25); // 8s
	2.wait;
	~bassKick.value(2); // 4s
	~dustLead.value(1, 0.25, speed: 4); // 32s
	~dustLead.value(2); // 16s
	~shapeBits.value(\sawSine, 2, 0.025); // 6s
	
	90.wait;
	
	Pbind(
		\instrument, \sawSine,
		\freq, Pstutter(
			Pseq([1], inf),
			Pseq([750, 500, 250, 1000]*1.618, inf)
		),
		\dur, 0.125,
		\legato, 0.75,
		\imp, Pswitch(
			[
				Pstutter(
					Pseq([2, 2, 4, 1, 0,  0, 1, 0,  0, 2, 4, 0, 4, 0, 2, 10], 3),
					Pseq([1, 2, 4, 6, 10, 8, 2, 50, 1, 3, 5, 175], inf)
				),
				Pstutter(
					Pseq([2, 2, 4, 1, 0,  0, 1, 0,  0, 2, 4, 0, 4, 0, 2, 10], 2, 13),
					Pseq([1, 2, 4, 6, 10, 8, 2, 50, 1, 3, 5, 175], inf)
				),
				Pstutter(
					Pseq([1,2,2, 10, 5,3,  1,  2, 8,  2,  4,  1,   1, 2,  6,  2]),
					Pseq([1,6,25,250,4,400,600,10,500,700,625,1000,50,400,125,85])
				)
			],
			Pstutter(
				Pseq([1, 1, 1], inf),
				Pseq([0, 1, 2], inf)
			)
		),
		\pan, Pseq([-1, 0, 1], inf),
		\amp, 0.15
	).play;
	
	4.wait;
	
	~bassKick.value; // 2s
	
	4.wait;
	~simpleBassLine.value(\triSaw, inf, 0.25, pitchShift: 1.25);
	
	~bass3.value(8); // 32s
	~bass3.value(8, 7500, 0.0125, 0.3, 1); // 32s
	(0.25).wait;
	~snare3.value(4, 2000, 0.5); // 32s
	
	2.wait;
	
	Synth(\envSine, [\sFreq, 0, \eFreq, 300, \amp, 0.5, \fadeIn, 2, \sustain, 0, \fadeOut, 0]);
	
	
}).play;