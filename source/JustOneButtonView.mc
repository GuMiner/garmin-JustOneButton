using Toybox.Application;
using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;

class JustOneButtonView extends WatchUi.View {
	var getOptions;
	var postOptions;

	var queriedSwitchState = false;
	var gotValidState = false;
	var hitError = false;
	
	var isSwitchOff = false;
	var pendingToggle = false;
	
	var inputSyncState;
	function initialize(state) {
		inputSyncState = state;
		
		var authToken = Lang.format("Bearer $1$", [Application.getApp().getProperty("AuthBearerToken")]);
		getOptions = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
    		:headers => {
    			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
    			"Authorization" => authToken
    		},
    		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	
    	postOptions = {
    		:method => Communications.HTTP_REQUEST_METHOD_POST,
    		:headers => {
    			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
    			"Authorization" => authToken
    		},
    		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
		
		View.initialize();
	}
	
	function onSwitchStatusResponse(responseCode, data) {
		if (responseCode == 200) {
			gotValidState = true;
      		if("off".equals(data["state"]))
      		{
      			isSwitchOff = true;
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
			isSwitchOff = !isSwitchOff;
			getSwitchStatus();
       	}
   		else {
       		hitError = true;
   		}
   		
   		WatchUi.requestUpdate();
	}
	
	function getSwitchStatus() {
    	var url = Application.getApp().getProperty("StatusUri"); 
    	Communications.makeWebRequest(url, {}, getOptions, method(:onSwitchStatusResponse));
	}
	
	function toggleSwitchState() {
    	var url = "";
    	if (isSwitchOff) {
    		url = Application.getApp().getProperty("TurnOnUri");
    	} else {
    		url = Application.getApp().getProperty("TurnOffUri");
    	}
    	
    	var entityId = Application.getApp().getProperty("EntityId");
    	Communications.makeWebRequest(url, { "entity_id" => entityId }, postOptions, method(:onSwitchToggleResponse));
	}
	
	function getRingColor() {
		var ringColor = Graphics.COLOR_BLUE;
        if (hitError)
        {
        	ringColor = Graphics.COLOR_DK_RED;
        }
        else if (pendingToggle)
        {
        	ringColor = Graphics.COLOR_YELLOW;
        }
        
        return ringColor;
	}
	
	function getButtonColor() {
		var buttonColor = Graphics.COLOR_LT_GRAY;
        if (gotValidState)
        {
        	if (isSwitchOff)
        	{
        		buttonColor = Graphics.COLOR_RED;
    		}
    		else
    		{
    			buttonColor = Graphics.COLOR_GREEN;
    		}
        }
        
        return buttonColor;
	}

    function onUpdate(dc) {
		// Handle switch input / status updates.    
    	if (!queriedSwitchState) {
    		queriedSwitchState = true;
    		getSwitchStatus();
    	}
    	
    	if (gotValidState && inputSyncState.toggleSwitch) {
    		inputSyncState.toggleSwitch = false;
    		pendingToggle = true;
    		toggleSwitchState();
    	}
    	
    	// Render
        dc.clearClip();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        dc.setColor(getRingColor(), Graphics.COLOR_BLUE);
        dc.fillCircle(120, 120, SyncState.RING_RADIUS);
        
        dc.setColor(getButtonColor(), Graphics.COLOR_WHITE);
        dc.fillCircle(120, 120, SyncState.BUTTON_RADIUS);
    }
}
