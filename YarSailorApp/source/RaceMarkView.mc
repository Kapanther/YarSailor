import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Position;
import Toybox.System;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Application;

class RaceMarkView extends WatchUi.View {
    private var _latitude as Double?;
    private var _longitude as Double?;
    private var _heading as Float?;
    private var _speed as Float?;
    private var _timer as Timer.Timer?;
    private var _menuIcon as BitmapResource?;
    private var _portMarker as BitmapResource?;
    private var _starboardMarker as BitmapResource?;
    private var _currentMarkIndex as Number;
    private var _totalMarks as Number;

    function initialize() {
        View.initialize();
        _latitude = null;
        _longitude = null;
        _heading = null;
        _speed = null;
        _timer = null;
        _menuIcon = null;
        _portMarker = null;
        _starboardMarker = null;
        _currentMarkIndex = 0;
        _totalMarks = 0;
        
        // Load total marks count from selected course
        var isSampleCourse = Application.Storage.getValue("isSampleCourse");
        if (isSampleCourse != null && isSampleCourse) {
            _totalMarks = SampleCourse.getWaypointCount();
        }
    }

    function onLayout(dc as Dc) as Void {
        _menuIcon = WatchUi.loadResource(Rez.Drawables.MenuIcon);
        _portMarker = WatchUi.loadResource(Rez.Drawables.PortMarker);
        _starboardMarker = WatchUi.loadResource(Rez.Drawables.StarboardMarker);
    }

    function onShow() as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        
        // Start timer to update GPS every 0.25 seconds
        _timer = new Timer.Timer();
        _timer.start(method(:updateGPS), 250, true);
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Draw "Race Mark" label
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 10, Graphics.FONT_TINY, "Next Mark", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Calculate bearing deviation and distance
        var deviationValue = "---";
        var deviationDirection = "";
        var distanceValue = "--";
        var distanceUnit = "m";
        var markName = null;
        
        if (_latitude != null && _longitude != null && _totalMarks > 0) {
            var markLat = null;
            var markLon = null;
            
            var isSampleCourse = Application.Storage.getValue("isSampleCourse");
            if (isSampleCourse != null && isSampleCourse) {
                markLat = SampleCourse.getWaypointLatitude(_currentMarkIndex);
                markLon = SampleCourse.getWaypointLongitude(_currentMarkIndex);
                markName = SampleCourse.getWaypointName(_currentMarkIndex);
            }
            
            if (markLat != null && markLon != null) {
                // Calculate bearing to mark
                var bearingToMark = calculateBearing(_latitude, _longitude, markLat, markLon);
                
                // Calculate deviation from current heading
                if (_heading != null) {
                    var deviation = bearingToMark - _heading;
                    
                    // Normalize to -180 to 180
                    while (deviation > 180) { deviation -= 360; }
                    while (deviation < -180) { deviation += 360; }
                    
                    var absDeviation = deviation.abs();
                    deviationDirection = deviation < 0 ? "L" : "R";
                    deviationValue = absDeviation.format("%03d");
                }
                
                // Calculate distance to mark in meters
                var distance = calculateDistance(_latitude, _longitude, markLat, markLon);
                if (distance > 2000) {
                    distanceValue = (distance / 1000).format("%.2f");
                    distanceUnit = "km";
                } else {
                    distanceValue = distance.format("%.0f");
                }
            }
        }
        
        // Draw bearing deviation (top half)
        dc.drawText(width / 2, 70, Graphics.FONT_NUMBER_HOT, deviationValue, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2 + 70, height / 2 - 30, Graphics.FONT_LARGE, deviationDirection, Graphics.TEXT_JUSTIFY_LEFT);
        
        // Draw port/starboard marker if applicable
        if (markName != null) {
            if (markName.find("(P)") != null && _portMarker != null) {
                // Port marker - draw to the left of deviation
                dc.drawBitmap(width / 2 - 120, 75, _portMarker);
            } else if (markName.find("(S)") != null && _starboardMarker != null) {
                // Starboard marker - draw to the right of deviation
                dc.drawBitmap(width / 2 + 80, 75, _starboardMarker);
            }
        }
        
        // Draw distance to mark (bottom half)
        dc.drawText(width / 2, height / 2 + 25, Graphics.FONT_NUMBER_MILD, distanceValue, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(195, height / 2 + 35, Graphics.FONT_XTINY, distanceUnit, Graphics.TEXT_JUSTIFY_LEFT);
        
        // Draw current mark name/number at top
        var markText = "No Course";
        if (_totalMarks > 0) {
            var isSampleCourse = Application.Storage.getValue("isSampleCourse");
            if (isSampleCourse != null && isSampleCourse) {
                // Reuse markName variable if not already set
                if (markName == null) {
                    markName = SampleCourse.getWaypointName(_currentMarkIndex);
                }
                if (markName != null && markName.length() > 0) {
                    markText = markName;
                    
                    // Strip out (P) or (S) from display
                    var pIndex = markText.find("(P)");
                    if (pIndex != null) {
                        markText = markText.substring(0, pIndex) + markText.substring(pIndex + 3, markText.length());
                    }
                    var sIndex = markText.find("(S)");
                    if (sIndex != null) {
                        markText = markText.substring(0, sIndex) + markText.substring(sIndex + 3, markText.length());
                    }
                    
                    // Trim any trailing spaces
                    while (markText.length() > 0 && markText.substring(markText.length() - 1, markText.length()).equals(" ")) {
                        markText = markText.substring(0, markText.length() - 1);
                    }
                    
                    // Show first 15 characters of mark name
                    if (markText.length() > 15) {
                        markText = markText.substring(0, 15);
                    }
                } else {
                    markText = "Mark " + (_currentMarkIndex + 1);
                }
            }
        }
        
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 2 - 100, Graphics.FONT_MEDIUM, markText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw button glyphs
        if (_menuIcon != null) {
            dc.drawBitmap(10, 120, _menuIcon); // Menu icon - Middle left
        }
        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(30, 196, Graphics.FONT_TINY, "Prev", Graphics.TEXT_JUSTIFY_LEFT); // Bottom left
        dc.drawText(245, 196, Graphics.FONT_TINY, "Next", Graphics.TEXT_JUSTIFY_RIGHT); // Bottom right
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw heading and speed at bottom
        var headingText = "---°";
        if (_heading != null) {
            headingText = _heading.format("%03d") + "°";
        }
        
        var speedText = "-- kts";
        if (_speed != null) {
            var knots = _speed * 1.94384;
            speedText = knots.format("%.1f") + " kn";
        }
        
        // Draw separator line between heading and speed
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(130, 236, 130, 255);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        dc.drawText(125, 229, Graphics.FONT_SMALL, headingText, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(135, 229, Graphics.FONT_SMALL, speedText, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onHide() as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }
    
    function updateGPS() as Void {
        var info = Position.getInfo();
        onPosition(info);
    }
    
    function onPosition(info as Position.Info) as Void {
        if (info.position != null) {
            var position = info.position;
            _latitude = position.toDegrees()[0];
            _longitude = position.toDegrees()[1];
        }
        
        if (info.heading != null) {
            _heading = Math.toDegrees(info.heading);
            if (_heading < 0) {
                _heading += 360;
            }
        }
        
        if (info.speed != null) {
            _speed = info.speed;
        }
        
        WatchUi.requestUpdate();
    }
    
    // Calculate bearing from point 1 to point 2 (in degrees)
    function calculateBearing(lat1 as Double, lon1 as Double, lat2 as Double, lon2 as Double) as Float {
        var lat1Rad = Math.toRadians(lat1);
        var lat2Rad = Math.toRadians(lat2);
        var lonDiff = Math.toRadians(lon2 - lon1);
        
        var y = Math.sin(lonDiff) * Math.cos(lat2Rad);
        var x = Math.cos(lat1Rad) * Math.sin(lat2Rad) - Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(lonDiff);
        var bearing = Math.atan2(y, x);
        
        bearing = Math.toDegrees(bearing);
        
        // Normalize to 0-360
        while (bearing < 0) {
            bearing += 360;
        }
        while (bearing >= 360) {
            bearing -= 360;
        }
        
        return bearing;
    }
    
    // Calculate distance between two points (in meters)
    function calculateDistance(lat1 as Double, lon1 as Double, lat2 as Double, lon2 as Double) as Float {
        var R = 6371000.0; // Earth radius in meters
        
        var lat1Rad = Math.toRadians(lat1);
        var lat2Rad = Math.toRadians(lat2);
        var latDiff = Math.toRadians(lat2 - lat1);
        var lonDiff = Math.toRadians(lon2 - lon1);
        
        var a = Math.sin(latDiff / 2) * Math.sin(latDiff / 2) +
                Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                Math.sin(lonDiff / 2) * Math.sin(lonDiff / 2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c;
    }
    
    function previousMark() as Void {
        if (_totalMarks > 0) {
            _currentMarkIndex = (_currentMarkIndex - 1 + _totalMarks) % _totalMarks;
            WatchUi.requestUpdate();
        }
    }
    
    function nextMark() as Void {
        if (_totalMarks > 0) {
            _currentMarkIndex = (_currentMarkIndex + 1) % _totalMarks;
            WatchUi.requestUpdate();
        }
    }
}
