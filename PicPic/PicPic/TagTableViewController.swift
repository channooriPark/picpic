//
//  TagTableViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 17..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON


class TagTableViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tagTable: UITableView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var data = [JSON]()
    var imageData = [String:UIImage]()
    let log = LogPrint()
    var range : NSRange!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tagTable.dataSource = self
        self.tagTable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tagcell")as! TagPeopleTableViewCell
        
        
        let Rowdata = data[indexPath.row]
        log.log("Rowdata : \(Rowdata)")
        cell.data = Rowdata
        
        var image = UIImage()
        let imageURL = ImageURL()
        let urlStr = imageURL.imageurl(Rowdata["profile_picture"].string!)
        
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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        log.log("\(indexPath.row)")
        log.log("oasjdf;lkejo;ajidjfe")
        
        let data = self.data[indexPath.row]
        log.log("\(data)")
        var count = self.appdelegate.testNavi.viewControllers.count-1
        if count < 0 {
            count = 0
        }
        //        print(count)
        var a = self.appdelegate.testNavi.viewControllers[count] as! SubViewController
        
        if a.type == "comment" {
            let b = a as! CommentViewController
            b.replaceText(data["id"].string!)
        }
        
    }
    
    
    func searchTag(str : String) {
        log.log("ddd")
        var page = 1
        let message : JSON = ["my_id":self.appdelegate.email,"str":str,"page":String(page)]
        self.appdelegate.doIt(512, message: message) { (readData) -> () in
            if let post = readData["friend"].array {
                if post.count != 0 {
                    self.data.removeAll()
                }
                
                for data in post {
                    if data != nil {
                        self.log.log("data : \(data)")
                        self.data.append(data)
                            
                    }
                        
                }
                
            }
            self.view.hidden = false
            self.tagTable.reloadData()
        }
    }
    
    
    
}
