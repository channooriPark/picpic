//
//  CategoryViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 12. 8..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class CategoryViewController: SubViewController , UIWebViewDelegate, UIScrollViewDelegate{

    var category_num : String!
    var email : String!
    var categorytitle : String = ""
    var refresh : UIRefreshControl!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = categorytitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        
        self.wkwebView = WKWebView(frame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.wkwebView.scrollView.delegate = self
        self.view.addSubview(self.wkwebView)
        self.refresh = UIRefreshControl()
        self.refresh.attributedTitle = NSAttributedString(string: "")
        self.refresh.addTarget(self, action: Selector("loadFeeds"), forControlEvents: UIControlEvents.ValueChanged)
        self.wkwebView.scrollView.addSubview(self.refresh)
        self.urlPath = self.servicePath+language+"list_by_tag.jsp"
        self.jScript = String(format:"fire('%@','%@')", arguments : [email,category_num])
        self.wkwebView.scrollView.addSubview(self.refresh)
        webViewLoad()
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    func loadFeeds(){
        // 기타작업 후 종료
        wkwebView.reload()
        self.refresh.endRefreshing()
    }
    
    func backToMyFeed(){
        var count = self.appdelegate.testNavi.viewControllers.count-2
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.appdelegate.testNavi.viewControllers[count] as! SubViewController
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search" || a.type == "tag_name" {
            self.appdelegate.testNavi.navigationBarHidden = true
        }else {
            self.appdelegate.testNavi.navigationBarHidden = false
        }
        self.appdelegate.tabbar.view.hidden = false
        if !self.appdelegate.myfeed.view.hidden {
            self.appdelegate.testNavi.navigationBarHidden = true
        }
        
        self.appdelegate.testNavi.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            backTo()
        }
    }
    
    func backTo(){
        var count = self.appdelegate.testNavi.viewControllers.count-2
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.appdelegate.testNavi.viewControllers[count] as! SubViewController
        
        if a.type == "post" {
            let post = self.appdelegate.testNavi.viewControllers[count]as! PostPageViewController
            post.postImage.enterForeground()
        }
        
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search"{
            self.appdelegate.testNavi.navigationBarHidden = true
        }else {
            self.appdelegate.testNavi.navigationBarHidden = false
        }
        if self.appdelegate.myfeed.view.hidden == false {
            self.appdelegate.testNavi.navigationBarHidden = true
        }
        
//        self.appdelegate.controller.removeAtIndex(a.index)
        self.appdelegate.tabbar.view.hidden = false
        self.appdelegate.testNavi.popViewControllerAnimated(true)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("aaaaa")
        wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    @IBAction func back(sender: AnyObject) {
        //        NSLog("\(self.navigationController?.viewControllers)")
        backTo()
        
    }
}
