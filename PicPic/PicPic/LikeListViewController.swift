//
//  LikeListViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 27..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import WebKit

class LikeListViewController: SubViewController ,UIScrollViewDelegate {

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var email : String!
    var tagId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        
        self.wkwebView = WKWebView(frame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        wkwebView.scrollView.delegate = self
        self.view.addSubview(self.wkwebView)
        self.urlPath = self.servicePath+language+"like.jsp"
        self.jScript = String(format:"fire('%@','%@')", arguments : [email,tagId])
        webViewLoad()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = self.appdelegate.ment["timeline_like_user"].stringValue
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        super.viewDidAppear(animated)
    }
    
    
    func backToMyFeed(){
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search" {
            self.navigationController?.navigationBarHidden = true
        }else {
            self.navigationController?.navigationBarHidden = false
        }
        self.appdelegate.tabbar.view.hidden = false
        if !self.appdelegate.myfeed.view.hidden {
            self.navigationController?.navigationBarHidden = true
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
