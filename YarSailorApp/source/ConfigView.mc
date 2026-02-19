import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class ConfigView extends WatchUi.View {
    private var _selectedIndex as Number;
    private var _upArrow as BitmapResource?;
    private var _downArrow as BitmapResource?;
    private var _backArrow as BitmapResource?;

    function initialize() {
        View.initialize();
        _selectedIndex = 0;
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
        dc.drawText(width / 2, 35, Graphics.FONT_TINY, "Config", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Menu options
        var menuOptions = ["Set Course", "Settings"];
        var startY = 80;
        var spacing = 50;
        
        for (var i = 0; i < menuOptions.size(); i++) {
            var yPos = startY + (i * spacing);
            
            // Draw highlight box for selected item
            if (i == _selectedIndex) {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(20, yPos + 5, width - 40, 35);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }
            
            // Draw menu text
            dc.drawText(width / 2, yPos, Graphics.FONT_MEDIUM, menuOptions[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw button glyphs
        if (_upArrow != null) {
            dc.drawBitmap(10, 120, _upArrow); // Middle left - move up            
        }
        if (_downArrow != null) {
            dc.drawBitmap(42, 176, _downArrow); // Bottom left - move down
        }
        if (_backArrow != null) {
            dc.drawBitmap(220, 186, _backArrow); // Bottom right - back to nav
        }
    }

    function onHide() as Void {
    }
    
    function moveUp() as Void {
        _selectedIndex = (_selectedIndex - 1 + 2) % 2; // 2 menu items
        WatchUi.requestUpdate();
    }
    
    function moveDown() as Void {
        _selectedIndex = (_selectedIndex + 1) % 2; // 2 menu items
        WatchUi.requestUpdate();
    }
    
    function getSelectedIndex() as Number {
        return _selectedIndex;
    }
}
