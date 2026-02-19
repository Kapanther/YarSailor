import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class RaceStartLineSetView extends WatchUi.View {
    private var _backArrow as BitmapResource?;

    function initialize() {
        View.initialize();
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
        var height = dc.getHeight();
        
        // Draw title
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 10, Graphics.FONT_TINY, "Start Line Setup", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Placeholder text
        dc.drawText(width / 2, height / 2 - 20, Graphics.FONT_MEDIUM, "Coming Soon", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw back button indicator
        if (_backArrow != null) {
            dc.drawBitmap(10, height - 50, _backArrow);
        }
        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(50, height - 45, Graphics.FONT_SMALL, "Back", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }

    function onHide() as Void {
    }
}
