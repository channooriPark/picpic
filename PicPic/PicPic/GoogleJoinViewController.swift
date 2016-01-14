//
//  GoogleJoinViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2016. 1. 12..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class GoogleJoinViewController: UIViewController {

    
    var datePickerView : UIDatePicker = UIDatePicker()
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var birth : String!
    @IBOutlet weak var textSpace: NSLayoutConstraint!
    @IBOutlet weak var imageHei: NSLayoutConstraint!
    
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var birthText: UITextField!
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var userData : JSON = ["email":"","password":"","id":"","profile_picture":"noprofile.png","sex":"","bir_year":"","bir_mon":"","bir_day":"","register_form":"","country":"","device_id":"","push_token":"","regist_day":""]
    var checkGender : Bool = false
    var checkBirth : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.view.frame.size.width == 320.0 {
            
        }else if self.view.frame.size.width == 375.0 {
            imageHei.constant = 260
            textSpace.constant = 20
        }else {
            imageHei.constant = 260
            textSpace.constant = 20
        }
        
        birthLabel.text = self.appdelegate.ment["join_birthday"].stringValue
        if self.appdelegate.locale == "ko_KR" {
            birthText.text = "1990년 01월 01일"
        }else {
            birthText.text = "01/01/1990"
        }
        genderLabel.text = self.appdelegate.ment["join_sex"].stringValue
        nextButton.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        nextButton.enabled=false
        nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func selectBirth(sender: AnyObject) {
        let fomatter : NSDateFormatter = NSDateFormatter()
        
        //현재날자보다 크면 반환
        fomatter.dateFormat = "yyyyMMdd"
        let date = fomatter.dateFromString("19900101")
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.setDate(date!, animated: true)
        if self.appdelegate.locale == "ko_KR" {
            datePickerView.locale = NSLocale(localeIdentifier: "ko_KR")
        }else {
            datePickerView.locale = NSLocale(localeIdentifier: "en_US")
        }
        
        birthText.inputView = datePickerView
        
        let toolBar : UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        toolBar.tintColor = UIColor.grayColor()
        let doneItem : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("ShowSelectedDate"))
        let space : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([space,doneItem], animated: false)
        birthText.inputAccessoryView = toolBar
        
       
    }
    
    func ShowSelectedDate(){
        let fomatter : NSDateFormatter = NSDateFormatter()
        
        //현재날자보다 크면 반환
        fomatter.dateFormat = "yyyyMMdd"
        let time = Int(fomatter.stringFromDate(datePickerView.date))
        let current = Int(fomatter.stringFromDate(NSDate()))
        if time > current {
            let alert = UIAlertView(title: "", message: self.appdelegate.ment["join_birthday_errorMessage"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
            alert.show()
            return
        }
        
        checkBirth = true
        if checkGender {
            nextButton.enabled = true
            nextButton.setTitleColor(UIColor(colorLiteralRed: 0.41, green: 0.50, blue: 1.0, alpha: 1.0), forState: .Normal)
        }
        
        if self.appdelegate.locale == "ko_KR" {
            fomatter.dateFormat = "yyyy년 MM월 dd일"
        }else {
            fomatter.dateFormat = "MM/dd/yyyy"
        }
        self.birthText.text = NSString(format: "%@", fomatter.stringFromDate(datePickerView.date)) as String
        self.birthText.resignFirstResponder()
        fomatter.dateFormat = "yyyy/MM/dd"
        self.birth = fomatter.stringFromDate(datePickerView.date)
        let birthArray : NSArray = self.birth.componentsSeparatedByString("/")
        self.userData["bir_year"].string = birthArray[0]as! String
        self.userData["bir_mon"].string = birthArray[1]as! String
        self.userData["bir_day"].string = birthArray[2]as! String
    }
    
    @IBAction func maleSelected(sender: AnyObject) {
        maleButton.setImage(UIImage(named: "icon_join_male_c"), forState: UIControlState.Normal)
        femaleButton.setImage(UIImage(named: "icon_join_female"), forState: UIControlState.Normal)
        self.userData["sex"].stringValue = "M"
        checkGender = true
        if checkBirth {
            nextButton.enabled = true
            nextButton.setTitleColor(UIColor(colorLiteralRed: 0.41, green: 0.50, blue: 1.0, alpha: 1.0), forState: .Normal)
        }
    }
    
    @IBAction func femaleSelected(sender: AnyObject) {
        femaleButton.setImage(UIImage(named: "icon_join_female_c"), forState: UIControlState.Normal)
        maleButton.setImage(UIImage(named: "icon_join_male"), forState: UIControlState.Normal)
        self.userData["sex"].stringValue = "W"
        checkGender = true
        if checkBirth {
            nextButton.enabled = true
            nextButton.setTitleColor(UIColor(colorLiteralRed: 0.41, green: 0.50, blue: 1.0, alpha: 1.0), forState: .Normal)
        }
    }
    
    @IBAction func nextStep(sender: AnyObject) {
        if checkBirth && checkGender {
            print(userData)
            let profile = self.storyboard?.instantiateViewControllerWithIdentifier("GoogleprofileViewController")as! GoogleprofileViewController
            profile.userData = userData
            self.navigationController?.pushViewController(profile, animated: true)
        }
    }

}
