"~/Music/SC/samples/samples.sc".standardizePath.loadPaths;

SynthDef(\square) { |out=0, freq=440, amp=0.25, pan=0, sustain=1|
	var env  = EnvGen.kr(Env([0.5, 1, 0], [sustain, 0.1]), 1, doneAction: 2),
		sqr  = (Pulse.ar(freq, 0.5, amp)+Saw.ar(freq, amp*0.25))*env,
		pan2 = Pan2.ar(sqr, pan);
	
	Out.ar(out, pan2);
}.add;

SynthDef(\squareFade) { |out=0, freq=440, amp=0.25, sustain=1, curve=0|
	var env  = EnvGen.kr(Env([amp/2, amp, amp/2], [0.1, sustain-0.1], curve), 1, doneAction: 2),
		trem = SinOsc.kr(1),
		sqr  = Pulse.ar(freq, 0.5, (amp*0.75)+(abs(trem)*(amp*0.25)))*env,
		pan  = Pan2.ar(sqr, Line.kr(-1, 1, sustain));
	
	Out.ar(out, pan);
}.add;

SynthDef(\squareSpace) { |out=0, freq=440, amp=0.25, pan=0, gate=1|
	var env  = EnvGen.kr(Env.cutoff(4, amp), gate, doneAction: 2),
		inst = Pulse.ar(freq, 0.5, amp)*env,
		rvrb = FreeVerb.ar(inst, 0.75, 0.75, 0.5),
		pan2 = Pan2.ar(rvrb, pan);
	
	Out.ar(out, pan2);
}.add;

SynthDef(\leaves) { |out=0, gate=1, fadeIn=1, fadeOut=1, rate=4, density=25, amp=1, buf|
	var chan = buf.numChannels,
		samp = GrainBuf.ar(
			chan, // number of channels
			LFNoise1.kr(density), // trigger
			LFNoise1.kr.range(0.1, 0.25), // duration
			buf,
			rate, // playback rate
			LFNoise0.kr.range(0,1), // position
			2, // interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env([0, 0.5, 1, 0.25], [0.05, 0.05, 0.1], [2.5, -2.5, -5]).discretize,
				chan
			)
		) * XLine.kr(0.005, amp, fadeIn),
		env  = EnvGen.kr(Env.cutoff(fadeOut, 1), gate, doneAction: 2) * samp,
		rvrb = FreeVerb2.ar(env, env, 0.5, 1, 0),
		pan2 = Pan2.ar(rvrb, LFNoise0.kr(density, -1, 2)-1);
	
	Out.ar(out, pan2);
}.send(s);



Buffer.readChannel(s, a[5], channels: 0, action: { |kbuf|
	"Kalimbas loaded".postln;
	
Routine({
	var flourish,
		chimes,
		bass;
	
	flourish = Routine({
		var sustain = 32, // Should be divisible by 4
			leaf;

		leaf = Synth(\leaves, [\buf, kbuf, \fadeIn, 2, \fadeOut, 4, \density, 25, \amp, 0.15]);

		(sustain/4).do({ |i|
			var rate = (i+1)%5+1,
				dens = (i+1)%20*5+5;

			leaf.set(\rate, rate);
			leaf.set(\density, dens);

			4.wait;
		});

		leaf.set(\gate, 0);
	});
	
	bass = Routine({
		var loops  = 64,
			freq   = Pstutter(
				Pseq([10, 6, 14, 1], loops),
				Pseq([100, 61.8, 50, 161.8], loops)
			).asStream,
			legato = Pseq([2], loops).asStream,
			durs   = PdurStutter(
				Pseq([1,1,1,1,1,1, 2,2, 1,1,2,2,1,1, 2,4,6,1], loops),
				Pseq([1,1,1,1,1,1, 1,1, 1,1,1,1,1,1, 0.5,0.5,0.5,0.5], loops)
			).asStream;

		loops.do({ |i|
			var leg = legato.next,
				dur = durs.next,
				square = Synth(\square, [\freq, freq.next, \sustain, dur/leg, \amp, 0.15]);

			dur.wait;
		});
	});
	
	chimes = Routine({
		var loops   = 10,
			waitFor = 4,
			dur     = 0.1;

		loops.do({ |i|
			var freqs = [100, 161.8, 261.8, 423.6, 685.4, 1108.9]*(((i+1)%3)+1),
				stut = [1,1,1,1,1,1];

			if ((i+1)%4 == 0, {
				stut[1] = 6;
			});

			if ((i+1)%6 == 0, {
				stut = [2,2,2,2,2,2];
			});

			Pbind(
				\instrument, \squareSpace,
				\freq, Pstutter(
					Pseq(stut, 1),
					Pseq(freqs, 1)
				),
				\dur, PdurStutter(
					Pseq([1, 2, 3, 4, 5, 6], 1),
					dur
				),
				\amp, 0.2
			).play;

			waitFor.wait;
		});
	});
	
	
	flourish.play;
	8.wait;
	bass.play;
	16.wait;
	chimes.play;
	
	
	
	/*squares = Routine({
		var loops     = 32,
			changes   = 2,
			softLoops = loops/changes,
			sustain   = 0.05;
		
		softLoops.do({ |i|
			var freqs = Pshuf([100, 200, 300, 400, 500], changes);
			
			freqs.do({ |freq|
				var square = Synth(\square, [\freq, freq, \amp, 0.5]);
				
				sustain.wait;
				square.set(\gate, 0);
			});
		});
	}).play;*/
	
	/*Routine({
		var loops = 50,
			dur   = 0.1;
		
		loops.do({ |i|
			var freqs = [423.6, 1108.9, 685.4, 261.8, 161.8];
			
			if (i%2 == 0, { freqs[1] = 161.8;  });
			if (i%3 == 0, { freqs[2] = 261.8;  });
			if (i%4 == 0, { freqs[3] = 685.4;  });
			if (i%5 == 0, { freqs[4] = 1108.9; });
			
			freqs.do({ |freq, j|
				var square = Synth(\square, [\freq, freq, \amp, 0.25]);

				dur.wait;
				square.set(\gate, 0);
			});
		});
	}).play;*/
	
	/*Routine({
		var loops = 8,
			dur   = 0.25;
		
		loops.do({ |i|
			var freqs = Pseq([1108.9, 161.8, 423.6, 261.8, 423.6, 261.8, 685.4, 423.6], 1, i).asStream;
			
			freqs.do({ |freq, j|
				var square = Synth(\square, [\freq, freq, \amp, 0.3]);

				dur.wait;
				square.set(\gate, 0);
			});
		});
	}).play;*/
	
	/*Routine({
		var loops = 32,
			freqs = Pseq([1108.9, 685.4, 423.6, 261.8, 423.6, 261.8, 161.8, 423.6], loops).asStream,
			dur   = Pseq([1, 0.75, 0.5, 0.75, 1], loops).asStream;
		
		loops.do({ |i|
			var square = Synth(\square, [\freq, freqs.next, \amp, 0.25]);
			
			dur.next.wait;
			square.set(\gate, 0);
		});
	}).play;*/
	
	/*Routine({
		var loops = 32,
			freqs = Pseq([1108.9, 685.4, 423.6, 261.8, 161.8, 100], loops).asStream,
			dur   = PdurStutter(
				Pseq([2,2,2,2,2,2, 1,0.5,1,0.5,1,0.5], loops),
				Pseq([0.1], loops)
			).asStream;
		
		loops.do({ |i|
			var square = Synth(\square, [\freq, freqs.next, \amp, 0.2]);
			
			dur.next.wait;
			square.set(\gate, 0);
		});
	}).play;*/
	
}).play;
});