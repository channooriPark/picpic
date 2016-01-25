//
//  MyWebKit.swift
//  webkitTest
//
//  Created by byKim on 2015. 12. 9..
//  Copyright © 2015년 byKim. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

class MyWebKit : UIViewController, WKNavigationDelegate, WKUIDelegate{
    
    var language:String = ""
    var servicePath:String = "https://ios.picpic.world/_app3/"; //"https://192.168.1.128:8443/_app2/";
    var wkwebView: WKWebView!
    var urlPath:String!
    var jScript:String!
    
    var send_id:NSString!
    
    
    
    func webViewLoad() {
        wkwebView.navigationDelegate = self
        wkwebView.UIDelegate = self
        
        if #available(iOS 9.0, *) {
//            print(wkwebView.customUserAgent)
        } else {
            // Fallback on earlier versions
        }
        
        
        if #available(iOS 9.0, *) {
            let ua = String(format: "%@_%@", arguments:[NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String,NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String])
            wkwebView.customUserAgent = ua
        } else {
            // Fallback on earlier versions
        }
        
        let request = NSMutableURLRequest(URL:NSURL(string: urlPath)!)
        wkwebView!.loadRequest(request)
        self.view.addSubview(wkwebView)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if(jScript != nil ) {
//            print(jScript)
            webView.evaluateJavaScript(jScript) { (result, error) in
                if error != nil {
                    print("error ",error)
                }
            }
        }
    }
    
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.URL
//        print(url)
        
        
        if(url!.scheme == "http" || url!.scheme == "https") {
            if(url!.host == "ios.picpic.world" || url!.host == "192.168.1.128") {
                decisionHandler(WKNavigationActionPolicy.Allow)
            } else {
                UIApplication.sharedApplication().openURL(url!)
            }
        } else if(url!.scheme == "file") {
            decisionHandler(WKNavigationActionPolicy.Cancel)
        } else if(url!.scheme == "picpic") {
            decisionHandler(WKNavigationActionPolicy.Allow)
//            print("host : ",url?.host)
            openPage(url!)
        } else {
            decisionHandler(WKNavigationActionPolicy.Cancel)
        }
    }
    
    
    
    
    
    var moreToggle = false
    func openPage(url:NSURL){
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let log = LogPrint()
        send_id = url.path
        
        log.log("url : \(url)")
        var act:String = url.host!
        if send_id.length > 0 {
            send_id = send_id.substringFromIndex(1)
        }
        if url.host == "kakaolink" {
            let urlString:String = String(url)
            var urlStringArr = urlString.componentsSeparatedByString("?")
            urlStringArr = urlStringArr[1].componentsSeparatedByString("=")
            act = urlStringArr[0]
            send_id = urlStringArr[1]
        }
        log.log("send_id                    \(send_id)")
        
        var message : JSON!
        
        switch(act) {
            // view controller 호출
            
        case "share_sns":
            log.log("share_sns  \(send_id)")
            let para = send_id.componentsSeparatedByString("/")
            let count = appdelegate.testNavi.viewControllers.count - 1
            //            message = ["my_id":self.email,"post_id":send_id]
            //            let connection = URLConnection(serviceCode: 504, message: message)
            //            let readData = connection.connection()
            let share = appdelegate.storyboard.instantiateViewControllerWithIdentifier("ShareViewController")as! ShareViewController
            share.post_id = para[0]
            share.url = para[4]
            if para[5] == "Y" {
                share.repicState = true
            }else {
                share.repicState = false
            }
            appdelegate.testNavi.viewControllers[count].addChildViewController(share)
            appdelegate.testNavi.viewControllers[count].view.addSubview(share.view)
            break
        case "more_sns":
            log.log("more_sns")
            if moreToggle {
                break
            }
            log.log(send_id)
            let para = send_id.componentsSeparatedByString("/")
            moreToggle = true
            //            message = ["my_id":self.email,"post_id":send_id]
            //            let connection = URLConnection(serviceCode: 504, message: message)
            //            let readData = connection.connection()
            if appdelegate.email == para[1] {
                let count = appdelegate.testNavi.viewControllers.count - 1
                let moreme = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MoreMeViewController")as! MoreMeViewController
                moreme.post_id = para[0]
                moreme.email = para[1]
                
                appdelegate.testNavi.viewControllers[count].addChildViewController(moreme)
                appdelegate.testNavi.viewControllers[count].view.addSubview(moreme.view)
            }else {
                let count = appdelegate.testNavi.viewControllers.count - 1
                let moreother = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MoreOtherViewController")as! MoreOtherViewController
                moreother.post_id = para[0]
                appdelegate.testNavi.viewControllers[count].addChildViewController(moreother)
                appdelegate.testNavi.viewControllers[count].view.addSubview(moreother.view)
            }
            
            break
        case "post":
            log.log("call post \(appdelegate.email)")
            
            let post = appdelegate.storyboard.instantiateViewControllerWithIdentifier("PostPageViewController")as! PostPageViewController
            appdelegate.controller.append(post)
//            post.index = appdelegate.controller.count - 1
            post.type = "post"
            post.email = appdelegate.email
            post.postId = send_id as String
            appdelegate.testNavi.navigationBarHidden = true
            appdelegate.testNavi.pushViewController(post, animated: true)
            break
            
        case "tag":
            let tagview = appdelegate.storyboard.instantiateViewControllerWithIdentifier("TagViewController")as! TagViewController
            appdelegate.controller.append(tagview)
            tagview.type = "tag"
//            tagview.index = appdelegate.controller.count - 1
            tagview.tagId = send_id as String
            tagview.email = appdelegate.email
            appdelegate.testNavi.navigationBarHidden = true
            appdelegate.tabbar.view.hidden = true
            appdelegate.testNavi.pushViewController(tagview, animated: true)
            break;
        case "user":
            log.log("call user ")
            
            if appdelegate.controller[appdelegate.controller.count-1].type == "search" {
                appdelegate.tabbar.view.hidden = false
            }
            
            let user = appdelegate.storyboard.instantiateViewControllerWithIdentifier("UserPageViewController")as! UserPageViewController
            appdelegate.controller.append(user)
            user.type = "user"
//            user.index = appdelegate.controller.count - 1
            user.myId = appdelegate.email
            user.userId = send_id as String
            appdelegate.testNavi.navigationBarHidden = true
            appdelegate.testNavi.pushViewController(user, animated: true)
            
            break;
        case "my_follower":
            log.log("call my_follower ")
            let follower = appdelegate.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
            follower.email = appdelegate.email
            follower.tagId = appdelegate.email
            follower.followType = "follower"
            appdelegate.testNavi.navigationItem.backBarButtonItem?.title = ""
            appdelegate.testNavi.navigationBar.backItem?.title = ""
            appdelegate.testNavi.navigationBarHidden = false
            appdelegate.tabbar.view.hidden = true
            appdelegate.testNavi.pushViewController(follower, animated: true)
            break;
        case "my_following":
            log.log("call my_following ")
            let follower = appdelegate.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
            follower.email = appdelegate.email
            follower.tagId = appdelegate.email
            follower.followType = "following"
            appdelegate.testNavi.navigationItem.backBarButtonItem?.title = ""
            appdelegate.testNavi.navigationBar.backItem?.title = ""
            appdelegate.tabbar.view.hidden = true
            appdelegate.testNavi.navigationBarHidden = false
            appdelegate.testNavi.pushViewController(follower, animated: true)
            break;
        case "follower":
            log.log("call follower ")
            let follower = appdelegate.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
            follower.email = appdelegate.email
            follower.tagId = send_id as String
            follower.followType = "follower"
            appdelegate.testNavi.navigationItem.backBarButtonItem?.title = ""
            appdelegate.testNavi.navigationBarHidden = false
            appdelegate.tabbar.view.hidden = true
            appdelegate.testNavi.pushViewController(follower, animated: true)
            break;
        case "following" :
            log.log("call follower")
            let follower = appdelegate.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
            follower.email = appdelegate.email
            follower.tagId = send_id as String
            follower.followType = "following"
            appdelegate.testNavi.navigationItem.backBarButtonItem?.title = ""
            appdelegate.tabbar.view.hidden = true
            appdelegate.testNavi.navigationBarHidden = false
            appdelegate.testNavi.pushViewController(follower, animated: true)
            break;
        case "profile_edit":
            log.log("call profile_edit ")
            let edit = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MyfeedEditProfileNav")as! UINavigationController
            appdelegate.testNavi.presentViewController(edit, animated: true, completion: nil)
            break;
        case "setting":
            log.log("call setting ")
            let setting = appdelegate.storyboard.instantiateViewControllerWithIdentifier("settingNav")as! UINavigationController
            appdelegate.testNavi.presentViewController(setting, animated: true, completion: nil)
            break;
            
        case "comment":
            log.log("coment")
            log.log(send_id)
            let para = send_id.componentsSeparatedByString("/")
            
            let comment = appdelegate.storyboard.instantiateViewControllerWithIdentifier("comment")as! CommentViewController
            log.log(appdelegate.email)
            appdelegate.controller.append(comment)
            comment.type = "comment"
//            comment.index = appdelegate.controller.count - 1
            comment.my_id = appdelegate.email
            comment.post_id = para[0]
            comment.postEmail = para[1]
            //            self.viewcontroller.presentViewController(comment, animated: true, completion: nil)
            //            self.contentview.pushViewController(comment, animated: true)
            appdelegate.testNavi.pushViewController(comment, animated: true)
            appdelegate.main.view.hidden = true
            appdelegate.tabbar.view.hidden = true
            break
            
        case "category" :
            let para = send_id.componentsSeparatedByString("/")
            let category = appdelegate.storyboard.instantiateViewControllerWithIdentifier("CategoryViewController")as! CategoryViewController
            appdelegate.controller.append(category)
            category.type = "category"
            category.email = appdelegate.email
            category.category_num = para[0]
            category.categorytitle = para[1]
            appdelegate.testNavi.pushViewController(category, animated: true)
            appdelegate.tabbar.view.hidden = true
            break
            
            // 소켓 통신만 진행
        case "do_follow":
            log.log("call do_follow ")
            let type : String!
            
            log.log("\(appdelegate.userData["register_form"].stringValue)")
            
            if appdelegate.userData["register_form"].string == "10001" {
                type = "N"
            }else if appdelegate.userData["register_form"].string == "10002" {
                type = "F"
            }else if appdelegate.userData["register_form"].string == "10003" {
                type = "G"
            }else {
                type = "R"
            }
            
            
            let message : JSON = ["myId":appdelegate.email,"email":[["email":send_id]],"type":type]
            appdelegate.doIt(402, message: message, callback: { (readData) -> () in
                
            })
            break;
        case "do_follow_tag":
            log.log("call do_follow_tag ")
            let message : JSON = ["myId":appdelegate.email,"tag_id":send_id]
            //            let connection = URLConnection(serviceCode: 403, message: message)
            //            let readData = connection.connection()
            appdelegate.doIt(403, message: message, callback: { (readData) -> () in
                
            })
            break;
        case "do_like":
            log.log("like")
            log.log("\(appdelegate.controller)")
            var count = 0
            if appdelegate.controller.count == 1 {
                
            }else {
                count = appdelegate.controller.count-1
            }
            log.log("\(appdelegate.controller[count].type)")
            message = ["post_reply_id":send_id,"click_id":appdelegate.email,"like_form":"P"]
            appdelegate.doIt(302, message: message, callback: { (readData) -> () in
                
                log.log("\(readData)")
                if readData["msg"].string! == "success"{
                    
                }
            })
            break
        case "do_like_cancel":
            log.log("call do_like_cancel ")
            message = ["post_reply_id":send_id,"click_id":appdelegate.email,"like_form":"P"]
            //            let connection = URLConnection(serviceCode: 303, message: message)
            //            let readData = connection.connection()
            appdelegate.doIt(303, message: message, callback: { (readData) -> () in
                if readData["msg"].string! == "success"{
                    log.log("좋아요 취소")
                }
            })
            break
        case "do_repic":
            break;
        case "tag_follower":
            log.log("call tag_follower ")
            let follower = appdelegate.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
            follower.email = appdelegate.email
            follower.tagId = send_id as String
            follower.followType = "tag"
            
            appdelegate.testNavi.hidesBottomBarWhenPushed = true
            appdelegate.testNavi.pushViewController(follower, animated: true)
            break;
        case "service" :
            let service = appdelegate.storyboard.instantiateViewControllerWithIdentifier("serviceNav")as! UINavigationController
            appdelegate.signin.presentViewController(service, animated: true, completion: nil)
            break
        case "policy" :
            let policy = appdelegate.storyboard.instantiateViewControllerWithIdentifier("policyNav")as! UINavigationController
            appdelegate.signin.presentViewController(policy, animated: true, completion: nil)
            break
        case "user_name" :
            var count = 0
            if appdelegate.controller.count == 1 {
                
            }else {
                count = appdelegate.controller.count-1
            }
            
            if appdelegate.controller[count].type == "post" {
                let a = appdelegate.controller[count]as! PostPageViewController
                a.postImage.enterBackground()
            }
            
            log.log("user_name \(send_id)")
            let user = appdelegate.storyboard.instantiateViewControllerWithIdentifier("CommentUserPageViewController")as! CommentUserPageViewController
            appdelegate.controller.append(user)
            user.type = "user"
//            user.index = appdelegate.controller.count - 1
            user.myId = appdelegate.email
            user.userId = send_id as String
            appdelegate.testNavi.navigationBarHidden = true
            appdelegate.testNavi.pushViewController(user, animated: true)
            break
        case "tag_name" :
            
            var count = 0
            if appdelegate.controller.count == 1 {
                
            }else if appdelegate.controller.count == 0 {
                count = 0
            }else {
                count = appdelegate.controller.count-1
            }
            
            if appdelegate.controller[count].type == "post" {
                let a = appdelegate.controller[count]as! PostPageViewController
                a.postImage.enterBackground()
            }
            log.log("tag_name \(send_id)")
            let tagview = appdelegate.storyboard.instantiateViewControllerWithIdentifier("CommentTagPageViewController")as! CommentTagPageViewController
//            let tagview = TagPageViewController()
            appdelegate.controller.append(tagview)
            tagview.type = "tag_name"
//            tagview.index = appdelegate.controller.count - 1
            tagview.tagId = send_id as String
            tagview.email = appdelegate.email
            appdelegate.testNavi.navigationBarHidden = true
            appdelegate.tabbar.view.hidden = true
            appdelegate.testNavi.pushViewController(tagview, animated: true)
            break
            
        case "like_list" :
            let like = appdelegate.storyboard.instantiateViewControllerWithIdentifier("LikeListViewController")as! LikeListViewController
            like.email = appdelegate.email
            like.tagId = send_id as String
            appdelegate.testNavi.navigationBarHidden = false
            appdelegate.tabbar.view.hidden = true
            appdelegate.testNavi.pushViewController(like, animated: true)
            break
        default:
            break;
        }
    }
    
    @available(iOS 8.0, *)
    func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge,
        completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
            let cred = NSURLCredential.init(forTrust: challenge.protectionSpace.serverTrust!)
            completionHandler(.UseCredential, cred)
//            print("Did receive auth challenge")
    }
    
}