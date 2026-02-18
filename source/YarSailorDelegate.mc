using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

// Input delegate for handling user interactions
class YarSailorDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle menu button press
    function onMenu() {
        Sys.println("Menu pressed");
        return true;
    }

    // Handle select button press
    function onSelect() {
        Sys.println("Select pressed");
        return true;
    }

    // Handle back button press
    function onBack() {
        Sys.println("Back pressed");
        return false; // Return false to exit the app
    }

    // Handle next page button
    function onNextPage() {
        Sys.println("Next page");
        return true;
    }

    // Handle previous page button
    function onPreviousPage() {
        Sys.println("Previous page");
        return true;
    }

}
