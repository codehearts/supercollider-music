// 1m57s

SynthDef(\sineBass) { |out=0, freq=100, imp=1, amp=1|
	var sine = SinOsc.ar(
		freq,
		0,
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	);
	Out.ar(out, sine);
}.send(s);

SynthDef(\highPulse) { |freq=1500, atk=0.25, dec=0.25, imp=1, amp=0.5, da=2, out=0|
	var sine = SinOsc.ar(
		freq,
		0,
		EnvGen.kr(
			Env(
				[0, amp, 0],
				[atk, dec]
			),
			Impulse.kr(imp)
		)
	);
	Out.ar(out, sine);
}.send(s);

SynthDef(\singleHighPulse) { |freq=1500, atk=0.25, dec=0.25, maxAmp=0.05, minAmp=0.025, da=2, out=0|
	var sine = SinOsc.ar(
		freq,
		0,
		EnvGen.kr(
			Env(
				[0, maxAmp, minAmp],
				[atk, dec]
			)
		)
	);
	Out.ar(out, sine);
}.send(s);

SynthDef(\wnoisePulse) { |out=0, imp=2, amp=0.1, gate=1, fadeDur=1, fadeCurve=1, da=2|
	var noise = WhiteNoise.ar(
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	),
	env = EnvGen.kr(Env.cutoff(fadeDur, fadeCurve), gate, doneAction: da)*noise;
	
	Out.ar(out, env);
}.send(s);

SynthDef(\panWnoisePulse) { |imp=2, amp=0.1, gate=1, fadeDur=1, fadeCurve=1, da=2|
	var noise = WhiteNoise.ar(
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	),
	env = EnvGen.kr(Env.cutoff(fadeDur, fadeCurve), gate, doneAction: da)*noise;
	
	Out.ar(Stepper.kr(Impulse.kr(2*imp), 0, 0, 1, 1), env);
}.send(s);

SynthDef(\pnoisePulse) { |out=0, imp=2, amp=0.5, gate=1, fadeDur=1, fadeCurve=1, da=2|
	var noise = PinkNoise.ar(
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	),
	env = EnvGen.kr(Env.cutoff(fadeDur, fadeCurve), gate, doneAction: da)*noise;
	
	Out.ar(out, env);
}.send(s);

SynthDef(\panPnoisePulse) { |imp=2, amp=0.5, gate=1, fadeDur=1, fadeCurve=1, da=2|
	var noise = PinkNoise.ar(
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	),
	env = EnvGen.kr(Env.cutoff(fadeDur, fadeCurve), gate, doneAction: da)*noise;
	
	Out.ar(Stepper.kr(Impulse.kr(2*imp), 0, 0, 1, 1), env);
}.send(s);

SynthDef(\bnoisePulse) { |out=0, imp=2, amp=0.25, gate=1, fadeDur=1, fadeCurve=1, da=2|
	var noise = BrownNoise.ar(
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	) + Dust.ar(
		Stepper.kr(
			Impulse.kr(imp), 0, 2, 20000, 100
		),
		Stepper.kr(
			Impulse.kr(imp), 0, 0, 1, 1
		)*amp*0.75
	),
	env = EnvGen.kr(Env.cutoff(fadeDur, fadeCurve), gate, doneAction: da)*noise;
	
	Out.ar(out, env);
}.send(s);

SynthDef(\panBnoisePulse) { |imp=2, amp=0.25, gate=1, fadeDur=1, fadeCurve=1, da=2|
	var noise = BrownNoise.ar(
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	) + Dust.ar(
		Stepper.kr(
			Impulse.kr(imp*2), 0, 2, 20000, 100
		),
		Stepper.kr(
			Impulse.kr(imp), 0, 0, 1, 1
		)*amp*0.75
	),
	env = EnvGen.kr(Env.cutoff(fadeDur, fadeCurve), gate, doneAction: da)*noise;
	
	Out.ar(Stepper.kr(Impulse.kr(2*imp), 1, 0, 1, -1), env);
}.send(s);

SynthDef(\panBiStep) { |out=0, fMin=600, fMax=1000, step=100, aImp=25, fImp=10, pImp=25, amp=1|
	var saw = Saw.ar(
			Stepper.kr(Impulse.kr(fImp), 0, fMin, fMax, step)/2,
			Stepper.kr(Impulse.kr(aImp), 0, 0, 1, 1)
		),
		sine = SinOsc.ar(
			Stepper.kr(Impulse.kr(fImp), 0, fMin, fMax, step),
			0,
			Stepper.kr(Impulse.kr(aImp), 0, 0, 1, 1)
		),
		pan = Pan2.ar(sine+saw, Stepper.kr(Impulse.kr(pImp), 0, -1, 1, 2));
	
	Out.ar(out, pan*amp);
}.send(s);



SynthDef(\fadeIn) { |bus, dur=5|
	var env = EnvGen.ar(Env([0, 1], [dur]), 1, 1);
	Out.ar(0, In.ar(bus)*env);
}.send(s);










// Music starts here
Routine({
var hpit  = (),
	hpul  = (),
	noise = (),
	sbass = (),
	step  = ();

// Use this to skip blocks of audio!
//if (false, {



/*
4500Hz left channel
Loops every 6s
*/
hpul[1] = Synth(\highPulse, [\freq, 4500, \atk, 1, \dec, 1.5, \imp, 0.1667, \amp, 0.05]);
7.wait;

/*
Panning brown
Loops every 2s
*/
noise[1] = Synth(\panBnoisePulse, [\imp, 1, \amp, 0.4]);
/*
6500Hz right channel
Loops every 8s
*/
hpul[2] = Synth(\highPulse, [\out, 1, \freq, 6500, \atk, 1.5, \dec, 2, \imp, 0.125, \amp, 0.025]);
3.wait;

/*
10000Hz constant left channel
*/
hpit[1] = Synth(\singleHighPulse, [\freq, 10000, \maxAmp, 0.05, \minAmp, 0.01, \atk, 0.5, \dec, 5]);
/*
Right channel white
Loops every 4s
Reserves 2, 3
*/
noise[2] = Routine({
	loop({
		noise[3] = Synth(\wnoisePulse, [\out, 1, \imp, 2]);
		(0.5).wait;
		noise[3].free;
		(3.5).wait;
	});
}).play;
4.wait;

noise[2].stop;

/*
15000Hz constant left channel
*/
hpit[2] = Synth(\singleHighPulse, [\out, 1, \freq, 15000, \maxAmp, 0.1, \minAmp, 0.025, \atk, 0.25, \dec, 2.5]);
/*
17500Hz right channel
Loops every 10s
*/
hpul[3] = Synth(\highPulse, [\out, 1, \freq, 15000, \atk, 2, \dec, 0.5, \imp, 0.1, \amp, 0.1]);
/*
Panning white
Loops every 2s
Reserves 4, 5
*/
noise[4] = Routine({
	loop({
		noise[5] = Synth(\panWnoisePulse, [\imp, 2]);
		(0.5).wait;
		noise[5].free;
		(3.5).wait;
	});
}).play;
2.wait;
noise[2].reset.play;
4.wait;

/*
Loops every 2s
*/
sbass[1] = Synth(\sineBass, [\freq, 200, \imp, 1, \amp, 0.5]);
1.wait;

/*
Loops every 1/3s
*/
sbass[2] = Synth(\sineBass, [\freq, 100, \imp, 6, \amp, 0.5]);
6.wait;

/*
Right channel sineBass
Loops every 2s
Reserves 3, 4
*/
sbass[4] = Routine({
	loop({
		sbass[3] = Synth(\sineBass, [\out, 1, \freq, 125, \imp, 3, \amp, 0.75]);
		1.wait;
		sbass[3].free;
		1.wait;
	});
}).play;
4.wait;

sbass[1].free;
4.wait;

sbass[2].free;
2.wait;

noise[1].set(\gate, 0);
noise[4].stop;
8.wait;

/*
Panning stepper
Fades in
*/
step[1] = Bus.control(s, 2);
step[2] = Synth(\panBiStep, [\out, step[1], \aImp, 1.5, \fImp, 5.25, \pImp, 4.75, \fMin, 200, \fMax, 400, \amp, 0.25]);
Synth.after(
	step[2],
	\fadeIn,
	[\bus, step[1], \dur, 4]
);
4.wait;

step[1].set(\aImp, 5);
step[1].set(\fImp, 2);
2.wait;

step[1].set(\aImp, 2.5);
step[1].set(\fImp, 2.5);
4.wait;

step[1].free;
step[2].free;
/*
Panning stepper
*/
step[3] = Synth(\panBiStep, [\aImp, 1, \fImp, 3, \pImp, 15, \fMin, 200, \fMax, 400, \amp, 0.25]);
/*
Panning stepper
*/
step[4] = Synth(\panBiStep, [\aImp, 10, \fImp, 15, \pImp, 20, \fMin, 50, \fMax, 1000, \step, 50, \amp, 0.25]);
4.wait;

step[3].free;
4.wait;

step[4].set(\amp, 0.5);
4.wait;

/*
Panning brown
Loops every 2s
*/
noise[1] = Synth(\panBnoisePulse, [\imp, 1, \amp, 0.4]);
2.wait;

step[4].set(\aImp, 15, \fImp, 10, \pImp, 30);
4.wait;

noise[1].free;
step[4].set(\step, -10);
(7.5).wait;

step[4].set(\step, 50);
(4.5).wait;

step[4].set(\step, -100);
2.wait;

step[4].set(\step, 150);
2.wait;

step[4].set(\step, 5);
6.wait;

step[4].set(\step, -15);
5.wait;

step[4].free;
4.wait;

sbass[4].stop;
2.wait;

hpul[1].free;
4.wait;

hpul[2].free;
2.wait;

hpul[3].free;
2.wait;

noise[2].stop;
3.wait;

hpit[1].free;
hpit[2].free;



"It's Over".postln;
}).play;
"Now Playing";