//
//  NoticsViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 6..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class NoticsViewController: SubViewController{

    var email : String!
    var locale : String!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.appdelegate.ment["settings_notice"].stringValue
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        self.wkwebView = WKWebView(frame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.view.addSubview(self.wkwebView)
        self.email = self.appdelegate.email
        self.locale = self.appdelegate.userData["country"].string!
        if appdelegate.locale == "ko_KR" {
        }else {
            language = "en_"
        }
        
        self.urlPath = self.servicePath+language+"notice.jsp"
        self.jScript = String(format:"fire('%@','%@')", arguments : [email,locale])
        webViewLoad()
        
    }
    
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webViewDidFinishLoad(webView: UIWebView) {
        //println(__FUNCTION__);
//        print("fire('\(email)','\(locale)')")
        webView.stringByEvaluatingJavaScriptFromString("fire('\(email)','\(locale)')")
    }
    
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        //println(__FUNCTION__);
        
        //print(request.URL?.scheme);
        
        // http 링크는 브라우저로 연결, 그외 내부 file과 picpic은 접근, 기타는 false로 막음.
        if(request.URL?.scheme == "http" || request.URL?.scheme == "https") {
            UIApplication.sharedApplication().openURL(request.URL!)
        } else if(request.URL?.scheme == "file") {
            return true;
        } else if(request.URL?.scheme == "picpic") {
            return true;
        }
        return false;
    }

}
