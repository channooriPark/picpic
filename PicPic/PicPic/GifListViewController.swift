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
    var assetArr:[PHAsset] = []
    var list_gif:[String] = []
    var list_work:[String] = []
    let fileManager = NSFileManager.defaultManager()
    var selectMode = 0 // 0:일반 1:선택
    var selectArr:[Int] = []
    var commentView : CommentViewController?
    var delegate : GifListDelegate?
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var collectionView: UICollectionView!
    
    let asset = ALAssetsLibrary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GIFLIST")
        
        let nib = UINib(nibName: "SaveCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        let images = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
        print("images.count            ",images.count)
        for var i=0;i<images.count;i++ {
            let img = images[i] as! PHAsset
            print("img            ",img)
            
            if #available(iOS 9.0, *) {
                
                if let filename = img.valueForKey("filename")
                {
                    print(filename)
                    if filename.lowercaseString.hasSuffix(".gif") {
                        print(filename," is gif ")
                        img.requestContentEditingInputWithOptions(PHContentEditingInputRequestOptions()) { (input, _) in
                            let url = input!.fullSizeImageURL
                            print(url) // 배열에 담아 콜렉션 뷰에 로드하면 됨.
                            self.assetArr.append(img)
                            self.collections.append(UIImage(data: NSData(contentsOfURL: url!)!)!)
                        }
                    } else {
                        print("not gif ",i)
                    }
                }
                
            } else {
            }
            
        }
            self.collectionView.reloadData()
            print("collections count      ",self.collections.count)
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        print("deselect22222 ",indexPath.item)
        delegate?.addSelected(self.collections[indexPath.item],asset: self.assetArr[indexPath.item])
        self.navigationController?.popViewControllerAnimated(true)
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
        print("numberofiteminsection   ",collections.count)
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
        return UIEdgeInsetsMake(0.0, 100.0, 100.0, 100.0)
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

protocol GifListDelegate
{
    func addSelected(image : UIImage,asset:PHAsset)
}


