import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Toybox.Math;
import Toybox.Application;

class YarSailorView extends WatchUi.View {
    private var _latitude as Double?;
    private var _longitude as Double?;
    private var _heading as Float?;
    private var _speed as Float?;
    private var _timer as Timer.Timer?;
    private var _menuIcon as BitmapResource?;
    private var _cogIcon as BitmapResource?;

    function initialize() {
        View.initialize();
        _latitude = null;
        _longitude = null;
        _heading = null;
        _speed = null;
        _timer = null;
        _menuIcon = null;
        _cogIcon = null;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _menuIcon = WatchUi.loadResource(Rez.Drawables.MenuIcon);
        _cogIcon = WatchUi.loadResource(Rez.Drawables.CogIcon);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        
        // Start timer to update position every 0.25 seconds
        _timer = new Timer.Timer();
        _timer.start(method(:updatePosition), 250, true);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        var radius = (width < height ? width : height) / 2 - 5;
        
        // Draw rotating compass ring
        drawCompassRing(dc, centerX, centerY, radius);
        
        // Get current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour.format("%02d"),
            clockTime.min.format("%02d")
        ]);
        
        // Draw "Header and time at top
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 10, Graphics.FONT_TINY, "Home", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 35, Graphics.FONT_TINY, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        if (_latitude != null && _longitude != null) {
            var yPos = 50;
            
            // Draw heading/bearing (larger)
            var headingText = "---°";
            if (_heading != null) {
                headingText = _heading.format("%03d") + "°";
            }
            dc.drawText(width / 2, yPos, Graphics.FONT_NUMBER_HOT, headingText, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw speed in knots (centered, with kn at bottom right)
            if (_speed != null) {
                var knots = _speed * 1.94384; // Convert m/s to knots
                var speedValue = knots.format("%.1f");
                dc.drawText(width / 2, height / 2 - 10, Graphics.FONT_NUMBER_HOT, speedValue, Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(195, 209, Graphics.FONT_XTINY, "kn", Graphics.TEXT_JUSTIFY_LEFT);
            } else {
                dc.drawText(width / 2, height / 2 - 10, Graphics.FONT_NUMBER_HOT, "--", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(195, 209, Graphics.FONT_XTINY, "kn", Graphics.TEXT_JUSTIFY_LEFT);
            }
            
            // Draw course status in the middle
            var courseName = Application.Storage.getValue("selectedCourseName");
            var courseText = "No Course";
            if (courseName != null && courseName.length() > 0) {
                if (courseName.length() > 9) {
                    courseText = courseName.substring(0, 9);
                } else {
                    courseText = courseName;
                }
            }
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height / 2 + 75, Graphics.FONT_XTINY, courseText, Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            
            // Draw GPS coordinates at bottom in smaller text (moved up by 6 units)
            var latText = "Lat: " + _latitude.format("%.4f");
            var lonText = "Lon: " + _longitude.format("%.4f");
            
            dc.drawText(width / 2, height - 41, Graphics.FONT_XTINY, latText, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, height - 26, Graphics.FONT_XTINY, lonText, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw button icons
            if (_menuIcon != null) {
                dc.drawBitmap(10, 120, _menuIcon); // Menu icon - Middle left
            }
            if (_cogIcon != null) {
                dc.drawBitmap(35, 190, _cogIcon); // Config icon - Bottom left
            }
        } else {
            dc.drawText(width / 2, height / 2, Graphics.FONT_SMALL, "Acquiring GPS...", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    
    // Draw compass ring with cardinal directions
    function drawCompassRing(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        var currentHeading = _heading != null ? _heading : 0;
        
        // Cardinal directions (N=0, E=90, S=180, W=270)
        var cardinals = [0, 90, 180, 270]; // N, E, S, W
        var lineLength = 7.5;
        
        for (var i = 0; i < cardinals.size(); i++) {
            // Calculate angle relative to current heading
            // Subtract current heading so North points up when heading north
            var angle = cardinals[i] - currentHeading;
            var radians = Math.toRadians(angle);
            
            // Calculate outer and inner points for the line
            var outerX = centerX + radius * Math.sin(radians);
            var outerY = centerY - radius * Math.cos(radians);
            var innerX = centerX + (radius - lineLength) * Math.sin(radians);
            var innerY = centerY - (radius - lineLength) * Math.cos(radians);
            
            // North is red, others are white
            if (i == 0) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            }
            
            dc.setPenWidth(3);
            dc.drawLine(outerX, outerY, innerX, innerY);
        }
        
        // Reset color and pen width
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        
        // Stop and clean up timer
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }
    
    // Timer callback to update position
    function updatePosition() as Void {
        var info = Position.getInfo();
        onPosition(info);
    }
    
    // Position callback
    function onPosition(info as Position.Info) as Void {
        if (info.position != null) {
            var position = info.position;
            _latitude = position.toDegrees()[0];
            _longitude = position.toDegrees()[1];
        }
        
        // Get heading (bearing)
        if (info.heading != null) {
            _heading = Math.toDegrees(info.heading);
            if (_heading < 0) {
                _heading += 360;
            }
        }
        
        // Get speed
        if (info.speed != null) {
            _speed = info.speed;
        }
        
        WatchUi.requestUpdate();
    }

}
