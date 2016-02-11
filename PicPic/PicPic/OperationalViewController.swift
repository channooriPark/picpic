//
//  OperationalViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 4..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class OperationalViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title =  self.appdelegate.ment["settings_program_info_operational_policy"].stringValue
        var fileName : String = ""
        if appdelegate.locale == "ko_KR" {
            fileName = "text/ko/operational_policy"
        }else {
            fileName = "text/en/operational_policy"
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

}
