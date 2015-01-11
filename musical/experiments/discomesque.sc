SynthDef(\smoothWave) { |out=0, freq=150, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(0, 1), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);
	
	Out.ar(out, rvrb*sust);
}.add;

SynthDef(\bass) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var hit  = 0.15,
		sust = EnvGen.kr(Env([1, 1, 0], [sustain, 0.05]), 1, doneAction: 2),
		beat = EnvGen.kr(Env([1, 1, 0], [hit, 0.05]), 1),
		vSaw = VarSaw.ar(XLine.kr(freq*3, freq, hit), 0, 0.5, amp) * beat,
		tri  = LFTri.ar(XLine.kr(freq, freq/3, hit), 0, amp) * beat,
		pan2 = Pan2.ar(vSaw+tri, pan);
	
	Out.ar(out, pan2*sust);
}.add;



Routine({

Pbind(
	\instrument, \smoothWave,
	\freq, Pseq([200, 750, 400, 450, 750], inf),
	\dur, Pseq([2, 0.25, 0.75], inf),
	\imp, Pseq([0.25, 4, 90, 0.9, 150, 0.2, 25], inf),
	\amp, 0.25
).play;

4.wait;

// 18s
Pbind(
	\instrument, \bass,
	\freq, 75,
	\dur, Pseq([2, 0.225, 0.775, 1, 2, 2, 1], 2),
	\amp, 0.5
).play;

18.wait;

// 10s
Pbind(
	\instrument, \bass,
	\freq, 75,
	\dur, Pseq([0.5], inf),
	\amp, 0.5
).play;

/*10.wait;

Pbind(
	\instrument, \bass,
	\freq, 75,
	\dur, PdurStutter(
		Pstutter(
			Pseq([1,8,1,6], inf),
			Pseq([2,1,2,1], inf)
		),
		Pstutter(
			Pseq([16], inf),
			Pseq([0.25], inf) // @todo Specify loops here
		)
	),
	\legato, 0.25,
	\pan, 0,
	\amp, 0.5
).play;*/

// @todo After a while, a regular loose hihat hit would be nice

}).play;