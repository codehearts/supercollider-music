(
SynthDef(\acid, { arg out, freq = 1000, gate = 1, pan = 1, cut = 4000, rez = 0.8, amp = 1;
    Out.ar(out,
        Pan2.ar(
            RLPF.ar(
                Pulse.ar(freq, 0.05),
            cut, rez),
        pan) * EnvGen.kr(Env.linen(0.01, 1, 0.3), gate, amp, doneAction:2);
    )
}).add;

SynthDef(\noiseSnare) { |out=0, pan=0, freq=440, attack=0.005, sustain=0.05, decay=0.15, amp=0.25|
	var level, hitLevel, hit_time, noise, reverb, pan2;

	hit_time = 0.05;

	level = EnvGen.kr(Env([0,amp,amp,0], [attack,sustain,decay]), 1, doneAction: 2);
	hitLevel = EnvGen.kr(Env([0,amp,amp,0], [attack,hit_time,decay]), 1);

	noise = LFNoise0.ar(freq, hitLevel) + LFNoise0.ar(freq / 1.618, hitLevel);
	reverb = FreeVerb.ar(noise, 0, 1, 0.5);

	pan2 = Pan2.ar(reverb, pan);

	Out.ar(out, pan2 * level);
}.add;

SynthDef(\chipBassDrum) { |out=0, freq=150, sustain=0.25, pan=0, amp=1|
	var hit_time, level, pulse1, pulse2, pan2;

	hit_time = 0.1;
	level = EnvGen.kr(Env([1, 1, 0], [hit_time, 0.05]), 1, doneAction: 2);

	pulse1 = Pulse.ar(XLine.kr(freq, freq/4, hit_time), 0.5, amp);
	pulse2 = pulse1 - Pulse.kr(freq/4/2, 0.5, 0.75);
	pan2 = Pan2.ar(pulse2, pan);

	Out.ar(out, pan2 * level);
}.add;

// Based on code from http://permalink.gmane.org/gmane.comp.audio.supercollider.user/77153
SynthDef(\tape_delay) { |in=0, out=0, imp=1, lag=3, maxLag=0.2, decayTime=6|
	var input, newOut, delayTime, laggedDelayTime, outDelay;

	input = In.ar(in, 2) * 0.75;
	// Delay time jumps on impulse
	delayTime = Demand.kr(Impulse.kr(imp), 0, Dseq([0.3], inf));
	// Amount of time to reach new value
	laggedDelayTime = Lag.kr(delayTime, lag);
	// CombC - delay with feedback
	newOut = CombC.ar(input, maxLag, laggedDelayTime, decayTime) + in;

	ReplaceOut.ar(out, newOut);
}.add;
)

(
Pbind(\instrument, \acid, \dur, Pseq([0.25, 0.5, 0.25], inf), \root, -12,
    \degree, Pseq([0, 3, 5, 7, 9, 11, 5, 1], inf), \pan, Pfunc({1.0.rand2}),
    \cut, Pxrand([1000, 500, 2000, 300], inf), \rez, Pfunc({0.7.rand +0.3}), \amp, 0.2).play;

w = Window.new;
c = Slider(w,Rect(0,0,100,30));
c.keyDownAction = { |view, char, modifiers, unicode, keycode|
	unicode.postln;
	switch (unicode,
		32,  {Synth(\chipBassDrum, [\amp, 0.125]);},
		122, {Synth(\noiseSnare, [\freq, 8500, \amp, 0.35]);}
	)
};
w.onClose = {
	s.freeAll;
};
w.front;
)