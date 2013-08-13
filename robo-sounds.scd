// Various robotic/air raid siren noises

(

SynthDef(\roboSiren, {|sFreq = 440, eFreq = 220, dur = 10, crushRate = 100, crushStep = 0.1, amp = 0.5, out = 0|
	var osc, freq, env, reverb;

	env = EnvGen.kr(Env.linen(0.005, 0.005, dur, amp, 0), doneAction: 2);
	freq = EnvGen.kr(Env([sFreq, eFreq], [dur]), 1);
	osc = Saw.ar(freq, env);
	reverb = FreeVerb.ar(osc, 1, 1, 0.5);

	Out.ar(out, reverb);
}).play(s);

)

(

// Air raid siren (from AIF invasion night)
Pbind(
	\instrument, \roboSiren,
	\sFreq, Pseq([330], inf),
	\eFreq, Pseq([110], inf),
	\dur, Pseq([12.5], inf),
	\legato, 1,
	\amp, 0.5,
	\out, [0,1]
).play;

)

(

SynthDef(\roboScreech, {|sFreq = 500, eFreq = 1250, curve = -5, dur = 0.5, amp = 0.5, out = 0|
	var osc, freq, env;

	env = EnvGen.kr(Env.linen(0.005, 0.005, dur, amp, 0), doneAction: 2);
	freq = EnvGen.kr(Env([sFreq, eFreq], [dur], [curve]), 1);
	osc = Saw.ar(freq, env);

	Out.ar(out, osc);
}).play(s);

)