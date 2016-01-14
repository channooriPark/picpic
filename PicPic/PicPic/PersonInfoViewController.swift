//
//  PersonInfoViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 4..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class PersonInfoViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
