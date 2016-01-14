//
//  IntroMainViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 8..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class IntroMainViewController: UIViewController,UIPageViewControllerDataSource {
    @IBOutlet weak var pagecontrolDot: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var pageImages:NSArray!
    var gifImages:NSArray!
    var coment:NSArray!
    var pageViewController:UIPageViewController!
    var navigation:UINavigationController!
    let log = LogPrint()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        
        pagecontrolDot.tintColor = UIColor.lightGrayColor()
        pagecontrolDot.currentPageIndicatorTintColor = UIColor.whiteColor()
        nextButton.hidden = true

        pageImages = NSArray(objects: "bg_tutorial_1","bg_tutorial_2","bg_tutorial_3","bg_tutorial_4","bg_tutorial_5")
        gifImages = NSArray(objects: "tuto_1","tuto_2","tuto_3","tuto_4_kr","tuto_5")
        coment = NSArray(objects: "\(self.appdelegate.ment["tutorial_ment_1"].string!)","\(self.appdelegate.ment["tutorial_ment_2"].string!)","\(self.appdelegate.ment["tutorial_ment_3"].string!)","\(self.appdelegate.ment["tutorial_ment_4"].string!)","\(self.appdelegate.ment["tutorial_ment_5"].string!)")
        
        self.pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        
        self.pageViewController.dataSource = self
        
        let initialContentViewController = self.pageTutorialAtIndex(0) as TutorialViewController
        
        let viewControllers = NSArray(object: initialContentViewController)
        
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+37)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        self.view.bringSubviewToFront(self.pagecontrolDot)
        self.view.bringSubviewToFront(self.skipButton)
        self.view.bringSubviewToFront(self.nextButton)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.sharedApplication().statusBarStyle = .Default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageTutorialAtIndex(index:Int) ->TutorialViewController {
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController")as! TutorialViewController
        
        pageContentViewController.imageFileName = pageImages[index]as! String
        pageContentViewController.gifFileName = gifImages[index]as! String
        pageContentViewController.comentText = coment[index]as! String
        pageContentViewController.pageIndex = index
        
        return pageContentViewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        
        let viewController = viewController as! TutorialViewController
        var index = viewController.pageIndex as Int
        self.pagecontrolDot.currentPage = index
        print("gif Image Width",viewController.gifImage.frame)
        if index < pageImages.count {
            self.nextButton.hidden = true
        }
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        index--
        
        return self.pageTutorialAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        let viewController = viewController as! TutorialViewController
        var index = viewController.pageIndex as Int
        self.pagecontrolDot.currentPage = index
        print("gif Image Width",viewController.gifImage.frame)
        if index == NSNotFound {
            return nil
        }
        index++
        
        if index == pageImages.count {
            self.nextButton.hidden = false
            return nil
        }
        
        return self.pageTutorialAtIndex(index)
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int{
        let page : Int! = pageImages.count
        self.pagecontrolDot.numberOfPages = page
        return pageImages.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int{
        return 0
    }

    
    @IBAction func skipBUtton(sender: AnyObject) {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appdelegate.standardUserDefaults.objectForKey("tutorial") == nil {
            appdelegate.standardUserDefaults.setBool(true, forKey: "tutorial")
        }
        
        appdelegate.window?.rootViewController = self.appdelegate.signin
    }
    
    @IBAction func GoToLogin(sender: AnyObject) {
        skipBUtton(sender)
    }


}
