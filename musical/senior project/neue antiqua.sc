"~/Music/SC/samples/samples.sc".standardizePath.loadPaths;

SynthDef(\kring) { |out=0, dur=3, rate=1, pos=0, gate=1, amp=1, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			Impulse.ar(XLine.kr(100, 10, dur)), // trigger
			XLine.kr(0.1, 1.5, dur, doneAction: 2), // duration
			buf,
			rate, // playback rate
			pos, // position
			1, // no interpolation
			0, // panning
			-1 // grain envelope buffer
		),
		env = EnvGen.kr(Env([amp, amp, 0], [dur*0.75, dur*0.25]), gate, doneAction: 2);
	
	Out.ar(out, samp*env);
}.send(s);

SynthDef(\katmos) { |out=0, gate=1, fadeDur=2.5, totalDur=5, startDur=0.005, endDur=1, dense=250, pos=0, amp=1, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			LFNoise0.kr(dense), // trigger
			XLine.kr(startDur, endDur, totalDur), // duration
			buf,
			1, // playback rate
			pos, // position
			2, // linear interpolation
			0, // panning
			-1 // grain envelope buffer
		)*amp,
		env = EnvGen.kr(Env.cutoff(fadeDur, 1), gate, doneAction: 2)*samp;
	
	Out.ar(out, env);
}.send(s);

SynthDef(\mud) { |out=0, gate=1, fade=1, density=25, amp=1, buf|
	var chan = buf.numChannels,
		samp = GrainBuf.ar(
			chan, // number of channels
			LFNoise0.kr(density), // trigger
			LFNoise0.kr.range(0.05, 0.15), // duration
			buf,
			0.5, // playback rate
			LFNoise0.kr.range(0,1), // position
			2, // interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env([0, 1, 0.5], [0.1, 0.9], [-5, 5]).discretize,
				chan
			)
		) * amp,
		env  = EnvGen.kr(Env.cutoff(fade, 1), gate, doneAction: 2) * samp,
		pan2 = Pan2.ar(env, 0);
	
	Out.ar(out, pan2);
}.send(s);

SynthDef(\leaves) { |out=0, gate=1, fadeIn=1, fadeOut=1, rate=4, density=25, amp=1, buf|
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
		) * XLine.kr(0.005, amp, fadeIn),
		env  = EnvGen.kr(Env.cutoff(fadeOut, 1), gate, doneAction: 2) * samp,
		rvrb = FreeVerb2.ar(env, env, 0.5, 1, 0),
		pan2 = Pan2.ar(rvrb, LFNoise0.kr(density, -1, 2)-1);
	
	Out.ar(out, pan2);
}.send(s);

SynthDef(\dreamBuf) { |out=0, fadeIn=1, sustain=1, fadeOut=1, pan=0, amp=1, buf|
	var chan = buf.numChannels,
		samp = GrainBuf.ar(
			chan, // number of channels
			1, // trigger
			fadeIn+sustain+fadeOut, // duration
			buf,
			1, // playback rate
			0, // position
			2, // interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([0, 1, 1, 0], [0.25, 0.5, 0.25], 'linear', nil, 10).discretize,
				chan
			)
		),
		env  = EnvGen.kr(Env([0, amp, amp, 0], [fadeIn, sustain, fadeOut+5]), 1, doneAction: 2),
		rvrb = FreeVerb2.ar(samp*env, samp*env, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);
	
	Out.ar(out, pan2);
}.send(s);

SynthDef(\playBuf) { |out=0, pos=0, dur=1, pan=0, amp=1, buf|
	var samp = GrainBuf.ar(
			buf.numChannels,
			1, // trigger
			dur,
			buf,
			1, // playback rate
			pos,
			2, // interpolation
			0, // panning
			-1
		),
		env  = EnvGen.kr(Env([amp, amp], dur), 1, doneAction: 2),
		pan2 = Pan2.ar(samp*env, pan);
	
	Out.ar(out, pan2);
}.send(s);



SynthDef(\sineHumm) { |out=0, freq=440, amp=1, pan=0|
	var sine = SinOsc.ar(freq, 0, Saw.kr(1)*amp),
		pan2 = Pan2.ar(sine, pan);
	
	Out.ar(out, pan2);
}.add;

SynthDef(\hardSine) { |out=0, freq=440, gate=1, amp=1|
	var env  = EnvGen.kr(Env.cutoff(0), gate, doneAction: 2),
		aEnv = EnvGen.kr(Env([0, amp, amp/2], [0.15, 0.1], [5, -10])),
		sine = SinOsc.ar(freq, 0, aEnv),
		pan  = Pan2.ar(sine*env, 0, FSinOsc.kr(2));
	
	Out.ar(out, pan);
}.add;

SynthDef(\dripper) { |out=0, freq=1000, sImp=1, eImp=10, dur=4, atk=0.01, dec=0.1, pan=0, amp=1|
	var sine  = SinOsc.ar(freq, 0, amp),
		decay = Decay2.ar(Impulse.ar(XLine.kr(sImp, eImp, dur)), atk, dec, sine),
		rvrb  = FreeVerb.ar(decay, 0.5, 1, 1),
		pan2   = Pan2.ar(rvrb, pan);
	
	Out.ar(out, pan2);
}.add;

SynthDef(\square) { |out=0, freq=440, amp=0.25, gate=1|
	var env = EnvGen.kr(Env.cutoff(0, amp), gate, doneAction: 2),
		sqr = Pulse.ar(freq, 0.5, amp)*env;
	
	Out.ar(out, sqr);
}.add;

SynthDef(\squareBell) { |out=0, freq=440, amp=0.25, gate=1, sustain=1, curve=0|
	var env = EnvGen.kr(Env.asr(0, amp, sustain, curve), gate, doneAction: 2),
		sqr = Pulse.ar(freq, 0.5, amp)*env;
	
	Out.ar(out, sqr);
}.add;

SynthDef(\squareFade) { |out=0, freq=440, amp=0.25, sustain=1, curve=0|
	var env  = EnvGen.kr(Env([amp/2, amp, amp/2], [0.1, sustain-0.1], curve), 1, doneAction: 2),
		trem = SinOsc.kr(1),
		sqr  = Pulse.ar(freq, 0.5, (amp*0.75)+(abs(trem)*(amp*0.25)))*env,
		pan  = Pan2.ar(sqr, Line.kr(-1, 1, sustain));
	
	Out.ar(out, pan);
}.add;

SynthDef(\squareFadeReverb) { |out=0, freq=440, amp=0.25, sustain=1, curve=0|
	var env  = EnvGen.kr(Env([amp/2, amp, amp/2], [0.1, sustain-0.1], curve), 1, doneAction: 2),
		trem = SinOsc.kr(1),
		sqr  = Pulse.ar(freq, 0.5, (amp*0.75)+(abs(trem)*(amp*0.25)))*env,
		rvrb = FreeVerb.ar(sqr, 0.75, 1, 0.5),
		pan  = Pan2.ar(rvrb, Line.kr(-1, 1, sustain));
	
	Out.ar(out, pan);
}.add;

SynthDef(\grainUp) { |out=0, freq=440, sustain=5, amp=1|
	var aEnv = EnvGen.kr(Env([0, amp, amp, 0, 0], [sustain*0.65, sustain*0.15, sustain/4, sustain/4], [2.5, -2.5]), 1, doneAction: 2),
		sine = SinOsc.ar(freq, 0, Saw.kr(XLine.kr(25, 75, sustain)))*aEnv,
		rvrb = FreeVerb.ar(sine, 1, 1, 1);
	
	Out.ar(out, rvrb);
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
		drum = SinOsc.ar(freq, 0, WhiteNoise.ar(aEnv*0.15)) + WhiteNoise.ar(aEnv*0.5),
		rvrb = FreeVerb.ar(drum, 0.25, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

/*SynthDef(\bump) { |out=0, freq=1000, decay=0.25, pan=0|
	var aEnv = EnvGen.kr(Env.perc(0.005, decay), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, GrayNoise.ar(aEnv*0.15)) + BrownNoise.ar(aEnv*0.5),
		rvrb = FreeVerb.ar(drum, 0.25, 1, 0.75),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.play(s);*/



Buffer.readChannel(s, a[5], channels: 0, action: { |kbuf|
	"Kalimbas loaded".postln;

Routine({
	var slowestBase,
		background,
		weakMelody,
		weakAccomp,
		slowBase,
		fastBass,
		highBass,
		dripper,
		krings,
		melody,
		accomp,
		lKring,
		rKring,
		atmos1,
		atmos2,
		leaves,
		snare,
		base,
		bass,
		grup,
		mud;
	
	lKring = { |amp=0.1|
		Routine({
			Synth(\kring, [
				\buf, kbuf,
				\dur, 3.75,
				\pos, 0.09,
				\amp, amp
			]);
		}).play;
	};
	
	rKring = { |amp=0.1|
		Routine({
			Synth(\kring, [
				\out,  1,
				\buf,  kbuf,
				\dur,  1.75,
				\pos,  0.09,
				\rate, 1.1,
				\amp, amp/2
			]);
			(0.25).wait;

			Synth(\kring, [
				\out,  1,
				\buf,  kbuf,
				\dur,  2.75,
				\pos,  0.09,
				\rate, 1.25,
				\amp, amp
			]);
		}).play;
	};
	
	krings = { |amp=0.1|
		Routine({
			lKring.value(amp);
			(1.15).wait;
			rKring.value(amp);
		}).play;
	};
	
	atmos1 = { |amp=0.1, sustain=11, fade=11|
		Routine({
			var atmos = Synth(\katmos, [
				\buf,      kbuf,
				\totalDur, 5,
				\startDur, 0.005,
				\endDur,   0.5,
				\fadeDur,  fade,
				\pos,      0.05,
				\dense,    75,
				\amp,      amp
			]);
			
			sustain.wait;
			
			atmos.set(\gate, 0);
		}).play;
	};
	
	atmos2 = { |amp=0.1, sustain=11, fade=11|
		Routine({
			var atmos = Synth(\katmos, [
				\out,      1,
				\buf,      kbuf,
				\totalDur, 5,
				\startDur, 0.005,
				\endDur,   0.5,
				\fadeDur,  fade,
				\pos,      0.1,
				\dense,    75,
				\amp,      amp
			]);
			
			sustain.wait;
			
			atmos.set(\gate, 0);
		}).play;
	};
	
	
	
	slowestBase = Pbind(
		\instrument, \hardSine,
		\freq, Pseq([500, 600, 750, 400], 2, 3),
		\dur, 0.75,
		\amp, 0.05
	).play;
	
	(6).wait;
	
	background = Synth(\sineHumm, [\amp, 0.05]);
	slowestBase.stop;
	slowBase = Pbind(
		\instrument, \hardSine,
		\freq, Pseq([500, 600, 750, 400], 6, 3),
		\dur, 0.5,
		\amp, 0.05
	).play;
	
	(6).wait;
	
	dripper = Synth(\dripper, [\amp, 0.05, \eImp, 20, \pan, 0]);
	
	(6.25).wait;
	
	krings.value(0.1);
	atmos1.value(0.1, 39.25, 11);
	
	(0.25).wait;
	
	slowBase.stop;
	base = Pbind(
		\instrument, \hardSine,
		\freq, Pseq([400, 500, 600, 750], inf, 1),
		\dur, 0.25,
		\amp, 0.1
	).play;
	
	(2).wait;
	
	atmos2.value(0.2, 41, 7);
	
	grup = Pbind(
		\instrument, \grainUp,
		\freq, Pseq([250, 300, 400, 550], inf),
		\out, Pseq([0, 1], inf),
		\dur, 8,
		\legato, 0.65,
		\amp, 0.3
	).play;
	
	(4).wait;
	
	mud = Synth(\mud, [\buf, kbuf, \amp, 0.075]);
	
	(10).wait;
	
	bass = Pbind(
		\instrument, \bass,
		\freq, Prand([140, 150, 160], inf),
		\dur, 1,
		\legato, 0.25,
		\amp, 0.13
	).play;
	
	(0.5).wait;
	
	"Possible noise burst coming up".postln;
	
	snare = Pbind(
		\instrument, \snare,
		\freq, Prand([1075, 1100, 1125], inf),
		\dur, Pseq([1, 1, 1, 0.4, 0.6, 1, 1, 1, 0.04, 0.04, 0.32, 0.6], inf),
		\amp, 0.15
	).play;
	
	(7.5).wait;
	
	bass.stop;
	
	fastBass = Pbind(
		\instrument, \bass,
		\freq, Prand([140, 150, 160], inf),
		\dur, 0.5,
		\legato, 0.5,
		\amp, 0.13
	).play;
	
	(4).wait;
	
	dripper.set(\amp, 0.025);
	weakMelody = Pbind(
		\instrument, \squareFadeReverb,
		\freq, Pseq([600, 400, 450, 500, 790, 500, 600, 450], inf),
		\dur,  Pseq([3, 0.25, 0.25, 0.25, 0.25, 3, 1, 3], inf),
		\legato, 1,
		\amp, 0.1
	).play;
	
	// Atmosphere fades out here
	
	(22).wait;
	
	dripper.free;
	weakMelody.stop;
	snare.stop;
	fastBass.stop;
	
	(0.5).wait;
	
	bass.reset;
	bass.play;
	
	(8).wait;
	
	bass.stop;
	grup.stop;
	
	atmos1.value(0.15, 39, 7);
	
	(2).wait;
	
	atmos2.value(0.15, 33, 11);
	
	(10).wait;
	
	weakMelody.reset;
	weakMelody.play;
	
	(8).wait;
	
	weakAccomp = Pbind(
		\instrument, \square,
		\out, 1,
		\freq, Pseq([250, 300, 400, 600, 300], inf, 3),
		\dur, Pseq([3, 3, 1, 3, 1], inf),
		\legato, 1,
		\amp, 0.075
	).play;
	
	(11).wait;
	
	weakMelody.stop;
	weakAccomp.stop;
	
	// Atmosphere fades out here
	
	(8).wait;
	
	highBass = Pbind(
		\instrument, \bass,
		\freq, Prand([210, 225, 240], inf),
		\dur, 1,
		\legato, 0.25,
		\amp, 0.2
	).play;
	
	"Possible noise burst coming up".postln;
	
	(4).wait;
	
	melody = Pbind(
		\instrument, \squareFade,
		\freq, Pseq([600, 400, 450, 500, 790, 500, 600, 450], inf),
		\dur,  Pseq([3, 0.25, 0.25, 0.25, 0.25, 3, 1, 3], inf),
		\legato, 1,
		\amp, 0.15
	).play;
	
	(0.5).wait;
	
	snare.reset;
	snare.play;
	
	(7.25).wait;
	
	krings.value(0.25);
	highBass.stop;
	
	(0.25).wait;
	
	accomp = Pbind(
		\instrument, \square,
		\out, 1,
		\freq, Pseq([250, 300, 400, 600, 300], inf, 3),
		\dur, Pseq([3, 3, 1, 3, 1], inf),
		\legato, 1,
		\amp, 0.15
	).play;
	
	leaves = Synth(\leaves, [\buf, kbuf, \fadeIn, 4, \fadeOut, 4, \amp, 0.1, \rate, 4]);
	
	"Possible noise burst coming up".postln;
	
	(1).wait;
	
	atmos1.value(0.3, 38, 1);
	
	(2).wait;
	
	atmos2.value(0.3, 38, 1);
	
	(19).wait;
	
	leaves.set(\rate, 4.5, \amp, 0.15, \density, 30);
	
	(4).wait;
	
	leaves.set(\rate, 3, \amp, 0.2, \density, 35);
	
	(4).wait;
	
	leaves.set(\rate, 4, \amp, 0.25, \density, 40);
	
	(4).wait;
	
	leaves.set(\gate, 0);
	Synth(\dreamBuf, [\buf, kbuf, \fadeIn, 4, \sustain, 2, \fadeOut, 4, \amp, 0.05]);
	
	(8).wait;
	
	mud.free;
	Synth(\dreamBuf, [\buf, kbuf, \fadeIn, 4, \sustain, 2, \fadeOut, 4, \amp, 0.1]);
	
	(7).wait;
	base.stop;
	melody.stop;
	accomp.stop;
	
	Synth(\playBuf, [\buf, kbuf, \pos, 0.075, \dur, 3, \amp, 0.35]);
	
	(3).wait;
	
	"It's Over".postln;
}).play;

});

"Now Playing";

/*more Routines
less the number of synthdefs
think about golden ratio, fibonacci series
look at GUI
microsound*/