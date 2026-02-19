import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;

class CourseConfirmationView extends WatchUi.View {
    private var _courseName as String;
    private var _waypointCount as Number;
    private var _isSampleCourse as Boolean;
    private var _backArrow as BitmapResource?;

    function initialize(courseName as String, waypointCount as Number, isSampleCourse as Boolean) {
        View.initialize();
        _courseName = courseName;
        _waypointCount = waypointCount;
        _isSampleCourse = isSampleCourse;
        _backArrow = null;
    }

    function onLayout(dc as Dc) as Void {
        _backArrow = WatchUi.loadResource(Rez.Drawables.BackArrow);
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var width = dc.getWidth();
        
        // Get current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour.format("%02d"),
            clockTime.min.format("%02d")
        ]);
        
        // Draw time at top
        dc.drawText(width / 2, 5, Graphics.FONT_MEDIUM, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw screen label
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 35, Graphics.FONT_TINY, "Confirm Course", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw course name (centered, may wrap)
        var displayName = _courseName;
        if (displayName.length() > 20) {
            displayName = displayName.substring(0, 20);
        }
        dc.drawText(width / 2, 80, Graphics.FONT_MEDIUM, displayName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw waypoint count
        var waypointText = "";
        if (_waypointCount > 0) {
            waypointText = _waypointCount + " waypoints";
        } else {
            waypointText = "waypoints: unknown";
        }
        dc.drawText(width / 2, 120, Graphics.FONT_SMALL, waypointText, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw confirmation message
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 160, Graphics.FONT_XTINY, "Press OK to confirm", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw button glyphs
        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(251, 71, Graphics.FONT_TINY, "Ok", Graphics.TEXT_JUSTIFY_RIGHT); // Top right - confirm
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        if (_backArrow != null) {
            dc.drawBitmap(220, 186, _backArrow); // Bottom right - cancel
        }
    }

    function onHide() as Void {
    }
    
    function confirmCourse() as Void {
        // Save the course selection
        Application.Storage.setValue("selectedCourseName", _courseName);
        Application.Storage.setValue("isSampleCourse", _isSampleCourse);
        
        // Return to nav screen
        var view = new YarSailorView();
        var delegate = new NavDelegate();
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);
    }
    
    function getCourseName() as String {
        return _courseName;
    }
    
    function getWaypointCount() as Number {
        return _waypointCount;
    }
    
    function isSampleCourse() as Boolean {
        return _isSampleCourse;
    }
}
