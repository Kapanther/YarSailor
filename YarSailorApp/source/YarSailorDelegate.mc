import Toybox.Lang;
import Toybox.WatchUi;

class YarSailorDelegate extends WatchUi.BehaviorDelegate {
    private var _currentScreenIndex as Number;

    function initialize() {
        BehaviorDelegate.initialize();
        _currentScreenIndex = 0;
    }
    
    function setScreenIndex(index as Number) as Void {
        _currentScreenIndex = index;
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new YarSailorMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    
    function onPreviousPage() as Boolean {
        // Middle left button - cycle to next screen
        _currentScreenIndex = (_currentScreenIndex + 1) % 5;
        switchToScreen(_currentScreenIndex);
        return true;
    }
    
    function switchToScreen(index as Number) as Void {
        var view;
        var delegate;
        
        if (index == 0) {
            view = new YarSailorView();
            delegate = new YarSailorDelegate();
            delegate.setScreenIndex(index);
        } else if (index == 1) {
            view = new RaceStartView();
            delegate = new RaceStartDelegate(view);
        } else if (index == 2) {
            view = new Race1View();
            delegate = new YarSailorDelegate();
            delegate.setScreenIndex(index);
        } else if (index == 3) {
            view = new Race2View();
            delegate = new YarSailorDelegate();
            delegate.setScreenIndex(index);
        } else if (index == 4) {
            view = new Race3View();
            delegate = new YarSailorDelegate();
            delegate.setScreenIndex(index);
        } else {
            view = new YarSailorView();
            delegate = new YarSailorDelegate();
            delegate.setScreenIndex(0);
        }
        
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
    }

}