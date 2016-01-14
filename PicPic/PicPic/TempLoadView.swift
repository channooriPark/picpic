//
//  TempLoadView.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 7..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class TempLoadView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, SaveCellDelegate {

    @IBOutlet weak var panningView: UIView!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    var parentViewController: CameraViewController?
    var panStartPoint: CGPoint?
    @IBOutlet weak var panImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let kBounceValue: CGFloat = 20.0
    let initialY: CGFloat = UIScreen.mainScreen().bounds.height - 30.0
    let fullOpenY: CGFloat = UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width
    
    var collections:[UIImage] = []
    var list_work:[String] = []
    var selectedIndex: Int?
    
    let fileManager = NSFileManager.defaultManager()
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TempLoadView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    override func awakeFromNib() {
        let nib = UINib(nibName: "SaveCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.loadData()
    }
    
    
    
    @IBAction func closeView() {
        self.parentViewController!.removeTempLoadView()
    }
    
    @IBAction func tapToOpenView(sender: AnyObject) {
        self.setConstsToOpenAll(0.1)
    }
    
    @IBAction func panThisView(sender: UIPanGestureRecognizer) {
        switch (sender.state)
        {
        case UIGestureRecognizerState.Began:
            panStartPoint = self.frame.origin
        case UIGestureRecognizerState.Changed:

            //print(sender.translationInView(self).y)
            
            if self.frame.origin.y + sender.translationInView(self).y < fullOpenY// too high
            {
                self.frame.origin.y = fullOpenY
                panImage.image = UIImage(named: "white_arrow_down")
            }
            else if self.frame.origin.y + sender.translationInView(self).y > initialY// too low
            {
                self.frame.origin.y = initialY
                panImage.image = UIImage(named: "white_arrow_up")
            }
            else
            {
                self.frame.origin.y = panStartPoint!.y + sender.translationInView(self).y
            }
        case UIGestureRecognizerState.Ended:
            if panStartPoint!.y == initialY
            {
                if self.frame.origin.y - ((initialY * 3 + fullOpenY) / 4) > 0//near to start
                {
                    resetConstsToZero(0.1)
                }
                else
                {
                    setConstsToOpenAll(0.1)
                }
            }
            else
            {
                if self.frame.origin.y - ((initialY + fullOpenY * 3) / 4) > 0//near to start
                {
                    resetConstsToZero(0.1)
                }
                else
                {
                    setConstsToOpenAll(0.1)
                }
            }
        case UIGestureRecognizerState.Cancelled:
            if panStartPoint!.y == initialY
            {
                resetConstsToZero(0.1)
            }
            else if panStartPoint!.y == fullOpenY
            {
                setConstsToOpenAll(0.1)
            }
        default:
            break
        }
    }
    
    func updateConstsIfNeeded(animated:Bool, completion:(finished: Bool)-> Void)// open, close시 애니메이션 구현
    {
        var duration: Double = 0.0
        if animated
        {
            duration = 0.1
        }
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
            
            self.parentViewController!.view.layoutIfNeeded()

            }, completion: completion)
        
    }
    
    func setConstsToOpenAll(duration: NSTimeInterval)
    {
        if self.frame.origin.y == fullOpenY
        {
            return
        }
        
        self.frame.origin.y = fullOpenY - kBounceValue
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {_ in
                self.frame.origin.y = self.fullOpenY
                self.parentViewController!.view.layoutIfNeeded()
            }, completion: {_ in self.panImage.image = UIImage(named: "white_arrow_down") })
        
    }
    
    func resetConstsToZero(duration: NSTimeInterval)
    {
        if self.frame.origin.y == initialY
        {
            return
        }
        self.frame.origin.y = initialY + kBounceValue
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {_ in
            self.frame.origin.y = self.initialY
            self.parentViewController!.view.layoutIfNeeded()
            }, completion: {_ in self.panImage.image = UIImage(named: "white_arrow_up") })
    }
    
    
    func loadData() {
        collections.removeAll()
        list_work.removeAll()
        
        do {
            let flist = try fileManager.contentsOfDirectoryAtPath(documentDirectory)
            
            // work 폴더에서 20로 시작되는 폴더들은 임시작업 폴더이며, db.json 정보가 있으면 유효한 폴더, 없으면 삭제처리
            for file_name in flist {
                if(file_name.hasPrefix("20")) {
                    let path = String(format: "%@/%@", arguments: [documentDirectory,file_name])
                    print(path)
                    let attribs:NSDictionary? = try fileManager.attributesOfItemAtPath(path)
                    
                    if let fileattribs = attribs {
                        let type = fileattribs["NSFileType"] as! String
                        if(type == NSFileTypeDirectory) {
                            let dbPath = String(format: "%@/db.json", arguments:[path])
                            print(dbPath)
                            // 없으므로 삭제처리
                            print(fileManager.fileExistsAtPath(dbPath))
                            
                            if fileManager.fileExistsAtPath(dbPath) {
                                
                                
                                let imgPath = String(format:"%@/thumb.jpg",arguments:[path])
                                print(imgPath)
                                print(fileManager.fileExistsAtPath(imgPath))
                                if fileManager.fileExistsAtPath(imgPath) {
                                    print(imgPath)
                                    list_work.append(file_name)
                                    let img = UIImage(contentsOfFile: imgPath)
                                    self.collections.append(img!)
                                    //self.selectArr.append(0)
                                }
                                else
                                {
                                    
                                }
                            }
                            else
                            {
                                do {
                                    try fileManager.removeItemAtPath(path)
                                    print(file_name, " is removed")
                                } catch let error as NSError {
                                    print(error.localizedDescription);
                                }
                            }
                        }
                    }
                    
                }
            }
            self.collectionView.reloadData()
        }
        catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
    let threePiecesWidth = floor(screenWidth / 3.0 - ((2.0 / 3) * 2))
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
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SaveCell
        
        
        cell.imageView.image = self.collections[indexPath.item]
        cell.layer.borderWidth = 3.0;
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.delegate = self
        //cell.layer.borderColor = UIColor.blueColor().CGColor
        
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.collectionView.indexPathsForSelectedItems()?.count > 1
        {
            self.collectionView.deselectItemAtIndexPath(self.collectionView.indexPathsForSelectedItems()?.dropFirst() as! NSIndexPath, animated: false)
        }
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SaveCell
        cell.btnAdd.hidden = false
        cell.btnDelete.hidden = false
        self.selectedIndex = indexPath.row
        print(self.selectedIndex!)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SaveCell
        cell.btnAdd.hidden = true
        cell.btnDelete.hidden = true
    }
    
    
    func addSelected()
    {
        self.closeView()

        let path = self.list_work[selectedIndex!]
        print(path)
        
        let path_gifs = String(format: "%@/gifs", arguments: [documentDirectory])
        
        let gifMakerVC = self.parentViewController!.storyboard?.instantiateViewControllerWithIdentifier("GifMakerViewController") as? GifMakerViewController
        
        gifMakerVC?.workFolder = String(format: "%@/%@", arguments: [documentDirectory, path])
        gifMakerVC?.gifsFolder = path_gifs
        gifMakerVC?.gifName = self.list_work[selectedIndex!]
        
        self.parentViewController!.appdelegate.testNavi.navigationBar.barTintColor = Config.getInstance().color
        self.parentViewController!.appdelegate.testNavi.navigationBarHidden = true
        self.parentViewController!.appdelegate.testNavi.pushViewController(gifMakerVC!, animated: true)
    }

    func deleteSelected()
    {
        collectionView(self.collectionView, didDeselectItemAtIndexPath: NSIndexPath(index: selectedIndex!))
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = String(format: "%@/%@", arguments: [documentDirectory,list_work[selectedIndex!]])
        do {
            try fileManager.removeItemAtPath(path)
            list_work.removeAtIndex(selectedIndex!)
            collections.removeAtIndex(selectedIndex!)

        } catch let error as NSError {
            print(error.localizedDescription);
        }
    
    self.collectionView.reloadData()
    }

}

