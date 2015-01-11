(

// Simple synthesis
SynthDef(\simpsyn) { |out=0|
	var inst = SinOsc.ar(
			LFNoise0.kr(
				5,
				XLine.kr(450, 250, 10),
				500
			),
			0,
			Saw.ar(
				LFNoise0.kr(5, 250, 350),
				0.75
			)
		);
	Out.ar(out, inst);
}.send(s);

x = Synth(\simpsyn);

)

(

SynthDef(\twuu) { |out=0, freq=440, dur=1, dir=0|
	var line, base, inst;
	
	if (dir == 0, {
		line = Line.kr(1, -1, dur);
	}, {
		line = Line.kr(-1, 1, dur);
	});
	
	base = SinOsc.ar(XLine.kr(freq, 50, dur, doneAction: 2), 0, 1);
	inst = Pan2.ar(base, line);
	
	Out.ar(out, inst);
}.send(s);

Routine({
	loop({
		var dur = rrand(0.1, 0.4);
		Synth(\twuu, [\freq, rrand(250, 1000), \dur, dur, \dir, 2.rand]);
		
		dur.wait;
	});
}).play;

)

(

// Drumming
SynthDef(\snare) { |out=0, freq=1000, decay=0.25|
	var eAmp = EnvGen.kr(Env.perc(0.005, decay), 1, doneAction: 2),
		drum = SinOsc.ar(freq, 0, GrayNoise.ar(eAmp*0.15)) + WhiteNoise.ar(eAmp*0.5);

	Out.ar(out, drum);
}.send(s);

Routine({
	var dur = 0.25;
	
	loop({
		Synth(\twuu, [\freq, 150, \dur, dur]);
	
		dur.wait;
	
		Synth(\snare, [\out, 0, \freq, 1000]);
		Synth(\snare, [\out, 1, \freq, 0500]);
	
		dur.wait;
	});
}).play;

)

(

SynthDef(\simp2) { |out=0|
	var env  = EnvGen.kr(Env.new([0.2, 1, 0.5], [2.5, 1.5], [3, -2.5]), 1, doneAction: 2),
		inst = SinOsc.ar(env*1000, 0, FSinOsc.kr(env*10)) + Saw.ar(env*500, 0.25);
	
	Out.ar(out, inst);
}.play(s);

)

(

SynthDef(\simp3) { |out=0|
	var inst = SinOsc.ar(
		440,
		0,
		Impulse.kr(
			XLine.kr(160, 16, 5, doneAction: 2),
			LFNoise1.kr(4, 0, 1)
		)
	);
	
	Out.ar(out, inst);
}.play(s);

)

(

SynthDef(\bubbles) { |out=0, lf=150, hf=500|
	var base = SinOsc.ar(LFNoise0.kr(25, lf, hf), 0, FSinOsc.kr(10)),
		inst = Pan2.ar(base, FSinOsc.kr(2), 1);
	
	Out.ar(out, inst);
}.play(s);

)

(

SynthDef(\simp4) { |out=0, freq=500, att=1, dec=0.5, amp=1|
	var fEnv = EnvGen.kr(Env.sine(att, dec), 1, doneAction: 2),
		inst = SinOsc.ar(freq*fEnv, 0, amp);
	
	Out.ar(out, inst);
}.send(s);

Routine({
	var att = 0.5;
	Synth(\simp4, [\freq, 1000, \att, att, \dec, 0.5]);
	att.wait;
	
	att = 0.35;
	Synth(\simp4, [\freq, 1250, \att, att, \dec, 0.25]);
	att.wait;
	
	att = 0.75;
	Synth(\simp4, [\freq, 1500, \att, att, \dec, 1]);
	(0.4).wait;
	
	att = 0.65;
	Synth(\simp4, [\freq, 1400, \att, att, \dec, 1]);
	(0.35).wait;
	
	att = 0.55;
	Synth(\simp4, [\freq, 1300, \att, att, \dec, 1]);
	(0.3).wait;
	
	att = 0.45;
	Synth(\simp4, [\freq, 1200, \att, att, \dec, 1]);
	(0.25).wait;
	
	att = 0.35;
	Synth(\simp4, [\freq, 1100, \att, att, \dec, 1]);
	(0.2).wait;
	
	att = 0.25;
	Synth(\simp4, [\freq, 1000, \att, att, \dec, 1]);
	(0.15).wait;
	
	att = 0.15;
	Synth(\simp4, [\freq, 900, \att, att, \dec, 1]);
	(0.1).wait;
	
	att = 0.1;
	Synth(\simp4, [\freq, 800, \att, att, \dec, 1]);
	(0.05).wait;

	att = 0.05;
	Synth(\simp4, [\freq, 700, \att, att, \dec, 1]);
}).play;

)

// Steppers
(

SynthDef(\randbistep) { |out=0, imp=25, dur=1|
	var saw = Saw.ar(
			Stepper.kr(Impulse.kr(dur), 0, 6, 10, 1)*50,
			TIRand.kr(0, 1, Impulse.kr(imp))
		),
		sine = SinOsc.ar(
			Stepper.kr(Impulse.kr(dur), 0, 6, 10, 1)*100,
			0,
			TIRand.kr(0, 1, Impulse.kr(imp))
		);
	
	Out.ar(out, sine+saw);
}.play(s);

)

(

SynthDef(\bistep) { |out=0, imp=20, dur=1|
	var saw = Saw.ar(
			Stepper.kr(Impulse.kr(dur), 0, 6, 10, 1)*50,
			Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)
		),
		sine = SinOsc.ar(
			Stepper.kr(Impulse.kr(dur), 0, 6, 10, 1)*100,
			0,
			Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)
		);
	
	Out.ar(out, sine+saw);
}.play(s);

)

(

// Panning stpper
// Sounds good with pImp set to aImp or fImp!
SynthDef(\panbistep) { |out=0, aImp=25, fImp=10, pImp=25|
	var saw = Saw.ar(
			Stepper.kr(Impulse.kr(fImp), 0, 6, 10, 1)*50,
			Stepper.kr(Impulse.kr(aImp), 0, 0, 1, 1)
		),
		sine = SinOsc.ar(
			Stepper.kr(Impulse.kr(fImp), 0, 6, 10, 1)*100,
			0,
			Stepper.kr(Impulse.kr(aImp), 0, 0, 1, 1)
		),
		pan = Pan2.ar(sine+saw, Stepper.kr(Impulse.kr(pImp), 0, -1, 1, 2));
	
	Out.ar(out, pan);
}.play(s);

)