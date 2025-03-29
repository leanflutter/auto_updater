import Cocoa
import FlutterMacOS

public class AutoUpdaterMacosPlugin: NSObject, FlutterPlugin,FlutterStreamHandler {
    private var _eventSink: FlutterEventSink?

    private var autoUpdater: AutoUpdater = AutoUpdater()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.leanflutter.plugins/auto_updater", binaryMessenger: registrar.messenger)
        let instance = AutoUpdaterMacosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "dev.leanflutter.plugins/auto_updater_event", binaryMessenger: registrar.messenger)
        eventChannel.setStreamHandler(instance)
        instance.autoUpdater.onEvent = {
            (eventName: String, eventData: NSDictionary) in
            guard let eventSink = instance._eventSink else {
                return
            }
            let event: NSDictionary = [
                "type": eventName,
                "data": eventData
            ]
            eventSink(event)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self._eventSink = events
        return nil;
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self._eventSink = nil
        return nil
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
        case "checkForUpdateInformation":
            autoUpdater.checkForUpdateInformation()
            result(true)
            break
        case "setScheduledCheckInterval":
            let interval = args["interval"] as! Int
            autoUpdater.setScheduledCheckInterval(interval)
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

