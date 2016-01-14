//
//  MainInterViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 8..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import WebKit

class MainInterViewController: SubViewController , UIScrollViewDelegate{

//    var webView : UIWebView!
    var email : String!
    var refresh : UIRefreshControl!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if let email = appdelegate.email {
            self.email = email
        }else {
            self.email = ""
        }
        self.view.frame = CGRectMake(0, 32, self.view.bounds.size.width, self.view.bounds.size.height-114)
        self.wkwebView = WKWebView(frame:CGRectMake(0, 32, self.view.bounds.size.width, self.view.bounds.size.height))
        self.wkwebView.scrollView.delegate = self
        
        var language : String = ""
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        self.urlPath = self.servicePath+language+"main.jsp"
        self.jScript = String(format:"fire('%@')", arguments : [email])
        wkwebView.scrollView.bounces = false
        webViewLoad()
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    func loadFeeds(){
        // 기타작업 후 종료
        fire()
        self.refresh.endRefreshing()
    }
    
    func fire(){
        self.urlPath = self.servicePath+language+"main.jsp"
        self.jScript = String(format:"fire('%@')", arguments : [email])
        wkwebView.scrollView.bounces = false
        webViewLoad()
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    
}
