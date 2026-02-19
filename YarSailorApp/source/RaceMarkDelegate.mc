import Toybox.WatchUi;
import Toybox.Lang;

class RaceMarkDelegate extends WatchUi.BehaviorDelegate {
    private var _view as RaceMarkView;

    function initialize(view as RaceMarkView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onPreviousPage() as Boolean {
        // Middle left button - cycle to next screen
        var delegate = new YarSailorDelegate();
        delegate.setScreenIndex(2);
        delegate.switchToScreen(0); // Go to Nav screen
        return true;
    }
    
    function onNextPage() as Boolean {
        // Bottom left button - previous mark
        _view.previousMark();
        return true;
    }
    
    function onBack() as Boolean {
        // Bottom right button - next mark
        _view.nextMark();
        return true;
    }
}
