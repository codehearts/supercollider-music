SynthDef(\bubbleSine) { |out=0, freq=150, filMin=0, filMax=1, imp=0.05, pulse=5, sustain=10, amp=0.5|
	var sust = EnvGen.kr(Env([amp,amp,0], [sustain, 0.75]), 1, doneAction: 2),
		bubble_gum = SinOsc.kr(0.5).abs().max(0.5).min(0.95),
		synth = VarSaw.ar(
			freq,
			0,
			bubble_gum,
			1
		);
	
	Out.ar(out, synth*sust);
}.add;

SynthDef(\sickSine) { |out=0, freq=150, gate=1, amp=0.5|
	var sust = Linen.kr(gate, susLevel: amp, doneAction: 2),
		bubble_gum = SinOsc.kr(0.5).abs().max(0.5).min(0.95),
		saw = Saw.kr(bubble_gum),
		pulse = Pulse.kr(bubble_gum/0.5, 0.5, 1).abs().range(0,0.925),
		sine = SinOsc.kr(bubble_gum).range(0,1).max(0.5),
		synth = VarSaw.ar(
			freq + (5 * sine),
			0,
			bubble_gum * pulse,
			saw
		);
	
	Out.ar(out, synth*sust);
}.add;

SynthDef(\ghostBoo) { |out=0, freq=250, sustain=1, amp=0.5|
	var level = EnvGen.kr(Env.linen(sustainTime: sustain), doneAction: 2) * amp,
		// effects
		bubble_gum = SinOsc.kr(0.5).abs().max(0.5).min(0.95),
		wiggle = SinOsc.kr(5, 0, Line.kr(1, 0, sustain)).range(-0.5, 0.5),
		// kr
		saw = Saw.kr(bubble_gum),
		pulse = Pulse.kr(bubble_gum/0.5, 0.5).abs().range(0,0.925),
		sine = SinOsc.kr(bubble_gum).range(0,1).max(0.5),
		// ar
		synth = VarSaw.ar(
			freq + (freq/2 * wiggle * bubble_gum),
			0,
			bubble_gum * pulse,
			saw
		);
	
	Out.ar(out, synth*level);
}.add;

SynthDef(\bubbleString) { |out=0, freq=250, amp=0.5, feedbackAmp=0.975, gate=1|
		// Properties
	var pluckAt = 0.5,
		period = freq.reciprocal,
		controlPeriod = ControlRate.ir,
   		block = controlPeriod.reciprocal,
		// Synths
		sustain = Linen.kr(gate, susLevel: amp, doneAction: 0),
		exciter = EnvGen.ar(
			Env.new(
				[0,1,0],
				[period * pluckAt + 0.01, period * (1-pluckAt) + 0.01],
				'linear'
			),
			doneAction: 0
		),
		bubble_gum = SinOsc.kr(0.5).abs().max(0.5),
		effects = bubble_gum,
		synth = (
			Pulse.ar(freq, bubble_gum) +
			VarSaw.ar(freq, 0, LFTri.kr(0.5).range(0.5,1))
		) * exciter,
		// Output
		feedback = LocalIn.ar(1),
		d1 = DelayL.ar(synth + feedback, period-block, period-block),
		d2 = DelayL.ar(synth + d1.neg, period-block, period-block) * feedbackAmp;
	
	LocalOut.ar(d2.neg);
	
	Out.ar(out, d2 * effects * sustain);
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
				[0,1,0],
				[period * pluckAt + 0.01, period * (1-pluckAt) + 0.01],
				'linear'
			),
			doneAction: 0
		),
		bubble_gum = SinOsc.kr(0.5).abs().max(0.5),
		stepAmp = Stepper.kr(Impulse.kr(5), 0, 0, 1, 1),
		effects = stepAmp * bubble_gum,
		modulator = Saw.ar(freq/1.618, Saw.kr(2)),
		synth = (
			Pulse.ar(freq, bubble_gum) +
			VarSaw.ar(freq, 0, bubble_gum)
		) * exciter,
		// Output
		feedback = LocalIn.ar(1),
		d1 = DelayL.ar(synth + feedback, period-block, period-block),
		d2 = DelayL.ar(synth + d1.neg, period-block, period-block) * feedbackAmp;
	
	LocalOut.ar(d2.neg);
	
	Out.ar(out, d2 * effects * level);
}.add;



//Synth(\bubbleSine, [\freq, 220]);



// 1 loop = 8 seconds
~melody4 = { |synth, loops=1, amp=0.25, shift=1, speed=1|
	Pbind(
		\instrument, synth,
		\freq, Pseq([59, 66, 62, 60, 59, 67, 64, 59, 66, 62].midicps*shift, loops),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([1.5, 2] / 2 / speed, inf)
		),
		\legato, 1,
		\amp, amp
	).play;
};



Routine({
	
	~melody4.value(\ghostBoo, 10, 0.5, 4/4, 2);
	
	/*
	~melody4.value(\cutString, 10, 0.5, 4/4, 2);
	//~melody4.value(\cutString, 10, 0.05, 2/4, 10);
	~melody4.value(\bubbleSine, 4, 0.5, 2/4);
	*/
	
	/*
	Synth(\bubbleString, [\freq, 100, \amp, 0.5, \feedbackAmp, 0.995]);
	(7.5).wait;
	Synth(\bubbleString, [\freq, 90, \amp, 0.5, \feedbackAmp, 0.995]);
	(2.5).wait;
	Synth(\bubbleString, [\freq, 100, \amp, 0.5, \feedbackAmp, 0.95]);
	*/
	
	/*
	~melody4.value(\bubbleSine, 1, 0.25, 6/4);
	(8).wait;
	~melody4.value(\bubbleSine, 2, 0.5, 6/4, 2);
	*/
	//~melody4.value(\sickSine, 4, 0.5, 2/4, 1/2);
	//~melody4.value(\bubbleSine, 4, 0.5, 2/4);
	
}).play;