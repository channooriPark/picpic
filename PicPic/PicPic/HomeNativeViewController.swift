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
    var gifData: [NSData] = []
    var recommendData: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerNib(UINib(nibName: "HomeTagCell", bundle: nil), forCellWithReuseIdentifier: "mainCell")
        
        
        let layout = PPMosaicLayout()
        layout.delegate = self
        self.collectionView.collectionViewLayout = layout
        
        self.refresh()
    }
    
    func refresh()
    {
        let appdelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        //514, 411
        let message = JSON(["my_id": appdelegate.email])
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
            
            appdelegate.doItSocket(514, message: message, callback: {(json) in
                
                for dic in json["interest"].array!
                {
                    let data = dic.dictionaryObject as! [String : String]
                    self.tagData.append(data)
                }
                dispatch_async(dispatch_get_main_queue(), { self.collectionView.reloadData()})
            })
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.tagData.count)
        return self.tagData.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("mainCell", forIndexPath: indexPath) as! HomeTagCell
        cell.cellIndexPath = indexPath
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let gif = self.gifData.count >= indexPath.row + 1 ? UIImage.gifWithData(self.gifData[indexPath.row]) : UIImage.gifWithData(NSData(contentsOfURL: NSURL(string: "http://gif.picpic.world/" + self.tagData[indexPath.row]["url"]!)!)!)
            dispatch_async(dispatch_get_main_queue(), {
                cell.gifImageView.image = gif
            })
        })
        
        //cell.gifImageView.image = UIImage.animatedImageWithAnimatedGIFURL(NSURL(string: self.tagData[indexPath.row]["url"]!))
        /*if (indexPath.item % 6) == 0
        {
        
        }
        else
        {
        if (indexPath.item % 6) == 1 || (indexPath.item % 6) == 5
        {
        cell.backgroundColor = UIColor.blueColor()
        }
        if (indexPath.item % 6) == 2 || (indexPath.item % 6) == 4
        {
        cell.backgroundColor = UIColor.redColor()
        }
        }*/
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath.item) \(self.collectionView.cellForItemAtIndexPath(indexPath)!.bounds)")
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, numberOfColumnsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath) -> PPMosaicCellSize {
        return (indexPath.item == 0 || indexPath.item == 7) ? .Big : .Small
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
