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
        
        // Start timer to update position every second
        _timer = new Timer.Timer();
        _timer.start(method(:updatePosition), 1000, true);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        
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
            
            // Draw speed in knots (very large, in lower half)
            var speedText = "-- kts";
            if (_speed != null) {
                var knots = _speed * 1.94384; // Convert m/s to knots
                speedText = knots.format("%.1f") + " kts";
            }
            dc.drawText(width / 2, height / 2 + 20, Graphics.FONT_NUMBER_HOT, speedText, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw GPS coordinates at bottom in smaller text (moved up by 6 units)
            var latText = "Lat: " + _latitude.format("%.4f");
            var lonText = "Lon: " + _longitude.format("%.4f");
            
            dc.drawText(width / 2, height - 41, Graphics.FONT_XTINY, latText, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, height - 26, Graphics.FONT_XTINY, lonText, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(width / 2, height / 2, Graphics.FONT_SMALL, "Acquiring GPS...", Graphics.TEXT_JUSTIFY_CENTER);
        }
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
