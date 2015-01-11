SynthDef(\vibrato) { |in=0, out=0, freq=220, imp=1|
	var input, newOut;

	input = In.ar(in, 2);

	newOut = FreqShift.ar(input, FSinOsc.kr(imp) * freq);

	ReplaceOut.ar(out, newOut);
}.add;

// Based on code from http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/Distortion-effect-tp5173262p5173287.html
SynthDef(\distortion) { |in=0, out=0, amount=0.99, amp=1|
	var input, amCoef, newOut;

	amCoef= 2*amount/(1-amount);

	input = HPF.ar(In.ar(in, 2), 400)*5;

	newOut = MidEQ.ar(LPF.ar((1+amCoef)*input/(1+(amCoef*input.abs)), [3800, 3900])*0.5, 120, 0.7, 8);

	ReplaceOut.ar(out, newOut * amp);
}.add;

SynthDef(\vibeSpark) { |out=0, imp=5, freq=150, sustain=0.25, attack=0.75, decay=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(
			Env.linen(sustain*attack, sustain*(1-attack), decay, amp, [-2.5,0,0]),
			1,
			doneAction: 2
		),
		saw  = Saw.ar(imp, aEnv),
		sine = SinOsc.ar(freq, 0, saw).min(amp).max(0-amp),
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

// Based on code from http://permalink.gmane.org/gmane.comp.audio.supercollider.user/77153
SynthDef(\tape_delay) { |in=0, out=0, imp=1, lag=3, maxLag=0.2, decayTime=6|
	var input, newOut, delayTime, laggedDelayTime, outDelay;

	input = In.ar(in, 2);
	// Delay time jumps on impulse
	delayTime = Demand.kr(Impulse.kr(imp), 0, Dseq([0.3], inf));
	// Amount of time to reach new value
	laggedDelayTime = Lag.kr(delayTime, lag);
	// CombC - delay with feedback
	newOut = CombC.ar(input, maxLag, laggedDelayTime, decayTime) + in;

	ReplaceOut.ar(out, newOut);
}.add;



Routine({

	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 75, 90, 100, 75] * 4 * 3.236),
				Pseq([75, 90, 110, 75, 90, 100, 75] * 3.236 * 1.618)
			],
			Pstutter(
				Pseq([1,1]/*[4,4]*/, inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pseq([4], inf),
		\legato, 1,
		\decay, Pseq([6], inf),
		\attack, 0.75,
		\imp, 5,
		\amp, 0.1,
		\out, 0
	).play;

	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([75, 90, 110, 75, 90, 100, 75] * 2),
				Pseq([75, 90, 110, 75, 90, 100, 75])
			],
			Pstutter(
				Pseq([1,1] * 4, inf),
				Pseq([0,1], 10)
			)
		),
		\dur, Pseq([2], inf),
		\legato, 1.5,
		\imp, 5,
		\amp, 0.1,
		\out, 0
	).play;

	Synth(\distortion, [\in, 0, \out, 0, \amount, 0.9, \amp, 0.5]);
	Synth(\vibrato, [\in, 0, \out, 0, \freq, -110, \imp, 1/32]);
	Synth(\tape_delay, [\in, 0, \out, 0, \imp, 0.15, \lag, 0.25, \maxLag, 0.5, \decayTime, 4]);

}).play;