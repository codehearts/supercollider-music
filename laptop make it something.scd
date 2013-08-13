// Experimentation with various instruments

// Leads

SynthDef(\reverseDusthumm, {|freq = 440, dur = 10, crushRate = 100, crushStep = 0.1, pan = 0, amp = 0.2, out = 0|
	var osc, env, panning, reverb;

	env = EnvGen.kr(Env.linen(dur, 0.005, 0.1, amp, 0), doneAction: 2);
	osc = Pulse.ar(freq, SinOsc.kr(crushRate, 0, 1).range(crushStep).abs, env);
	panning = Pan2.ar(osc, pan);
	reverb = FreeVerb.ar(panning, 1, 1, 0.5);

	Out.ar(out, reverb);
}).add;

// Basses

SynthDef(\triSaw) { |out=0, freq=150, hi=1, lo=0, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(lo, hi), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

// Drums

SynthDef(\bassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var env  = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2),
		sine = SinOsc.ar(XLine.kr(freq, freq/3, sustain), 0, amp)*env,
		sqr  = Pulse.ar(XLine.kr(freq, freq/3, sustain), 0.5)*(amp*0.25)*env,
		pan2 = Pan2.ar(sine+sqr, pan);

	Out.ar(out, pan2);
}.add;



Routine({

	// Sequencers

	// 1 loop = 1s
	~bassLine = { |loops=1, synth=\triSaw, amp=0.25, speed=1, pitchShift=1, lo=0, hi=1|
		Pbind(
			\instrument, synth,
			\freq, Pseq([440, 330, 440, 330, 550, 440, 550, 440]*pitchShift, loops),
			\dur, Pseq([0.125]/speed, inf),
			\legato, Pseq([0.5, 0.125], inf),
			\lo, lo,
			\hi, hi,
			\amp, amp
		).play;
	};

	// 1 loop = 2s
	~bassKick = { |loops=1, freq=150, amp=0.5, dur=0.5, legato=0.25, dStut1=1, dStut2=1, dStut3=4, pan=0|
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
					Pseq(dur.asArray, loops)
				)
			),
			\legato, legato,
			\pan, pan,
			\amp, amp
		).play;
	};



	// Music

	~bassLine.value(4, synth: \reverseDusthumm); // 4s
	2.wait;
	~bassKick.value; // 2s
	2.wait;
	~bassLine.value(4, amp: 0.15, pitchShift: 0.25, lo: 0.5, speed: 0.5); // 8s
	4.wait;
	~bassLine.value(4, amp: 0.15, lo: 0.25, hi: 0.75, speed: 0.5); // 8s
	4.wait;
	~bassLine.value(4, synth: \reverseDusthumm); // 4s

}).play;