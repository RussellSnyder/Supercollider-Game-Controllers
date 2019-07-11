// Connect PS3 controller and read input
HID.findAvailable;
HID.running;
HID.closeAll;

~ps3 = HID.open(1356, 616);
~ps3.close
~ps3.isOpen;

HID.debug = false;
HIDFunc.trace( false )
~ps3.action = { | value, physValue, rawValue, arrayValue, usage, page, elid | "HID device action: ".post; [value, physValue, rawValue, arrayValue, usage, page, elid].postln; };

~ps3.elements.at(50).action = nil;
~ps3.elements.at(66).action = { |value,element| "HID element action: ".post; [value,element].postln; };

// 0 = Joy_Left_Xaxis
// 1 = Joy_Left_Yaxis
// 2 = Joy_Right_Xaxis
// 3 = Joy_Right_Yaxis
// 4 = Select
// 5 = Joy_Left_Click
// 6 = Joy_Right_Click
// 7 = Start
// 8 = Arrow_Up
// 9 = Arrow_Right
// 10 = Arrow_Down
// 11 = Arrow_Left
// 12 = L2
// 13 = R2
// 14 = L1
// 15 = R1
// 16 - Triangle
// 17 - Circle
// 18 - X
// 19 - Square
// 20 - PS_Button
// 29 - Arrow_Up_CC
// 30 - Arrow_Right_CC
// 31 - Arrow_Down_CC
// 32 - Arrow_Left_CC
// 33 - L2_CC
// 34 - R2_CC
// 35 - L1_CC
// 36 - R1_CC
// 37 - Triangle_CC
// 38 - Circle_CC
// 39 - X_CC
// 40 - Square_CC

// 48 - Battery life?

// 57 - Roll
// 59 - Pitch

// 58 - ???

// 61 - Pitch #2?

// 60 Accellerometer?
// 62 Accell 2?
// 63 Accell 3?
// 64 Accell 4?
// 65 Accell 5?
// 66 Accell 6?




(
~cb_gate = { | bool |
	if (bool,{
		"On".postln;
	},{
		"Off".postln;
	})
};

~cb_joy = { | value |
	postf("%\n", value);
};

~map_joy = { | raw |
	LinLin.kr(raw, 0.0, 1.0, 1, -1)
};

c = Dictionary.new;
// ON/OFF send true false
// continuous data mapped 0 to 1;
c.add(\X -> {
	| cb, debug=false, silence=false |

	if(silence, {
			if (debug, {
				"X silence".post;
			});
		~ps3.elements.at(18).action = nil
	},{
		~ps3.elements.at(18).action = {
			|value,element|

			if (debug, {
				"X - ".post;
			});

			if(value == 1.0,{
				cb.value(true);
			},{
				cb.value(false);
			})
		}
	})
});

c.add(\Joy_Left_Xaxis -> {
	| cb, debug=false, silence=false |

	if(silence, {
			if (debug, {
				"Joy_Left_Xaxis silence".post;
			});
		~ps3.elements.at(0).action = nil
	},{
		~ps3.elements.at(0).action = {
			|raw|

		if (debug, {
			postf("Joy_Left_Xaxis raw %\n", raw);
		});

		cb.value(~map_joy.value(raw))
	}})
});


c.add(\Joy_Left_Yaxis -> {
	| cb, debug=false, silence=false |

	if(silence, {
			if (debug, {
				"Joy_Left_Yaxis silence".post;
			});
		~ps3.elements.at(1).action = nil
	},{
		~ps3.elements.at(1).action = {
			|raw|

		if (debug, {
			postf("Joy_Left_Yaxis raw %\n", raw);
		});

		cb.value(~map_joy.value(raw))
	}})
});

c.add(\Joy_Right_Xaxis -> {
	| cb, debug=false, silence=false |

	if(silence, {
			if (debug, {
				"Joy_Right_Xaxis silence".post;
			});
		~ps3.elements.at(2).action = nil
	},{
		~ps3.elements.at(2).action = {
			|raw|

		if (debug, {
			postf("Joy_Right_Xaxis raw %\n", raw);
		});

		cb.value(~map_joy.value(raw))
	}})
});

c.add(\Joy_Right_Yaxis -> {
	| cb, debug=false, silence=false |

	if(silence, {
			if (debug, {
				"Joy_Right_Yaxis silence".post;
			});
		~ps3.elements.at(18).action = nil
	},{
		~ps3.elements.at(3).action = {
			|raw|

		if (debug, {
			postf("Joy_Right_Yaxis raw %\n", raw);
		});

		cb.value(~map_joy.value(raw))
	}})
});

)

c.clear

// Testing
c[\X].value(~cb_gate, true, true);
c[\Joy_Left_Yaxis].value(~cb_joy, true, true);
c[\Joy_Right_Xaxis].value(~cb_joy);
c[\Joy_Right_Yaxis].value(~cb_joy, true);

(
SynthDef(\synthDefTest, {|out, gate=0, freq=440|
    Out.ar(out, SinOsc.ar(freq) * EnvGen.kr(Env.asr(0.1, 0.3, 1.3), gate, doneAction: Done.none));
}).store;
)

x = Synth(\synthDefTest);

c[\X].value({
	| on |
	if(on, {
		x.set(\gate, 1);
	},{
		x.set(\gate, 0);
	})
}, true);

x.free;
