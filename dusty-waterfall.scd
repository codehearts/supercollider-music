// Experimental instrumental based on the stage 4 theme from Touhou 10

SynthDef(\dusthumm, {|freq = 440, dur = 10, crushRate = 100, crushStep = 0.1, amp = 0.2, out = 0|
	var osc, env, reverb;

	env = EnvGen.kr(Env.linen(0.005, 0.005, dur, amp, 0), doneAction: 2);
	osc = Pulse.ar(freq, SinOsc.kr(crushRate, 0, 1).range(crushStep).abs, env);
	reverb = FreeVerb.ar(osc, 1, 1, 0.5);

	Out.ar(out, reverb);
}).add;

SynthDef(\reverseDusthumm, {|freq = 440, dur = 10, crushRate = 100, crushStep = 0.1, amp = 0.2, out = 0|
	var osc, env, reverb;

	env = EnvGen.kr(Env.linen(dur, 0.005, 0.1, amp, 0), doneAction: 2);
	osc = Pulse.ar(freq, SinOsc.kr(crushRate, 0, 1).range(crushStep).abs, env);
	reverb = FreeVerb.ar(osc, 1, 1, 0.5);

	Out.ar(out, reverb);
}).add;


Routine({

/*Pbind(
	\instrument, \reverseDusthumm,
	\freq, Pstutter(
			Pseq([10,   6,  3, 1],   inf),
			Pseq([100, 75, 50, 250], inf)
		),
	\dur, 0.75/2,
	\amp, 0.5
).play;*/

/*Pbind(
	\instrument, \reverseDusthumm,
	\freq, Pseq([1, 400, 750, 500]*2, inf),
	\dur, Pseq([0.75, 0.5, 0.5, 0.25]/2, inf),
	\amp, 0.25,
	\out, 1
).play;*/

Synth(\dusthumm, [\freq, 1, \dur, 10, \amp, 0.25, \out, 1]);
(5).wait;
Synth(\reverseDusthumm, [\freq, 1, \dur, 5, \amp, 1]);
(4.9).wait;

// Upper right-hand
Pbind(
	\instrument, \dusthumm,
	\freq, Pseq([59,59,  61,  62, 64,66,59,59, 68, 62,64,66,66, 69, 66,  69,  66, 63, 66, 63, 66, 59,59,57, 59, 55,64,61,61,59,61,62,64,61,66].midicps, inf),
	\dur,  Pseq([2, 0.75,0.75,0.5,1, 1, 1, 0.5,0.5,1, 1, 1, 0.5,0.5,0.25,0.25,2.5,0.5,0.5,0.5,0.5,1, 1, 0.5,0.5,1, 1, 1, 1, 1, 1, 1, 1, 2, 1]/2, inf),
	\amp, 0.25,
	\out, 1
).play;

// Lower right-hand
Pbind(
	\instrument, \dusthumm,
	\freq, Pseq([52,54,55,54,52,54,55,54,52,54,54,54,55,57,59].midicps, inf),
	\dur,  Pseq([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4]/2, inf),
	\amp, 0.1,
	\out, 1
).play;

// left-hand
Pbind(
	\instrument, \dusthumm,
	\freq, Pseq([28, 35, 40,30, 37, 42,31, 38, 43,30, 37, 42].midicps, 3),
	\dur,  Pseq([0.5,0.5,1, 0.5,0.5,1, 0.5,0.5,1, 0.5,0.5,1 ]/2, 3),
	\amp, 0.5
).play;
12.wait;

// left-hand (cont)
Pbind(
	\instrument, \dusthumm,
	\freq, Pseq([31, 38, 43,33, 40, 45].midicps, 1),
	\dur,  Pseq([0.5,0.5,1, 0.5,0.5,1]/2, 1),
	\amp, 0.5
).play;
2.wait;

// Upper left-hand (cont)
Pbind(
	\instrument, \dusthumm,
	\freq, Pseq([37].midicps, 6),
	\dur,  Pseq([0.5]/2, inf),
	\amp, 0.25
).play;

// Lower left-hand (cont)
Pbind(
	\instrument, \dusthumm,
	\freq, Pseq([30].midicps, 6),
	\dur,  Pseq([0.5]/2, inf),
	\amp, 0.25
).play;

}).play;