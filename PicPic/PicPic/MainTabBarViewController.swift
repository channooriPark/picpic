//
//  MainTabBarViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 6..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        print("1")
        self.appdelegate.navi = self.selectedViewController as! UINavigationController
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print("item :",item.tag)
        print("selected Index : ",self.selectedIndex)
        
        
    }

}
