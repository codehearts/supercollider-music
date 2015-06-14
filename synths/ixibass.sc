SynthDef(\ixibass, {arg out=0, amp=0.3, t_trig=1, freq=100, rq=0.004;
	var env, signal;
	var rho, theta, b1, b2;
	b1 = 1.98 * 0.989999999 * cos(0.09);
	b2 = 0.998057.neg;
	signal = SOS.ar(K2A.ar(t_trig), 0.123, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal, freq, rq) + RHPF.ar(signal, freq*0.5, rq);
	signal = Decay2.ar(signal, 0.4, 0.3, signal);
	DetectSilence.ar(signal, 0.01, doneAction:2);
	Out.ar(out, signal*(amp*0.45)!2);
}).add;


(
Pmono(\ixibass,
  \dur, Pseq([0.25, 0.25, 0.5, 0.75], inf),
  \midinote, Pseq([ 60, 50, 48, 62, 70] , inf)).play;

Pmono(\ixibass,
  \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.25], inf),
  \midinote, Pseq([ 48, 45, 48, 55, 57, 60, 50] , inf)).play(quant:[0,3.5,0])
)



Synth(\ixibass, [\freq, 110])
