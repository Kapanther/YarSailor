using Toybox.WatchUi as Ui;

// Input delegate for handling user interactions
class YarSailorDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle back button press
    function onBack() {
        return false; // Return false to exit the app
    }

}
