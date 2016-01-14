//
//  SaveListViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 24..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SaveListViewController : SubViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource   {
    
    var collectionType = 0 // 0:임시저장 1:gifs
    var collections:[UIImage] = []
    var list_gif:[String] = []
    var list_work:[String] = []
    let fileManager = NSFileManager.defaultManager()
    var selectMode = 0 // 0:일반 1:선택
    var selectArr:[Int] = []
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnGifList: UIButton!
    @IBOutlet var btnSaveList: UIButton!
    var backButton : UIBarButtonItem!
    var selectButton : UIBarButtonItem!
    var deleteButton : UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.type = "giflist"
        btnSaveList.backgroundColor = UIColor.lightGrayColor()
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        
        selectButton = UIBarButtonItem(title: "선택", style: .Plain, target: self, action: Selector("actedit"))
        
        deleteButton = UIBarButtonItem(title: "삭제", style: .Plain, target: self, action: Selector("actdelete"))
        
        
        self.navigationItem.rightBarButtonItem = selectButton
        
        let nib = UINib(nibName: "SaveCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.loadData()
        // Do any additional setup after loading the view.
    }
    
    func backToMyFeed(){
        self.appdelegate.testNavi.navigationBar.barTintColor = Config.getInstance().color
        self.appdelegate.testNavi.navigationBarHidden = true
        self.appdelegate.testNavi.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
        @IBAction func actSaveList(sender: UIButton) {
            btnGifList.backgroundColor = UIColor.blackColor()
            sender.backgroundColor = UIColor.lightGrayColor()
            collectionType = 0
            self.loadData()
        }
        
        @IBAction func actGifList(sender: UIButton) {
            btnSaveList.backgroundColor = UIColor.blackColor()
            sender.backgroundColor = UIColor.lightGrayColor()
            collectionType = 1
            self.loadData()
        }
        
    func actedit(){
        if(selectMode==0) {
            selectMode = 1
            self.navigationItem.leftBarButtonItem = deleteButton
            selectButton.title = "취소"
        } else {
            selectMode = 0
            selectButton.title = "선택"
            self.navigationItem.leftBarButtonItem = backButton
            self.collectionView.reloadData()
            for var i=0;i<collections.count;i++ {
                self.selectArr[i] = 0
            }
        }
    }
    
    func actdelete(){
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        
        let numOfCell = selectArr.count
        
        var deleteArr:[Int] = []
        
        for var i=(numOfCell-1);i>=0;i-- {
            if(selectArr[i] == 1) {
                deleteArr.append(i)
            }
        }
        //deleteArr.reverse() // 뒤부터 삭제
        print(deleteArr.count)
        
        if(collectionType==0) {
            for indx in deleteArr {
                let path = String(format: "%@/%@", arguments: [documentDirectory,list_work[indx]])
                do {
                    try fileManager.removeItemAtPath(path)
                    list_work.removeAtIndex(indx)
                    collections.removeAtIndex(indx)
                    print(indx," delete")
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
            self.collectionView.reloadData()
        } else {
            for indx in deleteArr {
//                let path = String(format: "%@/gifs/%@", arguments: [documentDirectory,list_gif[indx]])
//                print(path)
                do {
                    try fileManager.removeItemAtPath(list_gif[indx])
                    list_gif.removeAtIndex(indx)
                    collections.removeAtIndex(indx)
                    print(indx," delete")
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
            self.collectionView.reloadData()
        }
        
        for var i=0;i<collections.count;i++ {
            self.selectArr[i] = 0
        }
        
        self.selectMode = 1
        actedit()
    }
    
        func loadData() {
            collections.removeAll()
            list_work.removeAll()
            list_gif.removeAll()
            
            do {
                let flist = try fileManager.contentsOfDirectoryAtPath(documentDirectory)
                
                // work 폴더에서 20로 시작되는 폴더들은 임시작업 폴더이며, db.json 정보가 있으면 유효한 폴더, 없으면 삭제처리
                if(collectionType == 0) {
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
                                            self.selectArr.append(0)
                                        } else {
//                                            do {
//                                                try fileManager.removeItemAtPath(path)
//                                            } catch let error as NSError {
//                                                print(error.localizedDescription);
//                                            }
                                        }
                                        
                                        
                                    } else {
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
                } else {
                    let path_gifs = String(format: "%@/gifs", arguments: [documentDirectory])
                    
                    let flist = try fileManager.contentsOfDirectoryAtPath(path_gifs)
                    
                    for file_name in flist {
                        let path_gif = String(format: "%@/%@", arguments: [path_gifs,file_name])
                        
                        list_gif.append(path_gif)
                        let img = UIImage(contentsOfFile: path_gif)
                        self.collections.append(img!)
                        self.selectArr.append(0)
                    }
                    self.collectionView.reloadData()
                }
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
        }
        
        
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
            
            print("select ",indexPath)
            
            // 삭제 기능
            if(selectMode == 1) {
                let cell2 = collectionView.cellForItemAtIndexPath(indexPath)
                
                if(selectArr[indexPath.item] == 0) { // 선택됨
                    selectArr[indexPath.item] = 1
                    cell2!.layer.borderColor = Config.getInstance().color.CGColor
                } else { // 해제함.
                    selectArr[indexPath.item] = 0
                    cell2!.layer.borderColor = UIColor.blackColor().CGColor
                }
            } else { // 글작성 페이지로 이동
                if(collectionType==0) {
                    // workFolder를  GifMakerVC 전달
                    let path = self.list_work[indexPath.item]
                    print(path)
                    
                    let path_gifs = String(format: "%@/gifs", arguments: [documentDirectory])
                    
                    let gifMakerVC = self.storyboard?.instantiateViewControllerWithIdentifier("GifMakerViewController") as? GifMakerViewController
                    
                    gifMakerVC?.workFolder = String(format: "%@/%@", arguments: [documentDirectory, path])
                    gifMakerVC?.gifsFolder = path_gifs
                    gifMakerVC?.gifName = self.list_work[indexPath.item]
                    
                    self.appdelegate.testNavi.navigationBar.barTintColor = Config.getInstance().color
                    self.appdelegate.testNavi.navigationBarHidden = true
                    self.appdelegate.testNavi.pushViewController(gifMakerVC!, animated: true)
                    
                    
                } else {
                    // gif File명을 글쓰기 화면으로 전달
                    let path = self.list_gif[indexPath.item]
                    print(path)
                    
                    let gifVC = self.storyboard?.instantiateViewControllerWithIdentifier("gifVC") as? GIFViewController
                    self.appdelegate.testNavi.navigationBar.barTintColor = Config.getInstance().color
                    self.appdelegate.testNavi.navigationBarHidden = false
                    gifVC?.moviePath = NSURL(string: path)
                    print(path)
                    self.appdelegate.testNavi.pushViewController(gifVC!, animated: true)
                    
                    
                }
            }
            
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
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("SaveCell", forIndexPath: indexPath) as! RACollectionViewCell
            
            
            cell.imageView.image = self.collections[indexPath.item]
            cell.layer.borderWidth = 3.0;
            cell.layer.borderColor = UIColor.blackColor().CGColor
            //cell.layer.borderColor = UIColor.blueColor().CGColor
            
            return cell
        }
        
        // 드래그앤 드롭 지원 여부
        func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool {
            
            if(collectionType == 0) {
                return false
            } else {
                return true
            }
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
            //return UIEdgeInsetsMake(self.collectionView.contentInset.top, 0, self.collectionView.contentInset.bottom, 0)
        }
        
        
        
        
        
}
