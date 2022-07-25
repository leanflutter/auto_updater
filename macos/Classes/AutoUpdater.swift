import Cocoa
import FlutterMacOS
import Sparkle

public class AutoUpdater: NSObject, SPUUpdaterDelegate {
    var _userDriver: SPUStandardUserDriver?
    var _updater: SPUUpdater?
    
    public var onEvent:((String) -> Void)?
    
    override init() {
        super.init()
        let hostBundle: Bundle = Bundle.main
        
        _userDriver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: nil)
        _updater = SPUUpdater(
            hostBundle: hostBundle,
            applicationBundle: hostBundle,
            userDriver: _userDriver!,
            delegate: self
        )
    }
    
    public func setFeedURL(_ feedURL: URL?) {
        _updater?.setFeedURL(feedURL)
        try? _updater?.start()
    }
    
    public func checkForUpdates() {
        _updater?.checkForUpdates()
    }
    
    public func checkForUpdatesInBackground() {
       _updater?.checkForUpdatesInBackground()
    }

    public func setScheduledCheckInterval(_ interval: Int) {
        _updater?.updateCheckInterval = TimeInterval(interval)
    }
    
    // SPUUpdaterDelegate
    
    public func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        _emitEvent("error");
    }
    
    public func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        _emitEvent("checking-for-update")
    }
    
    public func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        _emitEvent("update-available")
    }
    
    public func updaterDidNotFindUpdate(_ updater: SPUUpdater, error: Error) {
        _emitEvent("update-not-available")
    }
    
    public func updater(_ updater: SPUUpdater, didDownloadUpdate item: SUAppcastItem) {
        _emitEvent("update-downloaded")
    }
    
    public func updater(_ updater: SPUUpdater, willInstallUpdateOnQuit item: SUAppcastItem, immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) -> Bool {
        _emitEvent("before-quit-for-update")
        return true
    }
    
    public func _emitEvent(_ eventName: String) {
        if (onEvent != nil) {
            onEvent!(eventName)
        }
    }
}
