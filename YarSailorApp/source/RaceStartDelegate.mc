import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.System;

class RaceStartDelegate extends WatchUi.BehaviorDelegate {
    private var _view as RaceStartView;
    private var _timer as Timer.Timer?;
    private var _lastSelectTime as Number;

    function initialize(view as RaceStartView) {
        BehaviorDelegate.initialize();
        _view = view;
        _timer = new Timer.Timer();
        _timer.start(method(:onTimerTick), 1000, true);
        _lastSelectTime = 0;
    }

    function onMenu() as Boolean {
        // Top left (LIGHT button) - doesn't work for input in apps
        return false;
    }
    
    function onPreviousPage() as Boolean {
        // Middle left button - cycle screens
        cleanup();
        
        // Race Start is index 1, so cycle to index 2 (Race Mark)
        var nextIndex = 2;
        
        var delegate = new YarSailorDelegate();
        delegate.setScreenIndex(nextIndex);
        delegate.switchToScreen(nextIndex);
        return true;
    }
    
    function onNextPage() as Boolean {
        // Bottom left button - decrement timer
        _view.decrementTimer();
        return true;
    }
    
    function onSelect() as Boolean {
        // Top right button - start/pause timer (double-tap to reset)
        var currentTime = System.getTimer();
        
        // Check if this is a double-tap (within 500ms)
        if (currentTime - _lastSelectTime < 500) {
            // Double tap = reset
            _view.resetTimer();
            _lastSelectTime = 0;
        } else {
            // Single tap = toggle start/pause
            _view.toggleTimer();
            _lastSelectTime = currentTime;
        }
        
        return true;
    }
    
    function onBack() as Boolean {
        // Bottom right button - increment timer
        _view.incrementTimer();
        return true;
    }
    
    function onTimerTick() as Void {
        _view.tickTimer();
    }
    
    function cleanup() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }
}
