//
//  SearchTagViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 8..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchTagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var tagDatas: Array<[String: AnyObject]> = []
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "SearchTagCell", bundle: nil), forCellReuseIdentifier: "searchTagCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tagDatas.count == 1
        {
            if self.tagDatas.first!["tag_name"] as! String == "null"
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
            return self.tagDatas.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("searchTagCell") as! SearchTagCell
        let dic = self.tagDatas[indexPath.row]
        cell.tagLabel.text = dic["tag_name"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dic = self.tagDatas[indexPath.row]
        
        let vc = TagNativeViewController()
        vc.tagName = dic["tag_name"] as! String
        
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setTableWithNewString(str: String)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let message = JSON(["my_id" : appdelegate.email, "str_list" : [["str" : str]], "type" : "T", "page" : "1"])
        appdelegate.doIt(515, message: message, callback: {(json) in
            if json["tag"].type != .Null && json["tag"].stringValue != "null"
            {
                self.tagDatas = json["tag"].arrayObject as! Array<[String : AnyObject]>
                self.tableView.reloadData()
            }
        })
    }
}
