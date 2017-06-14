import GLKit

struct Canvas {
    
    // MARK: - Properties
    
    fileprivate let glkView: GLKView = {
        let view = GLKView(frame: .zero, context: EAGLContext(api: .openGLES2))
        view.transform = CGAffineTransform(rotationAngle: .pi / 2)
        return view
    }()
    
    fileprivate var extent: CGRect!
    fileprivate var ciContext: CIContext!
    fileprivate var glContext: EAGLContext!
        
    // MARK: - Initializer
    
    init(superview: UIView) {
        glkView.frame = superview.frame
        glkView.bindDrawable()
        glkView.isOpaque = false
        glkView.layer.isOpaque = false
        superview.addSubview(glkView)
        
        ciContext = CIContext(eaglContext: glkView.context)
        extent = CGRect(x: 0, y: 0, width: glkView.drawableWidth, height: glkView.drawableHeight)
    }
    
    // MARK: - Functions

    func draw(image: CIImage) {
        glkView.bindDrawable()
        if glkView.context != EAGLContext.current() {
            EAGLContext.setCurrent(glkView.context)
        }
        
        glClearColor(0.0,0.0,0.0,0.0);
        ciContext.draw(image, in: extent, from: image.extent)
        glkView.display()
    }
}
