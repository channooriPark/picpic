//
//  EditPostViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 10..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class EditPostViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate{

    var appdelegate : AppDelegate!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var messageView: RichTextView!
    @IBOutlet weak var backView: UIView!
    var activeView : UITextView!
    var url : String!
    var body : String!
    var post_id : String!
    var email : String!
    
    @IBOutlet weak var imageHei: NSLayoutConstraint!
    @IBOutlet weak var imageWid: NSLayoutConstraint!
    
    @IBOutlet weak var textHei: NSLayoutConstraint!
    @IBOutlet weak var textWid: NSLayoutConstraint!
    
//    @IBOutlet weak var backWid: NSLayoutConstraint!
    @IBOutlet weak var backHei: NSLayoutConstraint!
    var bodyTextView : RichTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageView.delegate = self
//        messageView.backgroundColor = UIColor.whiteColor()
//        messageView.becomeFirstResponder()
        imageWid.constant = self.view.frame.size.width
        var message : JSON = ["my_id":self.email,"post_id":post_id]
        appdelegate.doItSocket(504, message: message) { (readData) -> () in
//            print(readData)
            let imageURL = ImageURL()
            let temp = readData["url"].string!.componentsSeparatedByString("_2.")
            let iurl = NSURL(string: imageURL.imageurl("\(temp[0]).jpg"))
            let data = NSData(contentsOfURL: iurl!)
            self.image.image = UIImage(data: data!)
            self.image.contentMode = .ScaleAspectFill
            self.body = readData["contents"].string!
            self.url = readData["url"].string!
            self.messageView.putText(self.body,url: nil)
            self.refresh(self.messageView)
            
//            print(self.image.image?.size)
//            print(self.image.frame.size)
//            print("imageHei : ",self.imageHei.constant)
//            print("image height : ",self.image.frame.size.height)
            
//            self.image.hidden = true
//            self.messageView.hidden = true
            
            let imageView = UIImageView()
            imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)
            let img = UIImage(data: data!)
            
            let nWidth = UIScreen.mainScreen().bounds.width;
            let nHeight = nWidth * (img?.size.height)! / (img?.size.width)!
            
            self.imageWid.constant = nWidth
            self.imageHei.constant = nHeight
            self.backHei.constant = nHeight
            
            self.image.image = img
            if self.image.frame.size.width < self.image.frame.size.height {
                //self.image.frame.size.height = 4*UIScreen.mainScreen().bounds.width/3
//                self.messageView.frame.origin.y = self.image.frame.size.height + 30
                
            }else {
//                self.messageView.frame.origin.y = self.image.frame.size.height + 10
            }
            
            self.bodyTextView = RichTextView()
            self.bodyTextView.frame = CGRectMake(0, imageView.frame.size.height, self.view.frame.size.width, 150)
            self.bodyTextView.font = UIFont(name: "Helvetica", size: 17)
            self.bodyTextView.putText(self.body,url: nil)
            self.refresh(self.bodyTextView)
            
            self.bodyTextView.becomeFirstResponder()
            
            
            self.view.bringSubviewToFront(self.backView)
            self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)
//            print(imageView.frame)
//            print(self.image.frame)
//            print(self.scrollView.frame)
        }
        
        
        
        let complete : UIBarButtonItem = UIBarButtonItem(title: self.appdelegate.ment["complete"].stringValue, style: .Plain, target: self, action: Selector("complete:"))
        self.navigationItem.title = self.appdelegate.ment["post_edit_title"].stringValue
        self.navigationItem.rightBarButtonItem = complete
        
        let image = UIImageView(frame: CGRectMake(-20, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let backtap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "back:")
        image.addGestureRecognizer(backtap)
        self.navigationItem.leftBarButtonItem = backButton
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        backView.addGestureRecognizer(tap)
        
        if self.image.image == nil {
            self.image.image = UIImage()
        }
        if self.body == nil {
            self.body = ""
        }
        
        
        
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        

    }
    
    func back(sender:UIBarButtonItem){
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
//        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search"{
            self.navigationController?.navigationBarHidden = true
        }else {
            self.navigationController?.navigationBarHidden = false
        }
        if a.type == "post" {
            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
            post.postImage.enterForeground()
        }
        self.navigationController?.popViewControllerAnimated(true)
        self.appdelegate.main.view.hidden = false
        self.appdelegate.tabbar.view.hidden = false
    }
    
    
    func complete(sender: UIBarButtonItem!) {
        let newString = self.messageView.text.stringByReplacingOccurrencesOfString(", #", withString: " #", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let body = newString.stringByReplacingOccurrencesOfString(",#", withString: " #", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        
        let fullNameArr = body.componentsSeparatedByString(" ");
        var tag = ""
        for(var i=0;i<fullNameArr.capacity;i++) {
            let _str = fullNameArr[i]
            if(_str.hasPrefix("#")) {
                if(tag.characters.count>0) {
                    tag += ","
                }
                tag += _str
            }
            tag = tag.stringByReplacingOccurrencesOfString("#", withString: "")
        }
        
        
        //                        self.navigationController?.popToRootViewControllerAnimated(true)
        let message : JSON = ["my_id":self.appdelegate.email,"body":body,"url":self.url,"tags":tag,"type":"E","user_tags":"","and_tag":"","post_id":self.post_id]
//        print("message : ",message)
//        let connection = URLConnection(serviceCode: 232, message: message)
//        let readData = connection.connection()
        self.appdelegate.doItSocket(232, message: message) { (readData) -> () in
            if readData["msg"].string! == "success" {
//                if self.appdelegate.myfeed.wkwebView != nil {
//                    self.appdelegate.myfeed.fire()
//                }
//                if self.appdelegate.second.wkwebView != nil {
//                    if self.appdelegate.second.webState == "follow" {
//                        self.appdelegate.second.following()
//                    }else if self.appdelegate.second.webState == "all" {
//                        self.appdelegate.second.all()
//                    }else if self.appdelegate.second.webState == "category" {
//                    }
//                    
//                }
                
                
                var count = self.appdelegate.testNavi.viewControllers.count-2
                if count < 0 {
                    count = 0
                }
//                print(count)
                let a = self.appdelegate.testNavi.viewControllers[count]
                if a == self.appdelegate.myfeed {
                    self.navigationController?.navigationBarHidden = true
                }else {
                    self.navigationController?.navigationBarHidden = false
                }
                
                if self.appdelegate.myfeed.view.hidden == false {
                   self.navigationController?.navigationBarHidden = true
                }
                
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
        
    }
    
    
    func keyboardWillShow(sender: NSNotification) {
//        print("1")
        //self.view.frame.origin.y -= 300
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {

                self.scrollViewBottom.constant += keyboardSize.size.height
//            self.view.frame.origin.y -= keyboardSize.size.height;
            /*
            UIView.animateWithDuration(0.0, delay: 0, options: .CurveLinear, animations: {
            
            }, completion: { finished in
            //print("Napkins opened!")
            })*/
        }
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.scrollViewBottom.constant -= keyboardSize.size.height
//            self.view.frame.origin.y += keyboardSize.size.height;
//            print(keyboardSize.size.height)
        }
    }
    
    func dismissKeyboard() {
        messageView.endEditing(true)
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.scrollView.setContentOffset(CGPointMake(0,self.image.bounds.size.height), animated: true)
    }
    
    @IBAction func hashTag(sender: AnyObject) {
        text_type = TEXT_TYPE_REFRESH
        self.messageView.text = self.messageView.text + " #"
        refresh(self.messageView)
        messageView.becomeFirstResponder()
    }
    
    @IBAction func userTag(sender: AnyObject) {
        let usertag = self.storyboard?.instantiateViewControllerWithIdentifier("WriteSearchPageViewController")as! WriteSearchPageViewController
        usertag.typeText = "E"
        self.messageView.endEditing(true)
        self.appdelegate.testNavi.pushViewController(usertag, animated: true)
    }
    
    func replaceText(str:String){
        text_type = TEXT_TYPE_REFRESH
        let strArr = str.componentsSeparatedByString(",")
        for var i = 0; i<strArr.count; i++ {
            self.messageView.text = self.messageView.text + " @\(strArr[i])"
        }
        
        refresh(self.messageView)
        messageView.becomeFirstResponder()
    }
    
    func textbegin(){
        self.messageView.endEditing(true)
//        self.messageView.becomeFirstResponder()
    }
    
    
    var range_start = 0
    
    var text_type = 0
    let TEXT_TYPE_NONE = 0
    let TEXT_TYPE_MARK = 1
    let TEXT_TYPE_UNMARK = 2
    let TEXT_TYPE_REFRESH = 3
    let TEXT_TYPE_MARKING = 4;
    
    var text_color: UIColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
    let text_color_1 = UIColor(red: 0.71, green: 0.89, blue: 0.94, alpha: 0.3) // # 컬러
    let text_color_2 = UIColor(red: 0.82, green: 0.82, blue: 0.36, alpha: 0.3) // @ 컬러
    
    

}


extension EditPostViewController {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let str = textView.text! as String
        
        if(str.characters.count==0) {
            range_start = range.location
            if(text == "#") {
                text_color = text_color_1
                text_type = TEXT_TYPE_MARK
            } else if(text == "@") {
                text_color = text_color_2
                text_type = TEXT_TYPE_MARK
            } else {
                text_type = TEXT_TYPE_UNMARK
            }
            return true
        }
        
        if( (str.characters.count - range.location) <= 1) { // 커서가 제일 뒤에 있는 경우
            
            if(text == " " || text == "\n") {
                if(text_type == TEXT_TYPE_MARKING) {
                    text_type = TEXT_TYPE_UNMARK
                    range_start = range.location
                }
            } else if(text_type == TEXT_TYPE_NONE) {
                if(text == "#") {
                    range_start = range.location
                    text_color = text_color_1
                    text_type = TEXT_TYPE_MARK
                } else if(text == "@") {
                    range_start = range.location
                    text_color = text_color_2
                    text_type = TEXT_TYPE_MARK
                }
            } else if(text_type == TEXT_TYPE_MARKING) {
                if(str == "") {
                    range_start = range.location
                    text_type = TEXT_TYPE_UNMARK
                }
            }
        } else { // 텍스트 중간에 커서가 있는 경우
            if(str.characters.count>0) {
                text_type = TEXT_TYPE_REFRESH
            } else {
                //return false
            }
        }
        return true // realDelegate.textView(self, shouldChangeTextInRange: range, replacementText: text)
        
    }
    
    
    func refresh(textView : UITextView){
        let preAttributedRange: NSRange = textView.selectedRange
        
        let font = textView.font!
        
        let attrs = [ NSFontAttributeName : font]
        let attrs1 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_1]
        let attrs2 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_2]
        
        let txt = textView.text! as String
        let str_arr = txt.componentsSeparatedByString("\n")
        
        let para = NSMutableAttributedString()
        
        for(var i=0;i<str_arr.count;i++) {
            let str = str_arr[i]
            
            let str_arr2 = str.componentsSeparatedByString(" ")
            
            for(var j=0;j<str_arr2.count;j++) {
                let str = str_arr2[j]
                
                var attrString = NSAttributedString()
                
                if(str.hasPrefix("#")) {
                    attrString = NSAttributedString(string: str, attributes:attrs1)
                    para.appendAttributedString(attrString)
                } else if(str.hasPrefix("@")) {
                    attrString = NSAttributedString(string: str, attributes:attrs2)
                    para.appendAttributedString(attrString)
                } else {
                    attrString = NSAttributedString(string: str, attributes:attrs)
                    para.appendAttributedString(attrString)
                }
                if( (j+1) != str_arr2.count) {
                    attrString = NSAttributedString(string: " ", attributes:attrs)
                    para.appendAttributedString(attrString)
                }
            }
            if( (i+1) != str_arr.count) {
                let attrString = NSAttributedString(string: "\n", attributes:attrs)
                para.appendAttributedString(attrString)
            }
        }
        
        textView.attributedText = para
        textView.selectedRange = preAttributedRange
        text_type = TEXT_TYPE_NONE
    }
    
    
    
    func textViewDidChange(textView: UITextView) {
        if(text_type == TEXT_TYPE_NONE) {
            
        } else if(text_type == TEXT_TYPE_MARK) {
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.appendAttributedString(textView.attributedText)
            attributedString.addAttribute(NSBackgroundColorAttributeName, value: text_color, range: NSMakeRange(range_start, 1))
            
            textView.attributedText = attributedString
            text_type = TEXT_TYPE_MARKING
        } else if(text_type == TEXT_TYPE_UNMARK) {
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.appendAttributedString(textView.attributedText)
            attributedString.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(range_start, 1))
            textView.attributedText = attributedString
            text_type = TEXT_TYPE_NONE
        } else if(text_type == TEXT_TYPE_REFRESH) {
            let preAttributedRange: NSRange = textView.selectedRange
            
            let font = textView.font!
            
            let attrs = [ NSFontAttributeName : font]
            let attrs1 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_1]
            let attrs2 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_2]
            
            let txt = textView.text! as String
            let str_arr = txt.componentsSeparatedByString("\n")
            
            let para = NSMutableAttributedString()
            
            for(var i=0;i<str_arr.count;i++) {
                let str = str_arr[i]
                
                let str_arr2 = str.componentsSeparatedByString(" ")
                
                for(var j=0;j<str_arr2.count;j++) {
                    let str = str_arr2[j]
                    
                    var attrString = NSAttributedString()
                    
                    if(str.hasPrefix("#")) {
                        attrString = NSAttributedString(string: str, attributes:attrs1)
                        para.appendAttributedString(attrString)
                    } else if(str.hasPrefix("@")) {
                        attrString = NSAttributedString(string: str, attributes:attrs2)
                        para.appendAttributedString(attrString)
                    } else {
                        attrString = NSAttributedString(string: str, attributes:attrs)
                        para.appendAttributedString(attrString)
                    }
                    if( (j+1) != str_arr2.count) {
                        attrString = NSAttributedString(string: " ", attributes:attrs)
                        para.appendAttributedString(attrString)
                    }
                }
                if( (i+1) != str_arr.count) {
                    let attrString = NSAttributedString(string: "\n", attributes:attrs)
                    para.appendAttributedString(attrString)
                }
            }
            
            textView.attributedText = para
            textView.selectedRange = preAttributedRange
            text_type = TEXT_TYPE_NONE
        } else if(text_type == TEXT_TYPE_MARKING) {
            
        }
        //realDelegate.textViewDidChange(self)
    }
}

