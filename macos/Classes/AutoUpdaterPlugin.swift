import Cocoa
import FlutterMacOS

public class AutoUpdaterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "auto_updater", binaryMessenger: registrar.messenger)
        let instance = AutoUpdaterPlugin(registrar, channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private var registrar: FlutterPluginRegistrar!;
    private var channel: FlutterMethodChannel!
    
    private var autoUpdater: AutoUpdater = AutoUpdater()
    
    public init(_ registrar: FlutterPluginRegistrar, _ channel: FlutterMethodChannel) {
        super.init()
        self.registrar = registrar
        self.channel = channel
        autoUpdater.onEvent = {
            (eventName: String) in
            self._emitEvent(eventName)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args: [String: Any] = call.arguments as? [String: Any] ?? [:]
        
        switch call.method {
        case "setFeedURL":
            let feedURL = URL(string: args["feedURL"] as! String)
            autoUpdater.setFeedURL(feedURL)
            result(true)
            break
        case "checkForUpdates":
            let inBackground = args["inBackground"] as! Bool
            if(inBackground) {
                autoUpdater.checkForUpdatesInBackground()
            }else {
                autoUpdater.checkForUpdates()
            }
            result(true)
            break
        case "setScheduledCheckInterval":
            let interval = args["interval"] as! Double
            autoUpdater.setScheduledCheckInterval(interval)
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func _emitEvent(_ eventName: String) {
        let args: NSDictionary = [
            "eventName": eventName,
        ]
        channel.invokeMethod("onEvent", arguments: args, result: nil)
    }
}
