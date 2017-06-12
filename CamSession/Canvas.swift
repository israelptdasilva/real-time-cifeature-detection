import GLKit

struct Canvas {
    
    // MARK: - Properties
    
    fileprivate var glkView: GLKView = {
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
        superview.addSubview(glkView)
        ciContext = CIContext(eaglContext: glkView.context)
        extent = CGRect(x: 0, y: 0, width: glkView.drawableWidth, height: glkView.drawableHeight)
    }
    
    // MARK: - Functions

    func draw(image: CIImage) {
        var extent = image.extent
        extent.size.height = extent.width / (self.extent.width / self.extent.height)
        
        glkView.bindDrawable()
        ciContext.draw(image, in: self.extent, from: extent)
        glkView.display()
    }
}
