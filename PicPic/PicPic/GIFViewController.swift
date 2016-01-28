//
//  CreateGIFViewController.swift
//  createAniGIF
//
//  Created by Shawn Chun on 2015. 11. 5..
//  Copyright © 2015년 shawn. All rights reserved.
//

import UIKit
import SwiftyJSON
import Social
import FBSDKShareKit
import FBSDKCoreKit
import Accounts

class GIFViewController: SubViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var gifView: UIImageView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var control: UIControl!
    
    var activeView: UITextView?
    var moviePath: NSURL?
    var _hud: MBProgressHUD?
    var regift: Regift?
    var filename : String!
    var regift_photo: Regift_photo?
    var capturePhotoTimer: NSTimer?
    let log = LogPrint()
    let imageURL = ImageURL()
    
    
    @IBOutlet weak var imageHei: NSLayoutConstraint!
    @IBOutlet weak var controlHei: NSLayoutConstraint!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryBack: UIView!
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    var categoryTag : String!
    var categoryWidth : CGFloat!
    @IBOutlet weak var categoryViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var categoryViewHeight: NSLayoutConstraint!
    @IBOutlet weak var categoryScrollViewWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    var facebookState : Bool = false
    
    @IBOutlet weak var twitterImage: UIImageView!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var twitterButton: UIButton!
    var twitterState : Bool = false
    
    @IBOutlet weak var tumblrImage: UIImageView!
    @IBOutlet weak var tumblrLabel: UILabel!
    @IBOutlet weak var tumblrButton: UIButton!
    var tumblrState : Bool = false
    
    @IBOutlet weak var pinterestImage: UIImageView!
    @IBOutlet weak var pinterestLabel: UILabel!
    @IBOutlet weak var pinterestButton: UIButton!
    var pinterestState : Bool = false
    
    
    var url : String!
    var post_id : String!
    var shareApp = UIApplication.sharedApplication()
    var textEmpty = true
    
    
//    // gif 만들어주는 메소드
    func createGifFromURL(url: NSURL) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        facebookLabel.text = self.appdelegate.ment["facebook"].stringValue
        twitterLabel.text = self.appdelegate.ment["twitter"].stringValue
        tumblrLabel.text = self.appdelegate.ment["tumblr"].stringValue
        pinterestLabel.text = self.appdelegate.ment["pinterest"].stringValue
        
        
        
//        if self.appdelegate.standardUserDefaults.valueForKey("Facebook_Setting") == nil
//            || self.appdelegate.standardUserDefaults.valueForKey("Facebook_Setting")as! String == "N" {
//                self.facebookImage.image = UIImage(named: "icon_popup3_facebook")
//                self.facebookState = false
//        }
//        else {
//            self.facebookImage.image = UIImage(named: "icon_popup3_facebook_c")
//            self.facebookState = true
//        }
        
        if self.appdelegate.standardUserDefaults.valueForKey("Twitter_Setting") == nil
            || self.appdelegate.standardUserDefaults.valueForKey("Twitter_Setting")as! String == "N" {
                self.twitterImage.image = UIImage(named: "icon_popup3_twiiter")
                self.twitterState = false
        }
        else {
            self.twitterImage.image = UIImage(named: "icon_popup3_twiiter_c")
            self.twitterState = true
        }
        
        if self.appdelegate.standardUserDefaults.valueForKey("Tumblr_Setting") == nil
            || self.appdelegate.standardUserDefaults.valueForKey("Tumblr_Setting")as! String == "N" {
                self.tumblrImage.image = UIImage(named: "icon_popup3_tumblr")
                self.tumblrState = false
        }
        else {
            self.tumblrImage.image = UIImage(named: "icon_popup3_tumblr_c")
            self.tumblrState = true
        }
        
        if self.appdelegate.standardUserDefaults.valueForKey("Pinterest_Setting") == nil
            || self.appdelegate.standardUserDefaults.valueForKey("Pinterest_Setting")as! String == "N" {
                self.pinterestImage.image = UIImage(named: "icon_popup3_pinterest")
                self.pinterestState = false
        }
        else {
            self.pinterestImage.image = UIImage(named: "icon_popup3_pinterest_c")
            self.pinterestState = true
        }
        
        
        
        self.categoryView.layer.cornerRadius = 10
        self.categoryView.layer.masksToBounds = true
        
        self.categoryView.hidden = true
        self.categoryBack.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = self.appdelegate.ment["post_write"].stringValue
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
//        self.messageView.text = self.appdelegate.ment["post_write"].stringValue
//        self.messageView.textColor = UIColor.lightGrayColor()
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(dismissKeyboard)
        
        let contentInsets:UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        messageView.delegate = self
//        messageView.becomeFirstResponder()
        let complete : UIBarButtonItem = UIBarButtonItem(title: self.appdelegate.ment["complete"].stringValue, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("showCategoryView"))
        complete.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFontOfSize(15)], forState: .Normal)
        self.navigationItem.rightBarButtonItem  = complete
        
        self.imageHei.constant = Config.getInstance().hei
        self.controlHei.constant = Config.getInstance().hei
        
        let make = MakeFileNmae()
        self.filename = "\(make.getFileName(self.appdelegate.userData["m_id"].string!))_2.gif"
        
        // 로딩중 표시
        _hud = MBProgressHUD()
        _hud!.mode = MBProgressHUDModeIndeterminate
        view.addSubview(_hud!)
        controlLoading(false)
        
        //category View Setup
        self.categoryView.layer.cornerRadius = 10
        self.categoryView.layer.masksToBounds = true
        categoryWidth = self.view.frame.size.width/8
        categoryViewWidth.constant = categoryWidth*6
        categoryScrollViewWidth.constant = categoryWidth*6
        categoryViewHeight.constant = 350
        setcategory()
        
//        facebookButton.hidden = true
//        facebookImage.hidden = true
//        facebookLabel.hidden = true
    }
    
    func showCategoryView(){
        dismissKeyboard()
        self.view.bringSubviewToFront(categoryBack)
        self.view.bringSubviewToFront(categoryView)
        self.categoryBack.hidden = false
        self.categoryView.hidden = false
    }
    
    
    func setcategory(){
        self.categoryTitle.text = self.appdelegate.ment["category_select_ment"].stringValue
        let buttonDefault = ["category_non","category_daylife","category_animal","category_celebrities","category_emotion","category_animation","category_food","category_fashion","category_beauty","category_artdesign","category_sports","category_movie","category_tv","category_game","category_cartoon","category_reaction","category_vehicle","category_music","category_expression","category_action","category_interest","category_decades","category_nature","category_sticker","category_science","category_holidays"]
        let buttonHighLight = ["category_non","daylife_c","animal_c","celebrities_c","emotion_c","animation_c","food_c","fashion_c","beauty_c","artdesign_c","sports_c","movie_c","tv_c","game_c","cartoon_c","reaction_c","vehicle_c","music_c","expression_c","action_c","interest_c","decades_c","nature_c","sticker_c","science_c","holidays_c"]
        
        var index = 0
        var buttonwidth : CGFloat = categoryScrollViewWidth.constant/3
        var buttonheight : CGFloat = buttonwidth+30
        
        let count = buttonDefault.count/3 + 1
        log.log("\(count)")
        for var i=0; i<count; i++ {
            for var j=0; j<3; j++ {
                if index == buttonDefault.count { break }
                let button = UIButton(type: .Custom)
                button.frame = CGRectMake(buttonwidth*CGFloat(j), buttonheight*CGFloat(i), buttonwidth, buttonwidth)
                button.addTarget(self, action: "selectTag:", forControlEvents: .TouchUpInside)
                button.setImage(UIImage(named: buttonDefault[index]), forState: .Normal)
                button.setImage(UIImage(named: buttonHighLight[index]), forState: .Highlighted)
                button.tag = index
                
                let label = UILabel(frame: CGRectMake(buttonwidth*CGFloat(j), buttonheight*CGFloat(i)+buttonwidth, buttonwidth, 30))
                label.text = self.appdelegate.ment["category_\(index)"].stringValue
                label.textAlignment = .Center
                label.font = UIFont(name: "Helvetica", size: 13)
                self.categoryScrollView.addSubview(button)
                self.categoryScrollView.addSubview(label)
                index++
            }
        }
        self.categoryScrollView.contentSize = CGSize(width: self.categoryView.frame.size.width, height: buttonheight*9)
    }
    
    func selectTag(sender:UIButton!){
        print(sender.tag)
        self.categoryTag = "\(sender.tag)"
        self.categoryView.hidden = true
        self.categoryBack.hidden = true
        self.complete()
    }
    
    @IBAction func actFacebook(sender: AnyObject) {
        if facebookState {
            self.facebookImage.image = UIImage(named: "icon_popup3_facebook")
            facebookState = false
        }else {
            self.facebookImage.image = UIImage(named: "icon_popup3_facebook_c")
            facebookState = true
        }
    }
    
    @IBAction func actTwitter(sender: AnyObject) {
        if twitterState {
            self.twitterImage.image = UIImage(named: "icon_popup3_twiiter")
            twitterState = false
        }else {
            self.twitterImage.image = UIImage(named: "icon_popup3_twiiter_c")
            twitterState = true
        }
    }
    
    @IBAction func actTumblr(sender: AnyObject) {
        if tumblrState {
            self.tumblrImage.image = UIImage(named: "icon_popup3_tumblr")
            tumblrState = false
        }else {
            self.tumblrImage.image = UIImage(named: "icon_popup3_tumblr_c")
            tumblrState = true
        }
    }
    
    @IBAction func actPinterest(sender: AnyObject) {
        if pinterestState {
            self.pinterestImage.image = UIImage(named: "icon_popup3_pinterest")
            pinterestState = false
        }else {
            self.pinterestImage.image = UIImage(named: "icon_popup3_pinterest_c")
            pinterestState = true
        }
    }
    
    func facebook() {
        if !facebookState {
            twitter()
            return
        }
        
        var path = imageURL.gifImageUrl(self.url)
        log.log("\(path)")
        //        let share : FBSDKShareLinkContent = FBSDKShareLinkContent()
        //        share.imageURL = NSURL(string: path)
        
        
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentTitle = "PicPic"
        content.contentURL = NSURL(string: path)
        
        //        content.imageURL = NSURL(string: path)
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.Automatic
        //        dialog.delegate = self
        //        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
        
        dialog.show()
        //        DismissKeyboard()
        log.log("FACEBOOK");
    }
    
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject: AnyObject]) {
        log.log("FACEBOOK COMPLETE");
        twitter()
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        log.log("FACEBOOK ERROR");
        twitter()
    }
    
    func shareDidCancel(sharer: FBSDKSharing!){
        log.log("FACEBOOK CANCEL")
        twitter()
    }
    
    func twitter() {
        if !twitterState {
            tumblr()
            return
        }
        
        let twitter : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        let path = imageURL.gifImageUrl(url)
        let data = NSData(contentsOfURL: NSURL(string: path)!)!
        let im = UIImage.gifWithData(data)
        twitter.addImage(im)
        twitter.addURL(NSURL(string: path))
        twitter.completionHandler = {
            (result:SLComposeViewControllerResult) in
            if result == SLComposeViewControllerResult.Done {
                //                self.DismissKeyboard()
                self.log.log("TWITTER COMPLETE");
                self.tumblr()
            }
        }
        self.presentViewController(twitter, animated: true, completion: nil)
    }
    //                        message["status"] = "Test Tweet with image"
    //https://api.twitter.com/1.1/statuses/update_with_media.json
    //                        let requestURL = NSURL(string:"https://api.twitter.com/1.1/statuses/update.json")
    
    
    func tweetWithImage(data:NSData)
    {
        
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(
            ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil,
            completion: {(success: Bool, error: NSError!) -> Void in
                if success {
                    let arrayOfAccounts =
                    account.accountsWithAccountType(accountType)
                    
                    if arrayOfAccounts.count > 0 {
                        let twitterAccount = arrayOfAccounts.first as! ACAccount
                        var message = Dictionary<String, AnyObject>()
                        let requestURL = NSURL(string:"https://api.twitter.com/1.1/statuses/update_with_media.json")
                        let postRequest = SLRequest(forServiceType:
                            SLServiceTypeTwitter,
                            requestMethod: SLRequestMethod.POST,
                            URL: requestURL,
                            parameters: message)
                        
                        postRequest.account = twitterAccount
                        postRequest.addMultipartData(data, withName: "media", type: nil, filename: nil)
                        
                        postRequest.performRequestWithHandler({
                            (responseData: NSData!,
                            urlResponse: NSHTTPURLResponse!,
                            error: NSError!) -> Void in
                            if let err = error {
                                print("Error : \(err.localizedDescription)")
                            }
                            if urlResponse.statusCode == 200 {
                                let alert = UIAlertView(title: "\(urlResponse.statusCode)", message: "", delegate: nil, cancelButtonTitle: "확인")
                                alert.show()
                                //                                self.loading(false)
                            }else {
                                let alert = UIAlertView(title: "\(urlResponse.statusCode)", message: "", delegate: nil, cancelButtonTitle: "확인")
                                alert.show()
                                //                                self.loading(false)
                            }
                            
                            
                            print("Twitter HTTP response \(urlResponse.statusCode)")
                            
                        })
                    }
                }
                else
                {
                }
        })
        
        
    }
    
    func tumblr() {
        if !tumblrState {
            pinterest()
            return
        }
        //"https://www.tumblr.com/widgets/share/tool?shareSource=legacy&canonicalUrl=&url=http://www.picpic.world/pic/\(self.post_id)&posttype=photo&content=http://gif.picpic.world/\(self.url)&caption=www.picpic.world"
        let path = imageURL.gifImageUrl(self.url)
        let imageaddr = "https://www.tumblr.com/widgets/share/tool?shareSource=legacy&canonicalUrl=&url=http://www.picpic.world/pic/\(self.post_id)&posttype=photo&content=http://gif.picpic.world/\(self.url)&caption=www.picpic.world"
        let url_url = NSURL(string: imageaddr)
        let request = NSURLRequest(URL: url_url!)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "enterForeground",
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
        if(request.URL?.scheme == "http" || request.URL?.scheme == "https") {
            UIApplication.sharedApplication().openURL(request.URL!)
        }
        log.log("Tumblr");
    }
    
    func enterForeground() {
        pinterest()
    }
    
    func pinterest() {
        if !pinterestState {
            finishPost()
            return
        }
        //        let path = imageURL.gifImageUrl(self.url)
        let path = imageURL.gifImageUrl(self.url)
        let imageaddr = "https://www.pinterest.com/pin/create/button/?url=http%3A%2F%2Fwww.picpic.world%2Fpic%2F\(self.post_id)&media=http%3A%2F%2Fgif.picpic.world%2F\(self.url)"
        let url = NSURL(string: imageaddr)
        let request = NSURLRequest(URL: url!)
        if(request.URL?.scheme == "http" || request.URL?.scheme == "https") {
            UIApplication.sharedApplication().openURL(request.URL!)
        }
        finishPost()
        log.log("PINTEREST");
    }
    
    func finishPost() {
        self.appdelegate.testNavi.navigationBarHidden = false
        if self.appdelegate.myfeed.view.hidden == false {
            self.appdelegate.testNavi.navigationBarHidden = true
        }
        self.appdelegate.testNavi.popToRootViewControllerAnimated(true)
    }
    
    
    func dismissKeyboard() {
        messageView.resignFirstResponder()
    }
    
    func complete(){
        controlLoading(true)
        let data_gif: NSData
        if Config.getInstance().photoDataArr.count>0 {
            data_gif = NSData(contentsOfFile: (moviePath?.path!)!)!
        }
        else {
            data_gif = NSData(contentsOfFile: (moviePath?.path!)!)!
        }
        startAPI(data_gif)
    }
    
    // 이전 버튼 눌렀을 때
    @IBAction func movePreview(sender: UIButton) {
//        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.navigationBarHidden = false
        if self.appdelegate.myfeed.view.hidden == false {
            self.navigationController?.navigationBarHidden = true
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func backToMyFeed(){
        self.navigationController?.navigationBarHidden = false
        if self.appdelegate.myfeed.view.hidden == false {
            self.navigationController?.navigationBarHidden = true
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // 다음 버튼 눌렀을 때
    @IBAction func sendData(sender: UIButton) {
        
        //카테고리 설정 subView 띄워주고 tag에 추가 ,str추가 쉼표 추가 해줘야 한다
        controlLoading(true)
        let data_gif: NSData
        if Config.getInstance().photoDataArr.count>0 {
            print("regift_photo    ::      ",regift_photo!.createGif()!)
            data_gif = NSData(contentsOfURL: regift_photo!.createGif()!)!
        }
        else {
            data_gif = NSData(contentsOfURL: regift!.createGif()!)!
        }
        startAPI(data_gif)
    }
    
    func startAPI(data_gif: NSData) {
        print("messageView         ",messageView.text)
        if messageView.text == self.appdelegate.ment["post_write"].stringValue {
            print("messageView.text ",messageView.text)
            messageView.text = ""
        }
        let upload_url = "http://gif.picpic.world/uploadToServerForPicPic.php"
        let parameters = ["": ""]
        let request = urlRequestWithComponents(upload_url, parameters: parameters, imageData: data_gif)
//        print(request.0.URLRequest.URLString)
        Alamofire1.manager.upload(request.0, data: request.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
//                //print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON(completionHandler: { (request, response, data, error) in
                print(request,"         ::             ",response,"          ",data)
                self.dispatch_async_global {
                    if error != nil {
//                        //print("error: \(error!)")
                    }
                    self.dispatch_async_main {
                        if let dir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
                            let path_gif = dir.stringByAppendingPathComponent("image.gif")
                            data_gif.writeToFile(path_gif, atomically: true)
                        }
                        let newString = self.messageView.text.stringByReplacingOccurrencesOfString(", #", withString: " #", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        
                        let body = newString.stringByReplacingOccurrencesOfString(",#", withString: " #", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        
                        
                        let fullNameArr = body.componentsSeparatedByString(" ");
                        var tag = ""
                        for(var i=0;i<fullNameArr.capacity;i++) {
                            let _str = fullNameArr[i]
                            if(_str.hasPrefix("#")) {
                                if(tag.characters.count>0) {
                                    tag += ","
                                }
                                tag += _str
                            }
                            tag = tag.stringByReplacingOccurrencesOfString("#", withString: "")
                        }
                        let categoryString = self.appdelegate.ment["category_\(self.categoryTag)"].stringValue.stringByReplacingOccurrencesOfString(" ", withString: "")
                        tag += ","+categoryString
                        self.log.log("\(tag)")
                        var message : JSON = ["url":self.filename]
                        self.appdelegate.doIt(233, message: message, callback: { (readData) -> () in
                            
                        })
                        message = ["my_id":self.appdelegate.email,"body":body,"url":self.filename,"tags":tag,"type":"W","user_tags":"","and_tag":"","post_id":""]
                        print("message : ",message)
//                        connection = URLConnection(serviceCode: 232, message: message)
//                        readData = connection.connection()
                        self.appdelegate.doIt(232, message: message, callback: { (readData) -> () in
                            if readData["msg"].string! == "success" {
                                self.post_id = readData["post_id"].stringValue
                                if self.appdelegate.myfeed.wkwebView != nil {
                                    self.appdelegate.myfeed.fire()
                                }
                                if self.appdelegate.second.wkwebView != nil {
                                    if self.appdelegate.second.webState == "follow" {
                                        self.appdelegate.second.following()
                                    }else if self.appdelegate.second.webState == "all" {
                                        self.appdelegate.second.all()
                                    }else if self.appdelegate.second.webState == "category" {
                                    }
                                }
                                
                                self.url = self.filename
//                                self.facebook()
                                self.twitter()
                            }
                        })
                    }
                    self.controlLoading(false)
                }
            })
    }
    
    // 파일 업로드 관련 데이터
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        mutableURLRequest.timeoutInterval = 60
        mutableURLRequest.HTTPMethod = "POST"
        let lineEnd = "\r\n"
        let twoHyphens = "--"
        let boundaryConstant = "Boundary-animated_gif"
        mutableURLRequest.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        mutableURLRequest.setValue("multipart/form-data; boundary=\(boundaryConstant)", forHTTPHeaderField: "Content-Type")
        //post data
        let uploadData: NSMutableData = NSMutableData()
        uploadData.appendString("\(twoHyphens)\(boundaryConstant)\(lineEnd)")
        // add params (all params are strings)
        for (key, value) in parameters {
            if value != "" {
                uploadData.appendString("Content-Disposition: form-data; name=\"\(key)\"\(lineEnd)\(lineEnd)")
                uploadData.appendString("\(value)\(lineEnd)")
                uploadData.appendString("\(twoHyphens)\(boundaryConstant)\(lineEnd)")
//                //print("\(key): \(value)")
            }
        }
        //data
        uploadData.appendString("Content-Disposition: form-data; name=\"uploaded_file\"; filename=\"\(self.filename)\"\(lineEnd)\(lineEnd)")
        //        uploadData.appendString("Content-Type: image/jpeg\r\n\r\n")
        uploadData.appendData(imageData)
        uploadData.appendString("\(lineEnd)")
        uploadData.appendString("\(twoHyphens)\(boundaryConstant)\(twoHyphens)\(lineEnd)")
        print("uploadData            :::::::::::::  \n",uploadData)
        //set body
        mutableURLRequest.HTTPBody = uploadData
        return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.contentOffset = CGPoint.zero
        // 텍스트필드를 키보드가 가리지 않게 위치를 이동시켜주는 메소드 설정
        registNotification()
        controlLoading(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        log.log("\(moviePath?.path)")
        //let data = NSData(contentsOfURL: moviePath!)
        let d = NSData(contentsOfFile: (moviePath?.path)!)
        gifView.image = UIImage.gifWithData(d!)
        controlLoading(false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 텍스트필드를 키보드가 가리지 않게 위치를 이동시켜주는 메소드 해제
        messageView.endEditing(true)
        unregistNotification()
    }
    
    // 키보드가 올라왔을 때 실행되는 메소드
    func keyboardWasShown(notification: NSNotification){
        log.log("keyboard show")
        let info: NSDictionary  = notification.userInfo!
        let kbSize = info.valueForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.size
//        let contentInsets: UIEdgeInsets  = UIEdgeInsetsMake(120.0, 0.0, kbSize!.height, 0.0)
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint(x: 0, y: 330), animated: true)
        let aRect: CGRect = self.view.frame
        if let keyboardSize = (info.valueForKey(UIKeyboardFrameEndUserInfoKey) as? NSValue)?.CGRectValue() {
            self.scrollViewBottom.constant += keyboardSize.size.height
        }
        if activeView == nil {
            return
        }
        //스크롤이 필요 없다면 그냥 보여짐
//        if (!CGRectContainsPoint(aRect, activeView!.frame.origin) ) {
//            let scrollPoint:CGPoint = CGPointMake(0.0, activeView!.frame.origin.y - kbSize!.height)
//            scrollView.setContentOffset(scrollPoint, animated: true)
//        }
        log.log("gifView frame   \(gifView.frame)    \(control.frame)")
    }
    
    // 뒷배경 누르면 스크롤 위치 초기화
    @IBAction func backgroundTouch(sender: UIControl) {
        messageView.endEditing(true)
    }
    
    // 키보드가 사라졌을 때 실행되는 메소드
    func keyboardWillBeHidden(notification: NSNotification){
        log.log("###### keyboardWillBeHidden")
        let contentInsets:UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        let info: NSDictionary  = notification.userInfo!
        let kbSize = info.valueForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.size
        var aRect: CGRect = self.view.frame
        
        if let keyboardSize = (info.valueForKey(UIKeyboardFrameEndUserInfoKey) as? NSValue)?.CGRectValue() {
            self.scrollViewBottom.constant -= keyboardSize.size.height
        }
//        let scrollPoint : CGPoint = CGPointMake(0, 200)
//        scrollView.setContentOffset(CGPointMake(100,100), animated: true)
        
//        aRect.size.height -= kbSize!.height
        if activeView == nil {
            return
        }
        //스크롤이 필요 없다면 그냥 보여짐
//        if (!CGRectContainsPoint(aRect, activeView!.frame.origin) ) {
//            let scrollPoint:CGPoint = CGPointMake(0.0, 0.0)
//            scrollView.setContentOffset(scrollPoint, animated: true)
//        }
        
    }
    
    // 키보드가 올라오고 내려갈 때 발생하는 이벤트 설정
    func registNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:",
            name:"UIKeyboardDidShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:",
            name:"UIKeyboardWillHideNotification", object: nil)
    }
    
    // 키보드가 올라오고 내려갈 때 발생하는 이벤트 해제
    func unregistNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"UIKeyboardDidShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"UIKeyboardWillHideNotification", object: nil)
    }
    
    // 텍스트필드 선택시 발생하는 이벤트
    func textViewDidBeginEditing(textView: UITextView) {
//        if textEmpty {
//            textView.text = ""
//            textView.textColor = UIColor.blackColor()
//        }
        activeView = textView
//        self.scrollView.setContentOffset(CGPointMake(0,self.gifView.bounds.size.height), animated: true)
    }
    // 텍스트필드에서 다른 곳이 터치 됐을 때 발생하는 이벤트
    func textViewDidEndEditing(textView: UITextView) {
//        //print("###### textViewDidEndEditing")
//        if textView.text.isEmpty {
//            textView.text = self.appdelegate.ment["post_write"].stringValue
//            textView.textColor = UIColor.lightGrayColor()
//            textEmpty = true
//        }
        activeView = nil
    }
    
    // 메인 인디케이터 호출해주는 메소드
    func controlLoading(val: Bool) {
        if val {
            _hud!.show(true)
        }
        else {
            _hud!.hide(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dispatch_async_global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
    
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    var range_start = 0
    
    var text_type = 0
    let TEXT_TYPE_NONE = 0
    let TEXT_TYPE_MARK = 1
    let TEXT_TYPE_UNMARK = 2
    let TEXT_TYPE_REFRESH = 3
    let TEXT_TYPE_MARKING = 4;
    
    var text_color: UIColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
    let text_color_1 = UIColor(red: 0.71, green: 0.89, blue: 0.94, alpha: 0.3) // # 컬러
    let text_color_2 = UIColor(red: 0.82, green: 0.82, blue: 0.36, alpha: 0.3) // @ 컬러
    
    
    
    @IBAction func hashTag(sender: AnyObject) {
//        if textEmpty {
//            messageView.text = ""
//        }
        text_type = TEXT_TYPE_UNMARK
        text_color = text_color_1
        let str = self.messageView.text as String
        if str.characters.count == 0 {
            self.messageView.text = self.messageView.text + "#"
        }else {
            range_start = str.characters.count+1
            self.messageView.text = self.messageView.text + " #"
        }
        text_type = TEXT_TYPE_MARK
        textViewDidChange(messageView)
        messageView.becomeFirstResponder()
        refresh(messageView)
    }

    @IBAction func userTag(sender: AnyObject) {
        let usertag = self.storyboard?.instantiateViewControllerWithIdentifier("WriteSearchPageViewController")as! WriteSearchPageViewController
        usertag.typeText = "W"
        self.messageView.endEditing(true)
        self.navigationController?.pushViewController(usertag, animated: true)
        
    }
    
    
    func replaceText(str:String){
        print("replacetext     ",str)
//        if textEmpty {
//            messageView.text = " "
//        }
        text_type = TEXT_TYPE_MARK
        let astr = messageView.text as String
//        if astr.characters.count == 0 {
//            messageView.text = " "
//        }
        
        let strArr = str.componentsSeparatedByString(",")
        for var i = 0; i<strArr.count; i++ {
            self.messageView.text = self.messageView.text + " @\(strArr[i])"
        }
        print("messageView text     ",messageView.text)
        refresh(self.messageView)
        messageView.becomeFirstResponder()
        text_type = TEXT_TYPE_UNMARK
    }
    
    
    func textbegin(){
        self.messageView.becomeFirstResponder()
    }
    
    
    
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

extension GIFViewController {
    
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        log.log("should change Text in range \(range)")
        let str = textView.text! as String
        log.log("str \(str)")
        if(str.characters.count==0) {
            range_start = range.location
            if(text == "#") {
                text_color = text_color_1
                text_type = TEXT_TYPE_MARK
            } else if(text == "@") {
                text_color = text_color_2
                text_type = TEXT_TYPE_MARK
            } else {
                text_type = TEXT_TYPE_UNMARK
            }
            return true
        }
        
        if( (str.characters.count - range.location) <= 1) { // 커서가 제일 뒤에 있는 경우
            print("text_type  ",text_type)
            if(text == " " || text == "\n") {
//                if(text_type == TEXT_TYPE_MARKING) {
                    print("unmark")
                    text_type = TEXT_TYPE_UNMARK
                    range_start = range.location
//                }
            } else if(text_type == TEXT_TYPE_NONE) {
                if(text == "#") {
                    print("hash")
                    range_start = range.location
                    text_color = text_color_1
                    text_type = TEXT_TYPE_MARK
                } else if(text == "@") {
                    range_start = range.location
                    text_color = text_color_2
                    text_type = TEXT_TYPE_MARK
                }
            } else if(text_type == TEXT_TYPE_MARKING) {
                if(str == "") {
                    range_start = range.location
                    text_type = TEXT_TYPE_UNMARK
                }
            }
        } else { // 텍스트 중간에 커서가 있는 경우
            if(str.characters.count>0) {
                text_type = TEXT_TYPE_REFRESH
            } else {
                //return false
            }
        }
        return true // realDelegate.textView(self, shouldChangeTextInRange: range, replacementText: text)
        
    }
    
    
    func refresh(textView : UITextView){
        let preAttributedRange: NSRange = textView.selectedRange
        
        let font = textView.font!
        
        let attrs = [ NSFontAttributeName : font]
        let attrs1 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_1]
        let attrs2 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_2]
        
        let txt = textView.text! as String
        let str_arr = txt.componentsSeparatedByString("\n")
        
        let para = NSMutableAttributedString()
        
        for(var i=0;i<str_arr.count;i++) {
            let str = str_arr[i]
            
            let str_arr2 = str.componentsSeparatedByString(" ")
            
            for(var j=0;j<str_arr2.count;j++) {
                let str = str_arr2[j]
                
                var attrString = NSAttributedString()
                
                if(str.hasPrefix("#")) {
                    attrString = NSAttributedString(string: str, attributes:attrs1)
                    para.appendAttributedString(attrString)
                } else if(str.hasPrefix("@")) {
                    attrString = NSAttributedString(string: str, attributes:attrs2)
                    para.appendAttributedString(attrString)
                } else {
                    attrString = NSAttributedString(string: str, attributes:attrs)
                    para.appendAttributedString(attrString)
                }
                if( (j+1) != str_arr2.count) {
                    attrString = NSAttributedString(string: " ", attributes:attrs)
                    para.appendAttributedString(attrString)
                }
            }
            if( (i+1) != str_arr.count) {
                let attrString = NSAttributedString(string: "\n", attributes:attrs)
                para.appendAttributedString(attrString)
            }
        }
        
        textView.attributedText = para
        textView.selectedRange = preAttributedRange
        text_type = TEXT_TYPE_NONE
    }
    
    
    
    func textViewDidChange(textView: UITextView) {
        print("text_type   ",text_type)
        let str = textView.text as String
        if(text_type == TEXT_TYPE_NONE) {
            
        } else if(text_type == TEXT_TYPE_MARK) {
            print("text_type_mark")
            if str.characters.count == 1 {
                range_start = 0
            }
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.appendAttributedString(textView.attributedText)
            attributedString.addAttribute(NSBackgroundColorAttributeName, value: text_color, range: NSMakeRange(range_start, 1))
            textView.attributedText = attributedString
            text_type = TEXT_TYPE_MARKING
        } else if(text_type == TEXT_TYPE_UNMARK) {
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.appendAttributedString(textView.attributedText)
            attributedString.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(range_start, 1))
            textView.attributedText = attributedString
            text_type = TEXT_TYPE_NONE
        } else if(text_type == TEXT_TYPE_REFRESH) {
            print("text_type_refresh")
            let preAttributedRange: NSRange = textView.selectedRange
            
            let font = textView.font!
            
            let attrs = [ NSFontAttributeName : font]
            let attrs1 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_1]
            let attrs2 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_2]
            
            let txt = textView.text! as String
            let str_arr = txt.componentsSeparatedByString("\n")
            
            let para = NSMutableAttributedString()
            
            for(var i=0;i<str_arr.count;i++) {
                let str = str_arr[i]
                
                let str_arr2 = str.componentsSeparatedByString(" ")
                
                for(var j=0;j<str_arr2.count;j++) {
                    let str = str_arr2[j]
                    
                    var attrString = NSAttributedString()
                    
                    if(str.hasPrefix("#")) {
                        attrString = NSAttributedString(string: str, attributes:attrs1)
                        para.appendAttributedString(attrString)
                    } else if(str.hasPrefix("@")) {
                        attrString = NSAttributedString(string: str, attributes:attrs2)
                        para.appendAttributedString(attrString)
                    } else {
                        attrString = NSAttributedString(string: str, attributes:attrs)
                        para.appendAttributedString(attrString)
                    }
                    if( (j+1) != str_arr2.count) {
                        attrString = NSAttributedString(string: " ", attributes:attrs)
                        para.appendAttributedString(attrString)
                    }
                }
                if( (i+1) != str_arr.count) {
                    let attrString = NSAttributedString(string: "\n", attributes:attrs)
                    para.appendAttributedString(attrString)
                }
            }
            
            textView.attributedText = para
            textView.selectedRange = preAttributedRange
            text_type = TEXT_TYPE_NONE
        } else if(text_type == TEXT_TYPE_MARKING) {
            
        }
//        realDelegate.textViewDidChange(self)
    }
}