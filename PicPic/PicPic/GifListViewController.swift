//
//  GifListViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2016. 1. 3..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class GifListViewController: UIViewController , RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    var collectionType = 0 // 0:임시저장 1:gifs
    var collections:[UIImage] = []
    var list_gif:[String] = []
    var list_work:[String] = []
    let fileManager = NSFileManager.defaultManager()
    var selectMode = 0 // 0:일반 1:선택
    var selectArr:[Int] = []
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let images = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
        print("images.count            ",images.count)
        
        
        for var i=0;i<images.count;i++ {
            let img = images[i] as! PHAsset
            print("img            ",img)
            if #available(iOS 9.0, *) {
                let resources = PHAssetResource.assetResourcesForAsset(img)
                print("resources.count       ",resources.count,"          ", resources)
                if resources.count > 0 {
                    let filename = (resources[0] as PHAssetResource).originalFilename
                    print(filename)
                    if filename.lowercaseString.hasSuffix(".gif") {
                        print(filename," is gif ")
                        img.requestContentEditingInputWithOptions(PHContentEditingInputRequestOptions()) { (input, _) in
                            let url = input!.fullSizeImageURL
                            print(url) // 배열에 담아 콜렉션 뷰에 로드하면 됨.
                            self.collections.append(UIImage(data: NSData(contentsOfURL: url!)!)!)
                        }
                    } else {
                        print("not gif ",i)
                    }
                }
            } else {
            }
            
        }
        collectionView.reloadData()
    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath){
        
        print("deselect ",indexPath.item)
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        let threePiecesWidth = floor(screenWidth / 3.0 - ((2.0 / 3) * 2))
        //let twoPiecesWidth = floor(screenWidth / 2.0 - (2.0 / 2))
        return CGSizeMake(threePiecesWidth, threePiecesWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 2.0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("gifCell", forIndexPath: indexPath) as! RACollectionViewCell
        
        
        cell.imageView.image = self.collections[indexPath.item]
        cell.layer.borderWidth = 3.0;
        cell.layer.borderColor = UIColor.blackColor().CGColor
        return cell
    }
    
    // 드래그앤 드롭 지원 여부
    func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
    }
    
    func collectionView(collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 0.3
        }
    }
    
    func scrollTrigerPaddingInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, self.collectionView.contentInset.bottom, 0)
    }
    
}
