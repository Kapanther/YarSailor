import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Position;
import Toybox.System;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Attention;

class RaceStartView extends WatchUi.View {
    private var _countdownSeconds as Number;
    private var _timerRunning as Boolean;
    private var _timer as Timer.Timer?;
    private var _heading as Float?;
    private var _speed as Float?;
    private var _menuIcon as BitmapResource?;
    private const DEFAULT_COUNTDOWN = 300; // 5 minutes in seconds

    function initialize() {
        View.initialize();
        _countdownSeconds = DEFAULT_COUNTDOWN;
        _timerRunning = false;
        _timer = null;
        _heading = null;
        _speed = null;
        _menuIcon = null;
    }

    function onLayout(dc as Dc) as Void {
        // Load menu icon bitmap
        _menuIcon = WatchUi.loadResource(Rez.Drawables.MenuIcon);
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
        
        // Get current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour.format("%02d"),
            clockTime.min.format("%02d")
        ]);
        
        // Draw "Header and time at top
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 10, Graphics.FONT_TINY, "Race Start", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 35, Graphics.FONT_TINY, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw countdown timer (top half)
        var minutes = _countdownSeconds / 60;
        var seconds = _countdownSeconds % 60;
        var timerString = Lang.format("$1$:$2$", [
            minutes.format("%02d"),
            seconds.format("%02d")
        ]);
        dc.drawText(width / 2, 75, Graphics.FONT_NUMBER_HOT, timerString, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Show timer status only when paused
        if (!_timerRunning) {
            dc.drawText(140, 168, Graphics.FONT_XTINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw button glyphs
        if (_menuIcon != null) {
            dc.drawBitmap(10, 120, _menuIcon); // Menu icon - Middle left
        }
        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(42, 196, Graphics.FONT_SMALL, "-1", Graphics.TEXT_JUSTIFY_LEFT); // Bottom left
        dc.drawText(251, 59, Graphics.FONT_XTINY, "Reset/Go", Graphics.TEXT_JUSTIFY_RIGHT); // Top right
        dc.drawText(246, 196, Graphics.FONT_SMALL, "+1", Graphics.TEXT_JUSTIFY_RIGHT); // Bottom right
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
    
    function cleanup() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }
    
    // GPS update callback
    function updateGPS() as Void {
        var info = Position.getInfo();
        onPosition(info);
    }
    
    // Position callback
    function onPosition(info as Position.Info) as Void {
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
    
    // Timer control methods
    function incrementTimer() as Void {
        _countdownSeconds += 60; // Add 1 minute
        WatchUi.requestUpdate();
    }
    
    function decrementTimer() as Void {
        _countdownSeconds -= 60; // Subtract 1 minute
        if (_countdownSeconds < 0) {
            _countdownSeconds = 0;
        }
        WatchUi.requestUpdate();
    }
    
    function resetTimer() as Void {
        _countdownSeconds = DEFAULT_COUNTDOWN;
        _timerRunning = false;
        WatchUi.requestUpdate();
    }
    
    function toggleTimer() as Void {
        _timerRunning = !_timerRunning;
        WatchUi.requestUpdate();
    }
    
    function isTimerRunning() as Boolean {
        return _timerRunning;
    }
    
    function tickTimer() as Void {
        if (_timerRunning && _countdownSeconds > 0) {
            _countdownSeconds -= 1;
            
            // Beep on every minute
            if (_countdownSeconds > 10 && _countdownSeconds % 60 == 0) {
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_LOUD_BEEP);
                }
            }
            
            // Beep every second for last 10 seconds
            if (_countdownSeconds > 0 && _countdownSeconds <= 10) {
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_LOUD_BEEP);
                }
            }
            
            WatchUi.requestUpdate();
            
            // Stop timer and play GO tone when it reaches zero
            if (_countdownSeconds == 0) {
                _timerRunning = false;
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_ALERT_HI);
                }
            }
        }
    }
}
