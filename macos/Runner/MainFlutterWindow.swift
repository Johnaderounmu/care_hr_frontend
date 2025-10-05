import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    // Set Flutter view controller as content
    self.contentViewController = flutterViewController
    // Make window background a light grey instead of default black to avoid black splash
    if let contentView = self.contentView {
      contentView.wantsLayer = true
      contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
    // Improve window appearance
    self.titlebarAppearsTransparent = true
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
