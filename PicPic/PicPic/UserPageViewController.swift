//
//  UserPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 6..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import WebKit

class UserPageViewController: SubViewController,UIScrollViewDelegate{

    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var backButton: UIButton!
    var myId : String!
    var userId : String!
    let log = LogPrint()
    @IBOutlet weak var moreButton: UIButton!
    var statusbar : UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        let titleImage = UIImage(named: "imv_timeline_logo")
        self.navigationItem.titleView = UIImageView(image: titleImage)
        
        if myId == userId {
            moreButton.hidden = true
        }
        
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        self.statusbar = UIView()
        self.statusbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 20)
        self.statusbar.backgroundColor = UIColor(netHex: 0x484848)
        self.view.addSubview(statusbar)
        
        self.wkwebView = WKWebView(frame: CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height))
        self.view.addSubview(wkwebView)
        self.urlPath = self.servicePath+language+"user.jsp"
        self.jScript = String(format:"fire('%@','%@')", arguments : [myId,userId])
        self.wkwebView.scrollView.delegate = self
        webViewLoad()
        self.view.bringSubviewToFront(backButton)
        self.view.bringSubviewToFront(self.moreButton)
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
        log.log("1 \(self.navigationController?.viewControllers)")
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        
        if a.type == "post" {
            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
            post.postImage.enterForeground()
        }
        log.log("2")
        if a.type == "tag_name" || a.type == "post" || a.type == "user" || a.type == "search"{
            self.navigationController?.navigationBarHidden = true
        }else {
            self.navigationController?.navigationBarHidden = false
        }
        log.log("3")
//        log.log("a.index \(a.index)")
//        self.appdelegate.controller.removeAtIndex(a.index)
        self.navigationController?.popViewControllerAnimated(true)
        log.log("4 \(self.navigationController?.viewControllers)")
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
    
    @IBAction func more(sender: AnyObject) {
        let count = appdelegate.testNavi.viewControllers.count - 1
        let moreother = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MoreOtherViewController")as! MoreOtherViewController
        moreother.post_id = userId
        appdelegate.testNavi.viewControllers[count].addChildViewController(moreother)
        appdelegate.testNavi.viewControllers[count].view.addSubview(moreother.view)
    }
    
    @IBAction func backToTimeLine(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
