//
//  Extensions.swift
//  LocateMe
//
//  Created by Jun K on 2020-10-22.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import Contacts
import FloatingPanel
import CoreLocation


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    var safeArea : UILayoutGuide {
        return (view.safeAreaLayoutGuide)
    }
    var safeAreaHeight : CGFloat {
        return (view.safeAreaLayoutGuide.layoutFrame.height)
    }
    var safeAreaWidth : CGFloat {
        return (view.safeAreaLayoutGuide.layoutFrame.width)
    }
    
    var viewAreaHeight : CGFloat {
        return (view.frame.height)
    }
    var viewAreaWidth : CGFloat {
        return (view.frame.width)
    }
    
    // MARK: - NavigationBar
    func hideNavigationBar(animated: Bool){
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func showNavigationBar(animated: Bool) {
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setDefaultTitleNavigationBar(navTitle: String, backText: String){
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = navTitle
        
        let backButton = UIBarButtonItem()
        backButton.title = backText
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        //self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]//, .font: UIFont.systemFont(ofSize: viewAreaWidth/25, weight: .semibold)]
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
      //  self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = .white
    }
    
    
    // MARK: - Place Detail functions (ListDetail and PlaceDetail Controllers)
    func makeCall(phone: String){
        let phoneNumber : String = phone.replacingOccurrences(of: "[+1 () -]", with: "", options: .regularExpression)
        let callString : String = "tel://\(phoneNumber)"
        print(callString)
        
        if let url = URL(string: callString) {
            if UIApplication.shared.canOpenURL(url){
                if #available(iOS 10, *){
                    UIApplication.shared.open(url)
                }else{
                    UIApplication.shared.openURL(url)
                }
            }else{
                print("Can't place call")
            }
        }
    }
    
    func openWebsite(url: URL){
        let svc = SFSafariViewController(url: url)
        svc.modalPresentationStyle = .popover
        self.present(svc, animated: true, completion: nil)
    }
    
    func openShare(coordinate: CLLocationCoordinate2D){
        var shareUrl = ""
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            shareUrl = "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)"
        }
        else if (UIApplication.shared.canOpenURL(NSURL(string:"http://maps.apple.com/maps")! as URL)){
            shareUrl = "http://maps.apple.com/maps?saddr=\(coordinate.latitude),\(coordinate.longitude)"
        }
        // let shareUrl =    "http://maps.apple.com/maps?saddr=\(currentPlace.coordinate.latitude),\(currentPlace.coordinate.longitude)"
        let activityVC = UIActivityViewController(activityItems: [shareUrl], applicationActivities: nil)
        activityVC.isModalInPresentation = true
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func openDirection(place: Place){
        let addressDict = [CNPostalAddressStreetKey: place.name]
        let placeMark = MKPlacemark(coordinate: place.coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placeMark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    // MARK: - Place and List Icons
    
    func getDefaultList() -> [List] {
        var lists = [List]()
        
        let defaultTitle = ["Favourite", "Recreational", "Starred", "To explore"]
        let defaultImgs = [UIImage(systemName: "heart.circle.fill"),UIImage(systemName: "folder.circle.fill"), UIImage(systemName: "star.circle.fill"), UIImage(systemName: "flag.circle.fill")]
        let defaultColor = [UIColor.lightRed,  UIColor.lightTeal, UIColor.lightOrange, UIColor.lightGreen,]
        
        for i in 0...3{
            let list = List(title: defaultTitle[i], id: "", icon: defaultImgs[i] ?? UIImage(named: "locationicon")!, color: defaultColor[i], placeIds: [], count: 0)
            lists.append(list)
        }
        
        return lists
    }
    
    
    func setPlaceIcon(title: String)-> (UIImage, UIColor){
        var img = ""
        var color = UIColor.lightRed
        switch title {
        case "Gas Station", "Gas":
            img = "gasicon"
            color = UIColor.lightBlue
        case "Restaurants", "Restaurant", "Food":
            img = "restauranticon"
            color = UIColor.lightOrange
        case "Park", "Parks":
            img = "parkicon"
            color = UIColor.lightGreen
        case "Shop", "Shops":
            img = "shopicon"
            color = UIColor.lightPurple
        default:
            img = "locationicon"
        }
        let image = UIImage(named: img)?.withRenderingMode(.alwaysTemplate)
        return (image!, color)
    }
    
    func removeDimmedView(){
        if let dimmingView = self.view.viewWithTag(10) {
            dimmingView.removeFromSuperview()
        }
    }
}

// MARK: - Views (UIview, Stackview, Imageview, Image etc..)

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width-4 , height: self.frame.height+3))
        subView.backgroundColor = color
        subView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = 10
        insertSubview(subView, at: 0)
    }
    
    func addCornerRadius(radius: CGFloat){
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width , height: self.frame.height))
        subView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = 10
        //subView.backgroundColor = .veryLightGray
        addSubview(subView)
        // self.sendSubviewToBack(subView)
        //insertSubview(subView, at: 0)
    }
    
    
    func addHorizontalSeparators(color : UIColor) {
        let separator = createSeparator(color: color)
        insertArrangedSubview(separator, at: 1)
        let separators = createSeparator(color: color)
        insertArrangedSubview(separators, at: 3)
        separator.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
    }
    
    private func createSeparator(color : UIColor) -> UIView {
        let separator = UIView()
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.backgroundColor = color
        return separator
    }
}

extension UIImageView {
    func setUpIconImg(img: UIImage, color: UIColor, inset: CGFloat){
        let img = img.imageWithInset(insets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
        self.image = img.withRenderingMode(.alwaysTemplate)
        self.backgroundColor = color
        self.layer.cornerRadius = self.frame.width/2
    }
    func setUpAppLogo(img: UIImage, inset: CGFloat){
        let img = img.imageWithInset(insets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
        self.image = img
        self.layer.cornerRadius = self.frame.width/2
    }
}

extension UIImage {
    func imageWithInset(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
}

extension UIView {
    func addSlightShadow(){
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = safeAreaLayoutGuide.layoutFrame.width/120
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.masksToBounds = false
    }
    
    func setListIcon(title: String)-> (UIImage, UIColor){
        var img = ""
        var color = UIColor.lightPurple
        switch title {
        case "Favourite":
            img = "heart.fill"
            color = UIColor.lightRed
        case "To explore":
            img = "flag.fill"
            color = UIColor.lightGreen
        case "Starred":
            img = "star.fill"
            color = UIColor.lightOrange
        case "Recreational":
            img = "folder.fill"//"music.house.fill"
            color = UIColor.lightTeal
        default:
            img = "list.bullet"
        }
        let image = UIImage(systemName: img)
        return (image!, color)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = bounds
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func animate(view: UIView){
        self.alpha = 0
        UIView.animate(withDuration: 0.15 ,
                       delay: 0.2 , options: .curveEaseIn, animations: {
                        view.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
                        self.alpha = 1
        }, completion: { finish in
            UIView.animate(withDuration: 0.15){
                view.transform = CGAffineTransform.identity
            }
        })
    }
    
    func drawBottomCurve(){
        let offset = CGFloat(self.frame.size.height/2)
        let bounds = self.bounds
        
        let rectBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y  , width:  bounds.size.width, height: bounds.size.height / 2)
        let rectPath = UIBezierPath(rect: rectBounds)
        let ovalBounds = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        
        let ovalPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        self.layer.mask = maskLayer
    }
}

// MARK: - Gestures (TapGesture, PanGesture etc..)
extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        
        let mutableStr = NSMutableAttributedString.init(attributedString: attributedText)
        mutableStr.addAttributes([NSAttributedString.Key.font : label.font!], range: NSRange.init(location: 0, length: attributedText.length))
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: mutableStr)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

// MARK: - Types (String, Int, Double etc..)
extension Double {
    func roundToSingleDigit() -> String {
        if self >= 950{
            let km = Double(self / 1000)
            let divisor = pow(10.0, Double(1))
            let roundedKm = (km * divisor).rounded() / divisor
            return "\(roundedKm) km".replaceOccurance(target: ".0", withString: "")
            
        }else{
            print(self)
            let roundedMeters = 100 * Int((self / 100.0).rounded())
            return "\(roundedMeters) m"
        }
    }
}
extension Int {
    func placeSingularity() -> String {
        if self == 1{
            return "1 Place"
        }
        return "\(self) Places"
    }
}

extension CLLocationCoordinate2D: Equatable {
    static public func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor,font: UIFont, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
        guard let characterSpacing = characterSpacing else {return attributedString}
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func replaceOccurance(target: String, withString: String) -> String{
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func filterMapCategory(category: String) -> String {
        var parsedCategory = category.replacingOccurrences(of: "MKPOICategory", with: "")
        
        switch parsedCategory {
        case "GasStation":
            parsedCategory  = "Gas Station"
        default:
            print("No space needed in category")
        }
        return parsedCategory
    }
    
    func checkIfDefaultList() -> Bool{
        var defaultList: Bool
        
        switch self {
        case "Favourite", "Recreational", "Starred", "To explore" :
            defaultList = true
        default:
            defaultList = false
        }
        
        return defaultList
    }
}


// MARK: - Colors
extension UIColor{
    static var lightGrey : UIColor{
        return UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
    }
    static var veryLightGray : UIColor{
        return UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
    }
    static var backgroundGray : UIColor{
        return UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 1)
    }
    static var darkerGray : UIColor{
        return UIColor(red: 105/255.0, green: 105/255.0, blue: 105/255.0, alpha: 1)
    }
    static var placeholderGray: UIColor {
        return UIColor(red: 199/255.0, green: 199/255.0, blue: 205/255.0, alpha: 1)
    }
    static var teal: UIColor {
        return UIColor(red: 67/255.0, green: 195/255.0, blue: 206/255.0, alpha: 1)
    }
    static var lightBlue: UIColor {
        return UIColor(red: 211/255.0, green:231/255.0, blue: 238/255.0, alpha:1)
    }
    static var darkerBlue: UIColor {
        return UIColor(red: 56/255.0, green:78/255.0, blue: 120/255.0, alpha:1)
    }
    static var lightRed: UIColor {
        return UIColor(red: 231/255.0, green:151/255.0, blue: 150/255.0, alpha:1)
    }
    static var lightGreen: UIColor {
        return UIColor(red: 167/255.0, green:214/255.0, blue: 118/255.0, alpha:1)
    }
    static var Green: UIColor {
        return UIColor(red: 107/255.0, green:234/255.0, blue: 98/255.0, alpha:1)
    }
    static var lightPurple: UIColor {
        return UIColor(red: 191/255.0, green:184/255.0, blue: 218/255.0, alpha:1)
    }
    static var lightOrange: UIColor {
        return UIColor(red: 255/255.0, green:189/255.0, blue: 113/255.0, alpha:1)
    }
    static var lightPink: UIColor {
        return UIColor(red: 229/255.0, green:193/255.0, blue: 205/255.0, alpha:1)
    }
    static var lightTeal: UIColor {
        return UIColor(red: 78/255.0, green: 205/255.0, blue: 215/255.0, alpha: 1)
    }
    static var navyBlue: UIColor {
        return UIColor(red: 4 / 255, green: 47 / 255, blue: 66 / 255, alpha: 1)
    }
}


// MARK: - Others
public extension UIDevice {
    class var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    class var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
