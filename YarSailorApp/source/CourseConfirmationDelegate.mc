import Toybox.WatchUi;
import Toybox.Lang;

class CourseConfirmationDelegate extends WatchUi.BehaviorDelegate {
    private var _view as CourseConfirmationView;

    function initialize(view as CourseConfirmationView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() as Boolean {
        // Top right button - confirm course
        _view.confirmCourse();
        return true;
    }

    function onBack() as Boolean {
        // Bottom right button - cancel and go back to course selection
        var view = new CourseSelectionView();
        var delegate = new CourseSelectionDelegate(view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);
        return true;
    }
}
