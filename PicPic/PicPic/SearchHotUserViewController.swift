//
//  SearchHotUserViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 9..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SearchHotUserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PPMosaicLayoutDelegate, FollowerViewCellProtocol {

    @IBOutlet weak var collectionView: UICollectionView!
    var hotUserDatas: Array<[String: AnyObject]> = []
    var gifDatas: [String: UIImage] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerNib(UINib(nibName: "HotUserCell", bundle: nil), forCellWithReuseIdentifier: "hotUserCell")
        self.collectionView.registerNib(UINib(nibName: "HotUserPostCell", bundle: nil), forCellWithReuseIdentifier: "hotUserPostCell")
        self.collectionView.registerNib(UINib(nibName: "HomeNativeReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "mainReusableView")
        
        let layout = PPMosaicLayout()
        layout.delegate = self
        self.collectionView.collectionViewLayout = layout
        self.collectionView.bounces = false
        // Do any additional setup after loading the view.
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh()
    {
        self.hotUserDatas = []
        self.gifDatas = [:]
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let message = JSON(["my_id" : appdelegate.email])
        appdelegate.doIt(513, message: message, callback: {(json) in
            self.hotUserDatas = json["hot"].arrayObject as! Array<[String: AnyObject]>
            self.collectionView.reloadData()
        })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.hotUserDatas.count * 5
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.item % 10 == 0 || indexPath.item % 10 == 7 // users
        {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("hotUserCell", forIndexPath: indexPath) as! HotUserCell
            cell.cellIndexPath = indexPath
            cell.delegate = self
            
            let dic = self.hotUserDatas[indexPath.item / 5]
            
            cell.idLabel.text = dic["id"] as? String
            cell.profileImageView.sd_setImageWithURL(NSURL(string: "http://gif.picpic.world/" + (dic["profile_picture"]! as! String))!)
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.profileImageView.layer.masksToBounds = true
            
            if dic["follow_yn"] as! String != "N"
            {
                cell.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
            }
            
            cell.backgroundColor = (indexPath.item / 5 % 2 == 0) ? UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1) : UIColor.whiteColor()
            
            //bodyLabel
            let label = ActiveLabel()
            label.numberOfLines = 0
            label.lineSpacing = 4
            label.font = UIFont.systemFontOfSize(13)
            label.textAlignment = .Center
            
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            let tag1 = (dic["tag1_name"] as! String == "null") ? "" : "#" + (dic["tag1_name"] as! String)
            let tag2 = (dic["tag2_name"] as! String == "null") ? "" : "#" + (dic["tag2_name"] as! String)
            let tag3 = (dic["tag3_name"] as! String == "null") ? "" : "#" + (dic["tag3_name"] as! String)
            label.text = "\(tag1) \(tag2) \(tag3)"
            
            label.handleHashtagTap({(string) in
                let vc = TagNativeViewController()
                vc.tagName = string.substringFromIndex(string.startIndex.advancedBy(1))
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
            label.frame = CGRectMake(0, 0, cell.bodyView.frame.width, 20)
            cell.bodyViewHeightConstraints.constant = 20
            cell.bodyView.addSubview(label)
            
            return cell
        }
        else //post
        {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("hotUserPostCell", forIndexPath: indexPath) as! HotUserPostCell
            
            var index = indexPath.item / 5
            
            if index % 2 == 0 //left
            {
                index = index * 5 + (indexPath.item % 5) - 1
            }
            else
            {
                index = index * 5
                if indexPath.item % 5 > 2
                {
                    index += (indexPath.item % 5) - 1
                }
                else
                {
                    index += indexPath.item % 5
                }
            }
            var url = (self.hotUserDatas[indexPath.item / 5]["best4"] as! [[String: String]])[index % 5]["url"]!
            
            
            if self.gifDatas["\(index)"] == nil
            {
                if url != "null"
                {
                    url = url.substringWithRange(url.startIndex ..< url.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
                    Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                            self.gifDatas["\(index)"] = UIImage.gifWithData(data!) ?? UIImage()
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.gifImageView.image = self.gifDatas["\(index)"]
                            })
                        })
                    }
                }
                else
                {
                    self.gifDatas["\(index)"] = UIImage(named: "non_interest")
                    cell.gifImageView.image = self.gifDatas["\(index)"]
                }
            }
            else
            {
                cell.gifImageView.image = self.gifDatas["\(index)"]
            }
            
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "mainReusableView", forIndexPath: indexPath) as! HomeNativeReusableView
        view.titleLabel.text = "HOT USER"
        
        return view
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.item)
        if indexPath.item % 10 == 0 || indexPath.item % 10 == 7
        {
            let dic = self.hotUserDatas[indexPath.item / 5]
            let vc = UserNativeViewController()
            vc.userEmail = dic["email"] as! String
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            var index = indexPath.item / 5
            
            if index % 2 == 0 //left
            {
                index = index * 5 + (indexPath.item % 5) - 1
            }
            else
            {
                index = index * 5
                if indexPath.item % 5 > 2
                {
                    index += (indexPath.item % 5) - 1
                }
                else
                {
                    index += indexPath.item % 5
                }
            }
            let id = (self.hotUserDatas[indexPath.item / 5]["best4"] as! [[String: String]])[index % 5]["post_id"]!
            
            if id != "null"
            {
                let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let vc = appdelegate.storyboard.instantiateViewControllerWithIdentifier("PostPageViewController")as! PostPageViewController
                vc.postId = id
                vc.email = appdelegate.email
                vc.type = "post"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, numberOfColumnsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath) -> PPMosaicCellSize {
        return (indexPath.item % 10 == 0 || indexPath.item % 10 == 7) ? .Big : .Small
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func followTouched(indexPath: NSIndexPath) {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if self.hotUserDatas[indexPath.item / 5]["follow_yn"] as! String == "N"
        {
            self.hotUserDatas[indexPath.item / 5]["follow_yn"] = "Y"
        }
        else
        {
            self.hotUserDatas[indexPath.item / 5]["follow_yn"] = "N"
        }
        
        let type : String!
        let email = self.hotUserDatas[indexPath.item / 5]["email"]! as! String
        
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

}
