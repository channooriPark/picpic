//
//  MyFeedPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 8..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import WebKit

class MyFeedPageViewController: SubViewController,UIScrollViewDelegate {
    
    var email : String!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var statusbar : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        if let email = self.appdelegate.email {
            self.email = email
        }
        
        
        self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-70)
        self.statusbar = UIView()
        self.statusbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 20)
        self.statusbar.backgroundColor = UIColor(netHex: 0x484848)
        self.view.addSubview(statusbar)
        self.wkwebView = WKWebView(frame: CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height))
        self.wkwebView.scrollView.delegate = self
//        self.view.addSubview(wkwebView)
        self.urlPath = self.servicePath+language+"user.jsp"
        self.jScript = String(format:"fire('%@','%@')", arguments : [email,email])
        wkwebView.scrollView.bounces = false
        webViewLoad()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    
    func fire() {
        self.urlPath = self.servicePath+language+"user.jsp"
        self.jScript = String(format:"fire('%@','%@')", arguments : [email,email])
        webViewLoad()
    }

}
