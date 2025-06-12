import Cocoa
import FlutterMacOS

@main
class : Flutter {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}
