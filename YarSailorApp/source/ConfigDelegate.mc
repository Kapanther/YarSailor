import Toybox.Lang;
import Toybox.WatchUi;

class ConfigDelegate extends WatchUi.BehaviorDelegate {
    private var _view as ConfigView;

    function initialize(view as ConfigView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new YarSailorMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    
    function onPreviousPage() as Boolean {
        // Middle left button - move up in menu
        _view.moveUp();
        return true;
    }
    
    function onNextPage() as Boolean {
        // Bottom left button - move down in menu
        _view.moveDown();
        return true;
    }
    
    function onBack() as Boolean {
        // Bottom right button (hardware back) - go back to Nav screen instead of exiting
        var view = new YarSailorView();
        var delegate = new NavDelegate();
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);
        return true;
    }
    
    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        
        // Up button (middle left on 5-button watches) - move up in menu
        if (key == WatchUi.KEY_UP) {
            _view.moveUp();
            return true;
        }
        
        // Down button (bottom left on 5-button watches) - move down in menu
        if (key == WatchUi.KEY_DOWN) {
            _view.moveDown();
            return true;
        }
        
        // Select button (top right) - enter menu item
        if (key == WatchUi.KEY_ENTER) {
            var selectedIndex = _view.getSelectedIndex();
            
            if (selectedIndex == 0) {
                // Set Course
                var view = new CourseSelectionView();
                var delegate = new CourseSelectionDelegate(view);
                WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (selectedIndex == 1) {
                // Settings
                var view = new SettingsView();
                var delegate = new SettingsDelegate();
                WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
            }
            return true;
        }
        
        return false;
    }
}
