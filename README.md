# Feature Detector

**Goals:**

In this project I wanted to be able to perform real-time detection of text and rectangle shapes using the iPhone built-in camera. This is part of a proof-of-concept that I'm building for a self health diagnostic start-up. Here I will describe the steps I took to capture images frames, perform feature detection on them and draw an overlay representing the boundries of the detected featured.

------------

**Tools:**
- [AVCaptureSession](https://developer.apple.com/documentation/avfoundation/avcapturesession)
- [CIDetector](https://developer.apple.com/documentation/coreimage/cidetector)
- [GLKView](https://developer.apple.com/documentation/glkit/glkview)

Note: Apple has released the Vision Framework, which is now a replacement tool for feature detection on images.

------------

### Video capture with AVCaptureSession:

>An AVCaptureSession object is the central coordinating object you use to manage data capture. You use an instance to coordinate the flow of data from AV input devices to outputs. You add the capture devices and outputs you want to the session, then start data flow by sending the session a startRunning message, and stop the data flow by sending a stopRunning message.

To build a video session a new AVCaptureSession object needs to be created and configured as follows:

Start by making a new AVCaptureSession.

```swift
  var session = AVCaptureSession()
```

Next, the session needs to know which type of input and output need to be managed.

Make a new AVCaptureDeviceInput object with video media type:

```swift
  fileprivate var sessionInput: AVCaptureDeviceInput! = {
      let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
      return try? AVCaptureDeviceInput(device: device)
  }()
```


Now make a new AVCaptureVideoDataOutput object.

In the output settings we add the key kCVPixelBufferPixelFormatTypeKey and the recommended value kCVPixelFormatType_32BGRA to configure the decoder format. [`alwaysDiscardsLateVideoFrames`](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutput/1385780-alwaysdiscardslatevideoframes) is set to true to improve memory usage and give priority to frames currently being processed in the dispatch queue. The default value for this property is `true`.

```swift
  fileprivate var sessionOutput: AVCaptureVideoDataOutput! = {
      let output = AVCaptureVideoDataOutput()
      output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
      output.alwaysDiscardsLateVideoFrames = true
      return output
  }()
```


Additionaly, AVCaptureVideoDataOutput has a delegate property that can be set to listen for AVCaptureVideoDataOutputSampleBufferDelegate protocol callback functions everytime a frame buffer is outputed in the video session. The delegate object needs to implement the [`AVCaptureVideoDataOutputSampleBufferDelegate`](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate) protocol. 

A serial queue is used to send the sample buffers in sequence to delegate callback.

```swift
  sessionOutput?.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "cam.session", attributes: []))
```


Typically a UIViewController is the delegate implementing the [AVCaptureVideoDataOutputSampleBufferDelegate](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate) protocol:

```swift
  extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

      func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
      }
  }
```


Use a session preset to choose the camera presets best suitable for use case. By default this property is [AVCaptureSessionPresetHigh](https://developer.apple.com/documentation/avfoundation/avcapturesessionpresethigh?preferredLanguage=occ).

```swift
  fileprivate var sessionPreset = AVCaptureSessionPresetMedium
```


To preview the image frames from the video session use [AVCaptureVideoPreviewLayer](https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer), typically as a sublayer of view controller UIView. This project instead uses a GLKView (explained later in this doc) to draw a composition of the image frame with the bounding box of detected features, but a preview layer could be used as follows:

```swift
  var preview =  AVCaptureVideoPreviewLayer(session: session)
  superview.layer.addSublayer(preview)
```


Finally, session configurations are added with [beginConfiguration()](https://developer.apple.com/documentation/avfoundation/avcapturesession/1389174-beginconfiguration) paired with [commitConfiguration()](https://developer.apple.com/documentation/avfoundation/avcapturesession/1388173-commitconfiguration). A new or running session can have it's configurations changed as follows: 
```swift
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
```


Hook up the video session with the view controller:

```swift

...
  var camera: Camera!

  // MARK: - Override

  override func viewDidLoad() {
      super.viewDidLoad()
      camera = Camera(delegate: self)
      camera.session.startRunning()
  }

...
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) { 
    }
}
```


Check `Camera.swift` for video session configuration.

### Feature detection with CIDetector:

Now with the video session running, and the view controller being able to receive image buffers, feature detection is performed with a CIDetector object.

>A CIDetector object uses image processing to search for and identify notable features (faces, rectangles, and barcodes) in a still image or video. Detected features are represented by
CIFeature objects that provide more information about each feature.

The CIDetector receives a type:

```swift
let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [:])
```


To perform detection over an image, call [`features(in image: CIImage, options: [String : Any]? = nil)`](https://developer.apple.com/documentation/coreimage/cidetector/1438189-features) in the detector object. First convert the sampleBuffer to a CIImage object.
```swift
...
   
  func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var image = CIImage(cvPixelBuffer: imageBuffer, options: nil)
        
...
```


Detect rectangle features in image:
```swift
let options: [String : Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1, CIDetectorImageOrientation : 6, CIDetectorNumberOfAngles: 1]
 
detector?.features(in: image, options: options).forEach{ {
  if let feature = f as? CIRectangleFeature {
    print(feature.bounds)
  }
}
```


### Combine image frame with feature overlay and draw in a GLKView:

>The GLKView class simplifies the effort required to create an OpenGL ES application by directly managing a framebuffer object on your behalf; your application simply needs to draw into the framebuffer when the contents need to be updated.

Add a GLKView as subview of view controller's UIView:

```swift
  let glkView = GLKView(frame: .zero, context: EAGLContext(api: .openGLES2))
  glkView.frame = superview.frame
  superview.addSubview(glkView)
```


Bind the GLKView with the 

By default video image orientation is landscape left, so the GLKView image will render images rotate 90 degrees. So if images need to be drawn in portrait apply a rotation affine transform.

```swift
  glkView.transform = CGAffineTransform(rotationAngle: .pi / 2)
```


Use a CIContext to draw the image in the GLKView context. 

>CIContext: An evaluation context for rendering image processing results and performing image analysis.

```swift 
  let ciContext = CIContext(eaglContext: glkView.context)
```


Use bindDrawable() before drawing to the context. 

> If your application changed the framebuffer object bound to OpenGL ES, it calls this method to rebind the view’s framebuffer object to OpenGL ES.

Also, a GLKView that is not managed by a GLKView controller needs to have display() called to reload the it's contents after is drawn on. 

```swift
  glkView.bindDrawable()
  ciContext.draw(image, in: self.extent, from: extent)
  glkView.display()
```


Draw the final image in the GLKView:

```swift
...

    var camera: Camera!
    var canvas: Canvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(superview: view)
        camera = Camera(delegate: self)
        camera.session.startRunning()
    }

...
```

```swift
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var image = CIImage(cvPixelBuffer: imageBuffer, options: nil)
        
        CIDetector.rectangle?.features(in: image, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1, CIDetectorImageOrientation : 6, CIDetectorNumberOfAngles: 1]).forEach{ f in
            if let feature = f as? CIRectangleFeature {
                feature.perspectiveOverlay(on: image, with: CIColor.redTone).flatMap{
                    image = $0
                }
            }
        }
        
        canvas.draw(image: image)
    }
}
```

## Results

[Feature detection demo](https://www.youtube.com/watch?v=sTMycanUZls)


**Resources:**
* [AVFoundation programming guide](https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html)
* [Camera Capture in iOS - objc.io](https://www.objc.io/issues/21-camera-and-photos/camera-capture-on-ios/)
* [CoreImage-Detectors - shinobicontrols.com](https://www.shinobicontrols.com/blog/ios8-day-by-day-day-13-coreimage-detectors)
