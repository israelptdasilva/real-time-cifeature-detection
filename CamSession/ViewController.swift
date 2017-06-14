import AVFoundation
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var camera: Camera!
    var canvas: Canvas!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        camera = Camera(self.view, delegate: self)
        canvas = Canvas(superview: view)
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
        
        CIDetector.rectangle?.features(in: image, options: [CIDetectorNumberOfAngles: 3.0, CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: NSNumber(value: 1), CIDetectorImageOrientation : NSNumber(value: 6.0), CIDetectorFocalLength: NSNumber(value: 0.0), ]).first.flatMap{ f in
            if let feature = f as? Measurable {
                feature.perspectiveOverlay(on: image, with: CIColor.redTone).flatMap{
                    image = $0
                    canvas.draw(image: image)
                }
            }
        }
        
        canvas.draw(image: image)

    }
}


