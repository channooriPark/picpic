//
//  ViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 9. 30..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON
import CryptoSwift
import SpringIndicator


class ViewController: UIViewController,GIDSignInDelegate, GIDSignInUIDelegate{
    var navi:UINavigationController!
    var loginButton : UIButton!
//    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    var result : Bool = false
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var language = NSLocale.preferredLanguages()[0]
    var readData : JSON!
    var currentDate : String!
    var filename : String!
    var id : String!
    var sex : String!
    var bir_year : String!
    var bir_mon : String!
    var bir_day : String!
    let register_form = "10002"
    var token : NSString!
    var profileImage : UIImage!
    @IBOutlet weak var facebookloginButton: UIButton!
    @IBOutlet weak var signinbutton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var defaultLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    let log = LogPrint()
    
    @IBOutlet weak var logoWid: NSLayoutConstraint!
    @IBOutlet weak var logoHei: NSLayoutConstraint!
    
    @IBOutlet weak var loginViewLeading: NSLayoutConstraint!
    @IBOutlet weak var loginCenter: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        if self.view.frame.size.width == 320.0 {
            logoWid.constant = 100
            logoHei.constant = 108
            if self.appdelegate.locale != "ko_KR" {
                loginCenter.constant += 10
                loginViewLeading.constant = 20
            }
        }else if self.view.frame.size.width == 375.0 {
            logoWid.constant = 110
            logoHei.constant = 118
            if self.appdelegate.locale != "ko_KR" {
                loginCenter.constant += 10
                loginViewLeading.constant = 17
            }
        }else {
            logoWid.constant = 110
            logoHei.constant = 118
            if self.appdelegate.locale != "ko_KR" {
                loginCenter.constant += 10
                loginViewLeading.constant = 10
            }
        }
        
        self.googleLoginButton.setTitle("  \(self.appdelegate.ment["login_with_google"].stringValue)", forState: .Normal)
        self.facebookloginButton.setTitle("      \(self.appdelegate.ment["login_with_facebook"].stringValue)", forState: .Normal)
        self.accountLabel.text = self.appdelegate.ment["login_isExits"].stringValue
        self.defaultLoginButton.setTitle(self.appdelegate.ment["login_login"].stringValue, forState: .Normal)
        self.signinbutton.setTitle(self.appdelegate.ment["join_siginin"].stringValue, forState: .Normal)
        
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name,birthday,gender"], tokenString: FBSDKAccessToken.currentAccessToken().tokenString, version: nil, HTTPMethod: "GET")
            req.startWithCompletionHandler { (connection, result, error : NSError!) -> Void in
                if error == nil {
                    if let name = result.valueForKey("name"){
                        self.id = name as! String
                    }
                    if let birth = result.valueForKey("birthday") {
                        let day = birth as! String
                        let array : NSArray = day.componentsSeparatedByString("/")
                        self.bir_year = array[2] as! String
                        self.bir_mon = array[0] as! String
                        self.bir_day = array[1] as! String
                    }
                    if let gender = result.valueForKey("gender"){
                        if gender as! String == "male" {
                            self.sex = "M"
                        }else if gender as! String == "female" {
                            self.sex = "W"
                        }else{
                            self.sex = ""
                        }
                    }
                }else {
//                    print("error \(error)")
                }
            }
        }
        

        
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        print("signIn google                   yes")
        if error == nil {
            //sign in success
            let userId = user.userID
            let idToken = user.authentication.idToken
            let name = user.profile.name
            let email = user.profile.email
            settingData()
            var message:JSON = ["email":email]
            print("userId ",userId)
            self.appdelegate.doIt(213, message: message, callback: { (readData) -> () in
                print(readData["register_form"].stringValue)
                if readData["data"].stringValue == "1" && readData["register_form"].stringValue == "10001" {
                    print("있어 일반계정으로")
                    let alert = UIAlertView(title: "", message: self.appdelegate.ment["login_already_google"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                    alert.show()
                    return
                }else if readData["data"].stringValue == "1" {
                    message = ["email":email,"password":userId,"register_form":"10003","country":self.language,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":self.currentDate]
                    self.appdelegate.doIt(202, message: message, callback: { (readData) -> () in
                        
                        if readData["msg"].string! == "success" {
                            //                        NSLog("success")
                            self.log.log("success")
                            self.appdelegate.email = email
                            if self.appdelegate.standardUserDefaults.objectForKey("id") == nil {
                                self.appdelegate.email = email
                                self.appdelegate.standardUserDefaults.setValue(self.enc(email), forKey: "id")
                                self.appdelegate.standardUserDefaults.setValue(self.enc(userId), forKey: "password")
                                self.appdelegate.standardUserDefaults.setValue("10003", forKey: "register_form")
                                self.appdelegate.standardUserDefaults.synchronize()
                            }
                            self.appdelegate.window?.rootViewController = self.appdelegate.testNavi
                        }else {
                            let temp = name.stringByReplacingOccurrencesOfString(" ", withString: "_")
                            
                            let data : JSON = ["email":email,"password":userId,"id":temp,"profile_picture":"noprofile.png","sex":"","bir_year":"","bir_mon":"","bir_day":"","register_form":"10003","country":self.language,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":self.currentDate]
                            let join = self.storyboard?.instantiateViewControllerWithIdentifier("GoogleJoinViewController")as! GoogleJoinViewController
                            join.userData = data
                            self.appdelegate.userData = data
                            self.navigationController?.pushViewController(join, animated: true)
                        }
                    })
                    
                }else {
                    let temp = name.stringByReplacingOccurrencesOfString(" ", withString: "_")
                    
                    let data : JSON = ["email":email,"password":userId,"id":temp,"profile_picture":"noprofile.png","sex":"","bir_year":"","bir_mon":"","bir_day":"","register_form":"10003","country":self.language,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":self.currentDate]
                    let join = self.storyboard?.instantiateViewControllerWithIdentifier("GoogleJoinViewController")as! GoogleJoinViewController
                    join.userData = data
                    self.appdelegate.userData = data
                    self.navigationController?.pushViewController(join, animated: true)
                }
            })
        }else {
            //error
            print("\(error.localizedDescription)")
            
            NSNotificationCenter.defaultCenter().postNotificationName("ToggleAuthUINotification", object: nil, userInfo: nil)
        }
    }

    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func googleLogin(sender: AnyObject) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    @IBAction func Signin(sender: AnyObject) {
        self.performSegueWithIdentifier("GoToEmail", sender: self)
    }
    
    @IBAction func facebookLogined(sender: AnyObject) {
        print("facebookLogin")
        let login : FBSDKLoginManager = FBSDKLoginManager()
        
        login.logInWithReadPermissions(["public_profile","email","user_friends","user_about_me","user_birthday"], fromViewController: self) { (result, error) -> Void in
            if error != nil {
                NSLog("Process error")
            }else if result.isCancelled {
                NSLog("Cancelled")
            }else {
                NSLog("Logged in")
                NSLog("HI")
                self.settingData()
                let message : JSON = ["email":FBSDKAccessToken.currentAccessToken().userID,"password":FBSDKAccessToken.currentAccessToken().userID,"register_form":self.register_form,"country":self.language,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":self.currentDate]
                
                self.log.log("\(message)")
                self.appdelegate.doIt(202, message: message, callback: { (readData) -> () in
                    if readData["msg"].string! == "success" {
                        self.log.log("success")
                        self.appdelegate.email = FBSDKAccessToken.currentAccessToken().userID
                        if self.appdelegate.standardUserDefaults.objectForKey("id") == nil {
                            self.appdelegate.email = FBSDKAccessToken.currentAccessToken().userID
                            self.appdelegate.standardUserDefaults.setValue(self.enc(FBSDKAccessToken.currentAccessToken().userID), forKey: "id")
                            self.appdelegate.standardUserDefaults.setValue(self.enc(FBSDKAccessToken.currentAccessToken().userID), forKey: "password")
                            self.appdelegate.standardUserDefaults.synchronize()
                        }
                        self.appdelegate.window?.rootViewController = self.appdelegate.testNavi
                    }else{
                        self.log.log("fail")
                        self.joinSetInfo()
                    }
                })
                
            }
        }
        
    }
    
    func checkNational(nation:String)->String{
        var language : String = ""
        if nation == "ko" {
            language = "ko_KR"
        }else {
            language = "en_US"
        }
        return language
    }
    
    
    @IBAction func ClickedLogin(sender: AnyObject) {
        let viewController : UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController"))!
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appdelegate.window?.rootViewController = viewController

    }
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
//        print("User logged out...")
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
        let res = try! NSString(data: data, encoding: NSUTF8StringEncoding)
        
        return String(res!)
    }
    
    
    
    
    func settingData(){
        //나라설정
        let nation : NSArray = language.componentsSeparatedByString("-")
        self.language = checkNational(nation[0] as! String)
        //가입 날짜 설정
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        currentDate = formatter.stringFromDate(date)
        
    }
    
    
    func joinSetInfo(){
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name,picture,birthday,gender"], tokenString: FBSDKAccessToken.currentAccessToken().tokenString, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler { (connection, result, error : NSError!) -> Void in
            if error == nil {
                if let name = result.valueForKey("name"){
                    let temp = name.stringByReplacingOccurrencesOfString(" ", withString: "_")
                    self.log.log(temp)
                        self.id = temp
                }
                if let birth = result.valueForKey("birthday") {
                    let day = birth as! String
                    let array : NSArray = day.componentsSeparatedByString("/")
                    let string = "년도\(array[2])월\(array[0])일\(array[1])"
                    self.bir_year = array[2] as! String
                    self.bir_mon = array[0] as! String
                    self.bir_day = array[1] as! String
                }
                if let gender = result.valueForKey("gender"){
                    if gender as! String == "male" {
                        self.sex = "M"
                    }else if gender as! String == "female" {
                        self.sex = "W"
                    }else{
                        self.sex = ""
                    }
                }
                self.filename = "\(FBSDKAccessToken.currentAccessToken().userID)\(self.currentDate).jpg"
                let message : JSON = ["email":FBSDKAccessToken.currentAccessToken().userID,"password":FBSDKAccessToken.currentAccessToken().userID,"id":self.id,"profile_picture":self.filename,"sex":self.sex,"bir_year":self.bir_year,"bir_mon":self.bir_mon,"bir_day":self.bir_day,"register_form":self.register_form,"country":self.language,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":self.currentDate]
                self.appdelegate.userData = message
                let profile = self.storyboard?.instantiateViewControllerWithIdentifier("FacebookJoinViewController")as! FacebookJoinViewController
                profile.filename = self.filename
                self.presentViewController(profile, animated: true, completion: nil)
            }else {
            }
        }
    }
    
    
    
}

