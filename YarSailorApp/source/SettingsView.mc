import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class SettingsView extends WatchUi.View {
    private var _backArrow as BitmapResource?;
    private var _menuIcon as BitmapResource?;

    function initialize() {
        View.initialize();
        _backArrow = null;
        _menuIcon = null;
    }

    function onLayout(dc as Dc) as Void {
        // Load back arrow bitmap
        _backArrow = WatchUi.loadResource(Rez.Drawables.BackArrow);
        _menuIcon = WatchUi.loadResource(Rez.Drawables.MenuIcon);
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
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
        
        // Draw time at top
        dc.drawText(width / 2, 5, Graphics.FONT_MEDIUM, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw screen label just below time
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 35, Graphics.FONT_TINY, "Settings", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw main content
        dc.drawText(width / 2, height / 2 - 20, Graphics.FONT_LARGE, "Settings", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, height / 2 + 20, Graphics.FONT_SMALL, "(Coming Soon)", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw button glyphs
        if (_menuIcon != null) {
            dc.drawBitmap(10, 120, _menuIcon); // Menu icon - Middle left
        }
        
        if (_backArrow != null) {
            dc.drawBitmap(236, 186, _backArrow); // Bottom right - back to config
        }
    }

    function onHide() as Void {
    }
}
