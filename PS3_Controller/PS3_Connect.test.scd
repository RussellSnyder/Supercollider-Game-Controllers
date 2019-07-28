// Setup ////
(
// Load PS3_Connect ////
var testFile = thisProcess.nowExecutingPath.dirname +/+ "PS3_Connect.scd";
testFile.load;
~connectAndSetupPS3Controller.value(true);

// Mock Helpers
~ps3_test_helpers = Dictionary.new;

~ps3_test_helpers[\cb_gate_bool] = { | bool |
	if (bool,{
		true;
	},{
		false;
	})
};

~ps3_test_helpers[\cb_cc] = { | value |
	value
};

)

~ps3.postln;

/// Tests /////
(
// Should Silence All Controls
~ps3[\silence].value();
)

(
// Should Silence All Controls
~ps3[\panic].value();
)

(
// Should post when button from toggle group is pressed and released
~ps3[\control_group_toggle].do({
	| button |
	~ps3[button].value(~ps3_test_helpers[\cb_gate_bool]);
});
)

(
// Should silence toggle group responses and print to console
~ps3[\control_group_toggle].do({
	| button |
	~ps3[button].value(~ps3_test_helpers[\cb_gate_bool], true);
})
)

(
// Should post when joy Left Joy Xaxis is Moved
~ps3[\Joy_Left_Xaxis].value(~ps3_test_helpers[\cb_cc])
)

(
// Should post when joy Left Joy Yaxis is Moved
~ps3[\Joy_Left_Yaxis].value(~ps3_test_helpers[\cb_cc])
)

(
// Should post when joy Right Joy Y is Moved
~ps3[\Joy_Right_Yaxis].value(~ps3_test_helpers[\cb_cc])
)

(
// Should post when joy Right Joy X is Moved
~ps3[\Joy_Right_Xaxis].value(~ps3_test_helpers[\cb_cc])
)

(
// Should post when CC controls are touched
~ps3[\control_group_cc].do({
	| cc |
	~ps3[cc].value(~ps3_test_helpers[\cb_cc]);
});
)