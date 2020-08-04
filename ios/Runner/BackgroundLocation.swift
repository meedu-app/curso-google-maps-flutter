
import Foundation
import CoreLocation


protocol BackgroundLocationDelegate {
    func onBackgroundLocationUpdate(coord: CLLocationCoordinate2D)
}

class BackgroundLocation: NSObject, CLLocationManagerDelegate {
    let manager:CLLocationManager = CLLocationManager()
    var running = false
    var delegate: BackgroundLocationDelegate?
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location =  locations.last {
            if self.delegate != nil {
                self.delegate!.onBackgroundLocationUpdate(coord: location.coordinate)
            }
        }
    }
    
    override init() {
        super.init()
        self.manager.delegate = self
    }
    
    
    func start()  {
        
        if self.running {
            return
        }
        
        if #available(iOS 11.0, *) {
            self.manager.allowsBackgroundLocationUpdates = true
            self.manager.showsBackgroundLocationIndicator = true
            self.manager.pausesLocationUpdatesAutomatically = false
        }
        
        self.manager.startUpdatingLocation()
        self.running = true
        
    }
    
    func stop()  {
        if #available(iOS 11.0, *) {
            self.manager.allowsBackgroundLocationUpdates = false
            self.manager.showsBackgroundLocationIndicator = false
            self.manager.pausesLocationUpdatesAutomatically = true
        }
        self.manager.stopUpdatingLocation()
        self.running = false
    }
    
}
