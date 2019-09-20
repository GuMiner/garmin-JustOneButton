using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;

class JustOneButtonView extends WatchUi.View {
	const AUTH_HEADER = "Bearer ..."; 

	var queriedSwitchState = false;
	var gotValidState = false;
	var hitError = false;
	
	var isLightOff = false;
	
	var pendingToggle = false;
	
	var inputSyncState; // HomeHelperInputSyncState
	function initialize(state) {
		inputSyncState = state;
		View.initialize();
	}
	
	function onSwitchStatusResponse(responseCode, data) {
		if (responseCode == 200) {
			gotValidState = true;
      		if("off".equals(data["state"]))
      		{
      			isLightOff = true;
      		}
       	}
   		else {
       		hitError = true;
   		}
   		
   		WatchUi.requestUpdate();
	}
	
	function onSwitchToggleResponse(responseCode, data) {
		pendingToggle = false;
		if (responseCode == 200) {
			isLightOff = !isLightOff;
			getSwitchStatus();
       	}
   		else {
       		hitError = true;
   		}
   		
   		WatchUi.requestUpdate();
	}
	
	function getSwitchStatus() {
    	var url = "switch_status"; 
    	
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
    		:headers => {
    			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
    			"Authorization" => AUTH_HEADER
    		},
    		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	
    	Communications.makeWebRequest(url, {}, options, method(:onSwitchStatusResponse));
	}
	
	function toggleSwitchState() {
    	var url = "";
    	if (isLightOff) {
    		url = "turn_on";
    	} else {
    		url = "turn_off";
    	}
    	
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_POST,
    		:headers => {
    			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
    			"Authorization" => AUTH_HEADER
    		},
    		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	
    	Communications.makeWebRequest(url, { "entity_id" => "the entity id" }, options, method(:onSwitchToggleResponse));
	}

    // Update the view
    function onUpdate(dc) {
		//// Handle switch state updates    
    	if (!queriedSwitchState) {
    		queriedSwitchState = true;
    		getSwitchStatus();
    	}
    	
    	if (gotValidState && inputSyncState.toggleSwitch) {
    		inputSyncState.toggleSwitch = false;
    		pendingToggle = true;
    		toggleSwitchState();
    	}
    	
    	//// Render appropriately
    	// Reset the background
        dc.clearClip();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        
        var lightStateColor = Graphics.COLOR_LT_GRAY;
        if (gotValidState)
        {
        	if (isLightOff)
        	{
        		lightStateColor = Graphics.COLOR_RED;
    		}
    		else
    		{
    			lightStateColor = Graphics.COLOR_GREEN;
    		}
        }
        
        var pendingColor = Graphics.COLOR_BLUE;
        if (hitError)
        {
        	pendingColor = Graphics.COLOR_DK_RED;
        }
        else if (pendingToggle)
        {
        	pendingColor = Graphics.COLOR_YELLOW;
        }

        dc.setColor(pendingColor, Graphics.COLOR_BLUE);
        dc.fillCircle(120, 120, 80);
        
        dc.setColor(lightStateColor, Graphics.COLOR_WHITE);
        dc.fillCircle(120, 120, SyncState.BUTTON_RADIUS);
    }
}
