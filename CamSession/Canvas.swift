import GLKit

struct Canvas {
    
    // MARK: - Properties
    
    fileprivate var glkView: GLKView!
    
    fileprivate let extent: CGRect!
    
    fileprivate var ciContext: CIContext!
    
    // MARK: - Initializer
    
    init(superview: UIView) {
        glkView = GLKView(frame: .zero, context: EAGLContext(api: .openGLES2))
        glkView.frame = superview.frame
        glkView.transform = CGAffineTransform(rotationAngle: .pi / 2)
        superview.addSubview(glkView)
        
        ciContext = CIContext(eaglContext: glkView.context)
        glkView.bindDrawable()
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
