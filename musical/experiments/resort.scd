// Kind of rambunctious amplified bass guitar

SynthDef(\sineBell) { |out=0, pan=0, freq=100, attack=0.005, sustain=0.1, decay=0.005, amp=1|
	var sine, pan2;

	sine = SinOsc.ar(
		freq,
		0,
		EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2)
	);

	pan2 = Pan2.ar(sine, pan);

	Out.ar(out, pan2);
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

SynthDef(\bassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var hit_time, sust, osc, osc2, pan2;

	hit_time = 0.15;
	sust = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2);

	osc = SinOsc.ar(XLine.kr(freq*1.618, freq/3.236, hit_time), 0, amp);
	osc2 = osc - SinOsc.kr(freq/6.472, 0, 0.25);
	pan2 = Pan2.ar(osc2, pan);

	Out.ar(out, pan2*sust);
}.add;

// 1 loop = 2s
~bassKick = { |loops=1, freq=150, amp=0.5, dur=0.5, legato=0.25, dStut1=1, dStut2=1, dStut3=4, pan=0, speed=1|
	Pbind(
		\instrument, \bassDrum,
		\freq, Pseq(freq.asArray, inf),
		\dur, PdurStutter(
			Pstutter(
				Pseq(dStut1.asArray, inf),
				Pseq(dStut2.asArray, inf)
			),
			Pstutter(
				Pseq(dStut3.asArray, loops),
				Pseq(dur.asArray/speed, loops)
			)
		),
		\legato, legato,
		\pan, pan,
		\amp, amp
	).play;
};

// 1 loop = 4 seconds
~bassKick2 = { |loops=1, freq=150, amp=0.5, legato=0.25, pan=0|
	~bassKick.value(loops, freq, amp, [0.5, 2, 0.25, 0.5], legato, [7,1,7,1], [1,2,1,3], [16,1,2,13], pan);
};

// 1 loop = 14 seconds
~bassLine = { |synth, loops=1, legato=0.95, attack=0.005, decay=0.005, amp=0.25, imp=0.125, speed=1, scale=1, out=0|
	Pbind(
		\instrument, synth,
		\freq, Pswitch(
			[
				Pseq([28,32,38,42].midicps),
				Pseq([45,40,33,43].midicps),
				Pseq([43,33,40,45].midicps),
				Pseq([48,38,45,50].midicps),
				Pseq([50,45,38,48].midicps),
			],
			Pstutter(
				Pseq([3,1,3,1,3,1,3,1], inf),
				Pseq([0,1,0,2,0,3,0,4], loops)
			)
		) * scale,
		\dur, Pswitch(
			[
				Pseq([0.25] / 2)
			],
			Pstutter(
				Pseq([14], inf),
				Pseq([0], loops)
			)
		) / speed,
		\legato, legato,
		\attack, attack,
		\decay, decay,
		\amp, amp,
		\imp, imp,
		\pan, 0,
		\out, out
	).play;
};

SynthDef(\effectTest) { |effectBus, out=0, sustain=15|
	var audio, thing, thing2;

	audio = In.ar(effectBus);

	thing = SinOsc.kr(0.5, 0, 1);
	thing2 = SinOsc.kr(0.25, 0.5, 1);

	Out.ar(out, [audio * thing, audio * thing2]);
}.add;

SynthDef(\effectTest2) { |effectBus, out=0, amount=0.99|
	var in, amCoef, audio;

	in = HPF.ar(In.ar(effectBus), 400)*5;
	amCoef= 2 * amount / (1-amount);
	audio = MidEQ.ar(LPF.ar((1+amCoef)*in/(1+(amCoef*in.abs)), [3800, 3900])*0.5, 120, 0.7, 8);

	Out.ar(out, audio);
}.add;



Routine({
	var dur = 4,
	legato = 1;

	~sources = Group.new;

	~edge = Group.new(~sources, \addToTail);
	~edgeBus = Bus.audio(s, numChannels: 2);

	~pitchShifter = Group.new(~sources, \addToTail);
	~pitchShifterBus = Bus.audio(s, numChannels: 2);

	//~bassKick2.value(4, freq:400, dur:2, amp:0.25);

	//Synth(\wolfCub, [\freq, 75 * 20, \sustain, 0.75, \attack, 0.05, \decay, 0.75, \amp, 0.15, \out, 0]);
	//~bassLine.value(\sineBell, out:~pitchShifterBus, loops:inf, legato:0.9, amp:0.75, attack:0.025, decay:0.5, speed:1, scale:4);
	~bassLine.value(\sineBell, out:~edgeBus, loops:inf, legato:0.25, amp:0.1, attack:0.5, decay:0.05, speed:1/4, scale:2);

	Synth(\effectTest, [\effectBus, ~pitchShifterBus], ~pitchShifter, \addToTail);
	Synth(\effectTest2, [\effectBus, ~edgeBus, \amount, 0.99], ~edge, \addToTail);
}).play;