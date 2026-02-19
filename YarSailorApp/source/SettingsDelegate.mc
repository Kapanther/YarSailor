import Toybox.Lang;
import Toybox.WatchUi;

class SettingsDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new YarSailorMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    
    function onNextPage() as Boolean {
        // Bottom left button - go back to Config screen
        var view = new ConfigView();
        var delegate = new ConfigDelegate(view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);
        return true;
    }
    
    function onBack() as Boolean {
        // Bottom right button (hardware back) - go back to Config screen instead of exiting
        var view = new ConfigView();
        var delegate = new ConfigDelegate(view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);
        return true;
    }
}
