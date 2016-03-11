//
//  ReportViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 11..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReportViewController: UIViewController , UITextFieldDelegate{

    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var label3: UILabel!
    
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var etcText: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var etcLabel: UILabel!
    
    var reason : String!
    var post_id : String!
    var type : String!
    var reason_code : String!
    let log = LogPrint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = self.appdelegate.ment["report_it"].stringValue
        titleLabel.text = self.appdelegate.ment["whats_the_problem"].stringValue
        label1.text = self.appdelegate.ment["report_1"].stringValue
        label2.text = self.appdelegate.ment["report_2"].stringValue
        label3.text = self.appdelegate.ment["report_3"].stringValue
        etcLabel.text = self.appdelegate.ment["report_4"].stringValue
        etcText.placeholder = self.appdelegate.ment["report_etc"].stringValue

        etcText.delegate = self
        let image = UIImageView(frame: CGRectMake(0, 0, 20, 20))
        image.image = UIImage(named: "icon_camera_complete")
        let complete = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "complete")
        image.addGestureRecognizer(tap)
        self.navigationItem.rightBarButtonItem = complete
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let backimage = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        backimage.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: backimage)
        let backtap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "back")
        backimage.addGestureRecognizer(backtap)
        self.navigationItem.leftBarButtonItem = backButton
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func back(){
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
//        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search"{
//            self.navigationController?.navigationBarHidden = true
//        }else {
//            self.navigationController?.navigationBarHidden = false
//        }
//        self.appdelegate.moreToggle = false
//        self.appdelegate.tabbar.view.hidden = false
        if a.type == "post" {
            let b = a as! PostPageViewController
            b.postImage.enterForeground()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    

    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func button1(sender: AnyObject) {
        self.imageToggle(0)
        self.reason = self.label1.text
        self.reason_code = "0"
        etcText.resignFirstResponder()
//        print(self.reason)
    }

    @IBAction func button2(sender: AnyObject) {
        self.imageToggle(1)
        self.reason = self.label2.text
        self.reason_code = "1"
        etcText.resignFirstResponder()
//        print(self.reason)
    }

    @IBAction func button3(sender: AnyObject) {
        self.imageToggle(2)
        self.reason = self.label3.text
        self.reason_code = "2"
        etcText.resignFirstResponder()
//        print(self.reason)
    }

    @IBAction func button4(sender: AnyObject) {
        self.imageToggle(3)
//        sender.setImage(UIImage(named: "icon_"), forState: .Normal)
        if self.etcText.text == nil || self.etcText.text == "" {
            self.reason = ""
        }else {
            self.reason = self.etcText.text
        }
//        print(self.reason)
        self.reason_code = "3"
    }

    func complete(){
        
        log.log(self.post_id)
        log.log(self.reason_code)
        log.log(self.type)
//        log.log(self.reason)
        
        if let reason = self.etcText.text {
            self.reason = reason
        }
        
        
        let message : JSON = ["post_id":self.post_id,"call_id":self.appdelegate.email,"reason":self.reason,"type":self.type,"reason_code":self.reason_code]
        self.appdelegate.doItSocket(204, message: message) { (readData) -> () in
            if readData["msg"].string! == "success" {
                var count = (self.navigationController?.viewControllers.count)!-2
                if count < 0 {
                    count = 0
                }
//                print(count)
                let a = self.navigationController?.viewControllers[count] as! SubViewController
                if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search"{
                    self.navigationController?.navigationBarHidden = true
                }else {
                    self.navigationController?.navigationBarHidden = false
                }
                
                if a.type == "post" {
                    let b = a as! PostPageViewController
                    b.postImage.enterForeground()
                }
                self.appdelegate.moreToggle = false
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.imageToggle(3)
        self.reason_code = "3"
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    func imageToggle(index: Int){
        var imageArray = [self.image1,self.image2,self.image3,self.image4]
        for var i = 0; i < imageArray.count; i++ {
            if i == index {
                imageArray[i].image = UIImage(named: "icon_report_on")
            }else {
                imageArray[i].image = UIImage(named: "icon_report_off")
            }
        }
        
    }

}
