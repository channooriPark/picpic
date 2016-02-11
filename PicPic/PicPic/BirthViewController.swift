//
//  BirthViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 7..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class BirthViewController: UIViewController {
    
    var datePickerView : UIDatePicker = UIDatePicker()
    @IBOutlet weak var birthText: UITextField!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var birthSpace: NSLayoutConstraint!
    var birth : String!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var imageHei: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.view.frame.size.width == 320.0 {
            
        }else if self.view.frame.size.width == 375.0 {
            imageHei.constant = 260
            birthSpace.constant = 20
        }else {
            imageHei.constant = 260
            birthSpace.constant = 20
        }
        
        nextButton.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        birthLabel.text = self.appdelegate.ment["join_birthday"].stringValue
        if self.appdelegate.locale == "ko_KR" {
            birthText.text = "1990년 01월 01일"
        }else {
            birthText.text = "01/01/1990"
        }
        nextButton.enabled = false
        nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
    }
    
    @IBAction func birthSelect(sender: AnyObject) {
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
        nextButton.enabled = true
        nextButton.setTitleColor(UIColor(colorLiteralRed: 0.41, green: 0.50, blue: 1.0, alpha: 1.0), forState: .Normal)
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
        self.appdelegate.userData["bir_year"].string = birthArray[0] as? String
        self.appdelegate.userData["bir_mon"].string = birthArray[1] as? String
        self.appdelegate.userData["bir_day"].string = birthArray[2] as? String
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextToStep(sender: AnyObject) {
        if self.birth != nil {
            self.performSegueWithIdentifier("GoToGender", sender: self)
        }
    }

    @IBAction func back(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}
