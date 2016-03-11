//
//  CommentTagPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 19..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class CommentTagPageViewController: SubViewController,UIScrollViewDelegate,UIAlertViewDelegate{

    @IBOutlet weak var backButton: UIButton!
//    @IBOutlet weak var webView: UIWebView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var email : String!
    var tagId : String!
    var likeImage : UIImageView!
    let log = LogPrint()
    var statusbar : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.backButton.hidden = false
        self.statusbar = UIView()
        self.statusbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 20)
        self.statusbar.backgroundColor = UIColor(netHex: 0x484848)
        self.view.addSubview(statusbar)
        self.wkwebView = WKWebView(frame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height))
        self.view.addSubview(self.wkwebView)
        
        print(self.wkwebView.frame)
        
        
        
        let message : JSON = ["my_id":self.appdelegate.email,"tag_str":tagId]
        self.appdelegate.doItSocket(517, message: message) { (readData) -> () in
//            print(readData)
            if readData["tag_id"].stringValue != "" {
                if self.appdelegate.locale == "ko_KR" {
                }else {
                    self.language = "en_"
                }
                self.urlPath = self.servicePath+self.language+"tag.jsp"
                self.jScript = String(format:"fire('%@','%@')", arguments : [self.email,self.tagId])
                self.log.log("\(self.email)    \(self.tagId)")
                self.webViewLoad()
                self.wkwebView.scrollView.delegate = self
                self.wkwebView.scrollView.bounces = false
                print("wkwebView scrollview content Size1   ",self.wkwebView.scrollView.contentSize)
                self.view.bringSubviewToFront(self.backButton)
            }else {
                let alert = UIAlertView(title: "", message: self.appdelegate.ment["toast_msg_not_exists_tag"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                alert.show()
            }
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            backTo()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        print("tag view frame       ",self.view.frame)
        print("wkwebView scrollview content Size   ",self.wkwebView.scrollView.contentSize)
        print(self.view.bounds)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backTo(){
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
        if self.appdelegate.myfeed.view.hidden == false {
            self.navigationController?.navigationBarHidden = true
        }
        
//        self.appdelegate.controller.removeAtIndex(a.index)
        self.appdelegate.tabbar.view.hidden = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func back(sender: AnyObject) {
        backTo()
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    func scrollViewDidScroll(webView : UIScrollView) {
        if webView.contentOffset.y > 150 {
            self.backButton.hidden = true
        }else {
            self.backButton.hidden = false
        }
    }

}
