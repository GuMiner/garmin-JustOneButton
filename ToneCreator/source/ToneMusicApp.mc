import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ToneMusicApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new ToneMusicView(), new ToneMusicDelegate() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as ToneMusicApp {
    return Application.getApp() as ToneMusicApp;
}