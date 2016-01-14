//
//  GetPasswordViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 11..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class GetPasswordViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet var backView: UIView!
    @IBOutlet weak var alertview: UIView!
    @IBOutlet weak var emailChecked: UILabel!
    @IBOutlet weak var emailText: UITextField!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var lostPassLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancleButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lostPassLabel.text = self.appdelegate.ment["login_isforgot"].stringValue
        okButton.setTitle(self.appdelegate.ment["popup_confirm"].stringValue, forState: .Normal)
        cancleButton.setTitle(self.appdelegate.ment["popup_cancel"].stringValue, forState: .Normal)
        emailText.placeholder = self.appdelegate.ment["popup_empty_email"].stringValue
        
        emailText.delegate = self
        
        self.alertview.layer.cornerRadius = 3
        self.alertview.layer.masksToBounds = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func ok(sender: AnyObject) {
        if emailText.text != "" {
            
            var message : JSON = ["email":self.emailText.text!]
            self.appdelegate.doIt(213, message: message, callback: { (readData) -> () in
                if readData["data"].stringValue == "1" {
                    self.dismissViewControllerAnimated(true) { () -> Void in
                        message = ["my_id":self.emailText.text!]
                        //                let connection = URLConnection(serviceCode: 220, message: message)
                        //                let readData = connection.connection()
                        self.appdelegate.doIt(220, message: message, callback: { (readData) -> () in
                            if readData["msg"].string! == "success" {
                                let alert : UIAlertView = UIAlertView(title: "", message: self.appdelegate.ment["new_login_forgot_popup_up"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                                alert.show()
                            }else {
                                
                            }
                            
                        })
                        
                    }
                }else {
                    self.emailChecked.text = self.appdelegate.ment["join_hint_email_check"].stringValue
                }
            })
            
            
            
            
        }else {
            emailChecked.text = self.appdelegate.ment["join_hint_email_check"].stringValue
        }
        
    }
    
    
    
    func ShowModalViewController() {
        self.performSegueWithIdentifier("SendToEmail", sender: self)
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
