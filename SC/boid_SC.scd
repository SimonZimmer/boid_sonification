s.reboot
s.meter;

{SinOsc.ar(400).dup}.play

(
SynthDef.new(\blipInstantiate, {
	arg amp=1;
	var sig, env;
	env = Line.kr(0,-80,rel, doneAction:2);
	sig = WhiteNoise.ar(0.25)*env.dbamp*amp;
	Out.ar(0,sig);
	Out.ar(1,sig);
}).store
)

x = {|rel=0.08| (Line.kr(0,-80,rel, doneAction:0)).dbamp*WhiteNoise.ar(0.25).dup}.play
x.set(\rel, 6);

(
p = Pbind(
	x, Pseq([1], inf);
).play;
)


//OSC messages
(
//instantiate
OSCdef.new(
	\instantiate,
	{
		arg msg;
		[msg[0]].postln;
		(
		p = Pbind(
			\instrument, \blipInstantiate,
			\dur, Pseq([1], inf);
		).play;
		)
	},
	'/instantiate',
	nil, 57120
);

/*OSCdef.new(
 	\boidspeed,
 	{
 		arg msg;
		[msg].postln;
		x.set(\amp, msg[1]);
 	},
 	'/boidspeed',
 	nil, 57120
);*/

//destroy
OSCdef.new(
	\destroy,
	{
		arg msg;
		[msg].postln;
	},
	'/destroy',
	nil, 57120
);
)