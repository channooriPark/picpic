//
//  AlramViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 26..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class AlramViewController: SubViewController ,UITableViewDataSource , UITableViewDelegate{
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var allImage: UIImageView!
    @IBOutlet weak var allSelectBar: UIImageView!
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var mySelectBar: UIImageView!
    @IBOutlet weak var followImage: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followSelectBar: UIImageView!
    @IBOutlet weak var allText: UILabel!
    @IBOutlet weak var myText: UILabel!
    @IBOutlet weak var followText: UILabel!
    @IBOutlet weak var alarmtableview: UITableView!
    var imageData = [String:UIImage]()
    var postData = [String:UIImage]()
    var allT = true
    var followT = false
    var myT = false
    var readData : JSON!
    var data = [JSON]()
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var message : JSON!
    var connection : URLConnection!
    var isGetData = false
    var all_page = 1
    var my_page = 1
    var follow_page = 1
    var count = 0
    var loadingCount = 1
    let log = LogPrint()
    @IBOutlet weak var followWid: NSLayoutConstraint!
    @IBOutlet weak var noalarmView: UIView!
    @IBOutlet weak var noalarmText: UILabel!
    
    var allJSON = [JSON]()
    var myJSON = [JSON]()
    var followJSON = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.type = "alarm"
        self.noalarmView.hidden = true
        noalarmText.text = self.appdelegate.ment["notification_noting"].stringValue
        noalarmView.hidden = true
        allText.text = self.appdelegate.ment["notification_all"].stringValue
        myText.text = self.appdelegate.ment["notification_my"].stringValue
        followText.text = self.appdelegate.ment["notification_follow"].stringValue
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        if self.appdelegate.locale != "ko_KR" {
            followText.font = followText.font.fontWithSize(11)
            followWid.constant = 85
        }
        
        self.view.frame = CGRectMake(0, 32, self.view.bounds.size.width, self.view.bounds.size.height-90)
        message = ["my_id":appdelegate.email,"type":"W","page":String(self.all_page)]
        self.isGetData = true
        self.appdelegate.doItSocket(602, message: message) { (readData) -> () in
            if readData == "has error3" {
                self.loading.stopAnimating()
            }else {
                self.log.log("\(readData)")
                self.message = ["my_id":self.appdelegate.email,"type":"M","page":String(self.my_page)]
                self.appdelegate.doItSocket(602, message: self.message) { (readData) -> () in
                    //            print(readData)
                    if readData == "has error3" {
                        self.loading.stopAnimating()
                    }else {
                        self.message = ["my_id":self.appdelegate.email,"type":"F","page":String(self.follow_page)]
                        //        connection = URLConnection(serviceCode: 602, message: message)
                        //        readData = connection.connection()
                        self.appdelegate.doItSocket(602, message: self.message) { (readData) -> () in
                            if readData == "has error3" {
                                self.loading.stopAnimating()
                            }else {
                                if readData["data"] == nil {
                                    self.log.log("readData follow nil")
                                }else {
                                    self.log.log("readData follow")
                                    self.followJSON = readData["data"].array!
                                }
                                
                                
                            }
                        }
                        if readData["data"] == nil {
                            self.log.log("readData my nil")
                        }else {
                            self.log.log("readData my")
                            self.myJSON = readData["data"].array!
                        }
                        
                    }
                }
                
                if readData["data"] == nil {
                    self.log.log("readData all data nil")
                    self.count = 0
                    self.noalarmView.hidden = false
                }else {
                    self.log.log("readData all")
                    self.log.log("laksdjfo;eijx;clvje;voij;flkn;lxgeq;oijgl;jda;dsj;oivajds;ofjf")
                    self.allJSON = readData["data"].array!
                    self.count = self.allJSON.count
                    self.data = self.allJSON
                    self.alarmtableview.reloadData()
                    if self.count == 0 {
                        self.noalarmView.hidden = false
                    }else {
                        self.noalarmView.hidden = true
                    }
                }
                self.isGetData = false
            }
        }
        alarmtableview.reloadData()
        
    }
    
    func getData(json:JSON){
        if json["data"] == nil {
            loadingCount = -1
//            print("\(all_page)\(my_page)\(follow_page)")
            if self.allT {
                if all_page == 1 {
                    self.count = 0
                }
            }else if self.myT {
                if my_page == 1 {
                    self.count = 0
                }
            }else if self.followT {
                if follow_page == 1 {
                    self.count = 0
                }
            }
            self.isGetData = false
            loading.stopAnimating()
            return
        }else {
            loadingCount = 1
            log.log("data not nil")
            if let post = json["data"].array {
                
                if self.allT {
                    for data in post {
                        self.allJSON.append(data)
                    }
                    self.data = self.allJSON
                    self.count = self.allJSON.count
                }else if self.myT {
                    for data in post {
                        self.myJSON.append(data)
                    }
                    self.data = self.myJSON
                    self.count = self.myJSON.count
                }else if self.followT {
                    for data in post {
                        self.followJSON.append(data)
                    }
                    self.data = self.followJSON
                    self.count = self.followJSON.count
                }
                
                self.count = self.data.count
            }
            self.isGetData = false
            self.log.log("\(self.data)")
            self.log.log("count : \(self.count)")
            self.log.log("data count : \(self.data.count)")
        }
        
        loading.stopAnimating()
        if self.count == 0 {
            self.noalarmView.hidden = false
        }else {
            self.noalarmView.hidden = true
        }
        
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if !isGetData {
            if (sender.direction == .Left) {
                if allT {
                    my()
                }else if myT {
                    follow()
                }
            }
            
            if (sender.direction == .Right) {
                if followT {
                    my()
                }else if myT {
                    all()
                }
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func allAlarm(sender: AnyObject) {
        all()
    }
    
    @IBAction func myAlarm(sender: AnyObject) {
        my()
    }
    
    @IBAction func followAlarm(sender: AnyObject) {
        follow()
    }
    
    func refresh() {
        if allT {
            all()
        }else if myT {
            my()
        }else if followT {
            follow()
        }
    }
    
    
    func all() {
        if isGetData {
            return
        }
        isGetData = true
        self.alarmtableview.scrollsToTop = true
        self.alarmtableview.contentOffset.y = 0
        self.alarmtableview.indexPathForRowAtPoint(CGPoint(x: 0, y: 0))
        
        
        allT = true
        followT = false
        myT = false
        
        allText.textColor = UIColor.blackColor()
        allText.font = UIFont(name: "Helvetica-Bold", size: 14)
        allImage.image = UIImage(named: "all")
        allSelectBar.image = UIImage(named: "imv_find_selectbar")
        
        myText.textColor = UIColor.lightGrayColor()
        myText.font = UIFont(name: "Helvetica", size: 14)
        myImage.image = UIImage(named: "icon_alarm_follower")
        mySelectBar.image = UIImage()
        
        followText.textColor = UIColor.lightGrayColor()
        if self.appdelegate.locale != "ko_KR" {
            followText.font = UIFont(name: "Helvetica", size: 11)
            followWid.constant = 85
        }else{
            followText.font = UIFont(name: "Helvetica", size: 14)
        }
        
        
        followImage.image = UIImage(named: "icon_alarm_following")
        followSelectBar.image = UIImage()
        
        
        self.data = self.allJSON
        self.count = self.data.count
        self.allJSON.removeAll()
        
        if self.count == 0 {
            self.noalarmView.hidden = false
        }else {
            self.noalarmView.hidden = true
        }
        self.all_page = 1
        self.sendData("W", page: String(self.all_page))
        
        //        message = ["my_id":appdelegate.email,"type":"W","page":String(all_page)]
        //        connection = URLConnection(serviceCode: 602, message: message)
        //        readData = connection.connection()
        //        self.appdelegate.doItSocket(602, message: message) { (readData) -> () in
        //            print(readData)
        //
        //            self.getData(readData)
        //            self.alarmtableview.reloadData()
        //        }
        
        
    }
    
    func my() {
        log.log("my in \(self.isGetData)")
        if isGetData {
            return
        }
        isGetData = true
        self.alarmtableview.scrollsToTop = true
        self.alarmtableview.contentOffset.y = 0
        self.alarmtableview.indexPathForRowAtPoint(CGPoint(x: 0, y: 0))
        allT = false
        followT = false
        myT = true
        
        myText.textColor = UIColor.blackColor()
        myText.font = UIFont(name: "Helvetica-Bold", size: 14)
        myImage.image = UIImage(named: "icon_alarm_follower_c")
        mySelectBar.image = UIImage(named: "imv_find_selectbar")
        
        allText.textColor = UIColor.lightGrayColor()
        allText.font = UIFont(name: "Helvetica", size: 14)
        allImage.image = UIImage(named: "all_copy")
        allSelectBar.image = UIImage()
        
        followText.textColor = UIColor.lightGrayColor()
        if self.appdelegate.locale != "ko_KR" {
            followText.font = UIFont(name: "Helvetica", size: 11)
            followWid.constant = 85
        }else{
            followText.font = UIFont(name: "Helvetica", size: 14)
        }
        followImage.image = UIImage(named: "icon_alarm_following")
        followSelectBar.image = UIImage()
        
        
        self.data = self.myJSON
        self.count = self.myJSON.count
        self.myJSON.removeAll()
        
        if self.count == 0 {
            self.noalarmView.hidden = false
        }else {
            self.noalarmView.hidden = true
        }
        self.my_page = 1
        self.sendData("M", page: String(self.my_page))
        log.log("my page : \(my_page)")
        
        //        message = ["my_id":appdelegate.email,"type":"M","page":String(my_page) ]
        //        print(message)
        //        connection = URLConnection(serviceCode: 602, message: message)
        //        readData = connection.connection()
        //        self.appdelegate.doItSocket(602, message: message) { (readData) -> () in
        //            print(readData)
        //            self.getData(readData)
        //            self.alarmtableview.reloadData()
        //        }
        
    }
    
    func follow() {
        if isGetData {
            return
        }
        isGetData = true
        
        self.alarmtableview.scrollsToTop = true
        self.alarmtableview.contentOffset.y = 0
        self.alarmtableview.indexPathForRowAtPoint(CGPoint(x: 0, y: 0))
        
        allT = false
        followT = true
        myT = false
        
        followText.textColor = UIColor.blackColor()
        if self.appdelegate.locale != "ko_KR" {
            followText.font = UIFont(name: "Helvetica-Bold", size: 11)
            followWid.constant = 85
        }else{
            followText.font = UIFont(name: "Helvetica-Bold", size: 14)
        }
        followImage.image = UIImage(named: "icon_alarm_following_c")
        followSelectBar.image = UIImage(named: "imv_find_selectbar")
        
        
        myText.textColor = UIColor.lightGrayColor()
        myText.font = UIFont(name: "Helvetica", size: 14)
        myImage.image = UIImage(named: "icon_alarm_follower")
        mySelectBar.image = UIImage()
        
        allText.textColor = UIColor.lightGrayColor()
        allText.font = UIFont(name: "Helvetica", size: 14)
        allImage.image = UIImage(named: "all_copy")
        allSelectBar.image = UIImage()
        
        self.data = self.followJSON
        self.count = self.followJSON.count
        self.followJSON.removeAll()
        
        if self.count == 0 {
            self.noalarmView.hidden = false
        }else {
            self.noalarmView.hidden = true
        }
        self.follow_page = 1
        self.sendData("F", page: String(follow_page))
        
        //        message = ["my_id":appdelegate.email,"type":"F","page":String(follow_page)]
        //        connection = URLConnection(serviceCode: 602, message: message)
        //        readData = connection.connection()
        //        self.appdelegate.doItSocket(602, message: message) { (readData) -> () in
        //            print(readData)
        //            self.getData(readData)
        //            self.alarmtableview.reloadData()
        //        }
        
    }
    
    func sendData(type : String, page : String){
        loading.startAnimating()
        message = ["my_id":appdelegate.email,"type":type,"page":page]
        self.appdelegate.doItSocket(602, message: message) { (readData) -> () in
            if readData == "has error3" {
                self.loading.stopAnimating()
            }else {
                self.getData(readData)
                self.alarmtableview.reloadData()
            }
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let Rowdata = self.data[indexPath.row]
        
        if Rowdata["type"].string! == "PL" || Rowdata["type"].stringValue == "TMP" {
            //post
            log.log("post in")
            let post = self.storyboard!.instantiateViewControllerWithIdentifier("PostPageViewController")as! PostPageViewController
            self.appdelegate.controller.append(post)
//            post.index = self.appdelegate.controller.count - 1
            post.type = "post"
            post.email = self.appdelegate.email
            post.postId = Rowdata["target_id_1"].string!
            self.appdelegate.testNavi.navigationBarHidden = true
            self.appdelegate.testNavi.pushViewController(post, animated: true)
        }else if Rowdata["type"].string! == "CL" || Rowdata["type"].string! == "PC" || Rowdata["type"].string! == "TMC" || Rowdata["type"].string! == "RP" {
            //comment
            log.log("comment in")
            let comment = self.storyboard!.instantiateViewControllerWithIdentifier("comment")as! CommentViewController
            self.appdelegate.controller.append(comment)
            comment.type = "comment"
//            comment.index = self.appdelegate.controller.count - 1
            comment.my_id = self.appdelegate.email
            comment.post_id = Rowdata["target_id_1"].string!
            
            let message : JSON = ["my_id":self.appdelegate.email,"post_id":Rowdata["target_id_1"].string!]
            self.appdelegate.doItSocket(504, message: message, callback: { (readData) -> () in
                comment.postEmail = readData["email"].string!
                self.appdelegate.tabbar.view.hidden = true
                self.appdelegate.testNavi.pushViewController(comment, animated: true)
            })
        }else if Rowdata["type"].string! == "FM" || Rowdata["type"].string! == "FP" || Rowdata["type"].string! == "FI" {
            //user
            log.log("user in")
            let user = self.appdelegate.storyboard.instantiateViewControllerWithIdentifier("UserPageViewController")as! UserPageViewController
            self.appdelegate.controller.append(user)
            user.type = "user"
//            user.index = self.appdelegate.controller.count - 1
            user.myId = self.appdelegate.email
            user.userId = Rowdata["who_email"].string!
            self.appdelegate.testNavi.navigationBarHidden = true
            self.appdelegate.testNavi.pushViewController(user, animated: true)
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let Rowdata = self.data[indexPath.row]
        var cellIdentifier : String = ""
        if let type = Rowdata["type"].string {
            if type == "RM" || type == "FP" || type == "FI" {
                cellIdentifier = "alarmText"
            }else if type == "PL" || type == "CL" || type == "PC" || type == "CMC" || type == "CMP" || type == "TMC" || type == "TMP" || type == "RP" {
                cellIdentifier = "alarmPhoto"
            }else if type == "FM" {
                cellIdentifier = "alarmOneButton"
            }else if type == "" {
                cellIdentifier = "alarmTwoButton"
            }
        }
        let cell = alarmtableview.dequeueReusableCellWithIdentifier(cellIdentifier)as! AlarmTableViewCell
        cell.type = cellIdentifier
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.data = Rowdata
        cell.alarm = self
        cell.setMent()
        var image = UIImage()
        var post = UIImage()
        let imageURL = ImageURL()
        let urlStr = imageURL.imageurl(Rowdata["profile_picture"].string!)
        let postStr = imageURL.imageurl(imageURL.thumnail(Rowdata["url"].string!))
        
        if indexPath.row == self.count-1 {
            log.log("end row")
            if self.allT {
                log.log("allT true \(isGetData)     data count : \(data.count)")
                log.log("all_page \(all_page) loading count : \(loadingCount)")
                if isGetData == false && self.data.count > 8 && all_page < 100 && loadingCount > 0{
                    log.log("page ++ ")
                    self.isGetData = true
                    self.all_page++
                    self.sendData("W", page: String(all_page))
                }else if all_page > 100 {
                    loading.stopAnimating()
                }
                
                //                self.all()
            }else if self.myT && self.data.count > 8 && my_page < 100 && loadingCount > 0{
                if isGetData == false {
                    self.isGetData = true
                    self.my_page++
                    self.sendData("M", page: String(my_page))
                }else if my_page > 100 {
                    loading.stopAnimating()
                }
                //                self.my()
            }else if self.followT && self.data.count > 8 && follow_page < 100 && loadingCount > 0{
                if isGetData == false {
                    self.isGetData = true
                    self.follow_page++
                    self.sendData("F", page: String(follow_page))
                }else if follow_page > 100 {
                    loading.stopAnimating()
                }
                //                self.follow()
            }
        }
        
        
        if cellIdentifier == "alarmPhoto" {
            if let pos = postData[postStr]{
                post = pos
                cell.post = pos
            }else {
                let url = NSURL(string: postStr)
                let postrequest : NSURLRequest = NSURLRequest(URL: url!)
                let postmainQueue = NSOperationQueue.mainQueue()
                NSURLConnection.sendAsynchronousRequest(postrequest, queue: postmainQueue, completionHandler: { (response, data, error) -> Void in
                    if let data = data {
                        if let image = UIImage(data: data) {
                            post = image
                        }else {
                            post = UIImage()
                        }
                        
                        cell.post = post
                        self.postData[postStr] = post
                    }
                })
            }
        }
        if let img = imageData[urlStr] {
            image = img
            cell.setData(image)
        }
        else {
            cell.profileImage.image = UIImage(named: "noprofile")
            
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
                        //                        print("image")
                    })
                }
            }
        }
        return cell
    }
}



