// 1m31s

"~/Music/supercollider-music//samples/samples.sc".standardizePath.loadPaths;
//"../samples/samples.sc".resolveRelative.loadPaths;



// Samples
SynthDef(\atmos) { |out=0, gate=1, fadeDur=2.5, totalDur=5, startDur=0.005, endDur=1, dense=250, pos=0, da=2, buf|
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
		),
		env = EnvGen.kr(Env.cutoff(fadeDur, 1), gate, doneAction: da) * samp;

	Out.ar(out, env);
}.send(s);

SynthDef(\kring) { |out=0, dur=3, rate=1, pos=0, buf|
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
		);

	Out.ar(out, samp);
}.send(s);

SynthDef(\babum) { |bus=0, imp=25, buf|
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
		pan = Pan2.ar(samp, FSinOsc.kr(2), 0.5);

	Out.ar(bus, pan);
}.send(s);

SynthDef(\sled) { |out=0, dur=10, gate=1, fadeDur=2.5, da=2, buf|
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
		env = EnvGen.kr(Env.cutoff(fadeDur, 1), gate, doneAction: da) * samp;

	Out.ar(out, env);
}.send(s);

// Kalimba Forest
SynthDef(\forest) { |bus=0, dense=150, vary=10, gate=1, amp=1, fadeDur=2.5, da=2, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			LFNoise0.kr(dense), // trigger
			LFNoise1.kr.range(0.1, vary*0.1), // duration
			buf,
			LFNoise0.kr.range(1, 1.025), // playback rate
			LFNoise1.kr.range(0, 1), // position
			2, // linear interpolation
			0, // panning
			-1 // grain envelope buffer
		),
		env = EnvGen.kr(Env.cutoff(fadeDur, 1), gate, doneAction: da) * samp;

	Out.ar(bus, env*amp);
}.send(s);


// Synthdefs
SynthDef(\bass) { |out=0, freq=150, dur=1|
	var inst = SinOsc.ar(XLine.kr(freq, 50, dur, doneAction: 2), 0, 1);

	Out.ar(out, inst);
}.send(s);

SynthDef(\snare) { |out=0, freq=1000, decay=0.25|
	var eAmp = EnvGen.kr(Env.perc(0.005, decay), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, GrayNoise.ar(eAmp*0.15)) + WhiteNoise.ar(eAmp*0.5);

	Out.ar(out, drum);
}.send(s);

SynthDef(\bell) { |out=0, freq=800, resFreq=2000, attack=0.005, decay=0.75, resDecay=2|
	var eAmp = EnvGen.kr(Env.perc(attack, decay), 1, doneAction: 2),
		base = SinOsc.ar(freq, pi, eAmp*0.25) + Saw.ar(freq/2, eAmp*0.005),
		ring = Ringz.ar(base, resFreq, resDecay),
		rvrb = FreeVerb.ar(ring, 0.3, 1, 1);

	Out.ar(out, rvrb);
}.send(s);


// Effect synths
SynthDef(\LRpan) { |bus, dur=5, level=1, da=2|
	Out.ar(0, Pan2.ar(In.ar(bus), Line.kr(-1, 1, dur, doneAction: da), level));
}.send(s);

SynthDef(\RLpan) { |bus, dur=5, level=1, da=2|
	Out.ar(0, Pan2.ar(In.ar(bus), Line.kr(1, -1, dur, doneAction: da), level));
}.send(s);

SynthDef(\fadeOut) { |bus, dur=1, da=2|
	// @todo No idea how to make this work
}.send(s);





// Music begins here
Buffer.readChannel(s, a[5], channels: 0, action: { |kbuf|
	"Kalimbas loaded".postln;

Buffer.readChannel(s, a[1], channels: 0, action: { |jbuf|
	"City of Julie loaded".postln;

Buffer.readChannel(s, a[3], channels: 0, action: { |dbuf|
	"Denjiha loaded".postln;

	r = Routine({
		var drumTempo = 1,
			atmos1,
			atmos2,
			atmosPan,
			atmosBus,
			bassR,
			snareR,
			sledL,
			sledR,
			effPan,
			effBus,
			effPan2,
			effBus2,
			babble,
			babbleSyn,
			forest,
			forest2;


"Ready to go!".postln;


// Use this to skip blocks of audio!
/*if (false, {*/


atmos1 = Synth(\atmos, [
	\buf,      kbuf,
	\totalDur, 5,
	\startDur, 0.005,
	\endDur,   0.5,
	\pos,      0.05,
	\dense,    75
]);
(2.5).wait;

atmos2 = Synth(\atmos, [
	\out,      1,
	\buf,      kbuf,
	\totalDur, 5,
	\startDur, 0.005,
	\endDur,   0.5,
	\pos,      0.1,
	\dense,    75
]);
(5).wait;

atmosBus = Bus.control(s, 2);
atmosPan = Synth(\atmos, [
	\out,      atmosBus,
	\buf,      kbuf,
	\totalDur, 5,
	\startDur, 0.05,
	\endDur,   0.9,
	\pos,      0.14,
	\dense,    75
]);
Synth.after(atmosPan, \LRpan, [\bus, atmosBus, \dur, 5, \da, 0]);

Synth(\kring, [
	\buf, kbuf,
	\dur, 3.75,
	\pos, 0.09
]);
(1.15).wait;

Synth(\kring, [
	\out,  1,
	\buf,  kbuf,
	\dur,  1.75,
	\pos,  0.09,
	\rate, 1.1
]);
(0.25).wait;

Synth(\kring, [
	\out,  1,
	\buf,  kbuf,
	\dur,  2.75,
	\pos,  0.09,
	\rate, 1.25
]);
(2.75).wait;

bassR = Routine({
	var bassDur = 0.25,
		bassBus = Bus.control(s, 2),
		bassSyn;

	loop({
		4.do({
			bassSyn = Synth.new(\bass, [\out, bassBus, \freq, 200, \dur, bassDur]);
			Synth.after(
				bassSyn,
				\LRpan,
				[\bus, bassBus, \dur, bassDur]
			);
			drumTempo.wait;

			bassSyn = Synth.new(\bass, [\out, bassBus, \freq, 200, \dur, bassDur]);
			Synth.after(
				bassSyn,
				\RLpan,
				[\bus, bassBus, \dur, bassDur]
			);
			drumTempo.wait;
		});

		// Lower frequency
		bassSyn = Synth.new(\bass, [\out, bassBus, \freq, 150, \dur, bassDur]);
		Synth.after(
			bassSyn,
			\LRpan,
			[\bus, bassBus, \dur, bassDur]
		);
		drumTempo.wait;

		bassSyn = Synth.new(\bass, [\out, bassBus, \freq, 150, \dur, bassDur]);
		Synth.after(
			bassSyn,
			\RLpan,
			[\bus, bassBus, \dur, bassDur]
		);
		drumTempo.wait;
	});
}).play;
((6*drumTempo) + (drumTempo/2)).wait;

snareR = Routine({
	loop({
		// Single snare (three times)
		3.do({
			Synth(\snare, [\out, 0, \freq, 1000]);
			Synth(\snare, [\out, 1, \freq, 0500]);
			drumTempo.wait;
		});

		// Double snare
		Synth(\snare, [\out, 0, \freq, 1050]);
		Synth(\snare, [\out, 1, \freq, 0550]);
		(drumTempo/4).wait;

		Synth(\snare, [\out, 0, \freq, 1000]);
		Synth(\snare, [\out, 1, \freq, 0500]);
		(drumTempo/4).wait;

		(drumTempo/2).wait;
	});
}).play;
(4*drumTempo).wait;

babble = Routine({
	loop({
		babbleSyn = Synth(\babum, [\buf, jbuf, \imp, 10]);
		"Julie?".postln;
		4.wait;

		babbleSyn.free;
		"...".postln;
		1.wait;
	});
});
babble.play;
5.wait;

// Fade out the panning Kalimba atmosphere
atmosPan.set(\gate, 0);

// Start the sled atmosphere
sledL = Synth(\sled, [
	\buf,     dbuf,
	\fadeDur, 5
]);
sledR = Synth(\sled, [
	\out,     1,
	\buf,     dbuf,
	\fadeDur, 5
]);
(7.5).wait;

effBus = Bus.control(s, 2);
effPan = Synth(\bass, [\out, effBus, \freq, 1000, \dur, 5]);
Synth.after(
	effPan,
	\LRpan,
	[\bus, effBus, \dur, 5]
);
(2.75).wait;

effBus2 = Bus.control(s, 2);
effPan2 = Synth(\bass, [\out, effBus2, \freq, 500, \dur, 2.5]);
Synth.after(
	effPan2,
	\RLpan,
	[\bus, effBus2, \dur, 2.5]
);
(4.75).wait;

babble.stop;
babbleSyn.free;
"Julie stopped".postln;

Synth(\bell, [\freq, 785, \decay, 3.5]);
3.wait;

Synth(\bell, [\out, 1, \freq, 850, \decay, 3]);
2.wait;

Synth(\bell, [\freq, 975, \decay, 1.5]);
(0.95).wait;

Synth(\bell, [\out, 1, \freq, 925, \decay, 1.5]);
(0.95).wait;

Synth(\bell, [\freq, 900, \decay, 1.5]);
(0.95).wait;

Synth(\bell, [\out, 1, \freq, 850, \decay, 1.5]);
(0.95).wait;

Synth(\bell, [\freq, 825, \decay, 4]);
Synth(\bell, [\out, 1, \freq, 650, \decay, 2.5]);
(2.5).wait;

// Fade out the sled atmosphere
sledL.set(\gate, 0);
(2.5).wait;
sledR.set(\gate, 0);

forest = Synth(\forest, [\dense, 15, \amp, 0.25, \fadeDur, 7.5]);
3.wait;

forest.set(\dense, 40);
forest2 = Synth(\forest, [\bus, 1, \dense, 25, \vary, 15, \amp, 0.25, \fadeDur, 1]);
3.wait;

forest.set(\dense, 75, \vary, 10, \amp, 0.5);
forest2.set(\amp, 0.5);
6.wait;

atmos1.set(\gate, 0);
(2.5).wait;

atmos2.set(\gate, 0);
(1.5).wait;

snareR.stop;
4.wait;

bassR.stop;
forest.set(\amp, 0.75);
forest2.set(\amp, 0.75);
4.wait;

forest.set(\gate, 0);
(9.5).wait;

forest2.set(\gate, 0);
1.wait;



"It's Over".postln;
	}).play;

});
});
});