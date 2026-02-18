using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Position as Position;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

// Main data view for sailing metrics
class YarSailorView extends Ui.View {

    hidden var speed;
    hidden var heading;
    hidden var latitude;
    hidden var longitude;
    hidden var accuracy;

    function initialize() {
        View.initialize();
        speed = 0.0;
        heading = 0.0;
        latitude = 0.0;
        longitude = 0.0;
        accuracy = Position.QUALITY_NOT_AVAILABLE;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // Update the view
    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        
        // Set text properties
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Draw title
        dc.drawText(width / 2, 10, Gfx.FONT_SMALL, "YarSailor", Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw sailing data
        var yPos = height / 4;
        
        // Speed
        dc.drawText(10, yPos, Gfx.FONT_MEDIUM, "Speed:", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(width - 10, yPos, Gfx.FONT_MEDIUM, speed.format("%.1f") + " kts", Gfx.TEXT_JUSTIFY_RIGHT);
        
        yPos += 40;
        
        // Heading
        dc.drawText(10, yPos, Gfx.FONT_MEDIUM, "Heading:", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(width - 10, yPos, Gfx.FONT_MEDIUM, heading.format("%.0f") + "°", Gfx.TEXT_JUSTIFY_RIGHT);
        
        yPos += 40;
        
        // Coordinates
        dc.drawText(10, yPos, Gfx.FONT_SMALL, "Lat:", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(width - 10, yPos, Gfx.FONT_SMALL, latitude.format("%.4f"), Gfx.TEXT_JUSTIFY_RIGHT);
        
        yPos += 30;
        
        dc.drawText(10, yPos, Gfx.FONT_SMALL, "Lon:", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(width - 10, yPos, Gfx.FONT_SMALL, longitude.format("%.4f"), Gfx.TEXT_JUSTIFY_RIGHT);
        
        // GPS Status
        yPos += 40;
        var gpsStatus = "GPS: ";
        if (accuracy == Position.QUALITY_GOOD) {
            gpsStatus += "Good";
        } else if (accuracy == Position.QUALITY_USABLE) {
            gpsStatus += "Usable";
        } else if (accuracy == Position.QUALITY_POOR) {
            gpsStatus += "Poor";
        } else {
            gpsStatus += "No Fix";
        }
        dc.drawText(width / 2, yPos, Gfx.FONT_TINY, gpsStatus, Gfx.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    // Position callback
    function onPosition(info) {
        if (info has :speed && info.speed != null) {
            // Convert m/s to knots (1 m/s = 1.94384 knots)
            speed = info.speed * 1.94384;
        }
        
        if (info has :heading && info.heading != null) {
            // Convert radians to degrees
            heading = Math.toDegrees(info.heading);
            if (heading < 0) {
                heading += 360;
            }
        }
        
        if (info has :position && info.position != null) {
            var position = info.position.toDegrees();
            latitude = position[0];
            longitude = position[1];
        }
        
        if (info has :accuracy && info.accuracy != null) {
            accuracy = info.accuracy;
        }
        
        Ui.requestUpdate();
    }

}
