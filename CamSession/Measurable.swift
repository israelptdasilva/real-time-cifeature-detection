import UIKit

protocol Measurable {
    var bounds: CGRect { get }
    var topLeft: CGPoint { get }
    var topRight: CGPoint { get }
    var bottomLeft: CGPoint { get }
    var bottomRight: CGPoint { get }
}

extension Measurable {
    func perspectiveOverlay(on image: CIImage, with color: CIColor) -> CIImage? {
        var overlay = CIImage(color: color)
        overlay = overlay.cropping(to: bounds)
        overlay = overlay.applyingFilter(
            "CIPerspectiveTransformWithExtent",
            withInputParameters: [
                "inputExtent": CIVector(cgRect: image.extent),
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)])
        
        return overlay
    }
}
