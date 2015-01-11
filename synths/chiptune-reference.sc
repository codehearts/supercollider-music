(
SynthDef(\EightBitSaw, {|freq = 440, dur = 1, amp = 0.2, out = 0|
	var osc, env, mask;

	env = EnvGen.kr(Env.linen(dur * 0.1, dur * 0.8, dur * 0.1, amp, 0), doneAction: 2);
	osc = Saw.ar(freq, env);
	mask = MantissaMask.ar(osc, 8); // make 8 bit
	Out.ar(out, mask);
}).play
)

(
SynthDef(\RoundedSine, {|freq = 440, dur = 1, amp = 0.2, out = 0|
	var osc, env, mask;

	env = EnvGen.kr(Env.linen(dur * 0.1, dur * 0.8, dur * 0.1, amp, 0), doneAction: 2);
	osc = SinOsc.ar(freq, 0, env).round(0.1);

	Out.ar(out, osc);
}).play
)

(
SynthDef(\LatchedSaw, {|freq = 440, dur = 1, amp = 0.2, out = 0|

	var osc, env, latched;

	env = EnvGen.kr(Env.linen(dur * 0.1, dur * 0.8, dur * 0.1, amp, 0), doneAction: 2);
	osc = Saw.ar(freq, env).round(0.1);
	latched = Latch.ar(osc, Impulse.ar(SampleRate.ir / 2));
	Out.ar(out, latched);
}).play
)

(
SynthDef(\RingSine, {|freq1 = 111, freq2 = 440, dur = 1, amp1 = 1, amp2 = 0.2, out = 0|

	var osc1, osc2, env1, env2;

	env1 = EnvGen.kr(Env.linen(dur * 0.1, dur * 0.8, dur * 0.1, amp1, 0), doneAction: 2);
	env2 = EnvGen.kr(Env.linen(dur * 0.1, dur * 0.8, dur * 0.1, amp2, 0));

	osc1 = SinOsc.ar(freq1, 0, env1);
	osc2 = SinOsc.ar(freq2, 0, osc1) * env2;
	Out.ar(out, osc2);
}).play
)

(
SynthDef(\RingSineGated, {|freq1 = 111, freq = 440, gate = 1, amp1 = 1, amp2 = 0.2, out = 0|

	var osc1, osc2, env1, env2;

	env1 = EnvGen.kr(Env.adsr(0.1, 0.01, amp1, 0.5), gate);
	env2 = EnvGen.kr(Env.adsr(0.2, 0.1, amp2, 0.1), gate, doneAction: 2);
		// with ring modulation, it doesn't matter which envelope gets the doneAction

	osc1 = SinOsc.ar(freq1, 0, env1);
	osc2 = SinOsc.ar(freq, 0, osc1) * env2;
	Out.ar(out, osc2);
}).add;

Pbind(
	\instrument,	\RingSineGated,
	\freq,		Pseq([440], 1),
	\freq2,	111,
	\amp1,	1,
	\amp2,	0.2,
	\dur,		1
).play
)