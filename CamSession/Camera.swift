import AVFoundation

struct Camera {
    
    // MARK: - Properties
    
    var session = AVCaptureSession()
    
    fileprivate var sessionPreset = AVCaptureSessionPresetHigh
    
    fileprivate var sessionInput: AVCaptureDeviceInput! = {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        return try? AVCaptureDeviceInput(device: device)
    }()
    
    fileprivate var sessionOutput: AVCaptureVideoDataOutput! = {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
        return output
    }()
    
    // MARK: - Initializer

    init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        session.beginConfiguration()
        if session.canAddInput(sessionInput) {
            session.addInput(sessionInput)
        }
        if session.canAddOutput(sessionOutput) {
            sessionOutput?.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "cam.session", attributes: []))
            session.addOutput(sessionOutput)
        }
        if session.canSetSessionPreset(sessionPreset) {
            session.sessionPreset = sessionPreset
        }
        session.commitConfiguration()
    }
}
