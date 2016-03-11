//
//  MoreMeViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 10..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class MoreMeViewController: UIViewController {

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var post_id : String!
    var body : String = ""
    var url : String!
    var email : String!
    let log = LogPrint()
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var moreView: UIView!
    
    
    @IBOutlet weak var backView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreView.layer.cornerRadius = 3
        self.moreView.layer.masksToBounds = true

        
        editButton.setTitle(self.appdelegate.ment["popup2_edit"].stringValue, forState: .Normal)
        deleteButton.setTitle(self.appdelegate.ment["popup2_delete"].stringValue, forState: .Normal)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        backView.addGestureRecognizer(tap)
        let message : JSON = ["":"","":""]
        appdelegate.doItSocket(504, message: message) { (readData) -> () in
            self.body = readData["contents"].string!
            self.url = readData["url"].string!
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        var count = (self.navigationController?.viewControllers.count)!-1
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        if a.type == "post" {
            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
//            post.postImage.enterForeground()
        }
        appdelegate.moreToggle = false
        self.view.removeFromSuperview()
    }
    
    @IBAction func edit(sender: AnyObject) {
        var count = (self.navigationController?.viewControllers.count)!-1
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        if a.type == "post" {
            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
            post.postImage.enterBackground()
        }
        let editpost = self.storyboard?.instantiateViewControllerWithIdentifier("EditPostViewController")as! EditPostViewController
        editpost.url = self.url
        editpost.post_id = self.post_id
        editpost.appdelegate = self.appdelegate
        editpost.email = self.email
        self.appdelegate.testNavi.navigationBarHidden = false
        
        self.appdelegate.testNavi.pushViewController(editpost, animated: true)
        self.appdelegate.moreToggle = false
        self.view.removeFromSuperview()
    }
    @IBAction func postDelete(sender: AnyObject) {
        let alert = UIAlertController(title: "", message: self.appdelegate.ment["post_delete_confirm"].stringValue, preferredStyle: .Alert)
        let ok = UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: .Default) { (ok) -> Void in
            var count = (self.navigationController?.viewControllers.count)!-1
            if count < 0 {
                count = 0
            }
            //        print(count)
            let a = self.navigationController?.viewControllers[count] as! SubViewController
            if a.type == "post" {
                let post = self.navigationController?.viewControllers[count]as! PostPageViewController
                post.postImage.enterBackground()
            }
            var tag = ""
            self.log.log(self.body)
            if let newString : String = self.body.stringByReplacingOccurrencesOfString(", #", withString: " #", options: NSStringCompareOptions.LiteralSearch, range: nil) {
                let body = newString.stringByReplacingOccurrencesOfString(",#", withString: " #", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let fullNameArr = body.componentsSeparatedByString(" ");
                
                for(var i=0;i<fullNameArr.capacity;i++) {
                    let _str = fullNameArr[i]
                    if(_str.hasPrefix("#")) {
                        if(tag.characters.count>0) {
                            tag += ","
                        }
                        tag += _str
                    }
                    tag = tag.stringByReplacingOccurrencesOfString("#", withString: "")
                }
            }
            self.log.log(self.body)
            self.log.log(self.url)
            self.log.log(tag)
            self.log.log(self.post_id)
            
            
            
            let message : JSON = ["myId":self.appdelegate.email,"body":self.body,"url":self.url,"tags":tag,"user_tags":"","and_tag":"","type":"D","post_id":self.post_id]
            self.appdelegate.doItSocket(232, message: message) { (readData) -> () in
                if readData["msg"].string! == "success" {
                    if self.appdelegate.second.view.hidden == false {
                        self.appdelegate.second.refresh()
                    }
                    if self.appdelegate.myfeed.view.hidden == false {
                        self.appdelegate.myfeed.fire()
                    }
                    
                    
                    
                    var count = (self.navigationController?.viewControllers.count)!-2
                    if count < 0 {
                        count = 0
                    }
                    self.log.log("1 \(self.navigationController?.viewControllers)")
                    let a = self.navigationController?.viewControllers[count] as! SubViewController
                    
                    if a.type == "tag_name" || a.type == "post" || a.type == "user" || a.type == "search"{
                        self.navigationController?.navigationBarHidden = true
                    }else {
                        self.navigationController?.navigationBarHidden = false
                    }
                    if !self.appdelegate.myfeed.view.hidden {
                        self.navigationController?.navigationBarHidden = true
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            self.appdelegate.moreToggle = false
            self.view.removeFromSuperview()
        }
        
        let cancel = UIAlertAction(title: self.appdelegate.ment["popup_cancel"].stringValue, style: .Default) { (cancel) -> Void in
            
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
