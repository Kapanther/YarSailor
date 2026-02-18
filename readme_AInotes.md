# YarSailor - AI Development Notes

## Button Mapping for Garmin Fenix 6X Pro

**IMPORTANT: The Garmin event names DO NOT match physical button positions!**

Physical button positions and their corresponding events:

### Physical Button Layout
```
        [UP]        - Not typically used
     
[LEFT TOP]                    [RIGHT TOP]
                              (SELECT button)

[LEFT MIDDLE]                 [RIGHT MIDDLE]
                              
[LEFT BOTTOM]                 [RIGHT BOTTOM]
                              (BACK button)
```

### Event Mapping
- **onMenu()** = LEFT TOP button (LIGHT button - NOT USABLE IN APPS, controls backlight only)
- **onPreviousPage()** = LEFT MIDDLE button (despite name suggesting "previous/down")  
- **onNextPage()** = LEFT BOTTOM button (despite name suggesting "next/up")
- **onSelect()** = RIGHT TOP button (SELECT/START button)
- **onBack()** = RIGHT BOTTOM button (BACK button)

### Current Screen Button Functions

#### Nav Screen
- **LEFT MIDDLE** (onPreviousPage): Cycle to next screen

**Screen Cycle Order:** Nav (0) → Race Start (1) → Race 1 (2) → Race 2 (3) → Race 3 (4) → Nav (0)

#### Race Start Screen
- **LEFT MIDDLE** (onPreviousPage): Cycle to next screen
- **LEFT BOTTOM** (onNextPage): -1 minute
- **RIGHT TOP** (onSelect): Start/Pause timer (double-tap to reset)
- **RIGHT BOTTOM** (onBack): +1 minute

**Note:** Garmin Connect IQ BehaviorDelegate doesn't support native long-press detection. Reset is implemented as double-tap on the RIGHT TOP button (tap twice quickly within 500ms).

#### Race 1, Race 2, Race 3 Screens
- **LEFT MIDDLE** (onPreviousPage): Cycle to next screen
- (Additional functions coming soon)

## Screen Layout

### Nav Screen
- Time (top)
- Bearing/Heading (large, top half)
- Speed in knots (large, lower half)
- Position (lat/long, bottom)
- Rotating compass ring (red = North, white = E/S/W)

### Race Start Screen
- Time (top)
- "Race Start" label
- Countdown timer (5:00 default, starts paused)
- Button indicators: -1, +1, RST
- Heading (bottom left) and Speed (bottom right)

## Update Frequencies
- Nav screen: GPS updates every 250ms (0.25 seconds) for smooth compass rotation
- Race Start: GPS updates every 250ms, countdown ticks every 1 second

## Technical Notes
- Speed conversion: m/s * 1.94384 = knots
- Heading: Converted from radians to degrees (0-359°, 0° = North)
- Timer uses separate countdown timer instance and GPS update timer
