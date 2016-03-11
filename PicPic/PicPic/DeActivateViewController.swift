//
//  DeActivateViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 4..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import FBSDKLoginKit
import FBSDKCoreKit

class DeActivateViewController: UIViewController {
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var deactivateLabel: UILabel!
    @IBOutlet weak var deactivateMentLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var activeView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activeView.layer.cornerRadius = 3
        self.activeView.layer.masksToBounds = true
        
        deactivateLabel.text = self.appdelegate.ment["popup_is_sign_out"].stringValue
        deactivateMentLabel.text = self.appdelegate.ment["popup_sign_out_str"].stringValue
        completeButton.setTitle(self.appdelegate.ment["popup_confirm"].stringValue, forState: .Normal)
        cancleButton.setTitle(self.appdelegate.ment["popup_cancel"].stringValue, forState: .Normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deactivate(sender: AnyObject) {
        let message : JSON = ["email":self.appdelegate.email]
        
        self.appdelegate.doItSocket(218, message: message) { (readData) -> () in
            if readData["msg"].string! == "success" {
                if FBSDKAccessToken.currentAccessToken() != nil {
                    let loginManager = FBSDKLoginManager()
                    loginManager.logOut()
                }
                if self.appdelegate.standardUserDefaults.objectForKey("id") != nil && self.appdelegate.standardUserDefaults.objectForKey("password") != nil{
//                    print("logout")
                    for key in self.appdelegate.standardUserDefaults.dictionaryRepresentation().keys {
                        self.appdelegate.standardUserDefaults.removeObjectForKey(key)
                    }
                }
                
                self.appdelegate.contentview = nil
                self.appdelegate.tabbar = nil
                self.appdelegate.main = nil
                self.appdelegate.alram = nil
                self.appdelegate.second = nil
                self.appdelegate.camera = nil
                self.appdelegate.myfeed = nil
                self.appdelegate.login = nil
                self.appdelegate.testNavi = nil
                
                if UIApplication.sharedApplication().currentUserNotificationSettings()?.types.rawValue == 0 {
                    print("Not Notification")
                    self.appdelegate.standardUserDefaults.setBool(false, forKey: "push")
                }else {
                    print("Accept Notification")
                    self.appdelegate.standardUserDefaults.setBool(true, forKey: "push")
                }
                self.appdelegate.standardUserDefaults.setValue(self.appdelegate.deviceId, forKey: "uuid")
                
                let intro = self.storyboard?.instantiateViewControllerWithIdentifier("IntroMainViewController")as! IntroMainViewController
                self.appdelegate.window?.rootViewController = intro
                self.appdelegate.reloadView()
            }
        }
        
        
        
    }

    @IBAction func cancle(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
