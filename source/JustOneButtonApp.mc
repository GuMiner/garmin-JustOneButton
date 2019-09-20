using Toybox.Application;

class JustOneButtonApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
    	// Setup a tiny amount of shared state so that input flows back to the display.
    	var syncState = new SyncState();
        return [ new JustOneButtonView(syncState), new TapInputDelegate(syncState) ];
    }

}