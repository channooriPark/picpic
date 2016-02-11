//
//  SettingPasswordChangeTableViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 3..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingPasswordChangeTableViewController: UITableViewController ,UITextFieldDelegate{

    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var newPassAgain: UITextField!
    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var currentPass: UITextField!
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var againImage: UIImageView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var complete: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        complete.title = self.appdelegate.ment["complete1"].stringValue
        self.navigationItem.title = self.appdelegate.ment["settings_myinfo_change_password"].stringValue
        currentPass.placeholder = self.appdelegate.ment["settings_myinfo_change_password_now"].stringValue
        newPass.placeholder = self.appdelegate.ment["settings_myinfo_change_password_new"].stringValue
        newPassAgain.placeholder = self.appdelegate.ment["settings_myinfo_change_password_new_confirm"].stringValue
        self.appdelegate.email = self.appdelegate.email
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == currentPass {
            currentImage.image = UIImage(named: "icon_login2_password_c")
        }else if textField == newPass {
            newImage.image = UIImage(named: "icon_login2_password_c")
        }else if textField == newPassAgain {
            againImage.image = UIImage(named: "icon_login2_password_c")
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == currentPass {
            if textField != "" {
                
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    @IBAction func complete(sender: AnyObject) {
        if currentPass.text != nil || currentPass.text != "" {
            if (newPass.text! == newPassAgain.text!) && newPass.text != nil && newPassAgain.text != nil {
                let password : NSString = newPass.text!
                let scPattern : NSString = "[a-z]"
                let pcPattern : NSString = "[A-Z]"
                let nPattern : NSString = "[0-9]"
                if password.length >= 6 && password.length <= 15 && self.matches(password, pattern: scPattern) && matches(password, pattern: pcPattern) && matches(password, pattern: nPattern) {
                    let current : String = currentPass.text!
                    let new : String = newPass.text!
                    let message : JSON = ["myId":self.appdelegate.email,"now_pw":current,"new_pw":new]
//                    let connection = URLConnection(serviceCode: 208, message: message)
//                    let readData = connection.connection()
                    self.appdelegate.doIt(208, message: message, callback: { (readData) -> () in
                        if readData["msg"].string! == "success" {
//                            print("success")
                            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
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
    

}
