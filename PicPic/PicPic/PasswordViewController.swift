//
//  PasswordViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 7..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController ,UITextFieldDelegate{
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var passText2: UITextField!
    @IBOutlet weak var checkLabel: UILabel!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var backView: UIView!
    var passTemp : String!
    var passTemp2 : String!
    @IBOutlet weak var imageHei: NSLayoutConstraint!
    @IBOutlet weak var passSpace: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.view.frame.size.width == 320.0 {
            
        }else if self.view.frame.size.width == 375.0 {
            imageHei.constant = 260
            passSpace.constant = 20
        }else {
            imageHei.constant = 260
            passSpace.constant = 20
        }
        
        passText.placeholder = self.appdelegate.ment["join_password"].stringValue
        passText2.placeholder = self.appdelegate.ment["join_password_confirm"].stringValue
        nextButton.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        
        passText.delegate = self
        passText2.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        backView.addGestureRecognizer(tap)
        passText.addTarget(self, action: Selector("didChangeText"), forControlEvents: UIControlEvents.EditingChanged)
        passText2.addTarget(self, action: Selector("didChangeText2"), forControlEvents: UIControlEvents.EditingChanged)
        nextButton.enabled = false
        nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
        
    }
    
    func didChangeText() {
        passTemp = passText.text
    }
    
    func didChangeText2() {
        if passText.text != "" && passText2.text != "" {
            nextButton.enabled = true
            nextButton.setTitleColor(UIColor(colorLiteralRed: 0.41, green: 0.50, blue: 1.0, alpha: 1.0), forState: .Normal)
        }else {
            nextButton.enabled = false
            nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
        }
        passTemp2 = passText.text
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func nextToStep(sender: AnyObject) {
        passTemp = passText.text
        passTemp2 = passText2.text
        
        if let pass = passText.text {
            if passText.text! == passText2.text! {
                let password : NSString = passText.text!
                let scPattern : NSString = "[a-z]"
                let pcPattern : NSString = "[A-Z]"
                let nPattern : NSString = "[0-9]"
                if password.length >= 6 && password.length <= 15 && self.matches(password, pattern: scPattern) && matches(password, pattern: pcPattern) && matches(password, pattern: nPattern) {
                    passText.resignFirstResponder()
                    passText2.resignFirstResponder()
                    checkLabel.text = ""
                    self.appdelegate.userData["password"].string = password as String
                    //                print(self.appdelegate.userData["password"].string)
                    self.performSegueWithIdentifier("GoToBirth", sender: self)
                }else {
                    checkLabel.text = self.appdelegate.ment["join_hint_password_pattern"].stringValue
                }
                
            }else {
                checkLabel.text = self.appdelegate.ment["join_hint_password_disaccord"].stringValue
            }
        }else {
            checkLabel.text = self.appdelegate.ment["join_hint_password_empty"].stringValue
        }
        
}
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == passText {
            if passTemp != nil {
                textField.text = passTemp
            }
        }else if textField == passText2 {
            if passTemp2 != nil {
                textField.text = passTemp2
            }
        }
    }
    
    func matches(password: NSString, pattern : NSString) -> Bool {
        var matches : NSArray!
        do {
            let regex = try NSRegularExpression(pattern: pattern as String, options: .CaseInsensitive)
            matches = regex.matchesInString(password as String, options: .ReportProgress, range: NSMakeRange(0, password.length))
        }catch {
//            print(error)
        }
        
        return matches.count > 0
        
    }
    @IBAction func back(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }

}
