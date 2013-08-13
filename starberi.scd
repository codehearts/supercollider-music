// Somewhat choppy synth duet

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

SynthDef(\plick) { |out=0, freq=1000, atk=0.005, dec=1|
	var sine  = SinOsc.ar(freq, 0, 0.25),
		saw   = Saw.ar(freq*1.25, 0.25),
		env   = EnvGen.kr(Env.perc(atk, dec*1.5), 1, doneAction: 2),
		eSine = sine*env,
		eSaw  = saw*(env*0.5),
		rvrb  = AllpassC.ar(eSine+eSaw, 0.025, 0.001, dec);

	Out.ar(out, rvrb);
}.add;



Routine({
	// 1 loop = 16 seconds
	~melody = { |synth, loops=1, amp=0.25, imp=1|
		Pbind(
			\instrument, synth,
			\freq, Pseq([60, 64, 53, 57, 55, 52, 53, 57, 55, 50, 52].midicps, loops),
			\dur, Pseq([1.5, 0.5, 0.5, 5.5, 4, 4, 4, 4, 4, 1.5, 2.5] / 2, loops),
			\legato, 0.5,
			\imp, imp,
			\amp, amp
		).play;
	};

	// 1 loop = 8 seconds
	~bassMelody = { |synth, loops=1, amp=0.25, imp=1|
		Pbind(
			\instrument, synth,
			\freq, Pstutter(
				Pseq([16], inf),
				Pseq([24, 24, 26, 19].midicps*4, loops)
			),
			\dur, 0.125,
			\legato, 1,
			\filMax, 0.1,
			\imp, imp,
			\amp, amp
		).play;
	};

	~melody2 = { |synth, loops=1, amp=0.25|
		var speed = 1;

		Pbind(
			\instrument, synth,
			\freq, Pseq([
				36,38,40,36,38,40,36,38,
				39,41,43,39,41,43,39,41,
				38,40,41,38,40,41,38,40,
				31,33,35,31,33,35,31,33
			].midicps * 1.618 * 4, loops),
			\dur, 0.125 * speed,
			\legato, 1,
			\amp, Pstutter(
				Pseq([8, 8, 8, 8], inf),
				Pseq([0.5, 0.65, 0.80, 1]*amp, loops)
			),
			\imp, 0.5,
			\filMax, 0.5,
			\filMin, 0.25
		).play;
	};

	~melody4 = { |synth, loops=1, amp=0.25, imp=0.95|
		Pbind(
			\instrument, synth,
			\freq, Pstutter(
				Pseq([4], inf),
				Pseq([59, 66, 62, 60, 59, 67, 64, 59, 66, 62].midicps, loops),
			),
			\dur, Pstutter(
				Pseq([8, 2], inf),
				Pseq([1.5, 2] / 8, inf)
			),
			\legato, 1,
			\imp, imp,
			\amp, amp
		).play;
	};

	~plickMelody4 = { |synth, loops=1, amp=0.25|
		Pbind(
			\instrument, synth,
			\freq, Pstutter(
				Pseq([1], inf),
				Pseq([59, 66, 62, 60, 59, 67, 64, 59, 66, 62].midicps * 1.618 * 5, loops),
			),
			\dur, Pstutter(
				Pseq([4, 1], inf),
				Pseq([1.5, 2] / 2, inf)
			),
			\legato, 1,
			\amp, amp
		).play;
	};

	~bassMelody.value(\starBerry, 20, 0.5, 2);
	//~melody2.value(\starBerry, 20, 0.5);
	~melody4.value(\starBerry, 20, 0.25, 0.75);
	//~plickMelody4.value(\plick, 20, 0.05);
}).play;