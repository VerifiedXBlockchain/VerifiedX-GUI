import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {

  private let methodChannelName = "io.reserveblock.wallet/quit"
  private var shouldTerminate = false


  override func applicationDidBecomeActive(_ notification: Notification) {
    signal(SIGPIPE, SIG_IGN) //Ignore signal
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    
    // Set up the platform channel
    if let flutterViewController = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let methodChannel = FlutterMethodChannel(
        name: methodChannelName,
        binaryMessenger: flutterViewController.engine.binaryMessenger
      )
      
      methodChannel.setMethodCallHandler { [weak self] call, result in
        if call.method == "quitApp" {
          self?.quitApp()
        }
      }
    }
  }

  override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    if shouldTerminate {
      return .terminateNow
    }

    // Prevent default termination and ask Flutter
    if let flutterViewController = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let methodChannel = FlutterMethodChannel(
        name: methodChannelName,
        binaryMessenger: flutterViewController.engine.binaryMessenger
      )
      
      methodChannel.invokeMethod("shouldQuit", arguments: nil) { [weak self] response in
        let shouldQuit = (response as? Bool) ?? false
        if shouldQuit {
          self?.shouldTerminate = true
          NSApplication.shared.terminate(nil)
        }
      }
    }
    
    return .terminateCancel
  }

  private func quitApp() {
    NSApplication.shared.terminate(nil)
  }
}
