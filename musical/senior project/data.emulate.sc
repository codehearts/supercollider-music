// 1m31s

var routFactory,
	plicker,
	panPlicker,
	panPlicker2,
	panPlicker3,
	doublePlicker;

SynthDef(\background) { |out=0|
	var pink     = PinkNoise.ar(0.05),
		brown    = BrownNoise.ar(0.05),
		pinkPan  = Pan2.ar(pink, FSinOsc.kr(1)),
		brownPan = Pan2.ar(brown, FSinOsc.kr(0.5));
	Out.ar(out, pinkPan+brownPan);
}.send(s);

SynthDef(\plick) { |out=0, freq=1000, atk=0.005, dec=1|
	var sine  = SinOsc.ar(freq, 0, 0.25),
		saw   = Saw.ar(freq*1.25, 0.25),
		env   = EnvGen.kr(Env.perc(atk, dec*1.5), 1, doneAction: 2),
		eSine = sine*env,
		eSaw  = saw*(env*0.5),
		rvrb  = AllpassC.ar(eSine+eSaw, 0.025, 0.001, dec);
	Out.ar(out, rvrb);
}.send(s);

SynthDef(\sinebass) { |out=0, freq=100, imp=1|
	var sine = SinOsc.ar(
		freq,
		0,
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)
	);
	Out.ar(out, sine);
}.send(s);

SynthDef(\beep) { |out=0, freq=440, amp=1, dur=1|
	var sine = SinOsc.ar(
		freq,
		0,
		Trig.kr(Line.kr(1, 0, dur), dur)
	),
	ring = Ringz.ar(sine, 2000, dur, amp);
	Out.ar(out, ring);
}.send(s);

SynthDef(\noisePulse) { |out=0, imp=2, amp=0.1|
	var noise = WhiteNoise.ar(
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	);
	Out.ar(out, noise);
}.send(s);

SynthDef(\panNoisePulse) { |imp=2, amp=0.1|
	var noise = WhiteNoise.ar(
		Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1)*amp
	);
	Out.ar(Stepper.kr(Impulse.kr(2*imp), 0, 0, 1, 1), noise);
}.send(s);

// Returns a simple one-channel plicker routine
plicker = { |delay=1|
	Routine.new({
		var freq = 500,
			rDelay = delay;
	
		loop({
			Synth(\plick, [\freq, freq]);
			freq = freq+250;
			if (freq == 1500, {
				freq = 500;
			});
			
			rDelay.wait;
		});
	}).play;
};

// Generate two panning plickers to use
routFactory = {
	{ |delay=1|
		Routine({
			var freq = 500,
				out  = 0,
				rDelay = delay;
		 	
			loop({
				Synth(\plick, [\out, out, \freq, freq]);
				
				if (out == 0, {
					out = 1;
				}, {
					out = 0;
				});
		
				freq = freq+250;
				if (freq == 1500, {
					freq = 500;
				});
		
				rDelay.wait;
			});
		}).play;
	};
};
panPlicker = routFactory.value;
panPlicker.reset;
panPlicker2 = routFactory.value;
panPlicker2.reset;
panPlicker3 = routFactory.value;
panPlicker3.reset;















// Music starts here
Routine({
var bg,
	plicks = (),
	sbass  = (),
	noise  = (),
	beeps;

bg = Synth(\background);
4.wait;

// Loops every 2 seconds
sbass[0] = Synth(\sinebass);
4.wait;

// Triple impulse bass routine
// Reserves indexes 1, 2
// Loops every 8 seconds
sbass[2] = Routine({
	loop({
		3.do({
			sbass[1] = Synth(\sinebass, [\out, 1, \freq, 150, \imp, 6]);
			1.wait;
			sbass[1].free;
			1.wait;
		});
		2.wait;
	});
}).play;
8.wait;

plicks[0] = panPlicker.value(2);
8.wait;

plicks[0].stop;
sbass[0].free;
sbass[1].free;
sbass[2].stop;

// Reserves indexes 3, 4, 5
// Loops every 4 seconds
sbass[3] = Routine({
	sbass[4] = Synth(\sinebass, [\imp, 0.5]);
	(0.5).wait;
	sbass[5] = Synth(\sinebass, [\out, 1, \imp, 0.5]);
}).play;
(7.5).wait;

sbass[3].stop;
sbass[4].free;
sbass[5].free;

sbass[7] = Routine({
	loop({
		sbass[6] = Synth(\sinebass, [\imp, 1]);
		1.wait;
		sbass[6].free;
		1.wait;
	});
}).play;
(1.25).wait;

sbass[8] = Routine({
	loop({
		sbass[9] = Synth(\sinebass, [\out, 1, \freq, 175, \imp, 0.25]);
		(0.75).wait;
		sbass[9].free;
		(1.25).wait;
	});
}).play;
4.wait;

beeps = Routine({
	loop({
		Synth(\beep, [\out, rrand(0, 1), \freq, rrand(750, 1250), \dur, rrand(0.1, 0.25), \amp, 0.25]);
		(0.5).wait;
	});
}).play;
4.wait;

// Triple impulse noise routine
// Reserves indexes 0, 1
// Loops every 8 seconds
noise[1] = Routine({
	loop({
		3.do({
			noise[0] = Synth(\panNoisePulse, [\imp, 6, \amp, 0.05]);
			1.wait;
			noise[0].free;
			1.wait;
		});
		2.wait;
	});
}).play;
1.wait;

beeps.stop;
(5.5).wait;

beeps.reset.play;
(2.5).wait;

beeps.stop;
noise[1].stop;
8.wait;

plicks[0] = plicker.value(1);
4.wait;

plicks[0].stop;
plicks[1] = panPlicker.value(1);
(4.75).wait;

// This plicker sort of doubles up with the other one
// Reserves indexes 2, 3
plicks[3] = Routine({
	loop({
		plicks[2] = panPlicker2.value(1);
		(1.75).wait;
		plicks[2].stop;
		(2.25).wait;
	});
}).play;
5.25.wait;

plicks[4] = panPlicker3.value(0.5);
4.wait;

plicks[4].stop;
plicks[4] = panPlicker3.value(0.25);
(4.75).wait;

plicks[4].stop;
plicks[4] = panPlicker3.value(0.125);
1.wait;

plicks[4].stop;
plicks[4] = panPlicker3.value(0.0625);
(0.5).wait;

plicks[4].stop;
1.5.wait;

plicks[3].stop;
plicks[2].stop;
(4.75).wait;

plicks[4] = panPlicker3.value(0.125);
1.wait;

plicks[4].stop;
plicks[4] = panPlicker3.value(0.0625);
(0.5).wait;

plicks[4].stop;
plicks[1].stop;
sbass[6].free;
sbass[7].stop;
sbass[8].stop;
1.wait;

bg.free;

"It's Over".postln;

}).play;

"Now Playing";