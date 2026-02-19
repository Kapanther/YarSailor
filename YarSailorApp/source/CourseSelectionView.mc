import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.PersistedContent;
import Toybox.Application;

class CourseSelectionView extends WatchUi.View {
    private var _courseNames as Array<String>;
    private var _selectedIndex as Number;
    private var _scrollOffset as Number;
    private var _upArrow as BitmapResource?;
    private var _downArrow as BitmapResource?;
    private var _backArrow as BitmapResource?;

    function initialize() {
        View.initialize();
        _courseNames = [];
        _selectedIndex = 0;
        _scrollOffset = 0;
        _upArrow = null;
        _downArrow = null;
        _backArrow = null;
    }

    function onLayout(dc as Dc) as Void {
        // Load arrow bitmaps
        _upArrow = WatchUi.loadResource(Rez.Drawables.UpArrow);
        _downArrow = WatchUi.loadResource(Rez.Drawables.DownArrow);
        _backArrow = WatchUi.loadResource(Rez.Drawables.BackArrow);
    }

    function onShow() as Void {
        loadCourses();
    }

    function loadCourses() as Void {
        _courseNames = [];
        
        // Add sample course first (for testing)
        _courseNames.add(SampleCourse.COURSE_NAME);
        
        // Try to get courses from persisted content
        var coursesIterator = PersistedContent.getCourses();
        if (coursesIterator != null) {
            var course = coursesIterator.next();
            while (course != null) {
                var courseName = course.getName();
                if (courseName != null && courseName.length() > 0) {
                    _courseNames.add(courseName);
                } else {
                    _courseNames.add("Unnamed Course");
                }
                course = coursesIterator.next();
            }
        }
        
        // Add a "No Course" option at the end
        _courseNames.add("(No Course)");
        
        WatchUi.requestUpdate();
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
        
        // Draw screen label just below time
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 35, Graphics.FONT_TINY, "Set Course", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw courses list
        if (_courseNames.size() == 0) {
            dc.drawText(width / 2, 100, Graphics.FONT_SMALL, "No courses found", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, 130, Graphics.FONT_XTINY, "Load courses via", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, 145, Graphics.FONT_XTINY, "Garmin Connect", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            var startY = 70;
            var lineHeight = 35;
            var maxVisible = 4;
            
            // Calculate scroll offset to keep selected item visible
            if (_selectedIndex < _scrollOffset) {
                _scrollOffset = _selectedIndex;
            } else if (_selectedIndex >= _scrollOffset + maxVisible) {
                _scrollOffset = _selectedIndex - maxVisible + 1;
            }
            
            // Draw visible items
            for (var i = 0; i < maxVisible && (_scrollOffset + i) < _courseNames.size(); i++) {
                var courseIndex = _scrollOffset + i;
                var yPos = startY + (i * lineHeight);
                
                // Draw highlight for selected item
                if (courseIndex == _selectedIndex) {
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                    dc.fillRectangle(10, yPos + 5, width - 20, 28);
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                }
                
                // Draw course name (truncate if too long)
                var courseName = _courseNames[courseIndex];
                if (courseName.length() > 18) {
                    courseName = courseName.substring(0, 15) + "...";
                }
                dc.drawText(width / 2, yPos, Graphics.FONT_SMALL, courseName, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
        
        // Draw button glyphs
        if (_upArrow != null) {
            dc.drawBitmap(10, 120, _upArrow); // Middle left - move up
        }
        if (_downArrow != null) {
            dc.drawBitmap(42, 176, _downArrow); // Bottom left - move down
        }
        if (_backArrow != null) {
            dc.drawBitmap(220, 186, _backArrow); // Bottom right - back to config
        }
        
        if (_courseNames.size() > 0) {
            dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(251, 71, Graphics.FONT_TINY, "Ok", Graphics.TEXT_JUSTIFY_RIGHT); // Top right - select course
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        }
    }

    function onHide() as Void {
    }
    
    function moveUp() as Void {
        if (_courseNames.size() > 0) {
            _selectedIndex = (_selectedIndex - 1 + _courseNames.size()) % _courseNames.size();
            WatchUi.requestUpdate();
        }
    }
    
    function moveDown() as Void {
        if (_courseNames.size() > 0) {
            _selectedIndex = (_selectedIndex + 1) % _courseNames.size();
            WatchUi.requestUpdate();
        }
    }
    
    function selectCourse() as Void {
        if (_courseNames.size() > 0) {
            if (_selectedIndex == _courseNames.size() - 1) {
                // "(No Course)" option selected - clear stored course and go to nav
                Application.Storage.setValue("selectedCourseName", null);
                Application.Storage.setValue("isSampleCourse", false);
                
                var view = new YarSailorView();
                var delegate = new NavDelegate();
                WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);
            } else if (_selectedIndex < _courseNames.size() - 1) {
                // Show confirmation screen
                var courseName = _courseNames[_selectedIndex];
                var waypointCount = 0;
                var isSampleCourse = false;
                
                // Get waypoint count
                if (courseName.equals(SampleCourse.COURSE_NAME)) {
                    waypointCount = SampleCourse.getWaypointCount();
                    isSampleCourse = true;
                } else {
                    // For synced courses, we don't have direct access to waypoint count
                    // Set to 0 to indicate "unknown" for now
                    waypointCount = 0;
                }
                
                // Navigate to confirmation screen
                var view = new CourseConfirmationView(courseName, waypointCount, isSampleCourse);
                var delegate = new CourseConfirmationDelegate(view);
                WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
            }
        }
    }
}
