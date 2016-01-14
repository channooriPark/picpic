//
//  TagViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 6..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import WebKit

class TagViewController: SubViewController ,UIScrollViewDelegate{

    @IBOutlet weak var backButton: UIButton!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var email : String!
    var tagId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.backButton.hidden = false
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        self.wkwebView = WKWebView(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.view.addSubview(self.wkwebView)
        self.jScript = String(format:"fire('%@','%@')", arguments : [email,tagId])
        self.view.bringSubviewToFront(self.backButton)
        self.wkwebView.scrollView.delegate = self
        webViewLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func back(sender: AnyObject) {
//        NSLog("\(self.navigationController?.viewControllers)")
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
//        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
//        print(a)
//        NSLog("",a.type)
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search"{
            self.navigationController?.navigationBarHidden = true
        }else {
            self.navigationController?.navigationBarHidden = false
        }
//        self.appdelegate.controller.removeAtIndex(a.index)
        self.appdelegate.tabbar.view.hidden = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("aaaaa")
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
