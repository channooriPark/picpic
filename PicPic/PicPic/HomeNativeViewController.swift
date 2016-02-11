//
//  HomeNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 12..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class HomeNativeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PPMosaicLayoutDelegate, HomeFriendCellProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var tagData: Array<[String: String]>  = []
    var gifData: [String : UIImage] = [ : ]
    var friendData: Array<[String: String]> = []{
        didSet{
            if friendData.count == 12 && self.tagData.count > 0
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self._hud.hide(true)
                    self.collectionView.reloadData()
                })
            }
        }
    }
    
    
    var _hud: MBProgressHUD = MBProgressHUD()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        self.appdelegate.testNavi.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        _hud.mode = MBProgressHUDModeIndeterminate
        _hud.center = self.view.center
        self.view.addSubview(_hud)
        _hud.hide(false)
        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerNib(UINib(nibName: "HomeTagCell", bundle: nil), forCellWithReuseIdentifier: "mainCell")
        self.collectionView.registerNib(UINib(nibName: "HomeFriendCell", bundle: nil), forCellWithReuseIdentifier: "mainFriendCell")
        self.collectionView.registerNib(UINib(nibName: "HomeNativeReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "mainReusableView")
        
        let layout = PPMosaicLayout()
        layout.delegate = self
        self.collectionView.collectionViewLayout = layout
        self.collectionView.bounces = false
        
        self.refresh()
    }
    
    func refresh()
    {
        self._hud.show(true)
        self.gifData = [:]
        self.tagData = []
        self.friendData = []
        
        self.collectionView.setContentOffset(CGPointZero, animated: false)
        self.collectionView.reloadData()
        
        let appdelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        //514, 411
        let message = JSON(["my_id": appdelegate.email])
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
            appdelegate.doItSocket(514, message: message, callback: {(json) in
                for dic in json["locale"].array!
                {
                    self.tagData.append(dic.dictionaryObject as! [String : String])
                }
                for dic in json["interest"].array!
                {
                    self.tagData.append(dic.dictionaryObject as! [String: String])
                }
                appdelegate.doItSocket(411, message: message, callback: {(json) in
                    print(json)
                    for dic in json["friends"].array!
                    {
                        self.friendData.append(dic.dictionaryObject as! [String : String])
                    }
                    appdelegate.doItSocket(411, message: message, callback: { (json) in
                        for dic in json["friends"].array!
                        {
                            self.friendData.append(dic.dictionaryObject as! [String : String])
                        }
                        
//                        for (index, dic) in self.tagData.enumerate()
//                        {
//                            let url = dic["url"]!.substringWithRange(dic["url"]!.startIndex ..< dic["url"]!.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
//                            
//                            Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
//                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
//                                    self.gifData["\(index)"] = UIImage.gifWithData(data!) ?? UIImage()
//                                })
//                            }
//                            
//                        }
//                        
//                        
//                        for (index, dic) in self.friendData.enumerate()
//                        {
//                            Alamofire.request(.GET, "http://gif.picpic.world/" + dic["profile_picture"]!, parameters: ["foo": "bar"]).response { request, response, data, error in
//                                self.imageData["\(index)"] = UIImage(data:data!)
//                            }
//                        }
                        
                        
                    })
                })
                
            })
        })
    
    }
    
    func fire()
    {
    }
    
    
    
    func followClicked(indexPath: NSIndexPath) {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if self.friendData[indexPath.item]["follow_yn"] == "N"
        {
           self.friendData[indexPath.item]["follow_yn"] = "Y"
        }
        else
        {
            self.friendData[indexPath.item]["follow_yn"] = "N"
        }

        let type : String!
        let email = self.friendData[indexPath.item]["email"]! as String
        
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
        appdelegate.doIt(402, message: message, callback: {(json) in})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, heightForHeaderInSection section: Int) -> CGFloat {
        if tagData.count < 18 { return 0.0 }
        
        if section == 1 || section == 3 || section == 4
        {
            return 40.0
        }
        
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tagData.count < 18 { return 0 }
        
        if section == 0
        {
            return 6
        }
        else if section == 2
        {
            return 12
        }
        else if section == 4
        {
            return self.tagData.count - 18 >= 0 ? self.tagData.count - 18 : 0
        }
        
        return 6

    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 || indexPath.section == 2 || indexPath.section == 4 // tags
        {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("mainCell", forIndexPath: indexPath) as! HomeTagCell
            cell.cellIndexPath = indexPath
            
            var index = indexPath.item
            if indexPath.section == 2
            {
                index += self.collectionView.numberOfItemsInSection(0)
            }
            else if indexPath.section == 4
            {
                index += self.collectionView.numberOfItemsInSection(0) + self.collectionView.numberOfItemsInSection(2)
            }

            if self.gifData["\(index)"] == nil
            {
                let dic = self.tagData[index]
                let url = dic["url"]!.substringWithRange(dic["url"]!.startIndex ..< dic["url"]!.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
                Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                        self.gifData["\(index)"] = UIImage.gifWithData(data!) ?? UIImage()
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.gifImageView.image = self.gifData["\(index)"]
                        })
                    })
                }
            }
            else
            {
                cell.gifImageView.image = self.gifData["\(index)"]
            }
            let text = self.tagData[index]["tag_name"]
            cell.tagLabel.font = (index == 0 || index == 7 || index == 12) ? UIFont.systemFontOfSize(18) : UIFont.systemFontOfSize(13)
            cell.tagLabel.text = "#\(text!)"
            
            return cell
        }
        else //recommands
        {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("mainFriendCell", forIndexPath: indexPath) as! HomeFriendCell
            cell.backgroundColor = (indexPath.item % 2 == 1) ? UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1) : UIColor.whiteColor()
            cell.cellIndexPath = indexPath
            cell.delegate = self
            
            var index = indexPath.item
            
            if indexPath.section == 3 {index += 6}
            
            if self.friendData.count < index + 1{
                return cell
            }

            cell.profileImageView.sd_setImageWithURL(NSURL(string: "http://gif.picpic.world/" + self.friendData[index]["profile_picture"]!), placeholderImage: UIImage(named: "noprofile"))
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.profileImageView.layer.masksToBounds = true
            
            cell.nameLabel.text = self.friendData[index]["id"]!
            cell.nameLabel.sizeToFit()
            cell.nameLabel.center.x = cell.profileImageView.center.x

            
            if self.friendData[index]["follow_yn"] != "N"
            {
                cell.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
            }
            
            return cell
        }
       
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "mainReusableView", forIndexPath: indexPath) as! HomeNativeReusableView
        view.titleLabel.text = (indexPath.section == 4) ? "인기태그" : "추천친구"
        
        return view
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath.section == 0 || indexPath.section == 2 || indexPath.section == 4
        {
            var index = indexPath.item
            if indexPath.section == 2
            {
                index += self.collectionView.numberOfItemsInSection(0)
            }
            else if indexPath.section == 4
            {
                index += self.collectionView.numberOfItemsInSection(0) + self.collectionView.numberOfItemsInSection(2)
            }
            
            let vc = TagNativeViewController()
            vc.tagName = self.tagData[index]["tag_name"]!

            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            var index = indexPath.item
            if indexPath.section == 3 {index += 6}
            
            let vc = UserNativeViewController()
            vc.userEmail = self.friendData[index]["email"]!
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, numberOfColumnsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath) -> PPMosaicCellSize {
//        return (indexPath.item == 0 || indexPath.item == 7) ? .Big : .Small
        if indexPath.section == 0
        {
            return (indexPath.item == 0) ? .Big : .Small
        }
        else if indexPath.section == 2
        {
            return (indexPath.item == 1 || indexPath.item == 6) ? .Big : .Small
        }
        
        return .Small
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
}
