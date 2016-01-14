//
//  ContentViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 8..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class ContentViewController: SubViewController {
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let titleImage = UIImage(named: "imv_timeline_logo")
        let titleImageView = UIImageView(image: titleImage)
        let tap = UITapGestureRecognizer(target: self, action: Selector("refresh"))
        tap.numberOfTapsRequired = 1
        titleImageView.addGestureRecognizer(tap)
        self.navigationItem.titleView = titleImageView
        self.navigationController?.navigationBar.addGestureRecognizer(tap)
        
        self.addChildViewController(appdelegate.tabbar)
        self.addChildViewController(appdelegate.main)
        self.addChildViewController(appdelegate.second)
        self.addChildViewController(appdelegate.alram)
        self.addChildViewController(appdelegate.myfeed)

        self.view.addSubview(appdelegate.tabbar.view)
        self.view.addSubview(appdelegate.main.view)
        self.view.addSubview(appdelegate.second.view)
        self.view.addSubview(appdelegate.alram.view)
        self.view.addSubview(appdelegate.myfeed.view)
        
        if self.appdelegate.notiType == 0 {
            appdelegate.second.view.hidden = true
            appdelegate.alram.view.hidden = true
            appdelegate.myfeed.view.hidden = true
        }else {
            appdelegate.second.view.hidden = true
            appdelegate.main.view.hidden = true
            appdelegate.myfeed.view.hidden = true
            appdelegate.tabbar.click4(appdelegate.tabbar.button4)
        }
        
        print("contentView Controller")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.type = "content"
    }
    
    func refresh() {
        print("refresh()")
        if appdelegate.main.view.hidden == false {
            appdelegate.main.wkwebView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }else if appdelegate.second.view.hidden == false {
            appdelegate.second.wkwebView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            if appdelegate.second.followT {
                appdelegate.second.following()
            }else if appdelegate.second.allT {
                appdelegate.second.all()
            }
        }
    }
    
    
    @IBAction func search(sender:UIBarButtonItem){
        let search = self.storyboard?.instantiateViewControllerWithIdentifier("SearchPageViewController")as! SearchPageViewController
        self.appdelegate.controller.append(search)
//        search.index = self.appdelegate.controller.count - 1
        search.type = "search"
        self.appdelegate.testNavi.pushViewController(search, animated: true)
        self.appdelegate.testNavi.navigationBarHidden = true
        self.appdelegate.tabbar.view.hidden = true
    }
}

extension UIView {
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion:((Bool) -> Void) = {(finished: Bool) ->Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: { () -> Void in
            self.alpha = 1.0
            }, completion: completion)
//        print("fadeIn")
    }
    
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion:((Bool) -> Void) = {(finished: Bool) ->Void in}){
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: { () -> Void in
            self.alpha = 0.0
            }, completion: completion)
//        print("fadeOut")
    }
}