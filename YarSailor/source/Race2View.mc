import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class Race2View extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.drawText(width / 2, height / 2 - 20, Graphics.FONT_LARGE, "Race 2", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, height / 2 + 20, Graphics.FONT_SMALL, "(Coming Soon)", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {
    }
}
