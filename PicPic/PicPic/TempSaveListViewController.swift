//
//  TempSaveListViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2016. 1. 4..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class TempSaveListViewController: SubViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
//    var collectionType = 0 // 0:임시저장 1:gifs
    var collections:[UIImage] = []
    var list_gif:[String] = []
    var list_work:[String] = []
    let fileManager = NSFileManager.defaultManager()
    var selectMode = 0 // 0:일반 1:선택
    var selectArr:[Int] = []
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var collectionView: UICollectionView!
    var backButton : UIBarButtonItem!
    var selectButton : UIBarButtonItem!
    var deleteButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.type = "giflist"
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
        for indx in deleteArr {
//            let path = String(format: "%@/tempSave/%@", arguments: [documentDirectory,list_work[indx]])
            print("delete path       ",list_work[indx])
            do {
                try fileManager.removeItemAtPath(list_work[indx])
                list_work.removeAtIndex(indx)
                collections.removeAtIndex(indx)
                print(indx," delete")
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        self.collectionView.reloadData()
        
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
            for file_name in flist {
                
                
                if(file_name.hasPrefix("tempSave")) {
                    let path = String(format: "%@/%@", arguments: [documentDirectory,file_name])
                    print("path    ",path)
                    
                    
                    let list = try fileManager.contentsOfDirectoryAtPath(path)
                    print("list   ",list)
                    for filepath in list {
                        let fileName = String(format: "%@/tempSave/%@", arguments: [documentDirectory,filepath])
                        let jsonName = String(format: "%@/tempSave/%@/save.json", arguments: [documentDirectory,filepath])
                        if fileManager.fileExistsAtPath(jsonName) {
                            print("aaaaaaaasdfe     ",filepath)
                            let path = String(format: "%@/tempSave/%@/save.jpg", arguments: [documentDirectory,filepath])
                            list_work.append(fileName)
                            let imgPath = String(format:"%@",arguments:[path])
                            print("imgPath          ",imgPath)
                            let img = UIImage(contentsOfFile: imgPath)
                            self.collections.append(img!)
                            self.selectArr.append(0)
                        }else {
                            
                        }
                    }
                }
            }
            print("collections.count   ",self.collections.count)
            self.collectionView.reloadData()
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
            print("backback   to cameraViewcontroller")
            var total_recording_time : Double = 0.0
            var num_of_capture : Int = 0
            var arr_recording_time : [Double] = [Double]()
            var dateText : String!
            var tmpFolder : String!
            var workFolder : String!
            var gifsFolder : String!
            var ratio : String!
            
            do{
                let list = try fileManager.contentsOfDirectoryAtPath(list_work[indexPath.item])
                let json_path = String(format: "%@/save.json", arguments: [list_work[indexPath.item]])
                
                if fileManager.fileExistsAtPath(json_path) {
                    let jsonData:NSData = NSData(contentsOfFile: json_path)!
                    let json = JSON(data:jsonData)
                    total_recording_time = json["total_recording_time"].doubleValue
                    num_of_capture = json["num_of_capture"].int!
                    arr_recording_time = json["arr_recording_time"].arrayObject as! [Double]
                    ratio = json["ratio"].stringValue
                }
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
                let date = dateFormatter.stringFromDate(NSDate())
                
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                
                dateText = date
                tmpFolder = "\(NSTemporaryDirectory())\(date)"
                workFolder = "\(documentDirectory)/\(date)"
                gifsFolder = "\(documentDirectory)/gifs"
                print(list_work[indexPath.item])
                try fileManager.copyItemAtPath(list_work[indexPath.row], toPath: workFolder)
                try fileManager.removeItemAtPath(list_work[indexPath.item])
            }catch {
                
            }
            
            
            let camera = self.appdelegate.camera
            camera.dateText = dateText
            camera.tmpFolder = tmpFolder
            camera.workFolder = workFolder
            camera.gifsFolder = gifsFolder
            camera.total_recording_time = total_recording_time
            camera.num_of_capture = num_of_capture
            camera.arr_recording_time = arr_recording_time
            camera.ratio = ratio
            camera.loadType = 1
            for var i = 0; i<arr_recording_time.count; i++ {
                camera.captureBar.addBar()
                camera.captureBar.update(arr_recording_time[i])
            }
            self.navigationController?.navigationBar.barTintColor = Config.getInstance().color
            self.navigationController?.navigationBarHidden = true
            self.navigationController?.popViewControllerAnimated(true)
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
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("saveCell", forIndexPath: indexPath) as! RACollectionViewCell
        
        
        cell.imageView.image = self.collections[indexPath.item]
        cell.layer.borderWidth = 3.0;
        cell.layer.borderColor = UIColor.blackColor().CGColor
        //cell.layer.borderColor = UIColor.blueColor().CGColor
        
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
        //return UIEdgeInsetsMake(self.collectionView.contentInset.top, 0, self.collectionView.contentInset.bottom, 0)
    }
}
