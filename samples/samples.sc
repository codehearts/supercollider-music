/**
 * Sets global variables with a list of available audio samples
 * a - An array of paths to all available audio files
 * p - A method that takes in an audio file path, reads it as a buffer, and plays it
 */

var dir = "~/Music/supercollider-music/samples/".standardizePath;
a = [
	dir++"Cello II.aiff",       // 0
	dir++"City of Julie.aiff",  // 1
	dir++"Code Couleur.aiff",   // 2
	dir++"Denjiha.aiff",        // 3
	dir++"Drum & Babass.aiff",  // 4
	dir++"Kaliba.aiff",         // 5
	dir++"Rebonddent.aiff",     // 6
	dir++"Track 30.aiff",       // 7
	dir++"Viens, va-t-en.aiff", // 8
	dir++"Wind.aiff",           // 9
	dir++"hk1.aiff",            // 10
	dir++"hk2.aiff",            // 11
	dir++"fru.aiff",            // 12
	dir++"svc1.aiff",           // 13
	dir++"svc2.aiff",           // 14
	dir++"rec_assim_1.aiff",    // 15
	dir++"rec_assim_2.aiff",    // 16
	dir++"rec_assim_3.aiff"     // 17
	];

p = { |file|
	Buffer.read(s, file, action: { |buf|
		{ PlayBuf.ar(buf.numChannels, buf, BufRateScale.kr(buf), doneAction: 2) }.play;
	});
};

"Audio sample array initialized";