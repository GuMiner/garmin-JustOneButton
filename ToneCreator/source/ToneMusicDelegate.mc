import Toybox.Lang;
import Toybox.WatchUi;

class ToneMusicDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }


    // Enter the song selection menu if either menu or select are pressed
    function onNextPage() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new ToneMusicMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new ToneMusicMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onSelect() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new ToneMusicMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
}