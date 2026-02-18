import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Toybox.Math;

class YarSailorView extends WatchUi.View {
    private var _latitude as Double?;
    private var _longitude as Double?;
    private var _heading as Float?;
    private var _speed as Float?;
    private var _timer as Timer.Timer?;

    function initialize() {
        View.initialize();
        _latitude = null;
        _longitude = null;
        _heading = null;
        _speed = null;
        _timer = null;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
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
        
        // Draw time at top (larger)
        dc.drawText(width / 2, 5, Graphics.FONT_MEDIUM, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        
        if (_latitude != null && _longitude != null) {
            var yPos = 50;
            
            // Draw heading/bearing (larger)
            var headingText = "---°";
            if (_heading != null) {
                headingText = _heading.format("%03d") + "°";
            }
            dc.drawText(width / 2, yPos, Graphics.FONT_NUMBER_HOT, headingText, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw speed in knots (centered, with kts at bottom right)
            if (_speed != null) {
                var knots = _speed * 1.94384; // Convert m/s to knots
                var speedValue = knots.format("%.1f");
                dc.drawText(width / 2, height / 2 + 15, Graphics.FONT_NUMBER_HOT, speedValue, Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(width / 2 + 40, height / 2 + 50, Graphics.FONT_XTINY, "kts", Graphics.TEXT_JUSTIFY_LEFT);
            } else {
                dc.drawText(width / 2, height / 2 + 15, Graphics.FONT_NUMBER_HOT, "--", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(width / 2 + 40, height / 2 + 50, Graphics.FONT_XTINY, "kts", Graphics.TEXT_JUSTIFY_LEFT);
            }
            
            // Draw GPS coordinates at bottom in smaller text (moved up by 6 units)
            var latText = "Lat: " + _latitude.format("%.4f");
            var lonText = "Lon: " + _longitude.format("%.4f");
            
            dc.drawText(width / 2, height - 41, Graphics.FONT_XTINY, latText, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, height - 26, Graphics.FONT_XTINY, lonText, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw screen label
            dc.drawText(width / 2, height - 12, Graphics.FONT_XTINY, "Nav Screen", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(width / 2, height / 2, Graphics.FONT_SMALL, "Acquiring GPS...", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    
    // Draw compass ring with cardinal directions
    function drawCompassRing(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        var currentHeading = _heading != null ? _heading : 0;
        
        // Cardinal directions (N=0, E=90, S=180, W=270)
        var cardinals = [0, 90, 180, 270]; // N, E, S, W
        var lineLength = 15;
        
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
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
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
