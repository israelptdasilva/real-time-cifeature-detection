import AVFoundation
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var camera: Camera!
    var canvas: Canvas!
    
    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(superview: view)
        camera = Camera(delegate: self)
        camera.session.startRunning()
    }
    
    // MARK: - Deinit

    deinit {
        camera.session.stopRunning()
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        var image = CIImage(cvPixelBuffer: imageBuffer, options: nil)
    
        CIDetector.rectangle?.features(in: image, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: NSNumber(value: 1), CIDetectorImageOrientation : NSNumber(value: 6.0), CIDetectorFocalLength: NSNumber(value: 0.0)]).forEach{ f in
            if let feature = f as? CIRectangleFeature {
                feature.perspectiveOverlay(on: image, with: CIColor.redTone).flatMap{
                    image = $0
                }
            }
        }
        
        CIDetector.text?.features(in: image, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorImageOrientation : NSNumber(value: 6.0), CIDetectorFocalLength: NSNumber(value: 0.0)]).forEach{ f in
            if let feature = f as? CITextFeature {
                feature.perspectiveOverlay(on: image, with: CIColor.blueTone).flatMap{
                    image = $0
                }
            }
        }
        
        canvas.draw(image: image)
    }
}


