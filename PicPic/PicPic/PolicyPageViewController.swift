//
//  PolicyPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 16..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class PolicyPageViewController: UIViewController {

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleImage = UIImage(named: "imv_timeline_logo")
        self.navigationItem.titleView = UIImageView(image: titleImage)
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
//        image.image = UIImage(named: "x_c")
//        let backButton = UIBarButtonItem(customView: image)
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
//        image.addGestureRecognizer(tap)
//        self.navigationItem.leftBarButtonItem = backButton
        
        self.navigationItem.title = self.appdelegate.ment["settings_program_info_privacy_policy"].stringValue
        var fileName : String = ""
        if appdelegate.locale == "ko_KR" {
            fileName = "text/ko/privacy_policy"
        }else {
            fileName = "text/en/privacy_policy"
        }
        var urlpath = NSBundle.mainBundle().pathForResource(fileName, ofType: "htm")
        var url = NSURL (string:urlpath!)
        var requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backToMyFeed() {
        
    }
    
    @IBAction func back(sender: AnyObject) {
        self.appdelegate.testNavi.navigationBarHidden = true
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
