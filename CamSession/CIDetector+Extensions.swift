import AVFoundation
import CoreImage

extension CIDetector {
    static let rectangle: CIDetector? = {
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [:])
        return detector
    }()
    
    static let text: CIDetector? = {
        let detector = CIDetector(ofType: CIDetectorTypeText, context: nil, options: [:])
        return detector
    }()
}

extension CIColor {
    static let redTone: CIColor = {
        return CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
    }()
    
    static let blueTone: CIColor = {
        return CIColor(red: 0.0, green: 0, blue: 1.0, alpha: 0.5)
    }()
}

extension CITextFeature: Measurable {}
extension CIRectangleFeature: Measurable {}
