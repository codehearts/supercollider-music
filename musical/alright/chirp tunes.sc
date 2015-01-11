SynthDef(\square) { |out=0, sustain=1, freq=440, pan=0, amp=0.25|
	var sust = EnvGen.kr(Env([1,1,0], [sustain, 0.005]), 1, doneAction: 2),
		sqre = Pulse.ar(freq, 0.5, amp),
		pan2 = Pan2.ar(sqre, pan);
	
	Out.ar(out, pan2*sust);
}.add;

SynthDef(\reverb) { |out=0, mix=0.5, room=0.5, damp=0.5|
	var in   = In.ar(out, 2),
		rvrb = FreeVerb.ar(in, mix, room, damp);
	
	ReplaceOut.ar(out, rvrb);
}.add;



Routine({
	
	
	
	// 1 loop = 0.5s
	~staccato = { |synth, loops=inf, amp=0.5, reverse=false, pitchShift=1, group=nil, addAction=0|
		var freq = [440, 220, 550, 330];
		
		if (reverse, { freq = freq.reverse; });
		
		Pbind(
			\instrument, synth,
			\group, group,
			\addAction, addAction,
			\freq, Pstutter(
				Pseq([2], inf),
				Pseq(freq*pitchShift, inf)
			),
			\dur, Pseq([0.125, 0.375], loops),
			\legato, Pseq([0.5, 0.125], inf),
			\amp, amp
		).play;
	};
	
	// 1 loop = 1s
	// Melody loops once every 8 seconds
	~harmony = { |synth, loops=inf, amp=0.25, group=nil, addAction=0|
		Pbind(
			\instrument, synth,
			\group, group,
			\addAction, addAction,
			\freq, Pseq([500,750,600,450, 500,750,600,875], inf),
			\dur, Pseq([1], loops),
			\legato, 1,
			\amp, amp
		).play;
	};
	
	// 1 loop = 1s
	~bumps = { |synth, loops=inf, amp=0.25, group=nil, addAction=0|
		Pbind(
			\instrument, synth,
			\group, group,
			\addAction, addAction,
			\freq, Pseq([100], inf),
			\dur, PdurStutter(
				Pstutter(
					Pseq([8, 1, 7], inf), // @todo Try using mouseY to power this
					Pseq([1, 4, 1], inf)
				),
				Pseq([0.5, 0.5], loops)
			),
			\legato, Pseq([0.25], inf),
			\amp, amp
		).play;
	};
	
	
	
	~reverb = Group.new;
	Synth.after(~reverb, \reverb, [\out, 0, \mix, 0.5, \room, 1, \damp, 0]);
	
	
	
	//~staccato.value(\square, 7, 0.25); // 3.5s
	~harmony.value(\square, 16, 0.1, ~reverb); // 16s
	~bumps.value(\square, 16, 0.25, ~reverb);
	
	// @todo Turn this into something I perform on my own
	
	
}).play;