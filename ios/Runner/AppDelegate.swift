import UIKit
import Flutter
import GoogleMaps
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,BackgroundLocationDelegate, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    
    let backgrounLocation = BackgroundLocation()
    var eventSink:FlutterEventSink?
    
    func onLocation(_ location: CLLocationCoordinate2D) {
        print(location.latitude,location.longitude)
        
        if self.eventSink != nil{
            self.eventSink!(["lat":location.latitude,"lng":location.longitude])
        }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCKBsa2IUb24xbqd7D6ukpA26F9bE4C9Sg")
        GeneratedPluginRegistrant.register(with: self)
        
        self.backgrounLocation.backgroundLocationDelegate = self
        
        let controller =  window?.rootViewController as! FlutterViewController
        
        
        let channel = FlutterMethodChannel(name: "app.meedu/geolocation", binaryMessenger: controller.binaryMessenger)
        
        let eventChannel = FlutterEventChannel(name: "app.meedu/geolocation-listener", binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler(self.callHandler)
        eventChannel.setStreamHandler(self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func  callHandler(call: FlutterMethodCall, result:@escaping FlutterResult) {
        switch call.method {
        case "start":
            self.backgrounLocation.start(background: true)
        case "stop":
            self.backgrounLocation.stop()
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    
    
    override func applicationWillTerminate(_ application: UIApplication) {
        self.backgrounLocation.stop()
    }
    
}
