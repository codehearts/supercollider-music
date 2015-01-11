// 1m42s

"~/Music/senpro/samples/samples.sc".standardizePath.loadPaths;
"~/Music/senpro/methods/melody-playback.sc".standardizePath.loadPaths;
//"../samples/samples.sc".resolveRelative.loadPaths;
//"../methods/melody-playback.sc".resolveRelative.loadPaths;



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
}.send(s);

SynthDef(\beep) { |out=0, freq=440, atk=0.1, dec=0.15, amp=1, da=2|
	var fEnv  = EnvGen.kr(
					Env([freq-100, freq, freq-50], [atk, dec], [-2.5, 2.5]),
					1,
					doneAction: da
				),
		sine = Saw.ar(fEnv, amp),
		rvrb = FreeVerb.ar(sine, 0.5, 1, 0);
	
	Out.ar(out, rvrb);
}.send(s);

SynthDef(\beeper) { |out=0, freq=440, imp=2, amp=1|
	var sine = SinOsc.ar(freq, 0, Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp);
	Out.ar(out, sine);
}.send(s);

SynthDef(\sineburst) { |out=0, freq=100, imp=1, amp=1|
	var sine = SinOsc.ar(
		freq,
		0,
		EnvGen.kr(Env([amp, amp, 0], [0.1, 0]), 1, doneAction: 2)
	);
	Out.ar(out, sine);
}.send(s);



SynthDef(\colorDeco) { |out=0, dur=2.5, fadeDur=1, pImp=5 da=2, amp=1, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			LFNoise0.kr.(1), // trigger
			LFNoise1.kr.range(0.05, 0.25), // duration
			buf,
			LFNoise0.kr.range(1, XLine.kr(1, 5, dur)), // playback rate
			LFNoise0.kr.range(0, 1), // position
			1, // linear interpolation
			0, // panning
			-1 // grain envelope buffer
		),
		env = EnvGen.kr(Env([1, 1, 0], [dur, fadeDur]), 1, 1, doneAction: da),
		pan = Pan2.ar(samp*env, FSinOsc.kr(pImp), amp);
	
	Out.ar(out, pan);
}.send(s);

SynthDef(\hkBurst) { |out=0, dur=2.5, pb=4, rImp=50, fadeDur=1, pImp=5 da=2, amp=1, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			Impulse.kr(Stepper.kr(Impulse.kr(1), 1, 1, 10, 9)), // trigger
			Stepper.kr(Impulse.kr(rImp), 0, 0.1, 1, -1), // duration
			buf,
			pb, // playback rate
			0, // position
			1, // linear interpolation
			0, // panning
			-1 // grain envelope buffer
		),
		env = EnvGen.kr(Env([1, 1, 0], [dur, fadeDur]), 1, 1, doneAction: da),
		pan = Pan2.ar(samp*env, FSinOsc.kr(pImp), amp);
	
	Out.ar(out, pan);
}.send(s);










// Music starts here
Buffer.readChannel(s, a[2], channels: 0, action: { |ccbuf|
	"Code Couleur loaded".postln;

Buffer.readChannel(s, a[11], channels: 0, action: { |hk1buf|
	"Hugs & Kisses Excerpt 2 loaded".postln;

Routine({
var db = (),
	bp = (),
	hk = (),
	sb = (),
	be = ();

// Use this to skip blocks of audio!
/*if (false, {*/



Synth(\domobass, [\sFreq, 50, \eFreq, 250, \atk, 5, \dur, 10, \dec, 15, \amp, 0.25, \panDir, -1]);
10.wait;

Synth(\domobass, [\sFreq, 150, \eFreq, 50, \atk, 1.75, \dur, 1, \dec, 0.25, \amp, 0.5, \panDir, 1]);
1.wait;

Synth(\domobass, [\sFreq, 25, \eFreq, 250, \atk, 0.75, \dur, 0, \dec, 2, \amp, 0.5, \panDir, -1]);
2.wait;

Synth(\domobass, [\sFreq, 25, \eFreq, 650, \atk, 0.75, \dur, 0, \dec, 1, \amp, 0.35, \panDir, -1]);
1.wait;

Synth(\domobass, [\sFreq, 1000, \eFreq, 50, \atk, 1.75, \dur, 0, \dec, 0.25, \amp, 0.45, \panDir, 1]);
1.wait;

bp[0] = Synth(\beeper, [\freq, 175, \imp, 8, \amp, 0.5]);
(0.5).wait;

bp[1] = Synth(\beeper, [\out, 1, \freq, 400, \imp, 10, \amp, 0.5]);
(0.8).wait;

bp[1].free;
Synth(\domobass, [\sFreq, 25, \eFreq, 200, \atk, 0.5, \dur, 0, \dec, 0.75, \amp, 0.35, \panDir, 1]);
(3).wait;

bp[1] = Synth(\beeper, [\out, 1, \freq, 500, \imp, 10, \amp, 0.5]);
(0.75).wait;

bp[1].free;
Synth(\domobass, [\sFreq, 0, \eFreq, 150, \atk, 0.5, \dur, 0, \dec, 0.75, \amp, 0.35, \panDir, -1]);
1.wait;

bp[0].set(\freq, 75, \imp, 1, \amp, 1);
(2.5).wait;

Synth(\domobass, [\sFreq, 0, \eFreq, 75, \atk, 0.8, \dur, 0, \dec, 0.2, \amp, 0.5, \panDir, -1]);
1.wait;

bp[0].free;
Synth(\colorDeco, [\buf, ccbuf, \fadeDur, 0.25, \pImp, 15, \amp, 0.9]);
(1.5).wait;

hk[0] = Synth(\hkBurst, [\out, 1, \buf, hk1buf, \pb, 4]);
2.wait;

hk[1] = Synth(\hkBurst, [\out, 1, \buf, hk1buf, \pb, 3, \dur, 10, \amp, 0.5]);
2.wait;

hk[1].set(\out, [0, 1]);
6.wait;

hk[2] = Synth(\hkBurst, [\buf, hk1buf, \pb, 4.5, \rImp, 75, \dur, 10, \amp, 0.5]);
8.wait;

bp[2] = Synth(\beeper, [\out, 1, \freq, 100, \imp, 6, \amp, 0.5]);
bp[3] = Synth(\beeper, [\out, 1, \freq, 100, \imp, 1/3, \amp, 0.5]);
sb[0] = 175;
sb[1] = 0.2;
sb[2] = m.value(\sineburst, [
		[\freq, sb[0]],
		[\freq, sb[0]+25],
		[\freq, sb[0]+50],
		[\freq, sb[0]+100],
		[\freq, sb[0]+50],
		[\freq, sb[0]+25]
	],
	[sb[1], sb[1], sb[1], sb[1], sb[1], sb[1]]
);
(sb[1]*3).wait;

be[0] = sb[1]*6;
be[1] = m.value(\beep, [
		[\freq, 2000, \amp, 0.5],
		[\freq, 2000, \amp, 0.5, \out, 1],
		[\freq, 2000, \amp, 0.5],
		[\freq, 2000, \amp, 0.5, \out, 1],
		[\freq, 1750, \amp, 0.5],
		[\freq, 1750, \amp, 0.5, \out, 1],
		[\freq, 1500, \amp, 0.5],
		[\freq, 1250, \amp, 0.5, \out, 1]
	],
	[be[0], be[0], be[0], be[0], be[0], be[0], be[0], be[0]]
);
(be[0]*8).wait;

Synth(\beep, [\freq, 2000, \atk, 5, \dec, 5, \out, 1, \amp, 0.1]);
4.wait;

Synth(\beep, [\freq, 200, \atk, 5, \dec, 5, \amp, 0.05]);
10.wait;

bp[4] = Synth(\beeper, [\freq, 110, \imp, 4.75, \amp, 0.75]);
1.wait;

bp[5] = Synth(\beeper, [\out, 1, \freq, 100, \imp, 5.25, \amp, 0.75]);
4.wait;

sb[2].stop;
9.wait;

be[1].stop;
2.wait;

bp[6] = Synth(\beeper, [\out, 1, \freq, 200, \imp, 18, \amp, 0.5]);
1.wait;

bp[7] = Synth(\beeper, [\freq, 185, \imp, 12, \amp, 0.4]);
2.wait;

bp[6].set(\freq, 90);
3.wait;

bp[8] = Synth(\beeper, [\freq, 125, \imp, 6.25, \amp, 0.6]);
4.wait;

bp[9] = Synth(\beeper, [\out, 1, \freq, 135, \imp, 3.6, \amp, 0.65]);
2.wait;

bp[10] = Synth(\beeper, [\freq, 85, \imp, 22.5, \amp, 0.75]);
4.wait;

bp[2].free;
bp[3].free;
bp[4].free;
bp[5].free;
bp[6].free;
bp[7].free;
bp[8].free;
bp[9].free;
bp[10].free;
(0.1).wait;

bp[11] = Synth(\beeper, [\freq, 200, \imp, 1, \amp, 1]);
bp[12] = Synth(\beeper, [\out, 1, \freq, 200, \imp, 1, \amp, 1]);
(0.85).wait;

bp[13] = Synth(\beeper, [\out, 1, \freq, 400, \imp, 1, \amp, 0.25]);
(0.15).wait;

bp[11].free;
bp[12].free;
bp[13].free;



"It's Over".postln;
}).play;

});
});


"Now Playing";