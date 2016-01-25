//
//  CommentViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 23..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import AssetsLibrary
import Photos
import CryptoSwift



class CommentViewController: SubViewController , UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, SwipableCellButtonActionDelegate,GifListDelegate{
    
    @IBOutlet weak var galleryButton: UIButton!
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet var contview: UIView!
    @IBOutlet weak var comTableView: UITableView!
    @IBOutlet weak var comTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentView: UIView!
    var my_id : String!
    var post_id : String!
    var dataCount = 0
    var data : JSON!
    var dataArray = [JSON]()
    var likYN : Bool!
    var comWrite : String = "W"
    var body : String!
    var imageData = [String:UIImage]()
    var postEmail : String!
    let log = LogPrint()
    var tag = TagTableViewController()
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    var height = [CGFloat]()
    var first = true
    var page = 1
    var com_id = ""
    var url : String!
    var imageComView : UIView!
    var comImage : UIImageView!
    var imagecancel : UIButton!
    let fileManager = NSFileManager.defaultManager()
    @IBOutlet weak var commentBarHei: NSLayoutConstraint!
    var writType : Int = 0  //0이면 내 글 , 1이면 남의 글
    
    var cellsCurrentlyEditing: Set<NSIndexPath>?
    
    
    var imageComArr = [String:UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cellsCurrentlyEditing = Set()
        
        self.navigationController?.navigationBarHidden = false
        if self.view.frame.size.width == 320.0 {
            commentBarHei.constant = 33
        }
        imageComView = UIView(frame: CGRectMake(0,self.view.frame.size.height-50-170,self.view.frame.size.width,170))
        imageComView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(imageComView)
        comImage = UIImageView(frame: CGRectMake((self.view.frame.size.width/2) - 75, 10, 150, 150))
        self.imageComView.addSubview(comImage)
        imageComView.hidden = true
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let image = UIImageView(frame: CGRectMake(-20, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let backtap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "back:")
        image.addGestureRecognizer(backtap)
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = self.appdelegate.ment["comment"].stringValue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        comTableView.dataSource = self
        comTextField.delegate = self
        
        let message : JSON = ["my_id":my_id,"post_id":post_id]
        self.appdelegate.doIt(504, message: message) { (readData) -> () in
            if self.appdelegate.email == readData["email"].stringValue {
                self.writType = 0
            }else {
                self.writType = 1
            }
            self.sendData()
        }
        
        
        
        
        self.comTextField.delegate = self;
        self.comTextField.addTarget(self, action: Selector("didChangeText"), forControlEvents: UIControlEvents.EditingChanged)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        comTableView.addGestureRecognizer(tap)
        let height = UIScreen.mainScreen().bounds.height
        //        self.scrollViewBottom.constant = height - 50
        //        self.commentTop.constant = height - 50
        //        self.scrollViewBottom.constant = self.commentTop.constant
        
        //        self.scrollView.frame.origin.y = height - 50
        
        
        log.log("\(self.scrollView.frame.origin.y)")
        log.log("\(self.commentView.frame.origin.y)")
        
        self.tag = self.storyboard?.instantiateViewControllerWithIdentifier("TagTableViewController")as! TagTableViewController
        
        self.tag.view.frame = CGRectMake(0, 60, self.view.bounds.size.width, self.scrollView.bounds.size.height - 60)
        self.addChildViewController(self.tag)
        self.view.addSubview(self.tag.view)
        self.tag.view.hidden = true
        self.view.bringSubviewToFront(self.tag.view)
        
        self.galleryButton.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if comTableView.contentSize.height > comTableView.frame.size.height {
            let offset = CGPointMake(0, comTableView.contentSize.height - comTableView.frame.size.height)
            self.comTableView.contentOffset = offset
        }
    }
    
    func back(sender:UIBarButtonItem){
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        
        
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search"{
            self.navigationController?.navigationBarHidden = true
        }else {
            self.navigationController?.navigationBarHidden = false
        }
        if a.type == "post" {
            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
            post.postImage.enterForeground()
            post.setCommentCount(self.dataArray.count)
            
        }
        self.navigationController?.popViewControllerAnimated(true)
        self.appdelegate.tabbar.view.hidden = false
        self.appdelegate.main.view.hidden = false
    }
    
    
    func sendData(){
        let message : JSON = ["my_id":self.my_id,"post_id":self.post_id,"page":String(page)]
        //        let connection = URLConnection(serviceCode: 321, message: message)
        //        data = connection.connection()
        self.appdelegate.doIt(321, message: message) { (readData) -> () in
            self.getData(readData)
        }
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            log.log("\(keyboardSize.size.height)")
            self.bottomLayout.constant += keyboardSize.size.height
            self.imageComView.frame.origin.y -= keyboardSize.size.height
            log.log("\(self.scrollView.bounds.size.height)")
            log.log("\(self.commentView.frame.origin.y)")
            //            self.tag.view.frame.origin.y -= keyboardSize.size.height - 40
            self.tag.view.frame = CGRectMake(0, 60, self.view.bounds.size.width, self.scrollView.bounds.size.height - keyboardSize.size.height - 60)
        }
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.bottomLayout.constant -= keyboardSize.size.height
            self.imageComView.frame.origin.y += keyboardSize.size.height
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendComment(textField)
        return true
    }
    
    @IBAction func gallery(sender: AnyObject) {
        let gifList = self.storyboard?.instantiateViewControllerWithIdentifier("GifListViewController")as! GifListViewController
        gifList.commentView = self
        gifList.delegate = self
        self.navigationController?.pushViewController(gifList, animated: true)
    }
    
    
    var asset : PHAsset!
    
    func addSelected(image:UIImage,asset:PHAsset) {
        print("addSelected in ")
        self.imageComView.hidden = false
        self.comImage.image = image
        self.asset = asset
    }
    
    func imagecancle(){
        log.log("cancel")
        imageComView.hidden = true
        comImage.image = nil
    }
    
    func deleteRow(indexPath:NSIndexPath){
        self.dataArray.removeAtIndex(indexPath.row)
        //        self.comTableView.reloadData()
        self.comTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func getData(json:JSON){
        if json["data"] == nil {
            return
        }else {
            if let array = json["data"].array {
                for data in  array{
                    log.log("\(data)")
                    self.height.append(70)
                    dataArray.insert(data, atIndex: 0)
                }
            }
        }
        comTableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell")as! CommentCell
        let Rowdata = self.dataArray[indexPath.row]
        cell.data = Rowdata
        cell.index = indexPath.row
        cell.cellIndex = indexPath
        cell.comment = self
        
        if indexPath.row == 0 {
            if self.dataArray.count > 8 {
                self.page++
                self.sendData()
            }else if self.page > 100 {
                
            }
        }
        print(self.writType)
        cell.writType = self.writType
        cell.setBody()
        self.height[indexPath.row] = cell.height
        if self.first {
            if self.dataArray.count-1 == indexPath.row {
                tableView.reloadData()
                self.first = false
            }
        }
        
        
        var image = UIImage()
        let imageURL = ImageURL()
        let urlStr = imageURL.imageurl(Rowdata["profile_picture"].string!)
        if let img = imageData[urlStr] {
            image = img
            cell.setData(image)
        }
        else {
            let imgURL = NSURL(string: imageURL.imageurl(Rowdata["profile_picture"].string!))
            let request : NSURLRequest = NSURLRequest(URL:imgURL!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue) { (response, data, error) -> Void in
                if error == nil {
                    let image2 = UIImage(data:data!)
                    //self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if image2 == nil {
                            let url = NSURL(string: imageURL.imageurl("noprofile.png"))
                            let data = NSData(contentsOfURL: url!)
                            image = UIImage(data: data!)!
                        }else {
                            image = image2!
                        }
                        cell.setData(image)
                        self.imageData[urlStr] = image
                    })
                }
            }
        }
        
        
        let imageCom = imageURL.gifImageUrl(Rowdata["url"].stringValue)
        if cell.urlString != nil {
            if let img = self.imageComArr[imageCom] {
                cell.imageComView(img)
            }else {
                let imageURL = NSURL(string: imageURL.gifImageUrl(Rowdata["url"].stringValue))
                let request : NSURLRequest = NSURLRequest(URL: imageURL!)
                let mainQueue = NSOperationQueue.mainQueue()
                NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                    if error == nil {
                        let image = UIImage.gifWithData(data!)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if image != nil {
                                print("image comment ")
                                cell.imageComView(image!)
                                self.imageComArr[imageCom] = image
                            }
                        })
                    }else {
                        print("image comment error  :  ",error)
                    }
                })
            }
        }
        
        log.log("height : \(self.height[indexPath.row])")
        cell.delegate = self
        
        guard let contains = self.cellsCurrentlyEditing?.contains(indexPath) else
        {
            return cell
        }
        if contains
        {
            cell.openCell()
        }
        
        return cell
    }
    
    var filename : String!
    
    @IBAction func sendComment(sender: AnyObject) {
        let rawString = comTextField.text
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimmed : NSString = (rawString?.stringByTrimmingCharactersInSet(whitespace))!
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let currentdate = formatter.stringFromDate(date)
        let make = MakeFileNmae()
        let file = make.getFileName(self.appdelegate.userData["m_id"].string!)
        
        filename = "\(file)\(currentdate)_2.gif"
        if trimmed.length == 0 && self.comImage.image == nil {
            log.log("빈칸이야 다시써")
            return
        }
        
        if comImage.image != nil {
            //이미지 댓글이 있을경우
            self.asset.requestContentEditingInputWithOptions(PHContentEditingInputRequestOptions()) { (input, _) in
                let url = input!.fullSizeImageURL
                print("url   ",url) // 배열에 담아 콜렉션 뷰에 로드하면 됨.
                let data_gif = NSData(contentsOfURL: url!)
                let upload_url = "http://gif.picpic.world/uploadToServerForPicPic.php"
                let parameters = ["": ""]
                let request = self.urlRequestWithComponents(upload_url, parameters: parameters, imageData: data_gif!)
                
                Alamofire1.manager.upload(request.0, data: request.1).progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    //                //print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                    }
                    .responseJSON(completionHandler: { (request, response, data, error) in
                        if error != nil {
                            print("image upload fail  ",error)
                        }else {
                            print("iamge upload success  ",response)
                            var message : JSON = ["url":self.filename]
                            self.appdelegate.doIt(233, message: message, callback: { (readData) -> () in
                                print(readData)
                                print("ok")
                            })
                        }
                    })
            }
        }
        
        if self.imageComView.hidden == false {
            self.imageComView.hidden = true
        }
        
        view.endEditing(true)
        self.comTextField.endEditing(true)
        var com_form = self.comWrite
        if comWrite == "E" {
            com_form = "E"
        }
        if let text = comTextField.text {
            if text != "" {
                var message : JSON = ["my_id":self.appdelegate.email,"com_id":self.com_id,"post_id":self.post_id,"body":text,"com_form":com_form,"user_tags":"","url":filename]
                self.appdelegate.doIt(231, message: message, callback: { (readData) -> () in
                    if readData["msg"].string! == "success"{
                        message = ["my_id":self.appdelegate.email,"post_id":self.post_id,"page":"1"]
                        self.appdelegate.doIt(321, message: message, callback: { (readData) -> () in
                            self.dataArray.removeAll()
                            self.getData(readData)
                            self.comTextField.text = ""
                        })
                    }
                })
            }
        }
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return height[indexPath.row]
    }
    
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    var rangeStart : Int = -1
    var textrange : NSRange!
    
    func didChangeText(){
        
        if rangeStart == -1 {
            return
        }
        
        let text = self.comTextField.text! as NSString
        
        let end = (text.length - rangeStart)
        self.log.log("end          \(end)")
        if end < 0 {
            rangeStart = -1
            self.tag.view.hidden = true
            return
        }
        textrange = NSMakeRange(rangeStart, end)
        let substring = text.substringWithRange(textrange)
        if substring != "" {
            self.tag.range = textrange
            self.tag.searchTag(substring)
            NSLog("\(substring)")
            log.log("subString : \(substring)")
        }
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //        var subString = ""
        let testString = self.comTextField.text! as NSString
        if ( ((testString.length) - range.location) <= 1) {
            
            if rangeStart == -1 {
                if string == "@" {
                    rangeStart = range.location+1
                    self.tag.view.hidden = false
                    if tag.data.count == 0 {
                        self.tag.view.hidden = true
                    }
                }
            }
            else {
                if string == " " {
                    self.tag.view.hidden = true
                    rangeStart = -1
                }else {
                    
                }
            }
        }
        return true
    }
    
    
    
    func replaceText(str:String){
        var text = self.comTextField.text! as NSString
        text = text.stringByReplacingCharactersInRange(textrange, withString: str)
        self.comTextField.text = text as String
        self.tag.view.hidden = true
    }
    
    
    
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
        //set body
        mutableURLRequest.HTTPBody = uploadData
        return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    
    
    
    
    
    func myImageUploadRequest(image: UIImage!, filename : String)
    {
        var state = false
        var imageData : NSData!
        if image != nil {
            imageData = UIImageJPEGRepresentation(image, 1)!
        }
        if(imageData==nil)  { return; }
        let myUrl = NSURL(string: "http://gif.picpic.world/uploadToServerForPicPic.php");
        //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
        
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        
        request.HTTPBody = createBodyWithParameters(nil, filePathKey: "uploaded_file", imageDataKey: imageData!, boundary: boundary,filename: filename)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                //                print("error=\(error)")
                return
            }
            
            // You can print out response object
            //            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //            print("****** response data = \(responseString!)")
            
            
            var err: NSError?
            do {
                var json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            }catch{
                //                print(error)
            }
            
            /*
            if let parseJSON = json {
            var firstNameValue = parseJSON["firstName"] as? String
            println("firstNameValue: \(firstNameValue)")
            }
            */
            
        }
        task.resume()
    }
    
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String,filename:String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        
        
        let mimetype = "image/gif"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    
    func firstButtonTouched(writeType: Int, comType: Int,data:JSON,index:NSIndexPath) {
        print("hidden button 1 touched",writeType , "    " , comType)
        self.cellDidClose(index)
        if comType == 0 {
            self.body = data["body"].string!
            self.comWrite = "E"
            self.comTextField.text = self.body
            self.com_id = data["reply_id"].stringValue
            self.comTextField.becomeFirstResponder()
        }else {
            self.comTextField.text = "@\(data["id"].string!)"
            self.comTextField.becomeFirstResponder()
        }
    }
    
    func secondBUttonTouched(writeType: Int, comType: Int,data:JSON,index : NSIndexPath) {
        print("hidden button 2 touched",writeType , "    " , comType)
        self.cellDidClose(index)
        if writeType == 1 && comType == 1 {
            let report = self.storyboard?.instantiateViewControllerWithIdentifier("ReportViewController")as! ReportViewController
            report.post_id = data["reply_id"].string!
            report.type = "C"
            self.appdelegate.testNavi.pushViewController(report, animated: true)
            self.comTableView.reloadData()
        }else {
            let reply = data["reply_id"].string!
            let message : JSON = ["my_id":self.appdelegate.email,"com_id":reply,"post_id":self.post_id,"body":"","com_form":"D","user_tags":""]
            
            print("message    ",message)
            //            let connection = URLConnection(serviceCode: 231, message: message)
            //            let readData = connection.connection()
            self.appdelegate.doIt(231, message: message, callback: { (readData) -> () in
                if readData["msg"].string! == "success" {
                    self.deleteRow(index)
                    if self.appdelegate.second.view.hidden == false {
                        if self.appdelegate.second.webState == "follow" {
                            self.appdelegate.second.following()
                        }else if self.appdelegate.second.webState == "all" {
                            self.appdelegate.second.all()
                        }else if self.appdelegate.second.webState == "category" {
                            self.appdelegate.second.category()
                        }
                    }
                    
                }
            })
            
        }
    }
    
    let key: String = "secret0key000000"
    let iv: String = "0123456789012345"
    
    func enc(str: String) -> String
    {
        let encryptedBytes: [UInt8] = try! str.encrypt(AES(key: key, iv: iv, blockMode: .CBC))
        let base64Enc = NSData(bytes: encryptedBytes).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return base64Enc
    }
    
    func cellDidOpen(cell: UITableViewCell) {
        let currentEditingIndex = self.comTableView.indexPathForCell(cell)
        self.cellsCurrentlyEditing?.insert(currentEditingIndex!)
    }
    
    func cellDidClose(index:NSIndexPath) {
        print("Close   ")
        self.cellsCurrentlyEditing?.remove(index)
    }
}


