//
//  UsernameViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 12..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class UsernameViewController: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var userSpace: NSLayoutConstraint!
    @IBOutlet weak var imageHei: NSLayoutConstraint!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var check: UILabel!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var nextButton: UIButton!
    let log = LogPrint()
    var nameTemp : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.view.frame.size.width == 320.0 {
            
        }else if self.view.frame.size.width == 375.0 {
            imageHei.constant = 260
            userSpace.constant = 20
        }else {
            imageHei.constant = 260
            userSpace.constant = 20
        }
        
        userName.delegate = self
        nextButton.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        userName.placeholder = self.appdelegate.ment["join_id"].stringValue
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        userName.addTarget(self, action: Selector("didChangeText"), forControlEvents: UIControlEvents.EditingChanged)
        nextButton.enabled = false
        nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
    }

    func didChangeText() {
        if userName.text != "" {
            nextButton.enabled = true
            nextButton.setTitleColor(UIColor(colorLiteralRed: 0.41, green: 0.50, blue: 1.0, alpha: 1.0), forState: .Normal)
        }else {
            nextButton.enabled = false
            nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
        }
        nameTemp = userName.text
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if nameTemp != nil {
            userName.text = nameTemp
        }
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func nextStep(sender: AnyObject) {
        if let name = userName.text {
            let space = name.componentsSeparatedByString(" ")
            let text = name as NSString
            if text.length > 20 || space.count > 1 {
                self.check.text = self.appdelegate.ment["join_hint_id_pattern"].stringValue
                return
            }
            
            if isValidID(name) {
                let id : String = userName.text!
                let message : JSON = ["id":id]
                //            let connection = URLConnection(serviceCode: 214, message: message)
                //            let readData = connection.connection()
                self.appdelegate.doIt(214, message: message, callback: { (readData) -> () in
                    if readData["data"].string == "1" {
                        self.check.text = self.appdelegate.ment["join_hint_id_already"].stringValue
                    }else {
                        self.appdelegate.userData["id"].string = id
                        self.performSegueWithIdentifier("GoToProfilePicture", sender: self)
                    }
                    
                    if readData["msg"].stringValue == "fail" {
                        self.check.text = self.appdelegate.ment["join_hint_id_pattern"].stringValue
                    }
                    
                })
            }else {
               self.check.text = self.appdelegate.ment["join_hint_id_pattern"].stringValue
            }
            
            
        }else {
            self.check.text = self.appdelegate.ment["join_hint_id_empty"].stringValue
        }
    }

    @IBAction func back(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    

    func isValidID(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9]*$"
        
        let IDTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        log.log("\(IDTest.evaluateWithObject(testStr))")
        return IDTest.evaluateWithObject(testStr)
    }

}
