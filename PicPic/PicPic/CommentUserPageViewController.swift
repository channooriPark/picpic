//
//  CommentUserPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 19..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class CommentUserPageViewController: SubViewController,UIAlertViewDelegate,UIScrollViewDelegate{

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var myId : String!
    var userId : String!
//    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    var statusbar : UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.statusbar = UIView()
        self.statusbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 20)
        self.statusbar.backgroundColor = UIColor(netHex: 0x484848)
        self.view.addSubview(statusbar)
        
        self.wkwebView = WKWebView(frame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height))
        self.view.addSubview(self.wkwebView)
        self.wkwebView.scrollView.delegate = self
        
        
        let message : JSON = ["my_id":myId,"user_id":userId]
        appdelegate.doItSocket(518, message: message) { (readData) -> () in
//            print("readData  :  ",readData)
            if readData["email"].stringValue == ""{
                let alert = UIAlertView(title: "", message: self.appdelegate.ment["toast_msg_not_exists_user"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                alert.show()
            }else {
                self.userId = readData["email"].string!
                if self.appdelegate.locale == "ko_KR" {
                }else {
                    self.language = "en_"
                }
                self.urlPath = self.servicePath+self.language+"user.jsp"
                self.jScript = String(format:"fire('%@','%@')", arguments : [self.myId,self.userId])
                self.webViewLoad()
                self.view.bringSubviewToFront(self.backButton)
                self.view.bringSubviewToFront(self.moreButton)
            }
            
        }
        
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            back()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        //        NSLog("\(self.navigationController?.viewControllers)")
        back()
    }
    
    func back(){
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        
        if a.type == "post" {
            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
            post.postImage.enterForeground()
        }
        
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search"{
            self.navigationController?.navigationBarHidden = true
        }else {
            self.navigationController?.navigationBarHidden = false
        }
//        self.appdelegate.controller.removeAtIndex(a.index)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("aaaaa")
        wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    
    @IBAction func more(sender: AnyObject) {
        let count = appdelegate.testNavi.viewControllers.count - 1
        let moreother = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MoreOtherViewController")as! MoreOtherViewController
        moreother.post_id = userId
        appdelegate.testNavi.viewControllers[count].addChildViewController(moreother)
        appdelegate.testNavi.viewControllers[count].view.addSubview(moreother.view)
    }
}
