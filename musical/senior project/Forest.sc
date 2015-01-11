"~/Music/SC/samples/samples.sc".standardizePath.loadPaths;



// Background Leads

SynthDef(\hardSine) { |out=0, freq=440, gate=1, amp=1|
	var env  = Linen.kr(gate, releaseTime: 2, doneAction: 2),
		aEnv = EnvGen.kr(Env([0, amp, amp/2], [0.15, 0.1], [5, -10])),
		sine = SinOsc.ar(freq, 0, aEnv),
		pan  = Pan2.ar(sine*env, 0, FSinOsc.kr(2)),
		rvrb = FreeVerb.ar(pan, 1, 1, 1);
	
	Out.ar(out, rvrb);
}.add;

SynthDef(\beep) { |out=0, freq=440, amp=1, sustain=1|
	var sine = SinOsc.ar(
			freq,
			0,
			Trig.kr(Line.kr(1, 0, sustain), sustain)
		),
		ring = Ringz.ar(sine, 2000, sustain, amp);
	
	Out.ar(out, ring);
}.add;

SynthDef(\plick) { |out=0, freq=1000, atk=0.005, dec=1, amp=0.5|
	var sine  = SinOsc.ar(freq, 0, 0.25),
		saw   = Saw.ar(freq * 1.25, 0.25),
		env   = EnvGen.kr(Env.perc(atk, dec*1.5), 1, doneAction: 2),
		eSine = sine * env,
		eSaw  = saw * (env * 0.5),
		rvrb  = AllpassC.ar(eSine + eSaw, 0.025, 0.001, dec);
	
	Out.ar(out, rvrb * amp);
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

// Noise

SynthDef(\noisySteamBurst) { |out=0, amp=0.1|
	var sust = EnvGen.kr(Env([amp,amp,0], [0.15,1], [-5]), 1, doneAction: 2),
		noise = WhiteNoise.ar(1),
		rvrb = FreeVerb.ar(noise, 1, 1, 0) + noise;
	
	Out.ar(out, rvrb * sust);
}.add;

// Samplers

SynthDef(\kalimbaAtmosphere) { |out=0, channel=0, gate=1, decay=2.5, density=250, pos=0, amp=0.5, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			LFNoise0.kr(density), // trigger
			XLine.kr(0.005, 0.5, 5), // duration
			buf,
			1, // playback rate
			pos, // position
			2, // linear interpolation
			0, // panning
			-1 // grain envelope buffer
		),
		pan = Pan2.ar(samp, channel),
		env = Linen.kr(gate, releaseTime: decay, doneAction: 2);
	
	Out.ar(out, pan*env*amp);
}.add;

// Effect Groups

SynthDef(\pitchShifter) { |out=0, effectBus=0, window=0.005, pRatio=1, pDisp=0, tDisp=0.0001|
	var in   = In.ar(effectBus, 2),
		env  = EnvGen.kr(Env([500,500,1],[0.5,1.5],[0,5]).circle, 1),
		frsh = FreqShift.ar(in, env);
	
	Out.ar(out, frsh);
}.add;





// Music begins
Buffer.readChannel(s, a[5], channels: 0, action: { |kbuf|
"Kalimbas loaded".postln;
Routine({
	
	// Initialize effect groups
	~sources = Group.new;
	~pitchShifter = Group.after(~sources);
	~pitchShifterBus = Bus.audio(s, 2);
	Synth(\pitchShifter, [\out, 0, \effectBus, ~pitchShifterBus], ~pitchShifter, \addToTail);
	
	
	
	//Synth(\distantMachine, [\amp, 0.05, \sustain, 10, \fadeOut, 6]); // 16s
	
	//50.wait;
	
	/*Pbind(
		\instrument, \plick,
		\out, 1,
		\freq, Pseq([750, 1000, 1500], inf),
		\dur, Pseq([0.5, 0.25, 0.25], inf),
		\amp, 0.5
	).play;*/
	
	/*Pbind(
		\instrument, \beep,
		\out, Pseq([0, 1], inf),
		\freq, Pseq([250, 500], inf),
		\dur, Pstutter(
			Pseq([5, 1], inf),
			Pseq([0.1, Rest(1)], inf)
		),
		\amp, 0.25
	).play;*/
	
	Pbind(
		\instrument, \beep,
		\out, Pseq([0, 1], inf),
		\freq, Pseq([250, 500], inf),
		\dur, Pseq([0.5], inf),
		\legato, 0.5,
		\amp, 0.25
	).play;
	
	(4.1).wait;
	
	Pbind(
		\instrument, \beep,
		\out, Pseq([1, \, 0, 1, \], inf),
		\freq, Pseq([250, \, 300, 350, \], inf),
		\dur, Pseq([0.1, Rest(0.2), 0.1, 0.1, Rest(2)], inf),
		\amp, 0.25
	).play;
	
	(0.55).wait;
	
	Pbind(
		\instrument, \noisySteamBurst,
		\dur, Pseq([1.5], inf),
		\amp, 0.1
	).play;
	
	/*Pbind(
		\instrument, \beep,
		\out, Pseq([0, 0, 1, 1], inf),
		\freq, Pstutter(
			Pseq([4, 1], inf),
			Pseq([500, 250], inf)
		),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([0.125/2, Rest(0.125*2)], inf)
		),
		\amp, 0.1
	).play;*/
	
	/*Pbind(
		\instrument, \beep,
		\out, Pseq([0, 1], inf),
		\freq, Pseq([750, 850, \, 1000, 900], inf),
		\dur, Pstutter(
			Pseq([5, 1], inf),
			Pseq([0.125, Rest(0.375)], inf)
		),
		\amp, 0.25
	).play;*/
	
	
	50.wait;
	
	
	Pbind(
		\instrument, \kalimbaAtmosphere,
		\dur, Pseq([60], 1),
		\channel, 0,
		\amp, 0.3,
		\buf, kbuf,
		\pos, 0.05,
		\density, 75
	).play;
	
	(2.5).wait;
	
	Pbind(
		\instrument, \kalimbaAtmosphere,
		\group, ~pitchShifter,
		\dur, Pseq([60], 1),
		\amp, 0.3,
		//\out, ~pitchShifterBus,
		\channel, 1,
		\buf, kbuf,
		\pos, 0.1,
		\density, 75
	).play;
	
	(5).wait;
	
	Pbind(
		\instrument, \hardSine,
		\freq, Pseq([500, 600, 750, 400], 2, 2),
		\dur, 0.75,
		\amp, 0.1
	).play;
	
	(6).wait;
	
	Pbind(
		\instrument, \hardSine,
		\freq, Pseq([400, 500, 600, 750], 3, 3),
		\dur, 0.5,
		\amp, 0.5
	).play;
	
	(7).wait;
	
	Pbind(
		\instrument, \hardSine,
		\freq, Pseq([400, 500, 600, 750], inf, 1),
		\out, ~pitchShifterBus,
		\dur, 0.25,
		\amp, 0.25
	).play;
	
}).play;
});