//
//  SearchUserViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 8..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FollowerViewCellProtocol {

    @IBOutlet weak var tableView: UITableView!
    var userDatas: Array<[String: AnyObject]> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "SearchUserCell", bundle: nil), forCellReuseIdentifier: "searchUserCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("searchUserCell") as! SearchUserCell
        let dic = self.userDatas[indexPath.row]
        cell.profileImageView.sd_setImageWithURL(NSURL(string: "http://gif.picpic.world/" + (dic["profile_picture"]! as! String))!)
        
        cell.delegate = self
        cell.cellIndexPath = indexPath
        
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
        cell.profileImageView.layer.masksToBounds = true
        
        cell.idLabel.text = dic["id"] as? String
        cell.idLabel.sizeToFit()
        
        if dic["follow_yn"] as! String != "N"
        {
            cell.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dic = userDatas[indexPath.row]
        
        let vc = UserNativeViewController()
        vc.userEmail = dic["email"] as! String
        
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userDatas.count == 1
        {
            if self.userDatas.first!["tag_name"] as! String == "null"
            {
                return 0
            }
            else
            {
                return 1
            }
        }
        else
        {
            return self.userDatas.count
        }
    }
    
    func followTouched(indexPath: NSIndexPath) {
        let dic = self.userDatas[indexPath.row]
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if dic["follow_yn"] as! String == "N"
        {
            self.userDatas[indexPath.row]["follow_yn"] = "Y"
        }
        else
        {
            self.userDatas[indexPath.row]["follow_yn"] = "N"
        }
        
        let type : String!
        let email = dic["email"]! as! String
        
        if appdelegate.userData["register_form"].string == "10001" {
            type = "N"
        }else if appdelegate.userData["register_form"].string == "10002" {
            type = "F"
        }else if appdelegate.userData["register_form"].string == "10003" {
            type = "G"
        }else {
            type = "R"
        }
        
        let message : JSON = ["myId":appdelegate.email,"email":[["email" : email]],"type":type]
        appdelegate.doItSocket(402, message: message, callback: {(json) in})
    }
    
    func setTableWithNewString(str: String)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let message = JSON(["my_id" : appdelegate.email, "str" : str, "type" : "U", "page" : "1"])
        appdelegate.doItSocket(515, message: message, callback: {(json) in
            if json["msg"].stringValue == "success"
            {
                self.userDatas = json["user"].arrayObject as! Array<[String : AnyObject]>
                self.tableView.reloadData()
            }
        })
    }
    
}
