//
//  Extensions.swift
//  GenericApp
//
//  Created by Ahmed Mh on 1/29/18.
//  Copyright © 2018 Machinestalk. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import ImageIO
import CoreMotion

private var flatAssociatedObjectKey: UInt8 = 0
private var palceHolderColorAssociatedObject: UInt8 = 0

struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

enum ImageFormat{
    case Unknown, png, jpeg, gif, tiff
}

extension NSData{
    var imageFormat: ImageFormat{
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        if buffer == ImageHeaderData.PNG
        {
            return .png
        } else if buffer == ImageHeaderData.JPEG
        {
            return .jpeg
        } else if buffer == ImageHeaderData.GIF
        {
            return .gif
        } else if buffer == ImageHeaderData.TIFF_01 || buffer == ImageHeaderData.TIFF_02{
            return .tiff
        } else{
            return .Unknown
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
extension String {
    
    func localized(lang:String) -> String {
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        
    }
    
}

extension String {
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
}

extension String {
    
    var isValidPassword: Bool {
        let passwordRegEx = "^(?!.*\\s)(?=.*?[A-Za-z])(?=.*?[0-9]).{8,16}$"
        return NSPredicate(format:"SELF MATCHES %@", passwordRegEx).evaluate(with: self)
    }
}
extension String {
    
    var isValidSaoudiPhoneNumber: Bool {
        if self.count == 9 && (self.hasPrefix("5") || self.hasPrefix("٥")){
        return true
        }
        else
        {
            return false
        }
    }
}
extension String {
    
    var isEmptyOrNull: Bool {
        if self.isEmpty || self.count == 0 {
            return true
        } else {
            return false
        }
    }
    
}
extension Decimal {
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber)
    }
}
extension String {
    var isDigits: Bool {
        guard !self.isEmpty else { return false }
        return !self.contains { Int(String($0)) == nil }
    }
}
extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        //layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    public func pauseAnimation(delay delay: Double) {
        let time = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, time, 0, 0, 0, { timer in
            let layer = self.layer
            let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.speed = 0.0
            layer.timeOffset = pausedTime
        })
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
    }
    
    public func resumeAnimation() {
        let pausedTime  = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    }

}
extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: range.lowerBound)
        let idx2 = index(startIndex, offsetBy: range.upperBound)
        return String(self[idx1..<idx2])
    }
}

extension CALayer {
    var borderWidthIB: NSNumber {
        get {
            return NSNumber(value: Float(borderWidth))
        }
        set {
            borderWidth = CGFloat(newValue.floatValue)
        }
    }
    var borderColorIB: UIColor? {
        get {
            return borderColor != nil ? UIColor(cgColor: borderColor!) : nil
        }
        set {
            borderColor = newValue?.cgColor
        }
    }
    var cornerRadiusIB: NSNumber {
        get {
            return NSNumber(value: Float(cornerRadius))
        }
        set {
            cornerRadius = CGFloat(newValue.floatValue)
        }
  }

}

extension UIView {
    func setRadiusWithShadow(_ radius: CGFloat? = nil) { // this method adds shadow to right and bottom side of button
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
    }
    
    func setAllSideShadow(shadowShowSize: CGFloat = 1.0) { // this method adds shadow to allsides
        let shadowSize : CGFloat = shadowShowSize
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y:  7,
                                                   width: self.frame.size.width,
                                                   height: self.frame.size.height + shadowSize))
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: -6.0, height: 6.0)
        self.layer.shadowOpacity = 0.7
        //self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowRadius = 8.0
    }
    
    func setAllSideShadow(shadowOpacity: Float = 1.0,shadowColor: UIColor,shadowOffset: CGSize,shadowRadius: CGFloat ) { // this method adds shadow to allsides
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        //self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowRadius = shadowRadius
    }
}
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}
extension UIScreen {
    
    enum SizeType: CGFloat {
        case Unknown = 0.0
        case iPhone4_4S = 960.0
        case iPhones_5_5s_5c_SE = 1136.0
        case iPhones_6_6s_7_8 = 1334.0
        case iPhone6Plus = 1920.0
        case iPhones_6sPlus_7Plus_8Plus = 2208
        case iPhoneX , iPhoneXS  = 2436
        case iPhoneXSMax = 2688
        case iPhoneXR = 1792.0
        
    }
    
    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
}

extension UITextField {
   
    
    @IBInspectable var alignment:Bool {
        set {
            if newValue {
                
                if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                    
                    self.textAlignment = .right
                }
            }
        }
        
        get{
            
            return false
        }
    }
    
}
extension UIColor {
    
    func colorByDarkeningColorWithValue(value:CGFloat)->UIColor{
        
        let totalComponents = self.cgColor.numberOfComponents
        let isGreyscale = (totalComponents == 2) ? true : false
        
        let oldComponents = self.cgColor.components
        var newComponents = [CGFloat]()
        
        if (isGreyscale) {
            newComponents.append((oldComponents?[0])! - value < 0.0 ? 0.0 : (oldComponents?[0])! - value)
            newComponents.append((oldComponents?[0])! - value < 0.0 ? 0.0 : (oldComponents?[0])! - value)
            newComponents.append((oldComponents?[0])! - value < 0.0 ? 0.0 : (oldComponents?[0])! - value)
            newComponents.append((oldComponents?[1])!)
        }else {
            newComponents.append((oldComponents?[0])! - value < 0.0 ? 0.0 : (oldComponents?[0])! - value)
            newComponents.append((oldComponents?[1])! - value < 0.0 ? 0.0 : (oldComponents?[1])! - value)
            newComponents.append((oldComponents?[2])! - value < 0.0 ? 0.0 : (oldComponents?[2])! - value)
            newComponents.append((oldComponents?[3])!)
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let newColor = CGColor(colorSpace: colorSpace, components: newComponents);
        let retColor = UIColor(cgColor: newColor!)
        
        return retColor;
    }
    convenience init(hex: Int) {
        self.init(hex: hex, a: 1.0)
    }
    
    convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff, a: a)
    }
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    convenience init?(hexString: String) {
        guard let hex = hexString.hex else {
            return nil
        }
        self.init(hex: hex)
    }
    
    func hexStringFromColor() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"%06x", rgb)
    }
}
/*
 An extension that adds a "flat" field to UINavigationBar. This flag, when
 enabled, removes the shadow under the navigation bar.
 */
@IBDesignable extension UINavigationBar {
    @IBInspectable var flat: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &flatAssociatedObjectKey) as? NSNumber else {
                return false
            }
            return obj.boolValue;
        }
        
        set {
            if (newValue) {
                let void = UIImage()
                setBackgroundImage(void, for: .any, barMetrics: .default)
                shadowImage = void
            } else {
                setBackgroundImage(nil, for: .any, barMetrics: .default)
                shadowImage = nil
            }
            objc_setAssociatedObject(self, &flatAssociatedObjectKey, NSNumber(value: newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
extension UIButton {
    
    
    
    func flipImageAndLabel(){
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        if(self.titleLabel != nil && self.imageView != nil){
            self.titleLabel!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.imageView!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }
    func alignImageRight() {
        if let titleLabel = self.titleLabel, let imageView = self.imageView {
            // Force the label and image to resize.
            titleLabel.sizeToFit()
            imageView.sizeToFit()
            imageView.contentMode = .scaleAspectFit
            
            // Set the insets so that the title appears to the left and the image appears to the right.
            // Make the image appear slightly off the top/bottom edges of the button.
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -1 * (imageView.frame.size.width + 4),
                                                bottom: 0, right: imageView.frame.size.width + 4)
            self.imageEdgeInsets = UIEdgeInsets(top: 4, left: titleLabel.frame.size.width + 4,
                                                bottom: 4, right: -1 * (titleLabel.frame.size.width + 4))
        }
    }
    func setUpAsTag(title:String,image:UIImage,spacing:CGFloat,bgColor:UIColor,textFont:UIFont,textColor:UIColor){
        self.setTitle(title, for: .normal)
        self.setImage(image, for: .normal)
        self.backgroundColor = bgColor
        self.layer.cornerRadius = 5
        self.setTitleColor(textColor, for: .normal)
        self.titleLabel?.font = textFont
        alignImageRight()
    }
    func bounce() {
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        self?.transform = .identity
            },completion: nil)
    }
}
extension UIImage{
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resizedCroppedImage(newSize:CGSize) -> UIImage {
        var ratio: CGFloat = 0
        var delta: CGFloat = 0
        var offset = CGPoint(x: 0, y: 0)
        if self.size.width > self.size.height {
            ratio = newSize.width / self.size.width
            delta = (ratio * self.size.width) - (ratio * self.size.height)
            offset = CGPoint(x:delta / 2, y:0)
        } else {
            ratio = newSize.width / self.size.height
            delta = (ratio * self.size.height) - (ratio * self.size.width)
            offset = CGPoint(x:0, y:delta / 2)
        }
        let clipRect = CGRect(x:-offset.x, y:-offset.y, width:(ratio * self.size.width) + delta, height:(ratio * self.size.height) + delta)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        UIRectClip(clipRect)
        self.draw(in: clipRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    var rounded: UIImage? {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = min(size.height/2, size.width/2)
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        
        let rect = CGRect(x:0, y:0, width:size.width, height:size.height)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return image!;
    }
    
        

        /// Returns the data for the specified image in JPEG format.
        /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
        /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
        func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
            return jpegData(compressionQuality: jpegQuality.rawValue)
        }

}
extension UINavigationController {
    func hideNavigationBar(hide:Bool){
        self.setNavigationBarHidden(hide, animated: false)
    }
    func setNavigationControllerTransparent(){
        self.navigationBar.backgroundColor = UIColor.clear
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
}

extension UINavigationBar {
    
    func setGradientBackground(colors: [UIColor]) {
        
        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
}

extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor]) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        startPoint = CGPoint(x: 0, y: 1)
        endPoint = CGPoint(x: 1, y: 1)
    }
    
    func createGradientImage() -> UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}


extension UIView {
    
    func setGradientView(_ color1: UIColor, _ color2: UIColor) {
        
        let gradient = CAGradientLayer()
        
        gradient.startPoint = CGPoint(x:0,y:1)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        gradient.frame = self.bounds
        gradient.colors = [color1.cgColor, color2.cgColor]
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func alphaGradientY(_ reverse: Bool) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        if !reverse {
            gradientLayer.startPoint = CGPoint(x:0.5,y:0.0)
            gradientLayer.endPoint = CGPoint(x:0.5,y:1.0)
            gradientLayer.locations = [(0.0), (0.2), (0.4), (0.6), (0.8) , (1.0)]
        }else{
            gradientLayer.startPoint = CGPoint(x:0.5,y:1.0)
            gradientLayer.endPoint = CGPoint(x:0.5,y:0.0)
            gradientLayer.locations = [(0.0), (0.2), (0.4), (0.6), (0.8) , (1.0)].reversed()
        }
        
        gradientLayer.colors = [UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha:            1).cgColor,
                                UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8).cgColor,
                                UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6).cgColor,
                                UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4).cgColor,
                                UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2).cgColor,
                                UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0).cgColor]
        self.layer.addSublayer(gradientLayer)
    }
    
    func alphaGradient(_ reverse: Bool) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds;
        if !reverse {
            gradientLayer.startPoint = CGPoint(x:0.0,y:0.5)
            gradientLayer.endPoint = CGPoint(x:1.0,y:0.5)
        }else{
            gradientLayer.startPoint = CGPoint(x:1.0,y:0.5)
            gradientLayer.endPoint = CGPoint(x:0.0,y:0.5)
        }
        gradientLayer.locations = [0.0, 0.35]
        gradientLayer.colors = [UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9).cgColor,
                                UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3).cgColor,
                                UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.0).cgColor]
        self.layer.addSublayer(gradientLayer)
    }
    
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 2.0,y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 2.0,y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
  
    
    func startShummering(){
        let light = UIColor(white: 0, alpha: 0.4).cgColor
        let dark = UIColor.black.cgColor
        let layerGradient = CAGradientLayer(layer: layer)
        layerGradient.colors=[dark,light,dark]
        layerGradient.frame = CGRect(x:-self.bounds.size.width, y:0, width:3*self.bounds.size.width, height:self.bounds.size.height)
        layerGradient.startPoint = CGPoint(x:0.0, y:0.5)
        layerGradient.endPoint   = CGPoint(x:1.0, y:0.525)
        layerGradient.locations  = [0.4, 0.5, 0.6]
        self.layer.mask = layerGradient
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.5;
        animation.repeatCount = Float.infinity
        layerGradient.add(animation, forKey: "shimmer")
    }
    
    func stopShmmering(){
        self.layer.mask = nil
    }
    

    
    var snapshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func snapshot(with frame: CGRect)->UIImage{
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        drawHierarchy(in: frame, afterScreenUpdates: true)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func shadowWithCornder(raduis: CGFloat, shadowColor: CGColor, shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat){
        let layer = self.layer
        layer.masksToBounds = false
        layer.cornerRadius = raduis
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func borderWithCornder(raduis: CGFloat, borderColor: CGColor, borderWidth: CGFloat){
        layer.cornerRadius = raduis
        clipsToBounds = true
        layer.borderColor = borderColor
        layer.borderWidth = borderWidth
    }
    
    func roundedCorner(corner: UIRectCorner, raduis: CGFloat){
        let rectShape = CAShapeLayer()
        rectShape.bounds = frame
        rectShape.position = center
        rectShape.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: raduis, height: raduis)).cgPath
        layer.mask = rectShape
    }
    
    func setCardView(cornerRadius: CGFloat, borderColor: CGColor, borderWidth: CGFloat, shadowOpacity: Float, shadowColor: CGColor, shadowRadius: CGFloat, shadowOffset: CGSize){
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor  =  borderColor
        self.layer.borderWidth = borderWidth
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor =  shadowColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.masksToBounds = true
    }
    
}
extension UILabel {
    @IBInspectable var adjustFontToRealIPhoneSize:Bool {
        set {
            if newValue {
                let currentFont = self.font
                var sizeScale: CGFloat = 1
                let model = UIDevice.current.modelName
                
                if model == "iPhone 6" {
                    sizeScale = 1.1
                }
                else if model == "iPhone 6 Plus" {
                    sizeScale = 1.3
                }
                
                self.font = currentFont?.withSize((currentFont?.pointSize)! * sizeScale)
            }
        }
        
        get {
            return false
        }
    }
    
    @IBInspectable var alignment:Bool {
        set {
            if newValue {
                
                if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                    
                    self.textAlignment = .right
                }
            }
        }
        
        get{
            
            return false
        }
    }
}
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
extension String {
    
    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: NSCharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    //Validate Email
    var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        let charcter  = NSCharacterSet(charactersIn: "+0123456789٠١٢٣٤٥٦٧٨٩").inverted
        var filtered:String!
        let inputString:NSArray = self.components(separatedBy: charcter) as NSArray
        filtered = inputString.componentsJoined(by: "") as String
        return  self == filtered
        
    }
    
    func convertToEnglishNumbers() -> NSNumber? {
        let Formatter: NumberFormatter = NumberFormatter()
        Formatter.locale = Locale(identifier: "EN")
        if let final = Formatter.number(from: self) {
            return final
        }
        return nil
    }
    
    func trim()->String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func DateTimeAgoLocalizedStrings(key: String) -> String {
        return NSLocalizedString(key, tableName: "TimeAgoLocalization", bundle: Bundle.main, comment: "")
    }
    
    var hex: Int? {
        return Int(self, radix: 16)
    }
    
    func emojiFlag() -> String {
        var string = ""
        var country = self.uppercased()
        for uS in country.unicodeScalars {
            string.append("\(UnicodeScalar(127397 + uS.value)!)")
        }
        return string
    }
    
   /* func convertToDictionary() -> NSDictionary?{
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }*/
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters as CharacterSet)
    }
    
   
    
  
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func getDateWith(_ format: String)->Date?{
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        
        if let date = dateFormatter.date(from: self) {
            
            return date
        }
        
        return nil
    }
    
    func isValidURL() -> Bool {
        
        if let url = URL(string: self) {
            
            return UIApplication.shared.canOpenURL(url)
        }
        
        return false
    }
}

extension CMMotionActivity {
    private func tf(_ b:Bool) -> String {
        return b ? "t" : "f"
    }
    func overallAct() -> String {
        let s = tf(self.stationary)
        let w = tf(self.walking)
        let r = tf(self.running)
        let a = tf(self.automotive)
        let c = tf(self.cycling)
        let u = tf(self.unknown)
        return "\(s) \(w) \(r) \(a) \(c) \(u)"
    }
}

extension Date {

    func toString(dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var year: Int {
        return Calendar.current.component(.year,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    public var remainingTime: String {
        let components = self.remainingDateComponents()
        
        if components.year! > 0 {
            
            if components.year! < 2 {
                if components.year! < 1 {
                    return "أقل من سنة"
                }else if components.year == 1{
                    return "سنة واحدة"
                }
                else{
                    return "أكثر من سنة"
                }
                
            }else if components.year == 2{
                return  "سنتين"
            }
            else if components.year! < 11{
                return stringFromFormat(format: "%%d سنوات", withValue: components.year!)
            }else{
                return stringFromFormat(format: "%%d سنة", withValue: components.year!)
            }
        }
        
        if components.month! > 0 {
            if components.month! < 2 {
                if components.month! < 1{
                    return "أقل من شهر"
                }else if components.month! == 1{
                    return "شهر"
                }else{
                    return "أكثر من الشهر"
                }
                
            }else if components.month! == 2 {
                return "شهرين"
            }
            else if components.month! < 11 {
                return stringFromFormat(format: "%%d أشهر", withValue: components.month!)
            }else{
                return stringFromFormat(format: "%%d شهر", withValue: components.month!)
            }
        }
        
        if components.day! >= 7 {
            let week = components.day!/7
            if week < 2 {
                if week < 1{
                    return "أقل من أسبوع"
                }else if week == 1{
                    return "أسبوع"
                }else{
                    return "أكثر من أسبوع"
                }
                
            }else if week == 2 {
                return "أسبوعين"
            }
            else {
                return stringFromFormat(format: "%%d أسابيع", withValue: week)
            }
        }
        
        if components.day! > 0 {
            if components.day! < 2 {
                if components.day! < 1{
                    return "أقل من يوم"
                }else if components.day! == 1 {
                    return "يوم"
                }else{
                    return "أكثر من يوم"
                }
            }else if components.day! == 2 {
                return "يومين"
            }
            else if components.day! < 11 {
                return stringFromFormat(format: "%%d أيام", withValue: components.day!)
            }else{
                return stringFromFormat(format: "%%d يوم", withValue: components.day!)
            }
        }
        
        if components.hour! > 0 {
            if components.hour! < 2 {
                return "ساعة"
            }else if components.day! == 2 {
                return "ساعتين"
            }
            else if components.hour! < 11 {
                return stringFromFormat(format: "%%d ساعات", withValue: components.hour!)
            }else{
                return stringFromFormat(format: "%%d ساعة", withValue: components.hour!)
            }
        }
        
        if components.minute! > 0 {
            if components.minute! < 2 {
                return "دقيقة"
            }else if components.day! == 2 {
                return "دقيقتين"
            }
            else if components.minute! < 11{
                return stringFromFormat(format: "%%d دقائق", withValue: components.minute!)
            }else{
                return stringFromFormat(format: "%%d دقيقة", withValue: components.minute!)
            }
        }
        
        if components.second! > 0 {
            if components.second! < 5 {
                return "الآن"
            } else if components.second! < 11 {
                return stringFromFormat(format: "%%d ثوانٍ", withValue: components.second!)
            }else{
                return stringFromFormat(format: "%%d ثانية", withValue: components.second!)
            }
        }
        
        return ""
    }
    
    public var timeArAgo: String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            
            if components.year! < 2 {
                if components.year! < 1 {
                    return "هذا العام"
                }else if components.year == 1{
                    return "منذ عام"
                }
                else{
                    return "العام الماضي"
                }
                
            }else if components.year == 2{
                return "منذ عامين"
            }
            else if components.year! < 11{
                return stringFromFormat(format: "منذ %%d سنوات", withValue: components.year!)
            }else{
                return stringFromFormat(format: "منذ %%d سنة", withValue: components.year!)
            }
        }
        
        if components.month! > 0 {
            if components.month! < 2 {
                if components.month! < 1{
                    return "هذا الشهر"
                }else if components.month! == 1{
                    return "منذ شهر"
                }else{
                    return "الشهر الماضي"
                }
                
            }else if components.month! == 2 {
                return "منذ شهرين"
            }
            else if components.month! < 11 {
                return stringFromFormat(format: "منذ %%d أشهر", withValue: components.month!)
            }else{
                return stringFromFormat(format: "منذ %%d شهر", withValue: components.month!)
            }
        }
        
        if components.day! >= 7 {
            let week = components.day!/7
            if week < 2 {
                if week < 1{
                    return "هذا الأسبوع"
                }else if week == 1{
                    return "منذ أسبوع"
                }else{
                    return "الأسبوع الماضي"
                }
                
            }else if week == 2 {
                return "منذ أسبوعين"
            }
            else {
                return stringFromFormat(format: "منذ %%d أسابيع", withValue: week)
            }
        }
        
        if components.day! > 0 {
            if components.day! < 2 {
                if components.day! < 1{
                    return "اليوم"
                }else if components.day! == 1 {
                    return "منذ يوم"
                }else{
                    return "أمس"
                }
            }else if components.day! == 2 {
                return "منذ يومين"
            }
            else if components.day! < 11 {
                return stringFromFormat(format: "منذ %%d أيام", withValue: components.day!)
            }else{
                return stringFromFormat(format: "منذ %%d يوم", withValue: components.day!)
            }
        }
        
        if components.hour! > 0 {
            if components.hour! < 2 {
                return "منذ ساعة"
            }else if components.day! == 2 {
                return "منذ ساعتين"
            }
            else if components.hour! < 11 {
                return stringFromFormat(format: "منذ %%d ساعات", withValue: components.hour!)
            }else{
                return stringFromFormat(format: "منذ %%d ساعة", withValue: components.hour!)
            }
        }
        
        if components.minute! > 0 {
            if components.minute! < 2 {
                return "منذ دقيقة"
            }else if components.day! == 2 {
                return "منذ دقيقتين"
            }
            else if components.minute! < 11{
                return stringFromFormat(format: "منذ %%d دقائق", withValue: components.minute!)
            }else{
                return stringFromFormat(format: "منذ %%d دقيقة", withValue: components.minute!)
            }
        }
        
        if components.second! > 0 {
            if components.second! < 5 {
                return "حالًا"
            } else if components.second! < 11 {
                return stringFromFormat(format: "منذ %%d ثوانٍ", withValue: components.second!)
            }else{
                return stringFromFormat(format: "منذ %%d ثانية", withValue: components.second!)
            }
        }
        
        return ""
    }
    
    private func dateComponents() -> DateComponents {
        let calander = NSCalendar.current
        return calander.dateComponents([.second, .minute, .hour, .day, .month, .year], from: self, to: Date())
    }
    
    private func remainingDateComponents() -> DateComponents {
        let calander = NSCalendar.current
        return calander.dateComponents([.second, .minute, .hour, .day, .month, .year], from: Date(), to: self)
    }
    
    
    private func stringFromFormat(format: String, withValue value: Int) -> String {
        let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(value: Double(value)))
        return String(format: localeFormat, value)
    }
    
    private func getLocaleFormatUnderscoresWithValue(value: Double) -> String {
        guard let localeCode = NSLocale.preferredLanguages.first else {
            return ""
        }
        // Russian (ru) and Ukrainian (uk)
        if localeCode == "ru" || localeCode == "uk" {
            let XY = Int(floor(value)) % 100
            let Y = Int(floor(value)) % 10
            
            if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
                return ""
            }
            
            if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
                return "_"
            }
            
            if Y == 1 && XY != 11 {
                return "__"
            }
        }
        
        return ""
    }
    
    func getFormattedDate(_ format: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        
        if let date = dateFormatter.date(from: dateFormatter.string(from: self)) {
            
            return date
        }
        
        return nil
    }
    
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
extension NSNull {
    func length() -> Int { return 0 }
    func integerValue() -> Int { return 0 }
    func floatValue() -> Float { return 0 }
    func componentsSeparatedByString(separator: String) -> [AnyObject] { return [AnyObject]() }
    func objectForKey(key: AnyObject) -> AnyObject? { return nil }
    func boolValue() -> Bool { return false }
}

extension UIViewController{
    
    func showTwoChoicesActionSheet(_ title: String?, message: String?,_ firstChoiceTitle: String?, _ firstChoiceHandler: ((UIAlertAction)->Void)?,_ secondChoiceTitle: String?, _ secondChoiceHandler: ((UIAlertAction)->Void)?,_ cancelChoiceTitle: String?, _ cancelChoiceHandler: ((UIAlertAction)->Void)?){
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        
        let firstChoice = UIAlertAction.init(title: firstChoiceTitle, style: .default, handler: firstChoiceHandler)
        alertController.addAction(firstChoice)
        
        let secondChoice = UIAlertAction.init(title: secondChoiceTitle, style: .default, handler: secondChoiceHandler)
        alertController.addAction(secondChoice)
        
        let cancelChoice = UIAlertAction.init(title: cancelChoiceTitle, style: .cancel, handler: cancelChoiceHandler)
        alertController.addAction(cancelChoice)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    var appDelegate: AppDelegate{
        get{
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
    class func topViewC(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewC(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewC(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewC(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewC(base: presented)
        }
        
        return base
    }
}
extension Double {
    func clean() -> String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
extension Float {
    func clean() -> String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
extension UINavigationBar {
    func transparentNavigationBar() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
    
    func cancelTransparentNavigationBar() {
        self.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.shadowImage = nil
        self.isTranslucent = false
    }
}
extension CGFloat {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
extension UIImageView {
    
    func rotate(){
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            
            self.transform = self.transform.rotated(by: CGFloat(Float.pi))
        }
    }
}
public extension UISearchBar {
    
    public func setTextColorFont(color: UIColor, font: UIFont) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
        tf.font = font
    }
}


extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}



extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
extension Dictionary where Key == String, Value == Any {
    
    mutating func append(anotherDict:[String:Any]) {
        for (key, value) in anotherDict {
            self.updateValue(value, forKey: key)
        }
    }
}
extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}
extension UIAlertController{
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.tintColor = .black
    }
}
extension UIView {
    func roundTop(radius:CGFloat = 5){
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func roundBottom(radius:CGFloat = 5){
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
}
extension UserDefaults {
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}


extension URL {
    func asyncDownload(completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()) {
        URLSession.shared
            .dataTask(with: self, completionHandler: completion)
            .resume()
    }
}
extension GMSMutablePath {

func appendPath(path : GMSPath?) {
    if let path = path {
        for i in 0..<path.count() {
            self.add(path.coordinate(at: i))
        }
    }
}
}
extension UserDefaults {
    
    func set(location:CLLocationCoordinate2D, forKey key: String){
        let locationLat = NSNumber(value:location.latitude)
        let locationLon = NSNumber(value:location.longitude)
        self.set(["lat": locationLat, "lon": locationLon], forKey:key)
    }
    
    func location(forKey key: String) -> CLLocationCoordinate2D?
    {
        if let locationDictionary = self.object(forKey: key) as? Dictionary<String,NSNumber> {
            let locationLat = locationDictionary["lat"]!.doubleValue
            let locationLon = locationDictionary["lon"]!.doubleValue
            return CLLocationCoordinate2D(latitude: locationLat, longitude: locationLon)
        }
        return nil
    }
}
extension Date {

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return end - start
    }
}
extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}
