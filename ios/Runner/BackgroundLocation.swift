import Foundation
import CoreLocation


protocol BackgroundLocationDelegate {
    func onLocation(_ location: CLLocationCoordinate2D)
}

class BackgroundLocation: NSObject, CLLocationManagerDelegate {
    let locationManager:CLLocationManager = CLLocationManager()
    var background:Bool = false;
    var backgroundLocationDelegate: BackgroundLocationDelegate?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if (self.backgroundLocationDelegate != nil) {
                self.backgroundLocationDelegate?.onLocation(location.coordinate)
            }
        }
    }
    
    
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func start(background:Bool)  {
        if background, #available(iOS 11.0, *) {
            self.background = true
            self.locationManager.showsBackgroundLocationIndicator = true
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.pausesLocationUpdatesAutomatically = false
            print("🎃🎃🎃🎃🎃🎃🎃 enable background location")
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func stop()  {
        if self.background, #available(iOS 11.0, *) {
            self.background = false
            self.locationManager.showsBackgroundLocationIndicator = false
            self.locationManager.allowsBackgroundLocationUpdates = false
            self.locationManager.pausesLocationUpdatesAutomatically = true
            print("🎃🎃🎃🎃🎃🎃🎃 stop background location")
        }
        self.locationManager.stopUpdatingLocation()
    }
}
