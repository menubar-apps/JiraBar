import Foundation
import AppKit

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
    
    static func imageFromUrl(fromURL url: URL) -> NSImage? {
        guard let data = try? Foundation.Data(contentsOf: url) else { return nil }
        guard let image = NSImage(data: data) else {
            print("OOOPSIE")
            return nil }
        return image
    }
}
