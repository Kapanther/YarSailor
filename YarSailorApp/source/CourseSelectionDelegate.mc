import Toybox.Lang;
import Toybox.WatchUi;

class CourseSelectionDelegate extends WatchUi.BehaviorDelegate {
    private var _view as CourseSelectionView;

    function initialize(view as CourseSelectionView) {
        BehaviorDelegate.initialize();
        _view = view;
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
    
    function onSelect() as Boolean {
        // Top right button - select the current course
        _view.selectCourse();
        return true;
    }
    
    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        
        // Up button (middle left) - move up in list
        if (key == WatchUi.KEY_UP) {
            _view.moveUp();
            return true;
        }
        
        // Down button (bottom left) - move down in list
        if (key == WatchUi.KEY_DOWN) {
            _view.moveDown();
            return true;
        }
        
        return false;
    }
}
