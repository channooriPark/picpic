//
//  WriteSearchPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 19..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class WriteSearchPageViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{

    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var searText: UITextField!
    var imageData = [String:UIImage]()
    let log = LogPrint()
    var data = [JSON]()
    var followPage = 1
    var type = false
    var typeText = ""
    var users = [String:String]()
    @IBOutlet weak var selectUser: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = self.appdelegate.ment["post_write_friend_tag"].stringValue
        
        self.selectUser.text = ""
        searText.delegate = self
        self.searText.addTarget(self, action: Selector("didChangeText"), forControlEvents: UIControlEvents.EditingChanged)
        
//        self.view.frame = CGRectMake(0, 190, self.view.bounds.size.width, self.view.bounds.size.height)
        
        
        let message : JSON = ["my_id":self.appdelegate.email,"user_id":self.appdelegate.email,"page":String(followPage)]
        self.appdelegate.doIt(404, message: message) { (readData) -> () in
            if let post = readData["data"].array {
                self.type = true
                for data in post {
                    self.data.append(data)
                }
                self.listTable.reloadData()
            }
        }
        
        
        let complete : UIBarButtonItem = UIBarButtonItem(title: self.appdelegate.ment["complete1"].stringValue, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("complete:"))
        self.navigationItem.rightBarButtonItem  = complete
        
        
    }
    
    
    func complete(sender:UIBarButtonItem!){
                var count = self.appdelegate.testNavi.viewControllers.count-2
                if count < 0 {
                    count = 0
                }
        
                log.log("\(self.appdelegate.testNavi.viewControllers)")
                log.log(count)
                if self.typeText == "W" {
                    let a =  self.appdelegate.testNavi.viewControllers[count] as! GIFViewController
                    a.replaceText(text)
                    
                }else {
                    let a = self.appdelegate.testNavi.viewControllers[count] as! EditPostViewController
                    a.replaceText(text)
                    
                }
                self.appdelegate.testNavi.popViewControllerAnimated(true)

    }
    
    func backToMyFeed(){
        var count = self.appdelegate.testNavi.viewControllers.count-2
        if count < 0 {
            count = 0
        }
        
        log.log("\(self.appdelegate.testNavi.viewControllers)")
        log.log(count)
        if self.typeText == "W" {
            let a =  self.appdelegate.testNavi.viewControllers[count] as! GIFViewController
            a.textbegin()
        }else {
            let a = self.appdelegate.testNavi.viewControllers[count] as! EditPostViewController
            a.textbegin()
        }
        self.appdelegate.testNavi.popViewControllerAnimated(true)
    }
    
    
    func searchStr(str: String) {
        log.log("ddd")
        
        let page = 1
        let message : JSON = ["my_id":self.appdelegate.email,"str":str,"page":String(page)]
        self.appdelegate.doIt(512, message: message) { (readData) -> () in
            if let post = readData["friend"].array {
                if post.count != 0 {
                    self.data.removeAll()
                }
                self.type = false
                for data in post {
                    if data != nil {
                        self.log.log("data : \(data)")
                        self.data.append(data)
                        
                    }
                    
                }
                
            }
            
            self.listTable.reloadData()
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    var cellArr = [WritSearchTableViewCell]()

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WritSearchTableViewCell")as! WritSearchTableViewCell
        let Rowdata = self.data[indexPath.row]
        cell.data = Rowdata
        cellArr.append(cell)
        var image = UIImage()
        let imageURL = ImageURL()
        var urlStr = ""
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if self.type {
            urlStr = imageURL.imageurl(Rowdata["url"].string!)
        }else {
            urlStr = imageURL.imageurl(Rowdata["profile_picture"].string!)
        }
        
        if let img = imageData[urlStr] {
            image = img
            cell.setData(image)
        }
        else {
            cell.profileImage.image = UIImage(named: "noprofile")
            
            let imgURL = NSURL(string: urlStr)
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
                        //                        print("image")
                    })
                }
            }
        }
        return cell
    }
    
    
    var text = ""
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = self.data[indexPath.row]
        log.log("\(data)")
        let cell = cellArr[indexPath.row]
        if cell.select {
            cell.select = false
            cell.selectButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
        }else {
            cell.select = true
            cell.selectButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
        }
        tagUser(data)
        
//        var count = (self.navigationController?.viewControllers.count)!-2
//        if count < 0 {
//            count = 0
//        }
//        
//        log.log("\(self.navigationController?.viewControllers)")
//        log.log(count)
//        if self.typeText == "W" {
//            var a =  self.navigationController?.viewControllers[count] as! GIFViewController
//            a.replaceText(data["id"].string!)
//        }else {
//            var a = self.navigationController?.viewControllers[count] as! EditPostViewController
//            a.replaceText(data["id"].string!)
//        }
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tagUser(data:JSON){
        if let temp = users[data["id"].stringValue] {
            log.log("aaaaa")
            users.removeValueForKey(data["id"].stringValue)
            var a = ""
            if text.containsString("\(data["id"].stringValue),") {
                a = text.stringByReplacingOccurrencesOfString("\(data["id"].stringValue),", withString: "")
            }else if text.containsString(",\(data["id"].stringValue)"){
                a = text.stringByReplacingOccurrencesOfString(",\(data["id"].stringValue)", withString: "")
            }else {
                a = text.stringByReplacingOccurrencesOfString("\(data["id"].stringValue)", withString: "")
            }
            text = a
        }else {
            if users.count > 0 {
                self.users[data["id"].stringValue] = data["id"].stringValue
                text = text + "," + users[data["id"].stringValue]!
            }else {
                self.users[data["id"].stringValue] = data["id"].stringValue
                text = text + users[data["id"].stringValue]!
            }
        }
        
        //        self.users[data["id"].stringValue] = data["id"].stringValue
        
        //        text = text + self.users[data["id"].stringValue]! + " "
        
        log.log(text)
        self.selectUser.text = text
    }
    
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    var rangeStart : Int = -1
    var textrange : NSRange!
    
    func didChangeText(){
        self.searchStr(self.searText.text!)
    }

    
    func appendString(str:String){
        log.log("\(self.appdelegate.tagUsers)")
        log.log("\(self.appdelegate.tagUsers.count)")
        var text = ""
        text = text + self.appdelegate.tagUsers[str]! + " "
        log.log(text)
        self.selectUser.text = "ddd"
    }
    
    func removeString(){
    }

}
