(

SynthDef(\kivBass) { |out=0, freq=100, gate=1, imp=0.125, pan=0, amp=0.5|
	var sust = Linen.kr(gate, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(0.88, 0.98), amp),
		pan2 = Pan2.ar(vSaw, pan);
	
	Out.ar(out, pan2*sust);
}.send(s);

Routine({
	var freq = Pseq([100, 75], inf).asStream,
		dur  = Pseq([4], inf).asStream;
	
	x = Synth(\kivBass, [\freq, freq.next]);
	
	loop({
		dur.next.wait;
		x.set(\freq, freq.next);
	}).play;
}).play;

)


(

SynthDef(\sawBass) { |out=0, freq=100, gate=1, pulse=2, imp=0.125, pan=0, amp=0.5|
	var sust = Linen.kr(gate, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, Saw.kr(pulse).range(0.5, 0.95), amp),
		pan2 = Pan2.ar(vSaw, pan);
	
	Out.ar(out, pan2*sust);
}.send(s);

Routine({
	var freq = Pseq([100, 75], inf).asStream,
		dur  = Pseq([4], inf).asStream;
	
	x = Synth(\sawBass, [\freq, freq.next]);
	
	loop({
		dur.next.wait;
		x.set(\freq, freq.next);
	}).play;
}).play;

)


(

SynthDef(\sawSine) { |out=0, freq=100, gate=1, pulse=2, imp=0.125, pan=0, amp=0.5|
	var sust = Linen.kr(gate, doneAction: 2),
		sine = SinOsc.ar(freq, 0, Saw.kr(pulse).range(0, amp));
	
	Out.ar(out, sine*sust);
}.send(s);

x = Synth(\sawSine);

)


(

SynthDef(\breakup) { |out=0, bus, channels=1, minImp=10, maxImp=2000, dur=5, gate=1|
	var sust = Linen.kr(gate, doneAction: 2),
		in   = In.ar(bus, channels),
		nois = Dust.kr(XLine.kr(maxImp, minImp, dur));
	
	ReplaceOut.ar(out, in*nois*sust);
}.send(s);

)


(

SynthDef(\sine) { |out=0, gate=1, pan=0, amp=0.5|
	var sust = Linen.kr(gate, doneAction: 2),
		sine = SinOsc.ar(EnvGen.kr(Env([100, 150, 75], [2, 3], [5, -5]).circle, 1), 0, amp),
		pan2 = Pan2.ar(sine, pan);
	
	Out.ar(out, pan2*sust);
}.send(s);

x = Synth(\sine);

)


(

SynthDef(\mouseBrokenWub) { |out=0, freq=150, sustain=0.25, pan=0, amp=0.5|
	var aEnv = EnvGen.kr(Env([amp,amp,0], [sustain, 0.05], [-2.5,0,0]), 1, doneAction: 2),
		fMod = MouseY.kr(1, 1000, 1),
		saw  = Saw.ar(100, aEnv),
		modu = SinOsc.ar(fMod, 0, saw),
		sine = SinOsc.ar(freq, 0, 1),
		pan2 = Pan2.ar(sine*modu, pan);
	
	Out.ar(out, pan2);
}.add;

x = Synth(\mouseBrokenWub, [\sustain, 500]);

)