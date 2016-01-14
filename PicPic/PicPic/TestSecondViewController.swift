//
//  TestSecondViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 8..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import WebKit

class TestSecondViewController: SubViewController , UIScrollViewDelegate{

//    var webView : UIWebView!
    var email : String!
    var refresh : UIRefreshControl!
    var followingButton : UIButton!
    var allButton : UIButton!
    var categoryButton:UIButton!
    
    var followselec : UIImageView!
    var allselec : UIImageView!
    var categoryselec : UIImageView!
    var lineView : UIView!
    
    var followT = true
    var allT = false
    var categoryT = false
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let log = LogPrint()
    var webState = ""
    var currentPoint:CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        self.type = "timeline"
        if let email = appdelegate.email {
            self.email = appdelegate.email
        }else {
            self.email = ""
        }
        
        self.view.frame = CGRectMake(0, 32, self.view.bounds.size.width, self.view.bounds.size.height-158)
        if self.view.frame.size.width == 320.0 || self.view.frame.size.width == 375.0 {
            self.wkwebView = WKWebView(frame:CGRectMake(0, 76.5, self.view.frame.size.width, self.view.frame.size.height))
        }else {
            self.wkwebView = WKWebView(frame:CGRectMake(0, 76, self.view.frame.size.width, self.view.frame.size.height))
        }
        self.wkwebView.scrollView.delegate = self
        
        log.log("\(self.view.frame)")
        log.log("\(UIScreen.mainScreen().bounds.width)")
        self.lineView = UIView()
        if self.view.frame.size.width == 320.0 {
            log.log("iPhone6")
            lineView.frame = CGRectMake(0, 76, self.view.frame.size.width, 0.5)
        }else {
            log.log("iPhone6+")
            lineView.frame = CGRectMake(0, 76, self.view.frame.size.width, 1)
            log.log("\(lineView.frame)")
        }
        
        
        
        lineView.backgroundColor = UIColor(netHex: 0xdedede)
        self.view.addSubview(lineView)
//        self.wkwebView.scrollView.delegate = self
//        self.view.addSubview(self.wkwebView)
        
        let width = self.view.frame.size.width/3
        followingButton = UIButton(type: .Custom)
        followingButton.frame = CGRectMake(width*0, 32, width, 44)
        followingButton.setTitle(self.appdelegate.ment["timeline_following"].stringValue, forState: .Normal)
        followingButton.backgroundColor = UIColor.whiteColor()
//        followingButton.setBackgroundImage(<#T##image: UIImage?##UIImage?#>, forState: <#T##UIControlState#>)
        followingButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        followingButton.addTarget(self, action: "following", forControlEvents: .TouchUpInside)
        followselec = UIImageView()
        followselec.image = UIImage(named: "imv_find_selectbar")
        followselec.frame = CGRectMake(width*0, 73, width, 3)
        self.view.addSubview(followingButton)
        self.view.addSubview(followselec)
        
        
        allButton = UIButton(type: .Custom)
        allButton.frame = CGRectMake(width*1, 32, width, 44)
        allButton.setTitle(self.appdelegate.ment["timeline_all"].stringValue, forState: .Normal)
        allButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        allButton.backgroundColor = UIColor.whiteColor()
        allButton.addTarget(self, action: "all", forControlEvents: .TouchUpInside)
        allselec = UIImageView()
        allselec.image = UIImage()
        allselec.frame = CGRectMake(width*1, 73, width, 3)
        self.view.addSubview(allButton)
        self.view.addSubview(allselec)
        
        
        categoryButton = UIButton(type: .Custom)
        categoryButton.frame = CGRectMake(width*2, 32, width, 44)
        categoryButton.setTitle(self.appdelegate.ment["timeline_category"].stringValue, forState: .Normal)
        categoryButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        categoryButton.backgroundColor = UIColor.whiteColor()
        categoryButton.addTarget(self, action: "category", forControlEvents: .TouchUpInside)
        categoryselec = UIImageView()
        categoryselec.image = UIImage()
        categoryselec.frame = CGRectMake(width*2, 73, width, 3)
        self.view.addSubview(categoryButton)
        self.view.addSubview(categoryselec)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        followingButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        allButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        categoryButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        followingButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 15)
        allButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        categoryButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        
        self.view.bringSubviewToFront(followingButton)
        self.view.bringSubviewToFront(allButton)
        self.view.bringSubviewToFront(categoryButton)
        self.view.bringSubviewToFront(followselec)
        self.view.bringSubviewToFront(allselec)
        self.view.bringSubviewToFront(categoryselec)
        log.log("subViews : \(self.view.subviews)")
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
            if (sender.direction == .Left) {
                if followT {
                    all()
                }else if allT {
                    category()
                }
            }
            
            if (sender.direction == .Right) {
                if categoryT {
                    all()
                }else if allT {
                    following()
                }
            }
    }
    
    func loadFeeds(){
        // 기타작업 후 종료
        fire()
        self.refresh.endRefreshing()
    }
    
    func following(){
        webState = "follow"
        followselec.image = UIImage(named: "imv_find_selectbar")
        allselec.image = UIImage()
        categoryselec.image = UIImage()
        followT = true
        allT = false
        categoryT = false
        
        followingButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        allButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        categoryButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        followingButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
        allButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        categoryButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        
        self.urlPath = self.servicePath+language+"list_by_follow.jsp"
        self.jScript = String(format:"fire('%@')", arguments : [email])
        self.wkwebView.scrollView.bounces = false
        webViewLoad()
    }
    
    func all(){
        webState = "all"
        followselec.image = UIImage()
        allselec.image = UIImage(named: "imv_find_selectbar")
        categoryselec.image = UIImage()
        followT = false
        allT = true
        categoryT = false
        followingButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        allButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        categoryButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        followingButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        allButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
        categoryButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        
        
        self.urlPath = self.servicePath+language+"list_by_all.jsp"
        self.jScript = String(format:"fire('%@')", arguments : [email])
        wkwebView.scrollView.bounces = false
        webViewLoad()
    }
    
    func category(){
        webState = "category"
        followselec.image = UIImage()
        allselec.image = UIImage()
        categoryselec.image = UIImage(named: "imv_find_selectbar")
        followT = false
        allT = false
        categoryT = true
        followingButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        allButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        categoryButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        followingButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        allButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        categoryButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
        
        self.wkwebView.scrollView.bounces = false
        self.urlPath = self.servicePath+language+"category.html"
        webViewLoad()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    func fire() {
        following()
    }
}
