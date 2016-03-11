//
//  LoginViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 11..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import CryptoSwift

class LoginViewController: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    var language = NSLocale.preferredLanguages()[0]
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var readData : JSON!
    let log = LogPrint()
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lostPass: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loginButton.setTitle(self.appdelegate.ment["login_login"].stringValue, forState: .Normal)
        lostPass.setTitle(self.appdelegate.ment["login_isforgot"].stringValue, forState: .Normal)
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == emailText || textField == passwordText{
            ScrollView.setContentOffset(CGPointMake(0, 215), animated: true)
            self.checkLabel.text = ""
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == passwordText || textField == emailText{
            ScrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        }
        if textField == passwordText {
            if passwordText != "" {
                LoginChecked(self)
            }
            
        }
        
    }
    
    
    //email check
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func dismissAlert(alert:UIAlertAction){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func LoginChecked(sender: AnyObject) {
        let nation : NSArray = language.componentsSeparatedByString("-")
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let currentDate = formatter.stringFromDate(date)
        
        self.language = checkNational(nation[0] as! String)
        
        if emailText.text != "" && isValidEmail(emailText.text!) {
            let email : String = emailText.text!
            let pass : String = passwordText.text!
            
            if self.appdelegate.standardUserDefaults.valueForKey("uuid") == nil {
                var uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString
                uuid = uuid?.stringByReplacingOccurrencesOfString("-", withString: "")
                uuid = "iPhone"+uuid!+uuid!
                
                self.appdelegate.standardUserDefaults.setValue(uuid, forKey: "uuid")
                self.appdelegate.deviceId = uuid!
            }else {
                self.appdelegate.deviceId = self.appdelegate.standardUserDefaults.valueForKey("uuid")as! String
            }
            
            let message : JSON = ["email":email,"password":pass,"register_form":"10001","country":self.appdelegate.locale,"device_id":self.appdelegate.deviceId,"push_token":self.appdelegate.token,"regist_day":currentDate]
//            let message : JSON = ["email":email,"password":pass,"register_form":"10001","country":self.appdelegate.locale,"device_id":"","push_token":"","regist_day":currentDate]
            print(self.appdelegate.locale)
            print(message)
//            let connection = URLConnection(serviceCode: 202, message: message)
//            self.readData = connection.connection()
            self.appdelegate.doItSocket(202, message: message, callback: { (readData) -> () in
                print(readData)
                if readData["msg"].string! == "success" {
                    self.readData = readData
                    self.Login()
                }else if readData["msg"].stringValue == "fail" {
                    self.checkLabel.text = self.appdelegate.ment["new_login_error"].stringValue
                }
            })
        }else {
            checkLabel.text = self.appdelegate.ment["new_login_wrong"].stringValue
        }
        
        
    }
    
    func loginDataSet(){
        
    }
    
    
    func Login(){
        
        let msg = self.readData["msg"]
        if msg == "success" {
            let email : String = self.readData["data"]["email"].string!
            let password : String = self.passwordText.text!
            let id : String = self.emailText.text!
            appdelegate.email = email
            if appdelegate.standardUserDefaults.objectForKey("id") == nil {
                appdelegate.standardUserDefaults.setValue(self.enc(id), forKey: "id")
                appdelegate.standardUserDefaults.setValue(self.enc(password), forKey: "password")
//                //print("alsdjfef;oiajsfi;oejasd;fe;io\(self.enc(id))")
//                //print("alsdjfef;oiajsfi;oejasd;fe;io\(self.enc(password))")
                appdelegate.standardUserDefaults.synchronize()
            }
            appdelegate.userData = self.readData["data"]
            log.log("\(appdelegate.userData)")
//            print(appdelegate.userData)
            appdelegate.controller.append(appdelegate.contentview)
//            appdelegate.contentview.index = appdelegate.controller.count-1
            appdelegate.contentview.type = "content"
            appdelegate.window?.rootViewController = appdelegate.testNavi
        }else {
            checkLabel.text = self.appdelegate.ment["new_login_wrong"].stringValue
        }
    }
    
    @IBAction func backClicked(sender: AnyObject) {
        logoClicked(sender)
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

    @IBAction func SearchPassword(sender: AnyObject) {
        self.performSegueWithIdentifier("NorifyModally", sender: self)
    }
    @IBAction func logoClicked(sender: AnyObject) {
        let viewController : UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("signinNavigationController")as! UINavigationController
        
        viewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        viewController.navigationBar.shadowImage = UIImage()
        viewController.navigationBar.translucent = true
        viewController.navigationBar.tintColor = UIColor.whiteColor()
        //        viewController.navigationItem.leftBarButtonItem = customBackButton
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appdelegate.window?.rootViewController = viewController
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
    
    
}
