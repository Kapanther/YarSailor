# YarSailor

A Garmin sailing application built with Connect IQ SDK for displaying real-time sailing metrics.

## Features

- **Speed Display**: Shows current speed in knots
- **Heading**: Displays compass heading in degrees
- **GPS Coordinates**: Shows latitude and longitude
- **GPS Quality Indicator**: Displays GPS signal quality status
- **Real-time Updates**: Continuous position tracking

## Supported Devices

YarSailor supports a wide range of Garmin devices including:
- Fenix 6/7 series
- Vivoactive 4 series
- Venu/Venu 2
- Epix 2
- MARQ 2

## Installation

### Prerequisites

1. Download and install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
2. Set up your development environment following the [Connect IQ Getting Started Guide](https://developer.garmin.com/connect-iq/getting-started/)

### Building the App

1. Clone this repository:
   ```bash
   git clone https://github.com/Kapanther/YarSailor.git
   cd YarSailor
   ```

2. Build using the Connect IQ SDK:
   ```bash
   monkeyc -o YarSailor.prg -f monkey.jungle -y <developer_key.der>
   ```

3. Test in the simulator:
   ```bash
   connectiq
   ```

### Installing on Device

1. Build the .iq package:
   ```bash
   monkeyc -o YarSailor.iq -f monkey.jungle -y <developer_key.der> -r
   ```

2. Copy the .iq file to your Garmin device or install via Garmin Express

## Usage

1. Launch YarSailor from your Garmin device
2. Wait for GPS signal acquisition
3. View real-time sailing metrics:
   - Speed (in knots)
   - Heading (in degrees)
   - GPS coordinates
   - GPS signal quality

### Controls

- **Back**: Exit the application

### Battery Usage

**Note**: This app uses continuous GPS tracking for real-time position updates, which may impact battery life. For extended sailing sessions, ensure your device is adequately charged or connected to a power source.

## Project Structure

```
YarSailor/
├── manifest.xml          # App manifest with metadata and permissions
├── monkey.jungle         # Build configuration
├── source/              # Source code directory
│   ├── YarSailorApp.mc      # Main application class
│   ├── YarSailorView.mc     # Data view for metrics display
│   └── YarSailorDelegate.mc # Input handler
└── resources/           # Application resources
    ├── resources.xml        # Resource configuration
    ├── drawables/          # Images and icons
    ├── layouts/            # UI layouts
    └── strings/            # Localized strings
```

## Development

### Key Files

- **YarSailorApp.mc**: Main application entry point
- **YarSailorView.mc**: Handles GPS position updates and metric display
- **YarSailorDelegate.mc**: Manages user input and interactions

### Permissions

The app requires the following permissions:
- **Positioning**: For GPS location data
- **Sensor**: For heading and speed data

## Future Enhancements

- [ ] Wind speed and direction
- [ ] Tacking angles
- [ ] Waypoint navigation
- [ ] Trip statistics (distance, average speed, max speed)
- [ ] Multiple display pages
- [ ] Data recording and history
- [ ] VMG (Velocity Made Good) calculation
- [ ] Customizable data fields

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Credits

Developed using the Garmin Connect IQ SDK.

## Support

For issues, questions, or feature requests, please open an issue on GitHub.
