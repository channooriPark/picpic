//
//  SettingBlockAccountTableViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 4..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingBlockAccountTableViewController: UITableViewController {
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var data = [JSON]()
    let log = LogPrint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.appdelegate.ment["settings_protect_id_manage"].stringValue
        self.tableView.delegate = self
        let message : JSON = ["my_id":self.appdelegate.email]
        print(message)
        self.appdelegate.doIt(410, message: message) { (readData) -> () in
            print("readData :  ",readData)
            self.getData(readData)
        }
        
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        
    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func getData(json:JSON){
        if let iddata = json["data"].array{
            for post in iddata {
                self.data.append(post)
            }
        }
        tableView.reloadData()
        log.log("\(self.data)")
        
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("blockAccount")as! SettingBlockTableViewCell
        cell.data = self.data[indexPath.row]
        log.log("\(cell.data)")
        cell.getData()

        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let json = data[indexPath.row]
            
            let message : JSON = ["my_id":self.appdelegate.email,"user_id":json["email"].string!]
            self.appdelegate.doIt(216, message: message, callback: { (readData) -> () in
                if readData["msg"].string! == "success" {
                    self.data.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            })
            
            
        }
    }
    
}
