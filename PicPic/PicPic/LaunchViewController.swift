//
//  LaunchViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 12. 15..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoHei: NSLayoutConstraint!
    @IBOutlet weak var logoWid: NSLayoutConstraint!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var type : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("launchViewController")
        if self.view.frame.size.width == 320.0 {
            logoWid.constant = 159
            logoHei.constant = 46
        }else if self.view.frame.size.width == 375.0{
            logoWid.constant = 170
            logoHei.constant = 49
            
        }else {
            logoWid.constant = 190
            logoHei.constant = 59
        }
        
        
        print("",logoImage.frame)
        print("",logoHei.constant)
        print("",logoWid.constant)
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("moveFirstView"), userInfo: nil, repeats: false)
    }
    
    func moveFirstView() {
        if type == "first" {
            let firstView = self.storyboard?.instantiateViewControllerWithIdentifier("FirstViewController")as! FirstViewController
            self.appdelegate.window?.rootViewController = firstView
        }else if type == "intro" {
            let intro = self.storyboard?.instantiateViewControllerWithIdentifier("IntroMainViewController")as! IntroMainViewController
            self.appdelegate.window?.rootViewController = intro
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
}
