//
//  TextAddViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 25..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class TextAddViewController: UIViewController ,UITextFieldDelegate , UIScrollViewDelegate{
    
    
    var preview : UILabel!
    
    var btnOK : UIButton!
    var btnCancle : UIButton!
    var editText : UITextField!
    
    var scrollview : UIScrollView!
    var selectedColor : UIButton!
    var colorArray : NSArray!
    var colorscrollview : UIScrollView!
    var gifMakerView : GifMakerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        preview = UILabel()
        preview.frame = CGRectMake(self.view.bounds.size.width/2-70, 50, 140, 40)
        preview.text = "PreView"
        preview.tintColor = UIColor.whiteColor()
        preview.textColor = UIColor.whiteColor()
        preview.textAlignment = .Center
        self.view.addSubview(preview)
        
        
        //확인
        btnOK = UIButton(type: .System)
        btnOK.frame = CGRectMake(self.view.bounds.size.width/2-70, self.view.bounds.size.height-70, 140, 50)
        btnOK.tintColor = UIColor.whiteColor()
        btnOK.setTitle("확인", forState: .Normal)
        btnOK.addTarget(self, action: Selector("actOK:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(btnOK)
        
        //취소
        btnCancle = UIButton(type: .System)
        btnCancle.frame = CGRectMake(5, 21, 50, 50)
        btnCancle.setImage(UIImage(named: "x_c"), forState: .Normal)
        btnCancle.tintColor = UIColor.whiteColor()
        btnCancle.addTarget(self, action: Selector("cancel"), forControlEvents: .TouchUpInside)
        self.view.addSubview(btnCancle)
        
        //텍스트
        editText = UITextField()
        editText.frame = CGRectMake(self.view.bounds.size.width/5, 120, (self.view.bounds.size.width/5)*3, 40)
        
        editText.borderStyle = .RoundedRect
        editText.placeholder = "텍스트 입력"
        self.view.addSubview(editText)
        
        self.editText.delegate = self;
        self.editText.addTarget(self, action: Selector("didChangeText"), forControlEvents: UIControlEvents.EditingChanged)
        
        
        
        
        
        //font
        scrollview = UIScrollView(frame: CGRectMake(0, self.view.bounds.size.height/3, self.view.bounds.size.width, 200))
        scrollview.scrollEnabled = true
        self.view.addSubview(scrollview)
        
        
        
        var fontFamilyNames = UIFont.familyNames()
        fontFamilyNames = fontFamilyNames.sort()
//        print(fontFamilyNames.count)
//        for familyname in fontFamilyNames {
//            print("----------------------------------")
//            let names = UIFont.fontNamesForFamilyName(familyname)
//            print("familyname = ",familyname)
//            print("font Names = ",names)
//        }
        
        
        let width = self.view.bounds.size.width/2
        var line = 0
        if fontFamilyNames.count%2 == 0 {
            line = fontFamilyNames.count/2
        }else {
            line = fontFamilyNames.count/2-1
            fontFamilyNames.removeLast()
        }
        
        var index = 0
        let hei : CGFloat = 30
        for var i=0; i<line; i++ {
            
            for var j=0; j<2; j++ {
                if index == 30 {
                    break
                }
                let button = UIButton(type: .System)
                let jj:CGFloat = CGFloat(j)
                button.frame = CGRectMake(width*jj, hei*CGFloat(i), width, 30)
                button.setTitle(fontFamilyNames[index], forState: .Normal)
                button.titleLabel?.font = UIFont(name: fontFamilyNames[index], size: 10)
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                button.addTarget(self, action: Selector("getFont:"), forControlEvents: .TouchUpInside)
                self.scrollview.addSubview(button)
                index++
            }
        }
        
        
        
        
        //color
        colorscrollview = UIScrollView(frame: CGRectMake(0, self.view.bounds.size.height/3*2, self.view.bounds.size.width, 120))
        colorscrollview.backgroundColor = UIColor.blackColor()
        colorscrollview.scrollEnabled = true
        self.view.addSubview(colorscrollview)
        let path = NSBundle.mainBundle().pathForResource("colorPalette", ofType: "plist")
        self.colorArray = NSArray(contentsOfFile: path!)
        
        
        var colorindex = 0
        let wid = self.view.bounds.size.width/20
        let count = colorArray.count/10
        
        if let colorlist = self.colorArray {
            for var i=0; i<count; i++ {
                for var j=0; j<10; j++ {
                    let button = UIButton(type: .System)
                    button.frame = CGRectMake(wid*CGFloat(j), wid*CGFloat(i), wid, wid)
                    print("",colorArray[colorindex] as! String)
                    button.backgroundColor = hexStringToUIColor(colorArray[colorindex] as! String)
                    button.addTarget(self, action: Selector("selectColor:"), forControlEvents: .TouchUpInside)
                    self.colorscrollview.addSubview(button)
                    colorindex++
                }
            }
        }
        self.scrollview.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height-200)
        self.colorscrollview.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height-75)
        self.scrollview.panGestureRecognizer.delaysTouchesBegan = self.scrollview.delaysContentTouches
    }
    
    func actOK(sender:UIButton!){
        
    }
    
    func getFont(sender:UIButton!){
        print(sender.titleLabel?.font.familyName)
        self.preview.font = UIFont(name: (sender.titleLabel?.font.familyName)!, size: 17)
    }
    
    
    func cancel(){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func selectColor(sender:UIButton!){
        print(sender.backgroundColor)
        self.preview.textColor = sender.backgroundColor
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
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
    
    func didChangeText(){
        self.preview.text = self.editText.text!
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    

}
