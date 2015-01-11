"~/Music/supercollider-music/samples/samples.sc".standardizePath.loadPaths;

SynthDef(\cutBuf) { |out=0, imp=2.5, sustain=4, amp=0.25, pb_rate=0.618, buf|
	var samp = GrainBuf.ar(
			buf.numChannels, // number of channels
			1, // trigger
			sustain, // duration
			buf,
			pb_rate, // playback rate
			0, // position
			0, // linear interpolation
			0, // panning
			Buffer.sendCollection(
				s,
				Env.new([0.75, 1], [1], [0]).discretize,
				buf.numChannels
			)
		),
		sEnv = EnvGen.kr(Env([amp, amp, 0], [sustain, 0.75], [0, 1]), 1, doneAction: 2),
		//cStp = Stepper.kr(Impulse.kr(imp), 0, 0, 1, 1),
		cStp = Pulse.kr(imp, 0.5),
		pan2 = Pan2.ar(samp * sEnv * cStp, FSinOsc.kr(0.5));

	Out.ar(out, pan2);
}.add;

Buffer.readChannel(s, a[15], channels: 0, action: { |ra1_buf|
	"Receive Assimilation I loaded".postln;
Buffer.readChannel(s, a[16], channels: 0, action: { |ra2_buf|
	"Receive Assimilation II loaded".postln;
Buffer.readChannel(s, a[17], channels: 0, action: { |ra3_buf|
	"Receive Assimilation III loaded".postln;
Routine({

~breakBuf = { |synth, buf, amp, imps, durs, loops=1|
	var sust = loops * durs.sum,
		sImp = Pseq(imps.asArray, inf).asStream,
		sDur = Pseq(durs.asArray, inf).asStream,
		inst = Synth(synth, [\buf, buf, \sustain, sust, \amp, amp, \imp, sImp.next]);

	Routine({
		(loops * imps.size - 1).do({
			sDur.next.wait;
			inst.set(\imp, sImp.next);
		});
	}).play;
};

~breakBuf.value(\cutBuf, ra2_buf, 0.5, [1, 2.5, 10], [8, 4, 3, 1], 2);

}).play;
}); // ra3_buf
}); // ra2_buf
}); // ra1_buf