// Accidental synth rock or something

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



Routine({

	// 1/6 is interesting, 1/12 as well
	var speed = 1/5;

	// Bass
	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				// Main melody start
				Pseq([ 50, 25, 50, 75] * 3.236),
				Pseq([ 50, 25, 50, 75] * 2.427),
				Pseq([ 50, 25,100,125] * 2.427),
					// Sub-main melody start
				Pseq([ 50, 25, 50, 75] * 2),
				Pseq([ 50, 25, 50, 75] * 1.618),
				Pseq([ 50, 25,100,150] * 1.618),
					// Sub-main melody end
				// Main melody end
				// Filler start
				Pseq([ 75, 50, 75, 50] * 3.236),
				Pseq([ 75,100, 75,100] * 3.236),
				Pseq([150,100,125, 75] * 2.427),
				Pseq([150,100,125, 75] * 2),
				// Filler end
			],
			Pswitch(
				[
					// Main melody (speed * 4 * 8)
					Pstutter(
						Pseq([4,3,1]),
						Pseq([0,1,2])
					),
					// Sub-main melody (speed * 4 * 6)
					Pstutter(
						Pseq([2,3,1]),
						Pseq([3,4,5])
					),
					// Filler (speed * 4 * 10)
					Pstutter(
						Pseq([4,2,2,2]),
						Pseq([6,7,8,9])
					),
				],
				Pstutter(
					Pseq([1,1,1,1,1,inf], inf),
					Pseq([0,1,0,1,0,2], 10)
				)
			)
		),
		\dur, Pseq([speed], inf),
		\legato, 1,
		\imp, 0.00025,
		\amp, 0.1,
		\out, 0
	).play;

	(speed * 4 * 14).wait;

	// Lead
	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				// Main melody start
				Pseq([150, 75,100,125] * 3.236 * 2),
				Pseq([150, 75,100,125] * 3.236 * 2 * 0.75),
				Pseq([150, 75,100,125] * 3.236 * 2 * 0.5),
				Pseq([ 75,100, 75,150] * 3.236 * 2 * 0.5),
				Pseq([ 75,100,125,150] * 3.236 * 2 * 0.5),
				Pseq([ 75,100,225,250] * 3.236 * 2 * 0.5),
				Pseq([ 50, 75,100,150] * 3.236 * 2 * 0.5),
				// Main melody end
			],
			// Main Melody (speed * 4 * 23)
			Pstutter(
				Pseq([2,2,2,1,1,2,2,2,1,1,2,2,2,1], 1), // 1 loop
				Pseq([0,1,2,3,4,0,1,2,5,6,1,0,1,6], 10)
			)
		),
		\dur, Pseq([speed], inf),
		\legato, 1,
		\imp, 0.00025,
		\amp, 0.075,
		\out, 0
	).play;

	(speed * 4 * 42).wait;

	// Lead
	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				// Main melody start
				Pseq([ 75,125, 75,100] * 3.236 * 2),
				Pseq([100,150,100,125] * 3.236 * 2 * 0.75),
				Pseq([150, \r,125, \r] * 3.236 * 2 * 0.5),
				Pseq([150, \r, \r, \r] * 3.236 * 2 * 0.5),
				Pseq([125, \r, \r, \r] * 3.236 * 2 * 0.5),
				// Main melody end
			],
			// Main Melody (speed * 4 * 10)
			Pstutter(
				Pseq([2,2,2,2,2], 2), // 2 loops
				Pseq([0,1,2,3,4], 10)
			)
		),
		\dur, Pseq([speed], inf),
		\legato, 1,
		\imp, 0.00025,
		\amp, 0.075,
		\out, 0
	).play;

	120.wait; // This would be a cool outro (below)

	Pbind(
		\instrument, \vibeSpark,
		\freq, Pswitch(
			[
				Pseq([50,50,50,50] * 3.236 * 2),
				Pseq([150,75,100,125] * 3.236 * 2),
				Pseq([150,75,100,125] * 3.236 * 2 * 0.75),
				Pseq([150,75,100,125] * 3.236 * 2 * 0.5),
				Pseq([75,100,75,150] * 3.236 * 2 * 0.5),
				Pseq([75,100,125,150] * 3.236 * 2 * 0.5),
			],
			Pstutter(
				Pseq([0,2,2,2,1,1], inf),
				Pseq([0,1,2,3,4,5], 10)
			)
		),
		\dur, Pseq([speed], inf),
		\legato, 1,
		\imp, 0.0025,
		\amp, 0.1,
		\out, 0
	).play;

	/*Pbind(
		\instrument, \vibeSpark,
		\freq, Pseq([59, 66, 62, 60, 59, 67, 64, 59, 66, 62].midicps * 2, 10),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([1.5, 2] / 2.5, inf)
		),
		\legato, 0.95,
		\imp, 0.00025,
		\amp, 0.1,
		\out, 0
	).play;*/

}).play;