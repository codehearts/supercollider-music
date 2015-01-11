SynthDef(\glitch) { |out=0, freqmax=1e4, bandrange=50|
	var osc;
	
	osc = Limiter.ar(
		LeakDC.ar(
			SinOsc.ar(
				0.11,
				BRF.ar(
					SinOsc.ar(
						SinOsc.ar(0.12).exprange(1, freqmax),
						2pi
					),
					1 / SinOsc.ar(0.13, 6pi).range(1, bandrange)
				)
			)
		)
	);
	
	Out.ar(out, osc);
}.send(s);



// I want that pitch-shift down sound that comes in the right channel after a few seconds!
Routine({
	Synth(\glitch, [\bandrange, [25, 100]]);
	Synth(\glitch, [\out, 1, \freqmax, 1e2, \bandrange, [100, 25]]);
}).play;