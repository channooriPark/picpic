//
//  MoreOtherViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 10..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class MoreOtherViewController: UIViewController {

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var post_id : String!
    var email : String!
    
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    let log = LogPrint()
    @IBOutlet weak var moreView: UIView!
    
    @IBOutlet weak var backView: UIView!
    var delegate : MoreOtherDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moreView.layer.cornerRadius = 3
        self.moreView.layer.masksToBounds = true
        
        blockButton.setTitle(self.appdelegate.ment["popup2_block"].stringValue, forState: .Normal)
        reportButton.setTitle(self.appdelegate.ment["popup2_report"].stringValue, forState: .Normal)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        backView.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
//        var count = self.appdelegate.testNavi.viewControllers.count-2
//        if count < 0 {
//            count = 0
//        }
//        //        print(count)
//        let a = self.appdelegate.testNavi.viewControllers[count] as! SubViewController
//        if a.type == "post" {
//            let post = self.appdelegate.testNavi.viewControllers[count]as! PostPageViewController
//            post.postImage.enterForeground()
//        }
        appdelegate.moreToggle = false
        self.view.removeFromSuperview()
    }
    
    @IBAction func block(sender: AnyObject) {
        let alert = UIAlertController(title: "", message: self.appdelegate.ment["user_block_confirm"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default) { (ok) -> Void in
            var message : JSON = ["my_id":self.appdelegate.email,"user_id":self.email]
            self.appdelegate.doIt(216, message: message, callback: { (readData) -> () in
                print("readData : ",readData)
                if readData["msg"].string == "success" {
                    if self.appdelegate.locale == "ko_KR" {
                        let alert = UIAlertView(title: "사용자 차단", message: "차단이 완료되었습니다", delegate: nil, cancelButtonTitle: "확인")
                        alert.show()
                    }else {
                        let alert = UIAlertView(title: "User Block", message: "User Blocked", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
            })
            self.appdelegate.moreToggle = false
            self.view.removeFromSuperview()
        }
        
        let cancel = UIAlertAction(title: self.appdelegate.ment["popup_cancel"].stringValue, style: UIAlertActionStyle.Default) { (cancel) -> Void in
            
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func report(sender: AnyObject) {
        self.delegate?.reportClicked()
        self.appdelegate.testNavi.navigationBarHidden = false
        self.appdelegate.testNavi.navigationBar.topItem?.title = self.appdelegate.ment["popup2_report"].stringValue
        let report = self.storyboard?.instantiateViewControllerWithIdentifier("ReportViewController")as! ReportViewController
        report.type = "P"
        report.post_id = self.post_id
        self.appdelegate.testNavi.pushViewController(report, animated: true)
        self.view.removeFromSuperview()
        
    }
}


protocol MoreOtherDelegate {
    func reportClicked()
}
