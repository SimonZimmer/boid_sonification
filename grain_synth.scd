Server.default=s=Server.local;
s.reboot

//paramter:
// - all axis: panning
// - distance to main camera: volume
// - x-axis: filter res
// - y-axis: grain startPos
// - z-axis: filter cutoff frequency
// - speed of boid (0,1): retrigger rate of grain (0,1)
// - distance to flock (0,1): release of grain (0,1)

//multichannel help file
//group help file
//Array a einer Gruppe aus EventStreamPlayern je boid eine Gruppe mit jeweiligen paramtern
//a[index].player = Pbind

//create group:
/*g = Group()

(
(
group: g,
dur: 1000,
).play
)

g.set(\freq, 100)
g.free*/

//define Array for synth groups
~allSynthGroups = Array.fill(50, {(x:0, y:0, z:0, s:0)})

~allSynthGroups[0].z = 10;

//define group
g = Group();


//define sine synth
(
SynthDef(\sine, {arg amp=1,cutOff=20000;
	var sig, env;
	env = EnvGen.kr(Env.new([0, 1, 0],[0.01,0.1,0.005], [1, -1]), doneAction:2);
	sig = WhiteNoise.ar()*env*amp;
	Out.ar(0,RLPF.ar(sig.dup,cutOff,0.1));
}).add;
)

(
p = Pbind(
	\instrument, \sine,
	\amp,Pfunc {~control},
	\dur, 0.25;
).play.trace;
)
~control =0.6;

(
//OSC messages

OSCdef.new(\numBoids,
{
	arg msg;
	//post received message
	msg[0].postln;
	msg[1].postln;
},
'/numBoids',
nil, 57120
);


/*OSCdef.new(\yCoord,
{
	arg msg, msgMap;
	//post received message
	msgMap = LinLin.ar(msg[1], -20,20, 50, 20000);
	//msgMap.postln;
	//~ampControl = 0.1;
},
'/yCoord',
nil, 57120
);*/

~ampControl = 0.1;
//OSC action for "instantiate"
OSCdef.new(\instantiate,
{
	arg msg;
	var index = msg[1];
	//post received message
	msg[0].postln;
	//start sequence
	p = Pbind(
	\instrument, \sine,
	\dur, 0.5,
	\amp,Pfunc {~ampControl},
	).play.trace;
},
'/instantiate',
nil, 57120
);

//OSC action for "destroy"
OSCdef.new(\destroy,
{
	arg msg;
	//post received message
	//[msg[0]].postln;
	//remove first instantiated grain synth from array
/*	synth_array.put (0, nil);*/
},
'/destroy',
nil, 57120
);

)




//define synth array
(
var synth_array = Array.new(50);
synth_array.insert(Synth(\sine,[\amp,rrand(0.2,1.0), \freq,rrand(100,600)]));
synth_array.postln;
/*synth_array.put (0, nil);*/
)

	(
	// make two control rate busses and set their values to 880 and 884.
	b = Bus.control(s, 1); b.set(880);
	c = Bus.control(s, 1);	c.set(884);
	// and make a synth with two frequency arguments

	(
	x = SynthDef(\synth, { arg freq1 = 440, freq2 = 440;
		Out.ar(0, SinOsc.ar([freq1, freq2], 0, 0.1));
	}).play(s);
	)

	// Now map freq1 and freq2 to read from the two busses
	x.map(\freq1, b.index, \freq2, c.index);

	// Now make a Synth to write to the one of the busses
	y = {Out.kr(b.index, SinOsc.kr(1, 0, 50, 880))}.play(addAction: \addToHead);

	// free y, and b holds its last value
	y.free;

	// use Bus-get to see what the value is. Watch the post window
	b.get({ arg val; val.postln; f = val; });

	b.set(\freq2,f/2)
	// set the freq2, this 'unmaps' it from c
	x.set(\freq2, f / 2);

	// freq2 is no longer mapped, so setting c to a different value has no effect
	c.set(200);

	x.free; b.free; c.free;
	)





//read buffer
b = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
//define grain synth
(
SynthDef(\sfgrain, {arg bufnum=0, pan=0.0, startPos=0.0, amp=0.1, dur=0.0001, loop=1;
	var grain;

	grain= PlayBuf.ar(1,bufnum, BufRateScale.kr(bufnum), 1, BufFrames.ir(bufnum)*startPos,loop= 1)*(EnvGen.kr(Env.perc(0.01,dur),doneAction:2)-0.001);

	Out.ar(0,Pan2.ar(grain, pan))}).add;
).add;
)

//play individual grain
Synth(\sfgrain,[\bufnum, b.bufnum, \startPos,rrand(0.0,1.0),\amp, exprand(0.005,0.1), \pan, 1.0.rand2]);