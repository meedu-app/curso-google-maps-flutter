import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, BackgroundLocationDelegate, FlutterStreamHandler {
    
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        
        self.eventSink = eventSink
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    func onBackgroundLocationUpdate(coord: CLLocationCoordinate2D) {
        
        if self.eventSink != nil{
            self.eventSink!(["lat":coord.latitude,"lng":coord.longitude])
        }
    }
    
    
    
    let backgroundLocation:BackgroundLocation = BackgroundLocation()
    var eventSink: FlutterEventSink?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCKBsa2IUb24xbqd7D6ukpA26F9bE4C9Sg")
        self.backgroundLocation.delegate = self
        let controller = window?.rootViewController as! FlutterViewController
        
        let channel = FlutterMethodChannel(name: "app.meedu/background-location", binaryMessenger: controller.binaryMessenger)
        
        let eventChannel = FlutterEventChannel(name: "app.meedu/background-location-events", binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler(self.handler)
        eventChannel.setStreamHandler(self)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func handler(call:FlutterMethodCall, result: FlutterResult)  {
        
        switch call.method {
        case "start":
            self.backgroundLocation.start()
            result(nil)
            
        case "stop":
            self.backgroundLocation.stop()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
    
    
    override func applicationWillTerminate(_ application: UIApplication) {
        self.backgroundLocation.stop()
    }
}
