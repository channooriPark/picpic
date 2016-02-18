//
//  LogoutAlertViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 2..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LogoutAlertViewController: UIViewController {

    @IBOutlet weak var backview: UIView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var activeView: UIView!
    @IBOutlet weak var logoutMent: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var cancleButton: UIButton!
    let log = LogPrint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activeView.layer.cornerRadius = 3
        self.activeView.layer.masksToBounds = true

        logoutMent.text = self.appdelegate.ment["popup_is_logout"].stringValue
        completeButton.setTitle(self.appdelegate.ment["popup_confirm"].stringValue, forState: .Normal)
        cancleButton.setTitle(self.appdelegate.ment["popup_cancel"].stringValue, forState: .Normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func oked(sender: AnyObject) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }else if self.appdelegate.standardUserDefaults.objectForKey("register_form") != nil {
            print("google logout")
            GIDSignIn.sharedInstance().signOut()
        }
        if self.appdelegate.standardUserDefaults.objectForKey("id") != nil && self.appdelegate.standardUserDefaults.objectForKey("password") != nil{
//            print("logout")
            for key in self.appdelegate.standardUserDefaults.dictionaryRepresentation().keys {
                self.appdelegate.standardUserDefaults.removeObjectForKey(key)
            }
            
        }
        GIDSignIn.sharedInstance().disconnect()
        self.appdelegate.contentview = nil
        self.appdelegate.tabbar = nil
        self.appdelegate.main = nil
        self.appdelegate.alram = nil
        self.appdelegate.second = nil
        self.appdelegate.camera = nil
        self.appdelegate.myfeed = nil
        self.appdelegate.login = nil
        self.appdelegate.testNavi = nil
        self.appdelegate.userData = ["email":"","password":"","id":"","profile_picture":"noprofile.png","sex":"","bir_year":"","bir_mon":"","bir_day":"","register_form":"","country":"","device_id":"","push_token":"","regist_day":""]
        self.appdelegate.email = ""

        if UIApplication.sharedApplication().currentUserNotificationSettings()?.types.rawValue == 0 {
            print("Not Notification")
            self.appdelegate.standardUserDefaults.setBool(false, forKey: "push")
        }else {
            print("Accept Notification")
            self.appdelegate.standardUserDefaults.setBool(true, forKey: "push")
        }
        self.appdelegate.standardUserDefaults.setValue(self.appdelegate.deviceId, forKey: "uuid")
        
        self.appdelegate.window?.rootViewController = self.appdelegate.signin
        self.appdelegate.standardUserDefaults.setValue(true, forKey: "tutorial")
        self.appdelegate.reloadView()
        log.log("token    \(self.appdelegate.token)")
    }
    
    @IBAction func cancled(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
