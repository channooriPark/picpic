//
//  EmailViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 7..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class EmailViewController: UIViewController ,UITextViewDelegate,UITextFieldDelegate{

    @IBOutlet weak var imageHei: NSLayoutConstraint!
    @IBOutlet weak var emailSpace: NSLayoutConstraint!
    @IBOutlet weak var checklabel: UILabel!
    @IBOutlet weak var EmailText: UITextField!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var servicePolicy: UITextView!
    let log = LogPrint()
    var emailTemp : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.view.frame.size.width == 320.0 {
            
        }else if self.view.frame.size.width == 375.0 {
            imageHei.constant = 260
            emailSpace.constant = 20
        }else {
            imageHei.constant = 260
            emailSpace.constant = 20
        }
        
        
//        EmailText.becomeFirstResponder()
        
        nextButton.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        
        servicePolicy.delegate = self
        EmailText.delegate = self
        
        let para = NSMutableAttributedString()
        let attrs1 = [NSFontAttributeName : UIFont.systemFontOfSize(14)]
        let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
        var attrString1 : NSAttributedString!
        var attrString2 : NSAttributedString!
        var attrString3 : NSAttributedString!
        var attrString4 : NSAttributedString!
        var attrString5 : NSAttributedString!
        if self.appdelegate.locale == "ko_KR" {
            attrString1 = NSAttributedString(string: "가입하면 PicPic의 ",attributes: attrs1)
            attrString2 = NSAttributedString(string: "이용약관", attributes:attrs)
            attrString3 = NSAttributedString(string: " 및 ",attributes: attrs1)
            attrString4 = NSAttributedString(string: "개인정보취급방침", attributes:attrs)
            attrString5 = NSAttributedString(string: "에 동의하게됩니다.",attributes: attrs1)
            
            para.appendAttributedString(attrString1)
            para.appendAttributedString(attrString2)
            para.appendAttributedString(attrString3)
            para.appendAttributedString(attrString4)
            para.appendAttributedString(attrString5)
        }else {
            attrString1 = NSAttributedString(string: "By signing up, you agree to the",attributes: attrs1)
            attrString2 = NSAttributedString(string: "\nTerms of Service", attributes:attrs)
            attrString3 = NSAttributedString(string: " and ",attributes: attrs1)
            attrString4 = NSAttributedString(string: "Privacy Policy.", attributes:attrs)
            
            para.appendAttributedString(attrString1)
            para.appendAttributedString(attrString2)
            para.appendAttributedString(attrString3)
            para.appendAttributedString(attrString4)
            
            
        }
        
        
        
        
        
        if self.appdelegate.locale == "ko_KR" {
            para.addAttribute(NSLinkAttributeName, value: "picpic://service", range: NSMakeRange(13, 4))
            
            para.addAttribute(NSLinkAttributeName, value: "picpic://policy", range: NSMakeRange(20, 8))
        }else {
            para.addAttribute(NSLinkAttributeName, value: "picpic://service", range: NSMakeRange(31, 17))
            
            para.addAttribute(NSLinkAttributeName, value: "picpic://policy", range: NSMakeRange(52, 15))
        }
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.Center
        para.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSMakeRange(0, para.length))
        self.servicePolicy.attributedText = para
        
        if let email = self.appdelegate.userData["email"].string {
            self.EmailText.text = email
        }
        if self.appdelegate.userData["email"].string == "" {
            EmailText.placeholder = self.appdelegate.ment["join_email"].stringValue
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        EmailText.addTarget(self, action: Selector("didChangeText"), forControlEvents: UIControlEvents.EditingChanged)
        nextButton.enabled = false
        nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
        
    }
    
    func didChangeText() {
        if EmailText.text != "" {
            nextButton.enabled = true
            nextButton.setTitleColor(UIColor(colorLiteralRed: 0.41, green: 0.50, blue: 1.0, alpha: 1.0), forState: .Normal)
        }else {
            nextButton.enabled = false
            nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
        }
        checklabel.text = ""
        emailTemp = EmailText.text
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func stepToNext(sender: AnyObject) {
        if let email = EmailText.text{
            if isValidEmail(email) {
                let message : JSON = ["email":email]
                
                self.appdelegate.doIt(213, message: message, callback: { (readData) -> () in
                    if let data = readData["data"].string {
                        if data == "1" {
                            self.checklabel.text = self.appdelegate.ment["join_hint_email_already"].stringValue
                        }else {
                            self.EmailText.resignFirstResponder()
                            self.appdelegate.userData["email"].string = email
                            self.checklabel.text = ""
                            self.performSegueWithIdentifier("GoToPassword", sender: self)
                        }
                    }else {
                        self.checklabel.text = self.appdelegate.ment["join_hint_email_check"].stringValue
                    }
                })
                
            }else {
                self.checklabel.text = self.appdelegate.ment["join_hint_email_pattern"].stringValue
            }
        }else {
           self.checklabel.text = self.appdelegate.ment["join_hint_email_empty"].stringValue
        }
        
    }

    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        log.log(URL.host!)
        UIApplication.sharedApplication().openURL(URL)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if emailTemp != nil {
            EmailText.text = emailTemp
        }
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    

}
