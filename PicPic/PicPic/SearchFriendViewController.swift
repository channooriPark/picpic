//
//  AlramViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 26..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchFriendViewController: SubViewController ,UITableViewDataSource , UITableViewDelegate {
    
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var fbImage: UIImageView!
    @IBOutlet weak var fbSelectBar: UIImageView!
    @IBOutlet weak var ggButton: UIButton!
    @IBOutlet weak var ggImage: UIImageView!
    @IBOutlet weak var ggSelectBar: UIImageView!
    @IBOutlet weak var recomImage: UIImageView!
    @IBOutlet weak var recomButton: UIButton!
    @IBOutlet weak var recomSelectBar: UIImageView!
    @IBOutlet weak var fbText: UILabel!
    @IBOutlet weak var ggText: UILabel!
    @IBOutlet weak var recomText: UILabel!
    @IBOutlet weak var tblFriend: UITableView!
    @IBOutlet weak var whereLabel: UILabel!
    
    var fbT = true
    var recomT = false
    var ggT = false
    var id = "";
    var count = 0
    var dict : NSDictionary!
    
    let friendData = NSMutableArray()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        self.navigationItem.title = self.appdelegate.ment["find_friend"].stringValue
        
        fbText.text = self.appdelegate.ment["find_friend_facebook"].stringValue
        ggText.text = self.appdelegate.ment["find_friend_google"].stringValue
        recomText.text = self.appdelegate.ment["find_friend_recommend"].stringValue
        
        if self.appdelegate.locale != "ko_KR" {
            fbText.font = UIFont(name: "Helvetica", size: 12)
            ggText.font = UIFont(name: "Helvetica", size: 12)
            recomText.font = UIFont(name: "Helvetica", size: 12)
        }else{
            fbText.font = UIFont(name: "Helvetica", size: 14)
            ggText.font = UIFont(name: "Helvetica", size: 14)
            recomText.font = UIFont(name: "Helvetica", size: 14)
        }

        facebook()

    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func onFacebook(sender: AnyObject) {
        facebook()
    }
    
    @IBAction func onGoogle(sender: AnyObject) {
        google()
    }
    
    @IBAction func onRecommend(sender: AnyObject) {
        recommend()
    }
    
    
    func facebook() {
        
        fbT = true
        recomT = false
        ggT = false
        
        fbText.textColor = UIColor.blackColor()
        fbSelectBar.image = UIImage(named: "imv_find_selectbar")
        
        ggText.textColor = UIColor.lightGrayColor()
        ggSelectBar.image = UIImage()
        
        recomText.textColor = UIColor.lightGrayColor()
        recomSelectBar.image = UIImage()
        
        getFriendData(0);
        
    }
    
    func google() {

        fbT = false
        recomT = false
        ggT = true
        
        ggText.textColor = UIColor.blackColor()
        ggSelectBar.image = UIImage(named: "imv_find_selectbar")
        
        fbText.textColor = UIColor.lightGrayColor()
        fbSelectBar.image = UIImage()
        
        recomText.textColor = UIColor.lightGrayColor()
        recomSelectBar.image = UIImage()
        
        getFriendData(1);
        
    }
    
    func recommend() {
        
        fbT = false
        recomT = true
        ggT = false
        
        recomText.textColor = UIColor.blackColor()
        recomSelectBar.image = UIImage(named: "imv_find_selectbar")
        
        
        ggText.textColor = UIColor.lightGrayColor()
        ggSelectBar.image = UIImage()
        
        fbText.textColor = UIColor.lightGrayColor()
        fbSelectBar.image = UIImage()
        
        getFriendData(2);
        
        
    }
    
    
    func getFriendData(inwhere : Int) {
        
        
        self.friendData.removeAllObjects();
        
        var inWhereString:String!
        
        var count = 0
        
        switch (inwhere) {
            
        case 0: // fb
            let message : JSON = ["my_id":self.appdelegate.email,"user_id":self.appdelegate.email]
            self.appdelegate.doIt(406, message: message) { (readData) -> () in
                print(self.appdelegate.email);
                //self.id = readData["id"].string!
            }
            
            //let dic = NSDictionary(objects: "location", forKeys: "with");
            inWhereString = self.appdelegate.ment["facebook_friend"].stringValue
            
            let params = ["fields": "id, name, first_name, last_name, picture.type(large), email"]
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
            graphRequest.startWithCompletionHandler({ (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                if(error == nil)
                {
                    self.dict = result as! NSDictionary;
                    
                    var ar = NSMutableArray();
                    ar = self.dict.objectForKey("data") as! NSMutableArray
                    
                    print(result)
                    
                    for (var i = 0; i < ar.count; i++) {
                        
                        var d = NSDictionary();
                        d = ar.objectAtIndex(i) as! NSDictionary;
                        
                        var profile = String();
                        profile = d.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String
                        
                        let friend = FriendEntity(name: d.objectForKey("name") as! String, profile:profile, first: "", sencond: "", third: "", fourth: "");
                        self.friendData.addObject(friend);
                    }
                    
                    if (inwhere == 0 || inwhere == 1) {
                        self.whereLabel.text = String(format: "%@ %d", inWhereString, self.friendData.count) + self.appdelegate.ment["friend_counter"].stringValue
                    } else {
                        self.whereLabel.text = inWhereString
                    }
                    
                    self.tblFriend.reloadData()
                }
                else
                {
                    print(error)
                }
            });
            count = 10
            break;
            
        case 1: // google
            inWhereString = self.appdelegate.ment["google_friend"].stringValue
            
            /*var plusService: GTLServicePlus = GTLServicePlus()
            plusService.retryEnabled = true
            plusService.authorizer = GPPSignIn.sharedInstance().authentication;
            let query = GTLQueryPlus.queryForActivitiesListWithUserId("me", collection: kGTLPlusCollectionVisible) as? GTLQueryPlus
            
            plusService.executeQuery(query, completionHandler: { (ticket, peopleFeed, error) -> Void in
            
            })*/
            count = 6
            break;
            
        case 2: // recommed
            inWhereString = self.appdelegate.ment["recommend_friend"].stringValue
            count = 3
            break;
            
        default:
            break;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendData.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   
        let cellIdentifier = "friendidentifier"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)as! SearchFriendTableViewCell
        
        let row = indexPath.row
        
        let friend = friendData.objectAtIndex(row) as? FriendEntity
        
        cell.friendname.text = friend!.name
        
        return cell;
    
    }
    
    
}



