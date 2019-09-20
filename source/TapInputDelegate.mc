using Toybox.Math;
using Toybox.WatchUi;

class TapInputDelegate extends WatchUi.InputDelegate {
	var inputSyncState;	
	function initialize(state) {
		inputSyncState = state;
		InputDelegate.initialize();
	}
	
	function onTap(clickEvent) {
		var coordinates = clickEvent.getCoordinates();

		var x = coordinates[0];
		var y = coordinates[1];
		var distanceSqd =
			(x - SyncState.SCREEN_CENTER)*(x - SyncState.SCREEN_CENTER) + 
			(y - SyncState.SCREEN_CENTER)*(y - SyncState.SCREEN_CENTER);

		if (distanceSqd < SyncState.BUTTON_RADIUS_SQD)
		{
			inputSyncState.toggleSwitch = !inputSyncState.toggleSwitch;
		}

		// We need to update the UI         
        WatchUi.requestUpdate();
        return true;
    }
}