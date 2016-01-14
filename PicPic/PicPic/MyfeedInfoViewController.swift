//
//  MyfeedInfoViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 11..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyfeedInfoViewController: UIViewController ,UITextFieldDelegate,UIAlertViewDelegate{

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let imageURL = ImageURL()
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var userID: UITextField!
    @IBOutlet var backView: UIView!
    var emailText : String!
    var username : String!
    @IBOutlet weak var IDText: UILabel!
    @IBOutlet weak var myAccount: UILabel!
    @IBOutlet weak var complete: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        complete.title = self.appdelegate.ment["complete1"].stringValue
        self.navigationItem.title = self.appdelegate.ment["settings_myinfo"].stringValue
        IDText.text = self.appdelegate.ment["settings_myinfo_change_profile_user_name"].stringValue
        myAccount.text = self.appdelegate.ment["settings_myinfo_change_profile_my_email"].stringValue
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        backView.addGestureRecognizer(tap)
        let message : JSON = ["my_id":self.appdelegate.email,"user_id":self.appdelegate.email]
//        let connection = URLConnection(serviceCode: 406, message: message)
//        let readData = connection.connection()
        self.appdelegate.doIt(406, message: message) { (readData) -> () in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let url = NSURL(string: self.imageURL.imageurl(readData["profile_picture"].string!)){
                    if let data = NSData(contentsOfURL: url){
                        self.profileImage.image = UIImage(data: data)
                    }
                }
            }
            self.profileImage.layer.borderWidth = 1
            self.profileImage.layer.masksToBounds = false
            self.profileImage.layer.borderColor = UIColor.clearColor().CGColor
            self.profileImage.layer.cornerRadius = self.profileImage.frame.height/2
            self.profileImage.clipsToBounds = true
            self.view.bringSubviewToFront(self.editButton)
            
            self.userID.text = readData["id"].string!
            self.email.text = readData["email"].string!
            self.emailText = readData["email"].string!
            self.username = readData["id"].string!
            self.userID.becomeFirstResponder()
        }
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func cancle(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func complete(sender: AnyObject) {
        if self.userID.text == username {
            self.appdelegate.testNavi.popViewControllerAnimated(true)
        }else {
            var message : JSON = ["id":self.userID.text!]//["my_id":self.emailText,"new_id":self.userID.text!]
            self.appdelegate.doIt(214, message: message, callback: { (readData) -> () in
                if readData["data"].stringValue == "0" {
                    self.appdelegate.doIt(215, message: message, callback: { (readData) -> () in
                        message = ["my_id":self.emailText,"new_id":self.userID.text!]
                        if readData["msg"].string! == "success" {
                            let alert = UIAlertView(title: self.appdelegate.ment["popup_id_already_title"].stringValue, message: self.appdelegate.ment["popup_id_change_complete"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                            alert.show()
                            self.appdelegate.myfeed.fire()
                            self.appdelegate.testNavi.popViewControllerAnimated(true)
                        }
                    })
                }else {
                    let alert = UIAlertView(title: self.appdelegate.ment["popup_id_already_title"].stringValue, message: self.appdelegate.ment["join_hint_id_already"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                    alert.show()
                }
            })
        }
    }
    
    @IBAction func edit(sender: AnyObject) {
        self.performSegueWithIdentifier("myfeedEditProfile", sender: self)
    }
}
