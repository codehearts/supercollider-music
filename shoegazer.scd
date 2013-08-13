// Not very shoegazey, but it has a nice little wolf howl

SynthDef(\vibeSpark) { |out=0, imp=5, freq=150, sustain=0.25, attack=0.75, decay=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(
			Env.linen(sustain*attack, sustain*(1-attack), decay, amp, [-2.5,0,0]),
			1,
			doneAction: 2
		),
		saw  = Saw.ar(imp, aEnv),
		sine = SinOsc.ar(freq*((aEnv + (1 - amp))*0.5), 0, saw).min(amp).max(0-amp),
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;

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

SynthDef(\wolfCub) { |out=0, freq=150, sustain=0.25, attack=0.75, decay=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(
			Env.linen(sustain*attack, sustain*(1-attack), decay, amp, [-2.5,0,0]),
			1,
			doneAction: 2
		),
		sine = SinOsc.ar(
			freq * ((aEnv + (1 - amp))*0.5),
			0,
			aEnv
		).min(amp).max(0-amp),
		rvrb = sine + FreeVerb.ar(sine, 0.5, 1, 0.5),
		pan2 = Pan2.ar(rvrb, pan);

	Out.ar(out, pan2);
}.add;



// 1 loop = 8 seconds
~bassMelody = { |synth, loops=1, amp=0.25, imp=1|
	Pbind(
		\instrument, synth,
		\freq, Pstutter(
			Pseq([16 / imp], inf),
			Pseq([24, 24, 26, 19].midicps * 5, loops)
		),
		\dur, 0.1 * imp,
		\legato, 1,
		\filMax, 0.1,
		\imp, imp,
		\amp, amp
	).play;
};



Routine({

	var speed = 0.75;

	Pbind(
		\instrument, \wolfCub,
		\freq, Pseq([75, 50, 65, 40] * 20, inf),
		\dur,  Pseq([0.75, 0.75, 0.75, 1.125], inf),
		\attack, 0.05,
		\decay, 0.75,
		\legato, 0.9,
		\amp, 0.15,
		\out, 0
	).play;

	//4.wait;

	//~bassMelody.value(\starBerry, loops:20, amp:0.75, imp:7.5);

	Pbind(
		\instrument, \vibeSpark,
		\freq, Pseq([75, 50, 65, 40] * 2, inf, 1),
		\dur,  Pseq([1.5, 1.5, 1.5, 2.25] / 2, inf),
		\attack, 0.75,
		\decay, 0.125,
		\legato, 0.5,
		\imp, 0.00025,
		\amp, 0.05,
		\out, 0
	).play;
}).play;