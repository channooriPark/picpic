//
//  MyView.swift
//  cameraTester
//
//  Created by Changho Kim on 2015. 11. 25..
//  Copyright © 2015년 picpic. All rights reserved.
//

import UIKit

public protocol MyViewDelegate {
    func didSelect(sender : UIButton)
    func callModal(sender : UIButton)
}

public class MyView: UIView , UITextViewDelegate{
    
    
    
    
    var touchStart:CGFloat?
    
    var label:UIButton?
    var btn_remove:UIButton?
    var btn_modify:UIButton?
    var btn_resize:UIButton?
    var input_text:UITextView?
    var icon1:UIImageView?
    var icon2:UIImageView?
    
    var lastLocation:CGPoint = CGPointMake(0, 0)
    
    let button_size:CGFloat = 30
    let button_offset:CGFloat = 15
    var text:String!
    var fontName:String!
    var color:String = "0xFFFFFF" //0xFFFFFF
    var index = 0
    
    
    var input_txt:UITextField?
    
    var lastPosition:CGPoint?
    
    var a = 0;
    
    public func redraw() {
        let center = self.center
        
        var newFrame = input_text?.frame
        newFrame?.size.width = (input_text?.contentSize.width)! //+ CGFloat(offset)
        newFrame?.size.height = (input_text?.contentSize.height)!
        
        input_text?.frame = newFrame!
        label?.frame = newFrame!
        //label?.layer.borderColor = UIColor.redColor().CGColor
        label?.layer.borderWidth = 0
        
        
        self.bounds = CGRect(x: 0, y: 0, width: newFrame!.width+30, height: newFrame!.height+30)
        self.center = center
        //mView.frame = newFrame!
        //mView.bounds = CGRect(x: 0, y: 0, width: newFrame!.width+30, height: newFrame!.height+30)
        //self.frame.size = CGSize(width: mView.frame.width,height: mView.frame.height)
        ////print(mView.frame)
        //self.backgroundColor = UIColor.brownColor()
        //mView.backgroundColor = UIColor.blueColor()
        
        
        //mView.center = CGPoint(x:self.frame.width/2, y:self.frame.height/2)
        
        var layerFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
        layerFrame.origin.x = self.layer.frame.origin.x
        layerFrame.origin.y = self.layer.frame.origin.y
        layerFrame.size.width = (newFrame?.size.width)! + 30
        layerFrame.size.height = (newFrame?.size.height)! + 30
        
        //mView.transform = (input_text?.transform)!
        ////print("mView.transform  ",mView.transform)
        //print("input_text?.transform ",input_text?.transform)
        
        
        
        //self.layer.frame.size = CGSize(width: label!.layer.frame.width+30, height:label!.layer.frame.height+30)
        
        let posX = newFrame!.size.width // - button_size
        let posY = newFrame!.size.height // - button_size
        
        let buttonSize = CGSize(width: button_size, height: button_size)
        btn_remove?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: buttonSize)
        icon1?.frame = CGRect(origin: CGPoint(x: posX, y: 0), size: buttonSize)
        icon2?.frame = CGRect(origin: CGPoint(x: 0, y: posY), size: buttonSize)
        
        ////print(self.mView.bounds)
    }
    
    
    public func regen() {
        
        //print("color : ",color)
        //print("font : ",fontName)
        
        input_text?.text = text
        input_text?.font = UIFont(name: self.fontName, size: CGFloat(30))
        input_text?.textColor = hexStringToUIColor(color)
        //print(input_text?.font)
        redraw()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.lastPosition = self.center
        
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        
        let input_width = frame.size.width
        
        input_text = UITextView()
        input_text!.contentInset    = UIEdgeInsetsMake(0,0,0,0);
        input_text!.textAlignment = NSTextAlignment.Center;
        input_text!.frame = CGRect(x:15,y:15,width:input_width,height:50)
        input_text!.backgroundColor = UIColor.clearColor()
        //input_text!.backgroundColor = UIColor.brownColor()  //UIColor.clearColor()
        input_text?.delegate = self
        
        self.addSubview(input_text!)
        //self.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        label = UIButton()
        
        label?.titleLabel?.textAlignment = NSTextAlignment.Center;
        label?.titleEdgeInsets.left = 10
        label?.titleEdgeInsets.top = 10
        label?.titleEdgeInsets.right = 10
        label?.titleEdgeInsets.bottom = 10
        
        label?.titleLabel!.numberOfLines = 0;
        label?.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        
        //label!.backgroundColor = UIColor.brownColor()
        
        //self.layer.frame.size = CGSize(width: label!.layer.frame.width+30, height:label!.layer.frame.height+30)
        
        self.addSubview(label!)
        
        
        let buttonSize = CGSize(width: button_size, height: button_size)
        
        btn_remove = UIButton()
        btn_remove?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: buttonSize)
        btn_remove?.setImage(UIImage(named:"btn_clear.png"), forState: UIControlState.Normal)
        btn_remove?.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        btn_remove?.addTarget(self, action: "didRemove:", forControlEvents: .TouchUpInside)
        btn_remove?.hidden = true
        self.addSubview(btn_remove!)
        
        /*
        btn_modify = UIButton()
        btn_modify?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: buttonSize)
        btn_modify?.setImage(UIImage(named:"btn_bigger.png"), forState: UIControlState.Normal)
        btn_modify?.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        //bnt_resize?.addTarget(self, action: "didRemove:", forControlEvents: .TouchUpInside)
        btn_modify?.hidden = true
        self.addSubview(btn_modify!)*/
        
        icon1 = UIImageView()
        icon1?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: buttonSize)
        icon1?.image = UIImage(named:"btn_turn_02")
        icon1?.contentMode = UIViewContentMode.ScaleAspectFit
        icon1?.hidden = true
        self.addSubview(icon1!)
        
        icon2 = UIImageView()
        icon2?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: buttonSize)
        icon2?.image = UIImage(named:"btn_turn_01")
        icon2?.contentMode = UIViewContentMode.ScaleAspectFit
        icon2?.hidden = true
        self.addSubview(icon2!)
        
        
        //self.addSubview(mView)
        
        initGestureRecognizers()
        
        //print("int end ",self.frame)
        
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count != 6) {
            return UIColor.whiteColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //delegate = self
    }
    /*
    required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
    }
    */
    var panGR : UIPanGestureRecognizer!
    var pinchGR : UIPinchGestureRecognizer!
    var rotationGR : UIRotationGestureRecognizer!
    
    func initGestureRecognizers() {
        
        //let tapGR = UITapGestureRecognizer(target: self, action: "didTap:")
        //addGestureRecognizer(tapGR)
        
        panGR = UIPanGestureRecognizer(target: self, action: "didPan:")
        addGestureRecognizer(panGR)
        
        pinchGR = UIPinchGestureRecognizer(target: self, action: "didPinch:")
        addGestureRecognizer(pinchGR)
        
        rotationGR = UIRotationGestureRecognizer(target: self, action: "didRotate:")
        addGestureRecognizer(rotationGR)
    }
    
    func disableGesture(){
        panGR.enabled = false
        pinchGR.enabled = false
        rotationGR.enabled = false
    }
    
    func enableGesture(){
        panGR.enabled = true
        pinchGR.enabled = true
        rotationGR.enabled = true
    }
    
    
    
    func didRotate(rotationGR: UIRotationGestureRecognizer) {
        //print("didRotate extension UIVIew11")
        self.superview!.bringSubviewToFront(self)
        //let rotation = rotationGR.rotation
        //self.transform = CGAffineTransformRotate((self.transform), rotation)
        //rotationGR.rotation = 0.0
        
        rotationGR.view!.transform = CGAffineTransformRotate(rotationGR.view!.transform, rotationGR.rotation)
        rotationGR.rotation = 0
    }
    
    func didPan(panGR: UIPanGestureRecognizer) {
        self.superview!.bringSubviewToFront(self)
        
        let translation =  panGR.translationInView(self.superview)
        
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        panGR.setTranslation(CGPointZero, inView: self)
    }
    
    func didPinch(pinchGR: UIPinchGestureRecognizer) {
        //print("didPinch")
        self.superview!.bringSubviewToFront(self)
        
        
        let scale = pinchGR.scale
        
        //self.transform = CGAffineTransformScale(self.transform, scale, scale)
        self.transform = CGAffineTransformScale(self.transform, scale, scale)
        
        
        let bttn_scale = 1/scale
        self.btn_remove?.transform = CGAffineTransformScale(self.btn_remove!.transform, bttn_scale, bttn_scale)
        //self.btn_modify?.transform = CGAffineTransformScale(self.btn_modify!.transform, bttn_scale, bttn_scale)
        self.btn_resize?.transform = CGAffineTransformScale(self.btn_resize!.transform, bttn_scale, bttn_scale)
        self.icon1?.transform = CGAffineTransformScale(self.icon1!.transform, bttn_scale, bttn_scale)
        self.icon2?.transform = CGAffineTransformScale(self.icon2!.transform, bttn_scale, bttn_scale)
        //self.label.tra
        self.label!.layer.borderWidth = self.label!.layer.borderWidth*bttn_scale
        pinchGR.scale = 1.0
    }
    
    
    
    public func selected() {
        self.superview!.bringSubviewToFront(self)
        
        self.input_text!.layer.borderColor = UIColor.whiteColor().CGColor
        self.input_text!.layer.borderWidth = 1.0
        
        //self.label!.layer.borderColor = UIColor.whiteColor().CGColor
        //self.label!.layer.borderWidth = 1.0
        
        self.btn_remove?.hidden = false
        //self.btn_modify?.hidden = false
        self.icon1?.hidden = false
        self.icon2?.hidden = false
        
        self.label?.hidden = true
        enableGesture()
        //self.btn_resize?.hidden = false
    }
    
    public func deselected() {
        disableGesture()
        self.input_text!.layer.borderColor = UIColor.clearColor().CGColor
        self.input_text!.layer.borderWidth = 0.0
        
        //self.label!.layer.borderColor = UIColor.clearColor().CGColor
        //self.label!.layer.borderWidth = 0.0
        
        self.btn_remove?.hidden = true
        //self.btn_modify?.hidden = true
        self.icon1?.hidden = true
        self.icon2?.hidden = true
        self.label?.hidden = true
        //self.btn_resize?.hidden = true
        self.endEdit()
        self.input_text?.endEditing(true)
    }
    
    public func endEdit() {
        self.label?.hidden = false
    }
    
    func didRemove(tapGR: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }
    
    /*
    func didPinch(pinchGR: UIPinchGestureRecognizer) {
    
    self.superview!.bringSubviewToFront(self)
    
    
    let scale = pinchGR.scale
    
    //self.transform = CGAffineTransformScale(self.transform, scale, scale)
    self.input_text?.transform = CGAffineTransformScale(self.input_text!.transform, scale, scale)
    
    
    let bttn_scale = 1/scale
    self.btn_remove?.transform = CGAffineTransformScale(self.btn_remove!.transform, bttn_scale, bttn_scale)
    //self.btn_modify?.transform = CGAffineTransformScale(self.btn_modify!.transform, bttn_scale, bttn_scale)
    self.btn_resize?.transform = CGAffineTransformScale(self.btn_resize!.transform, bttn_scale, bttn_scale)
    self.icon1?.transform = CGAffineTransformScale(self.icon1!.transform, bttn_scale, bttn_scale)
    self.icon2?.transform = CGAffineTransformScale(self.icon2!.transform, bttn_scale, bttn_scale)
    //self.label.tra
    self.label!.layer.borderWidth = self.label!.layer.borderWidth*bttn_scale
    pinchGR.scale = 1.0
    }
    */
    
    
    
    
    
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        /*
        let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
        //print("Backspace was pressed")
        } else {
        
        }*/
        
        //redraw()
        
        return true
    }
    
    public func textViewDidChange(textView: UITextView) {
        //print("aaa")
        //print(input_text?.contentSize.width)
        self.text = textView.text
        redraw()
    }
    
    
}


/*
extension UIView {
func didRotate(rotationGR: UIRotationGestureRecognizer) {
//print("didRotate extension UIVIew")
self.superview!.superview!.bringSubviewToFront(self.superview!)
let rotation = rotationGR.rotation
self.transform = CGAffineTransformRotate((self.transform), rotation)

rotationGR.rotation = 0.0
}

func didPan(panGR: UIPanGestureRecognizer) {
self.superview!.superview!.bringSubviewToFront(self.superview!)

let translation = panGR.translationInView(self.superview!)

self.superview!.center.x += translation.x
self.superview!.center.y += translation.y

panGR.setTranslation(CGPointZero, inView: self.superview!)
}

func didPinch(pinchGR: UIPinchGestureRecognizer) {
let view = self.superview as! MyView
let scale = pinchGR.scale

let bttn_scale = 1/scale
//print(scale)
//view.mView.transform = CGAffineTransformScale(view.mView.transform, scale, scale)
//view.btn_remove!.transform = CGAffineTransformScale(view.btn_remove!.transform, bttn_scale, bttn_scale)
}
}*/

extension UIButton {
    
    /*
    
    override func didRotate(rotationGR: UIRotationGestureRecognizer) {
    //print("didRotate extension")
    self.superview!.superview!.bringSubviewToFront(self.superview!)
    let rotation = rotationGR.rotation
    
    self.transform = CGAffineTransformRotate((self.transform), rotation)
    rotationGR.rotation = 0.0
    }
    func didPan(panGR: UIPanGestureRecognizer) {
    
    self.superview?.superview!.bringSubviewToFront(self.superview!)
    
    let translation = panGR.translationInView(self.superview!)
    
    self.superview!.center.x += translation.x
    self.superview!.center.y += translation.y
    
    panGR.setTranslation(CGPointZero, inView: self.superview)
    }*/
}
/*

extension UITextView {

override func didRotate(rotationGR: UIRotationGestureRecognizer) {
//print("didRotate extension")
self.superview!.superview!.bringSubviewToFront(self.superview!)
let rotation = rotationGR.rotation
self.transform = CGAffineTransformRotate((self.transform), rotation)
rotationGR.rotation = 0.0
}
}

extension UILabel {
func didPan(panGR: UIPanGestureRecognizer) {

self.superview?.superview!.bringSubviewToFront(self.superview!)

let translation = panGR.translationInView(self.superview!)

self.superview!.center.x += translation.x
self.superview!.center.y += translation.y

panGR.setTranslation(CGPointZero, inView: self.superview)
}
}

extension UIImageView {
func didRemove(tapGR: UITapGestureRecognizer) {
//print("remove ")
//self.removeFromSuperview()
self.superview?.removeFromSuperview()
}

func didResize(tapGR: UITapGestureRecognizer) {
//print("resize")
}

}
*/
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
