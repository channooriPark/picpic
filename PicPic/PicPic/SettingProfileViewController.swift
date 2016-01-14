//
//  SettingProfileViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 3..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingProfileViewController: UIViewController ,UITextFieldDelegate,UIAlertViewDelegate{

    @IBOutlet weak var complete: UIBarButtonItem!
    @IBOutlet weak var eidtBUtton: UIButton!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var userID: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let imageURL = ImageURL()
    @IBOutlet var backView: UIView!
    var emailText : String!
    @IBOutlet weak var idText: UILabel!
    @IBOutlet weak var myaccountText: UILabel!
    var username : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idText.text = self.appdelegate.ment["settings_myinfo_change_profile_user_name"].stringValue
        myaccountText.text = self.appdelegate.ment["settings_myinfo_change_profile_my_email"].stringValue
        
        self.navigationItem.title = self.appdelegate.ment["settings_myinfo_change_profile"].stringValue
        
        complete.title = self.appdelegate.ment["complete1"].stringValue
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
            self.view.bringSubviewToFront(self.eidtBUtton)
            
            self.userID.text = readData["id"].string!
            self.email.text = readData["email"].string!
            self.emailText = readData["email"].string!
            self.username = readData["id"].string!
            self.userID.becomeFirstResponder()
            
            
            let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
            image.image = UIImage(named: "back_white")
            let backButton = UIBarButtonItem(customView: image)
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
            image.addGestureRecognizer(tap)
            self.navigationItem.leftBarButtonItem = backButton
        }
        
        
    }
    
    func backToMyFeed(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func myinfoComplete(sender: AnyObject) {
        if self.userID.text == username {
            self.navigationController?.popViewControllerAnimated(true)
        }else {
            var message : JSON = ["id":self.userID.text!]//["my_id":self.emailText,"new_id":self.userID.text!]
            print(message)
            self.appdelegate.doIt(214, message: message, callback: { (readData) -> () in
                if readData["data"].stringValue == "0" {
                    message = ["my_id":self.emailText,"new_id":self.userID.text!]
                    self.appdelegate.doIt(215, message: message, callback: { (readData) -> () in
                        if readData["msg"].string! == "success" {
                            let alert = UIAlertView(title: self.appdelegate.ment["popup_id_already_title"].stringValue, message: self.appdelegate.ment["popup_id_change_complete"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                            alert.show()
                            self.appdelegate.myfeed.fire()
                        }
                    })
                }else {
                    let alert = UIAlertView(title: self.appdelegate.ment["popup_id_already_title"].stringValue, message: self.appdelegate.ment["join_hint_id_already"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                    alert.show()
                }
            })
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            self.appdelegate.testNavi.popViewControllerAnimated(true)
        }
    }
    
    
    @IBAction func editProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("editProfile", sender: self)
    }
    

}
