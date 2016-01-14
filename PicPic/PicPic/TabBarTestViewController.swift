//
//  TabBarTestViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 8..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class TabBarTestViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var button1 : UIButton!
    var button2 : UIButton!
    var button3 : UIButton!
    var button4 : UIButton!
    var button5 : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, self.view.bounds.size.height)
        self.view.backgroundColor = UIColor.blackColor()
        
//        print(self.view.bounds.size.width/5)
        let iconWid = self.view.bounds.size.width/5
        
        button1 = UIButton(type: .Custom)
        button1.frame = CGRectMake(0, 0, iconWid, 50)
        button1.setImage(UIImage(named: "home_c"), forState: .Normal)
        button1.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button1.addTarget(self, action: Selector("click:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(button1)
        
        
        button2 = UIButton(type: .Custom)
        button2.frame = CGRectMake(iconWid, 0, iconWid, 50)
        button2.setImage(UIImage(named: "feed"), forState: .Normal)
        button2.setImage(UIImage(named: "feed_c"), forState: .Highlighted)
        button2.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button2.addTarget(self, action: Selector("click2:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(button2)
        
        button3 = UIButton(type: .Custom)
        button3.frame = CGRectMake(iconWid*2, 0, iconWid, 50)
        let image = UIImage(named: "icon_timeline_camera")
        button3.setImage(UIImage(named: "icon_timeline_camera"), forState: .Normal)
        button3.setImage(UIImage(named: "icon_timeline_camera_c"), forState: .Highlighted)
        button3.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button3.addTarget(self, action: Selector("click3:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(button3)
        
        
        button4 = UIButton(type: .Custom)
        button4.frame = CGRectMake(iconWid*3, 0, iconWid, 50)
        button4.setImage(UIImage(named: "alram"), forState: .Normal)
        button4.setImage(UIImage(named: "alram_c"), forState: .Highlighted)
        button4.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button4.addTarget(self, action: Selector("click4:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(button4)
        
        button5 = UIButton(type: .Custom)
        button5.frame = CGRectMake(iconWid*4, 0, iconWid, 50)
        button5.setImage(UIImage(named: "user"), forState: .Normal)
        button5.setImage(UIImage(named: "user_c"), forState: .Highlighted)
        button5.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button5.addTarget(self, action: Selector("click5:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(button5)
    }
    
    
    
    
    @IBAction func click(sender: UIButton!){
        appdelegate.tabbar.view.hidden = false
        appdelegate.main.view.hidden = false
        appdelegate.second.view.hidden = true
        appdelegate.alram.view.hidden = true
        appdelegate.myfeed.view.hidden = true
        appdelegate.testNavi.navigationBarHidden = false
        appdelegate.main.fire()
        
        button1.setImage(UIImage(named: "home_c"), forState: .Normal)
        button2.setImage(UIImage(named: "feed"), forState: .Normal)
        button4.setImage(UIImage(named: "alram"), forState: .Normal)
        button5.setImage(UIImage(named: "user"), forState: .Normal)
    }
    
    @IBAction func click2(sender: UIButton!){
        appdelegate.tabbar.view.hidden = false
        appdelegate.second.view.hidden = false
        appdelegate.main.view.hidden = true
        appdelegate.alram.view.hidden = true
        appdelegate.myfeed.view.hidden = true 
        appdelegate.testNavi.navigationBarHidden = false
        appdelegate.second.fire()
        
        button1.setImage(UIImage(named: "home"), forState: .Normal)
        button2.setImage(UIImage(named: "feed_c"), forState: .Normal)
        button4.setImage(UIImage(named: "alram"), forState: .Normal)
        button5.setImage(UIImage(named: "user"), forState: .Normal)
    }
    @IBAction func click3(sender: UIButton!){
        self.tabBarController?.tabBar.hidden = true
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let cameraVC = self.appdelegate.camera
            self.appdelegate.testNavi.navigationBarHidden = true
            self.navigationController?.pushViewController(cameraVC!, animated: true)
        }
        else {
        }
    }
    
    @IBAction func click4(sender: UIButton!){
        appdelegate.alram.view.hidden = false
        appdelegate.main.view.hidden = true
        appdelegate.second.view.hidden = true
        appdelegate.myfeed.view.hidden = true
        appdelegate.tabbar.view.hidden = false
        appdelegate.testNavi.navigationBarHidden = false
        
        appdelegate.alram.alarmtableview.reloadData()
        
        button1.setImage(UIImage(named: "home"), forState: .Normal)
        button2.setImage(UIImage(named: "feed"), forState: .Normal)
        button4.setImage(UIImage(named: "alram_c"), forState: .Normal)
        button5.setImage(UIImage(named: "user"), forState: .Normal)
        
    }
    
    @IBAction func click5(sender: UIButton!){
        
        appdelegate.tabbar.view.hidden = false
        appdelegate.alram.view.hidden = true
        appdelegate.main.view.hidden = true
        appdelegate.second.view.hidden = true
        appdelegate.myfeed.view.hidden = false
        appdelegate.testNavi.navigationBarHidden = true
        appdelegate.myfeed.fire()
        
        button1.setImage(UIImage(named: "home"), forState: .Normal)
        button2.setImage(UIImage(named: "feed"), forState: .Normal)
        button4.setImage(UIImage(named: "alram"), forState: .Normal)
        button5.setImage(UIImage(named: "user_c"), forState: .Normal)
    }
    
}

