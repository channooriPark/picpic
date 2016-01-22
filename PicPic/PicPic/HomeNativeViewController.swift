//
//  HomeNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 12..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeNativeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PPMosaicLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tagData: Array<[String: String]> = []
    var gifData: [String : NSData] = [ : ]
    var recommendData: JSON?
    var _hud: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _hud = MBProgressHUD()
        _hud!.mode = MBProgressHUDModeIndeterminate
        _hud!.center = self.view.center
        self.view.addSubview(_hud!)
        _hud!.hide(false)
        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerNib(UINib(nibName: "HomeTagCell", bundle: nil), forCellWithReuseIdentifier: "mainCell")
        
        
        let layout = PPMosaicLayout()
        layout.delegate = self
        self.collectionView.collectionViewLayout = layout
        self.collectionView.bounces = false
        
        self.refresh()
    }
    
    func refresh()
    {
        self._hud!.show(true)
        self.gifData = [ : ]
        self.tagData = []
        self.collectionView.setContentOffset(CGPointZero, animated: false)
        self.collectionView.reloadData()
        
        let appdelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        //514, 411
        let message = JSON(["my_id": appdelegate.email])
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
            
            appdelegate.doItSocket(514, message: message, callback: {(json) in
                print(json)
                
                for dic in json["locale"].array!
                {
                    self.tagData.append(dic.dictionaryObject as! [String : String])
                }
                for dic in json["interest"].array!
                {
                    self.tagData.append(dic.dictionaryObject as! [String: String])
                }

                for (index, dic) in self.tagData.enumerate()
                {
                    let url = dic["url"]!.substringWithRange(dic["url"]!.startIndex ..< dic["url"]!.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {

                        if let gifURL = NSURL(string: "http://gif.picpic.world/" + url)
                        {
                            self.gifData["\(index)"] = NSData(contentsOfURL: gifURL) ?? NSData()
                        }
                        if self.tagData.count == self.gifData.count
                        {
                            dispatch_sync(dispatch_get_main_queue(), {
                                self.collectionView.reloadData()
                                self._hud!.hide(true)
                            })
                        }
                    })
                }
                
            })
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 5
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

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
            return self.gifData.count - 18 >= 0 ? self.gifData.count - 18 : 0
        }
        
        return 9

    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("mainCell", forIndexPath: indexPath) as! HomeTagCell
        cell.cellIndexPath = indexPath

        if self.gifData.count >= indexPath.item + 1
        {
            if indexPath.section == 0 || indexPath.section == 2 || indexPath.section == 4
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var index = indexPath.item
                    if indexPath.section == 2
                    {
                        index += self.collectionView.numberOfItemsInSection(0)
                    }
                    else if indexPath.section == 4
                    {
                        index += self.collectionView.numberOfItemsInSection(0) + self.collectionView.numberOfItemsInSection(2)
                    }
                    
                    let gif = UIImage.gifWithData(self.gifData["\(index)"]!)// gif init background

                    
                    if self.gifData["\(index)"]!.isEqualToData(NSData()){print("empty!")}
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.gifImageView.image = gif
                        let text = self.tagData[index]["tag_name"]
                        cell.tagLabel.text = "#\(text!)"

                        cell.tagLabel.sizeToFit()
                    })
                })
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath.item) \(self.collectionView.cellForItemAtIndexPath(indexPath)!.bounds)")
        
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
    
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
