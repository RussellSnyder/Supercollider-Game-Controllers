(
~connectAndSetupPS3Controller = {
	arg debug=false;
	var keepLooking, mapPS3Data, mapJpy;

	~ps3 = Dictionary.new;
	~ps3ConnectedHardware = nil;

	Tdef( 'tryOpenHID' , {
		keepLooking = true;
		while ( { keepLooking } ){
			if ( ~ps3ConnectedHardware.notNil ){
				if ( ~ps3ConnectedHardware.isOpen ){
					keepLooking = false;
				}
			};
			if ( keepLooking ){
				HID.findAvailable;
				if ( HID.findBy(1356, 616).size > 0 ){
					~ps3ConnectedHardware = HID.open(1356, 616);
					if ( ~ps3ConnectedHardware.notNil ){
						~ps3ConnectedHardware.closeAction = {
							"device closed".postln;
							Tdef( \tryOpenHID ).reset.play;
						};
						keepLooking = false;
						"PS3 Controller Connected".postln;
						mapPS3Data.value();
					}{
						2.0.wait;
					};
				}{
					2.0.wait;
				}
			}
		}
	}).play;

	mapPS3Data = {
		"mapping things...".postln;

		~ps3.add(\isDebug -> debug);

		~ps3.add(\control_group_toggle -> [
			\Triangle, \Circle, \X, \Square,
			\Arrow_Up, \Arrow_Right, \Arrow_Down, \Arrow_Left,
			\L1, \L2, \R1, \R2,
			\Select, \Start, \PS_Button,
			\Joy_Left_Click, \Joy_Right_Click
		]);

		~ps3.add(\control_group_joy -> [
			\Joy_Left_Xaxis, \Joy_Left_Yaxis,
			\Joy_Right_Xaxis, \Joy_Right_Yaxis
		]);

		~ps3.add(\control_group_cc -> [
			\Arrow_Up_CC, \Arrow_Right_CC, \Arrow_Down_CC, \Arrow_Left_CC,
			\L2_CC, \R2_CC, \L1_CC, \R1_CC,
			\Triangle_CC, \Circle_CC, \X_CC, \Square_CC,
			\L2_CC, \R2_CC, \L1_CC, \R1_CC
		]);

		~ps3.add(\HIDMap -> Dictionary.with(*[
			\Joy_Left_Xaxis -> 0,
			\Joy_Left_Yaxis -> 1,
			\Joy_Right_Xaxis -> 2,
			\Joy_Right_Yaxis -> 3,
			\Select -> 4,
			\Joy_Left_Click -> 5,
			\Joy_Right_Click -> 6,
			\Start -> 7,
			\Arrow_Up -> 8,
			\Arrow_Right -> 9,
			\Arrow_Down -> 10,
			\Arrow_Left -> 11,
			\L2 -> 12,
			\R2 -> 13,
			\L1 -> 14,
			\R1 -> 15,
			\Triangle -> 16,
			\Circle -> 17,
			\X -> 18,
			\Square -> 19,
			\PS_Button -> 20,
			\Arrow_Up_CC -> 29,
			\Arrow_Right_CC -> 30,
			\Arrow_Down_CC -> 31,
			\Arrow_Left_CC -> 32,
			\L2_CC -> 33,
			\R2_CC -> 34,
			\L1_CC -> 35,
			\R1_CC -> 36,
			\Triangle_CC -> 37,
			\Circle_CC -> 38,
			\X_CC -> 39,
			\Square_CC -> 40,
			\Batterylife -> 48,
			\Roll -> 57,
			\Pitch -> 59,
			\IDK -> 58,
			\Pitch2 -> 61,
			\accell -> 60,
			\accell2 -> 62,
			\accell -> 63,
			\accell -> 64,
			\accell -> 65,
			\accell -> 66,
		]));

		// Toogles send true or false when they are pressed/release respectively
		~ps3[\control_group_toggle].do({
			| button, i |

			~ps3.add(button -> {
				| cb, silence=false |

				if(silence, {
					~ps3ConnectedHardware.elements.at(~ps3[\HIDMap][button]).action = nil;
					if (debug, {
						format("% silence", button).postln;
					});
				},{
					~ps3ConnectedHardware.elements.at(~ps3[\HIDMap][button]).action = {
						|value,element|

						if(value == 1.0,{
							cb.value(true);
							if (debug, {
								format("% - Pressed", button).postln;
							})
						},{
							cb.value(false);
							if (debug, {
								format("% - Released", button).postln;
							})
						})
					}
				})
			});
		});

		~ps3[\control_group_joy].do({
			| joy |

			~ps3.add(joy -> {
				| cb, silence=false |

				if(silence, {
					~ps3ConnectedHardware.elements.at(~ps3[\HIDMap][joy]).action = nil;
					if (debug, {
						format("% silence", joy).postln;
					});
				},{
					~ps3ConnectedHardware.elements.at(~ps3[\HIDMap][joy]).action = {
						| value |

						var mapped;

						if ((joy == \Joy_Left_Xaxis) || (joy == \Joy_Right_Xaxis), {
							mapped = LinLin.kr(value, 0.0, 1.0, -1, 1);
						}, {
							mapped = LinLin.kr(value, 0.0, 1.0, 1, -1);
						});

						cb.value(mapped);

						if (debug, {
							format("% - %", joy, mapped).postln;
						});
					}
				})
			});
		});

		~ps3[\control_group_cc].do({
			| cc |

			~ps3.add(cc -> {
				| cb, silence=false |

				if(silence, {
					~ps3ConnectedHardware.elements.at(~ps3[\HIDMap][cc]).action = nil;
					if (debug, {
						format("% silence", cc).postln;
					});
				},{
					~ps3ConnectedHardware.elements.at(~ps3[\HIDMap][cc]).action = {
						| value |

						cb.value(value);

						if (debug, {
							format("% - %", cc, value).postln;
						});
					}
				})
			});
		});

		~ps3[\silence] = {
			~ps3[\HIDMap].keysValuesDo({
				| key, value |

				~ps3ConnectedHardware.elements.at(value).action = nil;

			});
			if (debug, {
				"All PS3 controls silenced".postln;
			});
		};

		~ps3[\panic] = ~ps3[\silence];

		"PS3 Controller Ready!".postln;
	}
})