//
//  FirstViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 28..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import SwiftyJSON
import CryptoSwift

class FirstViewController: UIViewController , UIAlertViewDelegate,FBSDKAppInviteDialogDelegate{
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var language = NSLocale.preferredLanguages()[0]
    let log = LogPrint()
    @IBOutlet weak var logoWid: NSLayoutConstraint!
    @IBOutlet weak var logoHei: NSLayoutConstraint!
    var pushData : NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.view.frame.size.width == 320.0 {
            logoWid.constant = 159
            logoHei.constant = 46
        }else if self.view.frame.size.width == 375.0{
            logoWid.constant = 170
            logoHei.constant = 49
            
        }else {
            logoWid.constant = 190
            logoHei.constant = 59
        }
        
        log.log("width: \(logoWid.constant)   height: \(logoHei.constant)")
        
        if appdelegate.standardUserDefaults.objectForKey("id") != nil && appdelegate.standardUserDefaults.objectForKey("password") != nil{
            
            if self.appdelegate.standardUserDefaults.valueForKey("register_form") != nil {
                if self.dec(self.appdelegate.standardUserDefaults.valueForKey("register_form")as! String) == "10001" {
                    picpicLogin()
                }else if self.dec(self.appdelegate.standardUserDefaults.valueForKey("register_form")as! String) == "10002" {
                    self.facebookLogin()
                }else if self.dec(self.appdelegate.standardUserDefaults.valueForKey("register_form")as! String) == "10003" {
                    self.googleLogin()
                }
            }else {
                //이전 버전의 로그인 형식 수정 2016 03 18 Fri
                
                //페이스북 로그인일 때
                if FBSDKAccessToken.currentAccessToken() != nil {
                    //10002
                    if  self.dec(appdelegate.standardUserDefaults.valueForKey("id") as! String) == FBSDKAccessToken.currentAccessToken().userID {
                        self.facebookLogin()
                    }else {
                        if self.appdelegate.standardUserDefaults.objectForKey("register_form") != nil {
                            googleLogin()
                        }else {
                            picpicLogin()
                        }
                    }
                }else if self.appdelegate.standardUserDefaults.objectForKey("register_form") != nil {
                    //10003
                    print("google")
                    self.googleLogin()
                }
                else { //10001
                    print("일반 로그인")
                    self.picpicLogin()
                }
            }
        }else { //단말기에 id와 password가 저장이 안되어 있을때에 로그인 화면으로 넘어간다
            appdelegate.window?.rootViewController = self.appdelegate.signin
        }
    }
    
    
    //페이스북 로그인 func
    func facebookLogin(){
        //데이터 셋팅
        let nation : NSArray = language.componentsSeparatedByString("-")
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let currentDate = formatter.stringFromDate(date)
        self.language = checkNational(nation[0] as! String)
        let register_form = "10002"
        if self.appdelegate.standardUserDefaults.valueForKey("uuid") == nil {
            var uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString
            uuid = uuid?.stringByReplacingOccurrencesOfString("-", withString: "")
            uuid = "iPhone"+uuid!+uuid!
            
            self.appdelegate.standardUserDefaults.setValue(uuid, forKey: "uuid")
            self.appdelegate.deviceId = uuid!
        }else {
            self.appdelegate.deviceId = self.appdelegate.standardUserDefaults.valueForKey("uuid")as! String
        }
        
        let message : JSON = ["email":FBSDKAccessToken.currentAccessToken().userID,"password":FBSDKAccessToken.currentAccessToken().userID,"register_form":register_form,"country":self.language,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":currentDate]
        // doit
        self.appdelegate.doIt(202, message: message, callback: { (readData) -> () in
            if readData["msg"].string! == "success" {
                self.appdelegate.userData = readData["data"]
                self.appdelegate.email = readData["data"]["email"].string!
                self.appdelegate.standardUserDefaults.setValue(self.enc("10002"), forKey: "register_form")
                self.appdelegate.controller.append(self.appdelegate.contentview)
                self.appdelegate.contentview.type = "content"
                self.appdelegate.window?.rootViewController = self.appdelegate.testNavi
                if self.pushData != nil {
                    self.appdelegate.URLopenPage(self.pushData)
                }
            }else { //Login fail
                let viewController : UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("signinNavigationController")as! UINavigationController
                self.appdelegate.window?.rootViewController = viewController
            }
        })
    }
    //구글 로그인 func
    func googleLogin(){
        let nation : NSArray = language.componentsSeparatedByString("-")
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let currentDate = formatter.stringFromDate(date)
        self.language = checkNational(nation[0] as! String)
        
        if self.appdelegate.standardUserDefaults.valueForKey("uuid") == nil {
            var uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString
            uuid = uuid?.stringByReplacingOccurrencesOfString("-", withString: "")
            uuid = "iPhone"+uuid!+uuid!
            
            self.appdelegate.standardUserDefaults.setValue(uuid, forKey: "uuid")
            self.appdelegate.deviceId = uuid!
        }else {
            self.appdelegate.deviceId = self.appdelegate.standardUserDefaults.valueForKey("uuid")as! String
        }
        
        let message : JSON = ["email":self.dec(appdelegate.standardUserDefaults.valueForKey("id")as! String),"password":self.dec(appdelegate.standardUserDefaults.valueForKey("password") as! String),"register_form":"10003","country":language,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":currentDate]
        // doit
        self.appdelegate.doIt(202, message: message, callback: { (readData) -> () in
            if readData["msg"].string! == "success" {
                self.appdelegate.email = readData["data"]["email"].string!
                self.appdelegate.userData = readData["data"]
                self.appdelegate.controller.append(self.appdelegate.contentview)
                self.appdelegate.contentview.type = "content"
                self.appdelegate.window?.rootViewController = self.appdelegate.testNavi
                self.appdelegate.standardUserDefaults.setValue(self.enc("10003"), forKey: "register_form")
                if self.pushData != nil {
                    self.appdelegate.URLopenPage(self.pushData)
                }
            }
            else{//Login fail
                let viewController : UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("signinNavigationController")as! UINavigationController
                self.appdelegate.window?.rootViewController = viewController
            }
        })
    }
    //일반로그인 func
    func picpicLogin(){
        //일반로그인일때 AccessToken이 nil일 때
        let nation : NSArray = language.componentsSeparatedByString("-")
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let currentDate = formatter.stringFromDate(date)
        self.language = checkNational(nation[0] as! String)
        
        if self.appdelegate.standardUserDefaults.valueForKey("uuid") == nil {
            var uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString
            uuid = uuid?.stringByReplacingOccurrencesOfString("-", withString: "")
            uuid = "iPhone"+uuid!+uuid!
            self.appdelegate.standardUserDefaults.setValue(uuid, forKey: "uuid")
            self.appdelegate.deviceId = uuid!
        }else {
            self.appdelegate.deviceId = self.appdelegate.standardUserDefaults.valueForKey("uuid")as! String
        }
        
        let message : JSON = ["email":self.dec(appdelegate.standardUserDefaults.valueForKey("id")as! String),"password":self.dec(appdelegate.standardUserDefaults.valueForKey("password") as! String),"register_form":"10001","country":language,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":currentDate]
        //doit
        self.appdelegate.doIt(202, message: message, callback: { (readData) -> () in
            if readData["msg"].string! == "success" {
                self.appdelegate.email = readData["data"]["email"].string!
                self.appdelegate.userData = readData["data"]
                self.appdelegate.standardUserDefaults.setValue(self.enc("10001"), forKey: "register_form")
                self.appdelegate.controller.append(self.appdelegate.contentview)
                self.appdelegate.contentview.type = "content"
                self.appdelegate.window?.rootViewController = self.appdelegate.testNavi
                if self.pushData != nil {
                    self.appdelegate.URLopenPage(self.pushData)
                }
            }else{//Login fail
                let viewController : UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("signinNavigationController")as! UINavigationController
                self.appdelegate.window?.rootViewController = viewController
            }
        })
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            let viewController : UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("signinNavigationController")as! UINavigationController
            appdelegate.window?.rootViewController = viewController
        }
    }
    
    func checkNational(nation:String)->String{
        var language : String = ""
        if nation == "ko" {
            language = "ko_KR"
        }else if nation == "en" {
            language = "en_US"
        }else if nation == "zh" {
            language = "zh_CN"
        }else if nation == "ja" {
            language = "ja_JP"
        }
        return language
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let key: String = "secret0key000000"
    let iv: String = "0123456789012345"
    
    func enc(str: String) -> String
    {
        let encryptedBytes: [UInt8] = try! str.encrypt(AES(key: key, iv: iv, blockMode: .CBC))
        let base64Enc = NSData(bytes: encryptedBytes).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return base64Enc
    }
    
    func dec(str: String) -> String
    {
        //let res: String = ""
        let decodedData = NSData(base64EncodedString: str, options: .IgnoreUnknownCharacters)
        
        let count = decodedData!.length / sizeof(UInt8)
        var byteArray = [UInt8](count: count, repeatedValue: 0)
        decodedData!.getBytes(&byteArray, length:count * sizeof(UInt8))
        
        let decodeStr: [UInt8] = try! byteArray.decrypt(AES(key: key, iv: iv, blockMode: .CBC))
        let data = NSData(bytes: decodeStr, length: Int(decodeStr.count))
        let res = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        return String(res!)
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
    }
    
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print(error)
    }
    
    
    

}
