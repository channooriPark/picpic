//
//  SearchPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 6..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import WebKit

class SearchPageViewController: SubViewController, UIScrollViewDelegate {

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    @IBOutlet weak var webView: UIWebView!
    var email : String!
    @IBOutlet weak var backButton: UIButton!
    let log = LogPrint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        let view = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        view.backgroundColor = UIColor(netHex: 0x484848)
        self.view.addSubview(view)
        
        
        
        self.email = self.appdelegate.email
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        log.log("before view frame : \(self.view.frame)")
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        self.wkwebView = WKWebView(frame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20))
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        wkwebView.addGestureRecognizer(tap)
        
        wkwebView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        self.wkwebView.scrollView.delegate = self
//        self.wkwebView = WKWebView(frame:CGRectMake(0, 0, self.view.frame.size.width, 100))
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        self.urlPath = self.servicePath+language+"search.jsp"
        self.jScript = String(format:"fire('%@')", arguments : [email])
        wkwebView.scrollView.bounces = false
        webViewLoad()
        self.view.bringSubviewToFront(self.backButton)
        log.log("application frame \(self.appdelegate.window?.screen.applicationFrame)")
        log.log("view frame : \(self.view.frame)")
        log.log("wkwebview frame : \(self.wkwebView.frame)")
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("aaaaa")
        wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    func keyboardWillShow(sender: NSNotification) {
        log.log("keyboard show")
        var size = sender.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size

        let userInfo = sender.userInfo
        let duration = userInfo![UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        let curve = userInfo![UIKeyboardAnimationCurveUserInfoKey]?.integerValue
        var rectsize = userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        rectsize = self.view.convertRect(rectsize, fromView: nil)
        
        let newHeight = self.view.frame.size.height - (size?.height)! - 10
        self.wkwebView.frame = CGRectMake(0, 20, self.view.frame.size.width, newHeight-20)
        
        print("frame ",self.view.frame)
        print("self.wkwebView.frame ",self.wkwebView.frame)
        UIView.animateWithDuration(duration!, delay: 0.0, options: .CurveEaseOut, animations: {

            //self.wkwebView.scrollView.contentInset = UIEdgeInsetsMake((size?.height)!, 0, (size?.height)!, 0)
            
            //self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, newHeight)
            
            
            //self.wkwebView.scrollView.scrollEnabled = false
            //self.wkwebView.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, newHeight)
//            self.wkwebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            
            
            }, completion: { finished in
//                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, newHeight)
//                self.wkwebView.frame = CGRectMake(0, 20, self.view.frame.size.width, newHeight-20)
//                self.wkwebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                print("Basket doors opened!")
                
        
                
        })
        
        
        log.log("contentSize \(wkwebView.scrollView.contentSize)")
        log.log("wkwebView \(wkwebView.frame)")
        log.log("view \(self.view.frame)")
        log.log("origizal \(self.view.frame.origin.y)")
        log.log("keyboard size  \(size)")
    }
    
    func keyboardWillHide(sender: NSNotification) {
        log.log("keyboard hide")
        let size = sender.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size
        
        let newHeight = self.view.frame.size.height + (size?.height)! + 10
        //self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, newHeight)
        self.wkwebView.frame = CGRectMake(0, 20, self.view.frame.size.width, newHeight-20)
//        self.wkwebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        print("frame ",self.view.frame)
        print("self.wkwebView.frame ",self.wkwebView.frame)
        log.log("contentSize \(wkwebView.scrollView.contentSize)")
        log.log("\(wkwebView.frame)")
        log.log("view \(self.view.frame)")
        log.log("origizal \(self.view.frame.origin.y)")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    deinit {
        wkwebView.scrollView.delegate = nil
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.appdelegate.testNavi.navigationBarHidden = true
//        self.appdelegate.tabbar.view.hidden = true
        super.viewDidAppear(animated)
    }
    
    func scrollViewDidScroll(webView : UIScrollView) {
//        if webView.contentOffset.y > 120 {
//            self.backButton.hidden = true
//        }else {
//            self.backButton.hidden = false
//        }
        
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func back(sender: AnyObject) {
        self.appdelegate.tabbar.view.hidden = false
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
