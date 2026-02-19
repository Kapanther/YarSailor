import Toybox.Lang;
import Toybox.WatchUi;

class RaceStartLineSetDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onPreviousPage() as Boolean {
        // Middle left button - go back to Race Start screen
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
    
    function onBack() as Boolean {
        // Bottom right button - also go back
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
