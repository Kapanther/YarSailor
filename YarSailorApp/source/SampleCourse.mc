import Toybox.Lang;

// Sample course data embedded in the app for testing
class SampleCourse {
    
    // Waypoint structure: [lat, lon, name, comment]
    static const WAYPOINTS as Array<Array> = [
        [-32.002127375811, 115.775839848537, "Start Finish 1", "1"],
        [-32.010965108852, 115.796931229495, "Miller (P)", "2"],
        [-31.995832452129, 115.825945695646, "Dolphin West (S)", "3"],
        [-32.012234078767, 115.799957671219, "Bricklanding A (S)", "4"],
        [-32.000571970725, 115.814454706267, "Armstrong (P)", "5"],
        [-32.004602726144, 115.805896485798, "Dome Bouy (P)", "6"],
        [-32.011347075046, 115.798604233408, "Bricklanding B (S)", "7"],
        [-31.998900714627, 115.780301012328, "Parker Bouy (P)", "8"],
        [-32.008345799833, 115.775709827479, "Suicide Bouy (P)", "9"],
        [-31.999377854607, 115.780446781311, "Parker DAY BOUY (S)", "10"],
        [-32.008086240108, 115.774119345664, "Mosman Bouy (P)", "11"],
        [-32.002127375811, 115.775839848537, "Start Finish 1", "12"]
    ];
    
    static const COURSE_NAME as String = "Sample Course";
    
    static function getWaypointCount() as Number {
        return WAYPOINTS.size();
    }
    
    static function getWaypoint(index as Number) as Array? {
        if (index >= 0 && index < WAYPOINTS.size()) {
            return WAYPOINTS[index];
        }
        return null;
    }
    
    static function getWaypointLatitude(index as Number) as Double? {
        var waypoint = getWaypoint(index);
        if (waypoint != null) {
            return waypoint[0];
        }
        return null;
    }
    
    static function getWaypointLongitude(index as Number) as Double? {
        var waypoint = getWaypoint(index);
        if (waypoint != null) {
            return waypoint[1];
        }
        return null;
    }
    
    static function getWaypointName(index as Number) as String? {
        var waypoint = getWaypoint(index);
        if (waypoint != null) {
            return waypoint[2];
        }
        return null;
    }
}
