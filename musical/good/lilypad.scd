// Cheery synth piece

SynthDef(\mutedBlip) { |out=0, freq=440, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.05]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, FSinOsc.kr(imp).range(0.4, 0.6), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\mutedBell) { |out=0, freq=440, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.5]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, FSinOsc.kr(imp).range(0.4, 0.6), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\triSaw) { |out=0, freq=150, imp=1, sustain=1, amp=0.5|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.75]), 1, doneAction: 2),
		vSaw = VarSaw.ar(freq, 0, LFTri.kr(imp).range(0, 1), amp),
		pan2 = Pan2.ar(vSaw, FSinOsc.kr(imp*2)*0.25),
		rvrb = FreeVerb.ar(pan2, 0.25, 1, 0.75);

	Out.ar(out, rvrb*sust);
}.add;

SynthDef(\uglySaw) { |out=0, sFreq=100, eFreq=200, imp=1, fadein=2, sustain=0.5, fadeout=1, curve=5, amp=0.5|
	var sust = EnvGen.kr(Env([0,1,1,0], [fadein,sustain,fadeout], [curve,0,curve]), 1, doneAction: 2),
		freq = EnvGen.kr(Env([sFreq, eFreq], [fadein], [curve]), 1),
		saw  = Saw.ar(freq, Saw.kr(50, amp/2)),
		vSaw = VarSaw.ar(freq, 0, FSinOsc.kr(imp).range(0.4, 0.7), amp/2),
		pan2 = Pan2.ar(vSaw+saw, FSinOsc.kr(fadein/2)/2);

	Out.ar(out, pan2*sust);
}.add;

SynthDef(\snare) { |out=0, freq=2500, decay=0.2, amp=0.5, pan=0|
	var eAmp = EnvGen.kr(Env.perc(0.005, decay), 1, doneAction: 2) * amp,
		drum = SinOsc.ar(freq, 0, GrayNoise.ar(eAmp*0.15)) + WhiteNoise.ar(eAmp*0.5),
		pan2 = Pan2.ar(drum, pan);

	Out.ar(out, pan2);
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

	// 1 loop = 0.5s
	~staccato = { |synth, loops=inf, amp=0.5, reverse=false, pitchShift=1|
		var freq = [440, 220, 550, 330];

		if (reverse, { freq = freq.reverse; });

		Pbind(
			\instrument, synth,
			\freq, Pstutter(
				Pseq([2], inf),
				Pseq(freq*pitchShift, inf)
			),
			\dur, Pseq([0.125, 0.375], loops),
			\legato, Pseq([0.5, 0.125], inf),
			\amp, amp
		).play;
	};

	// 1 loop = 4s
	~staccatoAccomp = { |loops=inf, reverse=false|
		Routine({
			loops.do({
				~staccato.value(\mutedBlip, 4, 0.25, reverse, 2); // 2s
				4.wait;
			});
		}).play;
	};

	// 1 loop = 1s
	~chorus = { |synth, loops=inf, amp=0.25, imp=0.5, pitchShift=1|
		Pbind(
			\instrument, synth,
			\freq, Pseq([660, 440, 770, 550]*pitchShift, inf),
			\dur, Pseq([1], loops),
			\legato, Pseq([0.75], inf),
			\imp, imp,
			\amp, amp
		).play;
	};

	// 1 loop = 6s
	~bassDrum = { |loops=inf, amp=0.5|
		Pbind(
			\instrument, \bass,
			\freq, 85,
			\dur, Pstutter(
				Pseq([2, 8], inf),
				Pseq([1, 0.5], loops)
			),
			\amp, amp
		).play;
	};

	// 1 loop = 1s
	~snareDrum = { |loops=inf, amp=0.5|
		Pbind(
			\instrument, \snare,
			\dur, Pseq([1], loops),
			\amp, amp
		).play;
	};



	~staccato.value(\mutedBlip, 7); // 3.5s
	(3.5).wait;

	// @todo Tweak this length sometime
	Synth(\triSaw, [\freq, 220, \sustain, 100, \amp, 0.05, \imp, 0.08333333333]); // 100s
	(0.5).wait;

	~chorus.value(\mutedBell, 20); // 20s
	4.wait;

	~staccato.value(\mutedBell, 24, 0.25); // 12s
	(2.25).wait;

	~staccatoAccomp.value(7); // 28s
	(7.75).wait;

	~bassDrum.value(6); // 36s
	8.wait;

	~chorus.value(\triSaw, 24, 0.25, 0.25, 0.1); // 24s
	8.wait;

	~chorus.value(\mutedBell, 20); // 20s
	(0.5).wait;

	~snareDrum.value(8); // 4s
	(3.5).wait;

	~staccato.value(\mutedBell, 24, 0.25); // 12s
	(4.25).wait;

	~staccatoAccomp.value(7, true); // 24s
	~snareDrum.value(1); // 1s
	(0.75).wait;

	~snareDrum.value(1); // 1s
	(0.5).wait;

	~snareDrum.value(8); // 8s
	(2.5).wait;

	// @todo Animals Are Ugly style low-freq saw build-up
	// @todo Ending would work with the stacco playing all alone
}).play;