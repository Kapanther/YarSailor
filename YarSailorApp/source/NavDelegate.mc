import Toybox.Lang;
import Toybox.WatchUi;

class NavDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new YarSailorMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    
    function onPreviousPage() as Boolean {
        // Middle left button - cycle to next screen (Race Start)
        var delegate = new YarSailorDelegate();
        delegate.setScreenIndex(1);
        delegate.switchToScreen(1);
        return true;
    }
    
    function onNextPage() as Boolean {
        // Bottom left button - go to Config screen
        var view = new ConfigView();
        var delegate = new ConfigDelegate(view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
        return true;
    }
}
