// Based on code from http://article.gmane.org/gmane.comp.audio.supercollider.user/50457
s.waitForBoot {
	// preparation; essentially, allocate an impulse response buffer, then follow a special buffer preparation step to set up the data the plugin needs. Different options are provided commented out for loading impulse responses from soundfiles.
	var lengthinsamples = 40000;
	~fftsize=8192; // also 4096 works on my machine; 1024 too often and amortisation too pushed, 8192 more high load FFT

	{
		var ir, irbuffer, bufsize;
		var nextmod=100;

		ir = [0] ++0.dup(100) ++ (Array.fill(lengthinsamples,{|i| if(i%(nextmod)==0,{nextmod= rrand(80,120); 0.3*((i.asFloat/lengthinsamples).squared)},{0.0}) }));

		irbuffer = Buffer.loadCollection(s, ir);

		s.sync;

		bufsize= PartConv.calcBufSize(~fftsize, irbuffer);

		~irspectrum = Buffer.alloc(s, bufsize, 1);

		~irspectrum.preparePartConv(irbuffer, ~fftsize);

		s.sync;

		irbuffer.free; // don't need time domain data anymore, just needed spectral version
	}.fork;
};

SynthDef(\ixibass, {arg out=0, amp=0.3, t_trig=1, freq=100, rq=0.004;
	var env, signal;
	var rho, theta, b1, b2;
	b1 = 1.98 * 0.989999999 * cos(0.09);
	b2 = 0.998057.neg;
	signal = SOS.ar(K2A.ar(t_trig), 0.123, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal, freq, rq) + RHPF.ar(signal, freq*0.5, rq);
	signal = Decay2.ar(signal, 0.4, 0.3, signal);
	DetectSilence.ar(signal, 0.01, doneAction:2);
	Out.ar(out, signal*(amp*0.45)!2);
}).add;

SynthDef(\sawSine) { |out=0, imp=5, freq=150, sustain=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(Env([0,amp,amp,0], [sustain*0.75, sustain*0.25, 0.25], [-2.5,0,0]), 1, doneAction: 2),
		saw  = Saw.ar(imp, aEnv),
		sine = SinOsc.ar(freq, 0, saw),
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\vibeSpark) { |out=0, imp=5, freq=150, sustain=0.25, attack=0.75, decay=0.25, pan=0, amp=0.5|
	var aEnv, saw, sine, rvrb, pan2;

	aEnv = EnvGen.kr(
		Env.linen(sustain*attack, sustain*(1-attack), decay, amp, [-2.5,0,0]),
		1,
		doneAction: 2
	);
	saw  = Saw.ar(imp, aEnv);
	sine = SinOsc.ar(freq, 0, saw).min(amp).max(0-amp);
	rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5);
	pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\susSine) { |out=0, freq=440, amp=0.25, pan=0, sustain=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0]), 1, doneAction: 2),
		sine = SinOsc.ar(freq, 0, amp) * env,
		pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
}.add;

SynthDef(\cutString) { |out=0, freq=250, amp=0.5, feedbackAmp=0.97, sustain=1|
		// Properties
	var pluckAt = 0.5,
		period = freq.reciprocal,
		controlPeriod = ControlRate.ir,
   		block = controlPeriod.reciprocal,
		// Synths
		level = EnvGen.kr(Env.linen(sustainTime: sustain), doneAction: 0),
		exciter = EnvGen.ar(
			Env.new(
				[0, 0.9, 0],
				[period * pluckAt + 0.01, period * (1-pluckAt) + 0.01],
				'linear'
			),
			doneAction: 0
		),
		modulator = SinOsc.ar(freq) + SinOsc.ar(freq / 2 * 0.618),
		synth = modulator * exciter,
		// Output
		feedback = LocalIn.ar(1),
		d1 = DelayL.ar(synth + feedback, period-block, period-block),
		d2 = DelayL.ar(synth + d1.neg, period-block, period-block) * feedbackAmp;

	LocalOut.ar(d2.neg);

	Out.ar(out, d2 * level * amp);
}.add;

SynthDef(\reverse_reverb) { |in=0, out=0, amp=1|
	var input, new_out;

	input = In.ar(in, 2);
	new_out = PartConv.ar(input, ~fftsize, ~irspectrum.bufnum, amp) + input;

	ReplaceOut.ar(out, new_out);
}.add;

// Based on code from http://permalink.gmane.org/gmane.comp.audio.supercollider.user/77153
SynthDef(\tape_delay) { |in=0, out=0, imp=1, lag=3, maxLag=0.2, decayTime=6|
	var input, newOut, delayTime, laggedDelayTime, outDelay;

	input = In.ar(in, 2) * 0.75;
	// Delay time jumps on impulse
	delayTime = Demand.kr(Impulse.kr(imp), 0, Dseq([0.3], inf));
	// Amount of time to reach new value
	laggedDelayTime = Lag.kr(delayTime, lag);
	// CombC - delay with feedback
	newOut = CombC.ar(input, maxLag, laggedDelayTime, decayTime) + in;

	ReplaceOut.ar(out, newOut);
}.add;

SynthDef(\vibrato) { |in=0, out=0, freq=220, imp=1|
	var input, newOut;

	input = In.ar(in, 2);

	newOut = FreqShift.ar(input, (FSinOsc.kr(imp) * freq) - (freq * MouseY.kr(0, 1)));
	//newOut = FreqShift.ar(input, FSinOsc.kr(imp) * freq * MouseY.kr(0, freq));

	ReplaceOut.ar(out, newOut);
}.add;

// Based on code from http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/Distortion-effect-tp5173262p5173287.html
SynthDef(\distortion) { |in=0, out=0, amount=0.99, amp=1, freq=0.25|
	var input, mod_amount, amCoef, newOut;

	mod_amount = FSinOsc.kr(freq).range(amount, 1) * amount;
	amCoef= 2*mod_amount/(1-mod_amount);

	input = HPF.ar(In.ar(in, 2), 400)*5;

	newOut = MidEQ.ar(LPF.ar((1+amCoef)*input/(1+(amCoef*input.abs)), [3800, 3900])*0.5, 120, 0.7, 8);

	ReplaceOut.ar(out, newOut * amp);
}.add;



// strummable guitar
// use mouse to strum strings
// based on code from http://www.sussex.ac.uk/Users/nc81/modules/cm1/scfiles/4.1%20Interaction%201.html
SynthDef(\strumGuitar) { |frets = #[0,0,0,0,0,0], out=0|
	var pitch, mousex, output;

	pitch = [ 52, 57, 62, 67, 71, 76 ]; // e a d g b e
	mousex = MouseX.kr;
	output = Mix.fill(pitch.size, { |i|
		var trigger, pluck, period, string, shift;

		// place trigger points from 0.25 to 0.75
		trigger = HPZ1.kr(mousex > (0.25 + (i * 0.1))).abs;
		pluck = WhiteNoise.ar(Decay.kr(trigger, 0.05));
		shift = Select.kr(frets[i] <= 0, [2.pow(1/12.0).pow(frets[i]), 1]);

		period = (pitch.at(i).midicps * shift).reciprocal;
		/* string = */CombL.ar(pluck, period, period, 4);
		//Pan2.ar(string, i * 0.2 - 0.5);
	});
	output = LPF.ar(output, 12000) + LeakDC.ar(output);

	Out.ar(out, output);
}.add;



// Try using these on the birds in bird-shifts with the pitch multiplied by 1
a = Synth(\vibrato, [\in, 0, \out, 0, \imp, 1/32, \freq, 32]);
b = Synth.after(a, \distortion, [\in, 0, \out, 0, \amount, 0.99]);
c = Synth.after(b, \tape_delay, [\in, 0, \out, 0, \imp, 1/8, \lag, 1/4, \maxLag, 1, \decayTime, 8]);
d = Synth.after(c, \reverse_reverb, [\in, 0, \out, 0]);

w = Window.new;
c = Slider(w,Rect(0,0,100,30));
z = Synth(\strumGuitar, [\frets, [0, 0, 9, 7, 7, 0]]).moveBefore(a);
/*c.keyDownAction = { |view, char, modifiers, unicode, keycode|
	unicode.postln;
	Synth(\ixibass, [
		\freq, unicode * 4,
		//\sustain, 1,
		//\legato, 1,
		//\feedbackAmp, 0.995,
		\amp, 0.125
	]).moveBefore(a);
};*/
w.onClose = {
	s.freeAll;
};
w.front;

Routine({
	inf.do({
		1.wait;
		"A".postln;
		z.set(\frets, [3, 9, 0, 0, 7, 0]);

		1.wait;
		"B".postln;
		z.set(\frets, [0, 0, 0, 0, 0, 0]);

		1.wait;
		"C".postln;
		z.set(\frets, [3, 5, 7, 0, 0, 5]);
	});
}).play;