// Supposed to sound like a marsh at night with a bell part, but I haven't gotten to the bells

SynthDef(\beep) { |out=0, freq=440, amp=1, sustain=1|
	var sine, ring;

	sine = SinOsc.ar(
		freq,
		0,
		Trig.kr(Line.kr(1, 0, sustain), sustain)
	);
	ring = Ringz.ar(sine, 2000, sustain, amp);

	Out.ar(out, ring);
}.add;





Routine({

	Pbind(
		\instrument, \beep,
		\freq, Pstutter(
			Pseq([4, 1], inf),
			Pseq([41, 39].midicps, inf)
		),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([0.125 / 2, Rest(0.125 * 2)], inf)
		),
		\amp, 0.05,
		\out, 0
	).play;

	Pbind(
		\instrument, \beep,
		\freq, Pswitch(
			[
				Pseq([\r]),
				Pstutter(
					Pseq([4, 1]),
					Pseq([53, 45].midicps, inf)
				)
			],
			Pstutter(
				Pseq([1, inf]),
				Pseq([0, 1])
			)
		),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([0.125 / 2, Rest(0.125 * 1.618)], inf)
		),
		\amp, 0.05,
		\out, 1
	).play;


90.wait;
	Pbind(
		\instrument, \beep,
		\freq, Pstutter(
			Pseq([4, 1], inf),
			Pseq([71, 59].midicps, inf)
		),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([0.125 / 2, Rest(0.125 * 2 * 8)], inf)
		),
		\amp, 0.075,
		\out, 0
	).play;

	(1.618 * 2).wait;

	Pbind(
		\instrument, \beep,
		\freq, Pstutter(
			Pseq([4, 1], inf),
			Pseq([59, 47].midicps, inf)
		),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([0.125 / 2, Rest(0.125 * 2 * 4)], inf)
		),
		\amp, 0.075,
		\out, 1
	).play;

	(1.618 * 2).wait;

	Pbind(
		\instrument, \beep,
		\freq, Pstutter(
			Pseq([4, 1], inf),
			Pseq([80, 97].midicps, inf)
		),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([0.125 / 2, Rest(0.125 * 2 * 12)], inf)
		),
		\amp, 0.05,
		\out, 0
	).play;

	Pbind(
		\instrument, \beep,
		\freq, Pswitch(
			[
				Pstutter( // 0
					Pseq([4, 1]),
					Pseq([71, 59].midicps, inf)
				),
				Pstutter( // 1
					Pseq([4, 1]),
					Pseq([59, 47].midicps, inf)
				),
				Pstutter( // 2
					Pseq([1,1,1,1,1]),
					Pseq([67, 55, 71, 60, 64].midicps, inf)
				),
				Pstutter( // 3
					Pseq([1,1,1,1,1]),
					Pseq([40, 50, 60, 70, 80].midicps, inf)
				),
				Pstutter( // 4
					Pseq([1,1,1,1,1]),
					Pseq([80, 70, 50, 60, 90].midicps, inf)
				)
			],
			Pstutter(
				Pseq([8, 4, 3, 1], inf),
				Pseq([0, 1, 2, 3], inf)
			)
		),
		\dur, Pstutter(
			Pseq([4, 1], inf),
			Pseq([0.125/2, Rest(0.125*2*10)], inf)
		),
		\amp, 0.1,
		\out, Pseq([0], inf)
	);//.play;

}).play;