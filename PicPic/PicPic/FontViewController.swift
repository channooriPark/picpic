//
//  FontViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 26..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class FontViewController: UIViewController {

    var gif : GifMakerViewController!
    var subView : UIView!
    var cancle : UIButton!
    var font : FontViewController!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        cancle = UIButton()
        cancle.frame = CGRectMake(5, 21, 30, 30)
        cancle.setImage(UIImage(named: "x_c"), forState: .Normal)
        cancle.addTarget(self, action: Selector("cancle:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(cancle)
        
        var size : CGFloat = 17
        if self.appdelegate.locale == "ko_KR" {
            size = 25
        }
        
        
        
        
//        self.view.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height)
        
        self.subView = UIView()
        subView.frame = CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.height)
        self.view.addSubview(subView)
        
        var fontFamilyNames = UIFont.familyNames()
        fontFamilyNames = fontFamilyNames.sort()
        
        
        let width = self.view.bounds.size.width/2
        
        
        for family in UIFont.familyNames() {
//            print("family name : ",family)
            for name in UIFont.fontNamesForFamilyName(family) {
//                print("font name : ",name)
            }
        }
        
        //line 1
        let button1 = UIButton(type: .System)
        button1.frame = CGRectMake(width*0, 0, width, 30)
        button1.setTitle(self.appdelegate.ment["font_yache"].stringValue, forState: .Normal)
        button1.titleLabel?.font = UIFont(name: "Yanolja Yache OTF", size: size)
        button1.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button1.addTarget(self, action: Selector("getFont:"), forControlEvents: .TouchUpInside)
        self.subView.addSubview(button1)
        
        let button2 = UIButton(type: .System)
        button2.frame = CGRectMake(width*1, 0, width, 30)
        button2.setTitle(self.appdelegate.ment["font_gotinc"].stringValue, forState: .Normal)
        button2.titleLabel?.font = UIFont(name: "NanumBarunGothicOTF", size: size)
        button2.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button2.addTarget(self, action: Selector("getFont:"), forControlEvents: .TouchUpInside)
        self.subView.addSubview(button2)
        
        //line 2
        let button3 = UIButton(type: .System)
        button3.frame = CGRectMake(width*0, 30, width, 30)
        button3.setTitle(self.appdelegate.ment["font_hanna"].stringValue, forState: .Normal)
        button3.titleLabel?.font = UIFont(name: "BM HANNA 11yrs old OTF", size: size)
        button3.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button3.addTarget(self, action: Selector("getFont:"), forControlEvents: .TouchUpInside)
        self.subView.addSubview(button3)
        
        let button4 = UIButton(type: .System)
        button4.frame = CGRectMake(width*1, 30, width, 30)
        button4.setTitle(self.appdelegate.ment["font_brush"].stringValue, forState: .Normal)
        button4.titleLabel?.font = UIFont(name: "Nanum Brush Script OTF", size: size)
        button4.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button4.addTarget(self, action: Selector("getFont:"), forControlEvents: .TouchUpInside)
        self.subView.addSubview(button4)
        
        //line 3
        let button5 = UIButton(type: .System)
        button5.frame = CGRectMake(width*0, 60, width, 30)
        button5.setTitle(self.appdelegate.ment["font_dohyeon"].stringValue, forState: .Normal)
        button5.titleLabel?.font = UIFont(name: "BM DoHyeon OTF", size: size)
        button5.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button5.addTarget(self, action: Selector("getFont:"), forControlEvents: .TouchUpInside)
        self.subView.addSubview(button5)
        
        let button6 = UIButton(type: .System)
        button6.frame = CGRectMake(width*1, 60, width, 30)
        button6.setTitle(self.appdelegate.ment["font_pen"].stringValue, forState: .Normal)
        button6.titleLabel?.font = UIFont(name: "NanumBarunpen", size: size)
        button6.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button6.addTarget(self, action: Selector("getFont:"), forControlEvents: .TouchUpInside)
        self.subView.addSubview(button6)
        
        //line 4
        let button7 = UIButton(type: .System)
        button7.frame = CGRectMake(width*0, 90, width, 30)
        button7.setTitle(self.appdelegate.ment["font_jua"].stringValue, forState: .Normal)
        button7.titleLabel?.font = UIFont(name: "BM JUA_OTF", size: size)
        button7.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button7.addTarget(self, action: Selector("getFont:"), forControlEvents: .TouchUpInside)
        self.subView.addSubview(button7)

        
        

    }

    func getFont(sender:UIButton!){
        if let text = self.gif.text {
            text.input_text?.font = UIFont(name: (sender.titleLabel?.font.familyName)!, size: 30)
            text.fontName = sender.titleLabel?.font.fontName
        }else {
            let alert = UIAlertView(title: "", message: self.appdelegate.ment["camera_addText_select"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
            alert.show()
        }
    }
    
    func cancle(sender:UIButton!){
        UIView.animateWithDuration(0.5, delay: 0.1, options: .CurveEaseOut, animations: { () -> Void in
            var frame = self.font.view.frame
            frame.origin.x = 0
            frame.origin.y = self.gif.view.bounds.size.height+200
            self.font.view.frame = frame
            }) { (finished) -> Void in
//                print("complete")
//                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                self.view.removeFromSuperview()
        }
        
        
        
        
    }
    
    
}
