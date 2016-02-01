//
//  ServiceViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 4..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class ServiceViewController: UIViewController ,UIWebViewDelegate{

    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.appdelegate.ment["settings_program_info_service_agreement"].stringValue        
        var fileName : String = ""
        if appdelegate.locale == "ko_KR" {
            fileName = "text/ko/service_agreement"
        }else {
            fileName = "text/en/service_agreement"
        }
        let urlpath = NSBundle.mainBundle().pathForResource(fileName, ofType: "htm")
        let url = NSURL (string:urlpath!)
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
//        webView.frame.size = CGSize(width: self.view.frame.size.width, height: webView.scrollView.contentSize.height)
//        webView.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: webView.scrollView.contentSize.height)
        webView.frame.size = CGSize(width: 200, height: webView.scrollView.contentSize.height)
        webView.scrollView.contentSize = CGSize(width: 200, height: webView.scrollView.contentSize.height)
        print("webView content Size ",webView.scrollView.contentSize)
        print("webView frame   :  ",webView.frame)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.scrollView.contentSize = CGSize(width: webView.frame.size.width, height: webView.scrollView.contentSize.height)
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
