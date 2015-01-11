// Based on code from http://article.gmane.org/gmane.comp.audio.supercollider.user/50457
s.waitForBoot {
	// preparation; essentially, allocate an impulse response buffer, then follow a special buffer preparation step to set up the data the plugin needs. Different options are provided commented out for loading impulse responses from soundfiles.
	var lengthinsamples = 10000;
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

SynthDef(\starBerry) { |out=0, freq=150, filMin=0.1, filMax=0.95, imp=1, gate=1, amp=0.5|
	var sust = Linen.kr(gate, releaseTime: 0.25, doneAction: 2),
		vSaw = VarSaw.ar(
			freq,
			0,
			EnvGen.kr(Env([filMin,filMax,filMin], [0.25*imp,0.75*imp], [-5,-5], 2), gate),
			amp
		),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

// Based on code from http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/plucked-string-waveguide-tp6890519.html
SynthDef(\bubbleString) { |out=0, freq=250, amp=0.5, feedbackAmp=0.975, gate=1|
	var pluckAt, period, controlPeriod, block, sustain, exciter, bubble_gum, effects, synth, feedback, d1, d2;

	// Properties
	pluckAt = 0.25;
	period = freq.reciprocal;
	controlPeriod = ControlRate.ir;
	block = controlPeriod.reciprocal / 2;

	// Synths
	sustain = Linen.kr(gate, susLevel: amp, releaseTime: 20, doneAction: 2);
	exciter = EnvGen.ar(
		Env.new(
			[0,1,0],
			[period * pluckAt + 0.01, period * (1-pluckAt) + 0.01],
			'linear'
		),
		doneAction: 0
	);
	bubble_gum = SinOsc.kr(0.5).abs().max(0.5);
	effects = bubble_gum;
	synth = (
		Pulse.ar(freq, bubble_gum, 0.125) +
		VarSaw.ar(freq, 0, LFTri.kr().range(0.5,1))
	) * exciter;

	// Output
	feedback = LocalIn.ar(1);
	d1 = DelayL.ar(synth + feedback, period-block, period-block);
	d2 = DelayL.ar(synth + d1.neg, period-block, period-block) * feedbackAmp;

	LocalOut.ar(d2.neg);

	Out.ar(out, d2 * effects * sustain);
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

	input = In.ar(in, 2);
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

// 1 loop = 14 seconds
~bassLine = { |synth, out=0, loops=1, legato=0.95, attack=0.005, decay=0.005, amp=0.25, speed=1, scale=1|
	Pbind(
		\instrument, synth,
		\freq, Pswitch(
			[
				Pseq([28,35,40, 30,37,42, 31,38,43, 30,37,42].midicps),
				Pseq([31, 38, 43,33, 40, 45].midicps)
			],
			Pstutter(
				Pseq([3,1], inf),
				Pseq([0,1], loops)
			)
		) * scale,
		\dur, Pswitch(
			[
				Pseq([0.5,0.5,1] / 2)
			],
			Pstutter(
				Pseq([14], inf),
				Pseq([0], loops)
			)
		) / speed,
		\feedbackAmp, 0.9975,
		\legato, legato,
		\attack, attack,
		\decay, decay,
		\amp, amp,
		\out, 0
	).play;
};

Routine({
	//y = Synth(\bubbleString, [\out, 0, \freq, 220, \feedbackAmp, 0.975, \amp, 0.75]);
	y = Pbind(
		\instrument, \bubbleString,
		\freq, Pseq([59, 66, 62, 60, 59, 67, 64, 59, 66, 62].midicps * 1.5, inf),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([1.5, 2] * 2, inf)
		),
		\feedbackAmp, 0.9975,
		\amp, 0.25,
		\out, 0
	);//.play;
	~bassLine.value(\bubbleString, loops:inf, amp:0.25, speed:1, scale:4);
	a = Synth(\distortion, [\in, 0, \out, 0, \amount, 0.25]);
	b = Synth.after(a, \vibrato, [\in, 0, \out, 0, \freq, -16, \imp, 1/8]);
	c = Synth.after(b, \reverse_reverb, [\in, 0, \out, 0]);
	d = Synth.after(c, \tape_delay, [\in, 0, \out, 0, \imp, 0.15, \lag, 0.25, \maxLag, 0.5, \decayTime, 4]);
}).play;