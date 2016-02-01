//
//  SettingTableViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 26..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingTableViewController: UITableViewController , UIAlertViewDelegate{
    
    
    @IBOutlet weak var myinfo: UILabel!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var opensetting: UILabel!
    @IBOutlet weak var accountSwitch: UISwitch!
    @IBOutlet weak var secretMent: UILabel!
    @IBOutlet weak var secretSetting: UILabel!
    @IBOutlet weak var blockAccount: UILabel!
    @IBOutlet weak var notics: UILabel!
    @IBOutlet weak var programInfo: UILabel!
    @IBOutlet weak var deActivite: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    let log = LogPrint()
    @IBOutlet weak var socialNetwork: UILabel!
    @IBOutlet weak var searchFriend: UILabel!
    
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var alarmLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = self.appdelegate.ment["setting"].stringValue
        myinfo.text = self.appdelegate.ment["settings_myinfo"].stringValue
        opensetting.text = self.appdelegate.ment["settings_public_setting"].stringValue
        secretMent.text = self.appdelegate.ment["settings_protect_account_script"].stringValue
        secretSetting.text = self.appdelegate.ment["settings_protect_account"].stringValue
        blockAccount.text = self.appdelegate.ment["settings_protect_id_manage"].stringValue
        notics.text = self.appdelegate.ment["settings_notice"].stringValue
        programInfo.text = self.appdelegate.ment["settings_program_info"].stringValue
        logoutLabel.text = self.appdelegate.ment["settings_logout"].stringValue
        deActivite.text = self.appdelegate.ment["settings_signout"].stringValue
        alarmLabel.text = self.appdelegate.ment["settings_alarm"].stringValue
        socialNetwork.text = self.appdelegate.ment["settings_social"].stringValue
        searchFriend.text = self.appdelegate.ment["settings_find_friend"].stringValue
        
        
        if self.appdelegate.standardUserDefaults.valueForKey("push")as! Bool == true {
            self.alarmSwitch.on = true
        }else {
            self.alarmSwitch.on = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        let message : JSON = ["my_id":self.appdelegate.email,"user_id":self.appdelegate.email]
        self.appdelegate.doIt(406, message: message) { (readData) -> () in
            print("\(readData)")
            if readData["public_yn"].string! == "Y" {
                self.accountSwitch.on = false
            }else {
                self.accountSwitch.on = true
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            if indexPath.row == 2 {
                self.performSegueWithIdentifier("logout", sender: self)
            }
        }
        
    }
    
    @IBAction func accountSetting(sender: AnyObject) {
        var message : JSON = ["email":self.appdelegate.email,"close_yn":""]
        if accountSwitch.on {
            message["close_yn"].string = "Y"
        }else {
            message["close_yn"].string = "N"
        }
        self.appdelegate.doIt(219, message: message) { (readData) -> () in
            self.log.log("\(readData)")
            if readData["msg"].string == "success" {
                if readData["close_yn"].string! == "Y" {
                    if self.appdelegate.locale == "ko_KR" {
                        let alert = UIAlertView(title: "비공개 설정", message: "계정이 비공개로 설정 되었습니다", delegate: self, cancelButtonTitle: "확인")
                        alert.show()
                    }else {
                        let alert = UIAlertView(title: "Set private Account", message: "Complete etting account private", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }else {
                    if self.appdelegate.locale == "ko_KR" {
                        let alert = UIAlertView(title: "비공개 설정", message: "계정이 공개로 설정 되었습니다", delegate: self, cancelButtonTitle: "확인")
                        alert.show()
                    }else {
                        let alert = UIAlertView(title: "Set private Account", message: "Complete setting account pubilc", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
            }else{
                
            }
        }
    }
    @IBAction func alarmSetting(sender: AnyObject) {
        print(alarmSwitch.on)
        if self.alarmSwitch.on == false {
            print("알림 안받어")
            UIApplication.sharedApplication().unregisterForRemoteNotifications()
            self.appdelegate.standardUserDefaults.setBool(false, forKey: "push")
        }else {
            print("알림 받어")
            if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false {
                let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                UIApplication.sharedApplication().registerForRemoteNotifications()
            }
            self.appdelegate.standardUserDefaults.setBool(true, forKey: "push")
        }
        print(UIApplication.sharedApplication().currentUserNotificationSettings())
        print(UIApplication.sharedApplication().isRegisteredForRemoteNotifications())
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title : String = ""
        
        switch section {
        case 0 :
            title = self.appdelegate.ment["settings_private"].stringValue
            break
        case 1 :
            title = self.appdelegate.ment["settings_noraml"].stringValue
            break
        default :
            title = self.appdelegate.ment["settings_program"].stringValue
            break
        }
        return title
    }
    
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            
        }
    }
    
    
    @IBAction func backToMyFeed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
