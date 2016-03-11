//
//  CameraViewController.swift
//  createAniGIF
//
//  Created by Shawn Chun on 2015. 11. 4..
//  Copyright © 2015년 shawn. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import SpringIndicator
import SwiftyJSON

class CameraViewController: SubViewController, AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UIAlertViewDelegate {
    var tmpFolder:String?
    var workFolder:String?
    var gifsFolder:String?
    var gifName:String?
    var dateText:String?
    
    var isRecord: Bool = false
    var picker: UIImagePickerController?
    var _hud: MBProgressHUD?
    var photoTimer: NSTimer?
    var captureType: String = "video"
    var maxDuration: CMTime = CMTimeMakeWithSeconds(15.0, 8)
    
    //Camera Capture requiered properties
    let session = AVCaptureSession()
    var sessionQueue: dispatch_queue_t = dispatch_queue_create("CameraSessionQueue", DISPATCH_QUEUE_SERIAL)
    var stillImageOutput: AVCaptureStillImageOutput!
    var videoDataOutput: AVCaptureMovieFileOutput!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    var done = false
    var capturePhotoTimer: NSTimer?
    var limitPhotoTimeTimer: NSTimer?
    
    var deviceInput:AVCaptureDeviceInput? // 전역으로 수정
    var gridLayer:UIImageView!
    var imagePicker: UIImagePickerController?
    var ghostLayer:UIImageView!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureTypeBtn: UIButton!
    @IBOutlet weak var videoRatioBtn: UIButton!
    //    @IBOutlet weak var cameraWid: NSLayoutConstraint!
    //    @IBOutlet weak var cameraHei: NSLayoutConstraint!
    @IBOutlet weak var gridBtn:UIButton!
    @IBOutlet weak var flashBtn:UIButton!
    @IBOutlet weak var selfiBtn:UIButton!
    @IBOutlet weak var btnGhost: UIButton!
    @IBOutlet weak var btnLoad: UIButton!
    @IBOutlet weak var btnCapture: UIButton!
    //    @IBOutlet weak var editPlusHei: NSLayoutConstraint!
    @IBOutlet weak var editPlusView: UIView!
    //    @IBOutlet weak var cameraViewPosY: NSLayoutConstraint!
    
    let fileManager = NSFileManager.defaultManager()
    
    @IBOutlet weak var nextWid: NSLayoutConstraint!
    @IBOutlet var btn_picker: UIButton!
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var captureDelete: UIButton!
    @IBOutlet weak var editBar: UIButton!
    
    @IBOutlet weak var captureBar: MyBar!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var editPlusViewHei: NSLayoutConstraint!
    
    @IBOutlet weak var lowerCameraCoverView: UIView!
    @IBOutlet weak var lowerCameraCoverViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var higherCameraCoverView: UIView!
    @IBOutlet weak var higherCameraCoverViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var editBarViewBottomConst: NSLayoutConstraint!
    
    //최대 녹화 시간 5초
    let max_recording_time = 5.0
    var max_recording_this_frame = 5.0
    //녹화를 한 시간
    var total_recording_time:NSTimeInterval = 0.0
    //동영상 갯수
    var num_of_capture = 0
    //녹화시간 Array
    var arr_recording_time:[Double] = []
    var timer:NSTimer?
    var startTime = NSTimeInterval()
    var is_saved:Bool = false
    var is_camera_ready = true
    
    var gifMaker = GifMaker()
    let log = LogPrint()
    var loadType : Int = 0
    
    @IBOutlet weak var editBarView: UIScrollView!
    @IBOutlet weak var btnback: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var spring: SpringIndicator!
    //    @IBOutlet weak var spring: UIActivityIndicatorView!
    var deleteState = 0
    var deleteToggle = false
    var ratio : String!
    // 갤러리 버튼 눌렀을 때
    /* 전승일씨 코드
    @IBAction func chooseVideo(sender: UIButton) {
    @IBOutlet var recordingBtn: UIButton!
    stopCamera()
    picker = UIImagePickerController()
    picker!.delegate = self
    picker!.allowsEditing = false
    picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    picker!.mediaTypes = [kUTTypeMovie as String]
    picker!.title = "동영상 선택"
    if let _: AnyClass = NSClassFromString("UIPopoverPresentationController") {
    picker!.popoverPresentationController?.sourceView = self.view
    picker!.popoverPresentationController?.sourceRect = self.view.frame
    }
    presentViewController(picker!, animated: true, completion: nil)
    }*/
    
    
    @IBAction func actEditBar(sender: AnyObject) {
        if self.editBarView.hidden == true {
            self.editBar.setImage(UIImage(named: "plus_c"), forState: .Normal)
            self.editBarView.hidden = false
        }else {
            self.editBar.setImage(UIImage(named: "plus"), forState: .Normal)
            self.editBarView.hidden = true
        }
    }
    
    @IBAction func actNext(sender: AnyObject) {
        //로딩 불러오기
        if total_recording_time < 0.6 {
            return
        }
        
        
        self.backViewShow(true)
        self.log.log("babckview animation started")
        NSThread.sleepForTimeInterval(0.2)
        
        
        if videoRatioBtn.enabled == false {
            videoRatioBtn.enabled = true
        }
        if btn_picker.enabled == false {
            btn_picker.enabled = true
        }
        var movieArr:[String] = []
        do {
            let flist = try fileManager.contentsOfDirectoryAtPath(workFolder!)
            
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for movName in flist {
                    //                    print("get ",movName)
                    if movName.hasSuffix(".mov") {
                        let name = movName.stringByReplacingOccurrencesOfString(".mov", withString: "")
                        let movPath = String(format:"%@/%@",arguments: [self.workFolder!,movName])
                        let jpgPath = String(format:"%@/%@", arguments:[self.workFolder!, name])
                        print("movPath   ",movPath)
                        print("imgPath   ",jpgPath)
                        do {
                            if self.fileManager.fileExistsAtPath(jpgPath) {
                                try self.fileManager.removeItemAtPath(jpgPath)
                            }
                        }catch {}
                        
                        self.gifMaker.movSplit(NSURL(fileURLWithPath: movPath), time_start: 0.0, time_end: 0.0, outputPath: jpgPath)
                        
                        movieArr.append(movPath)
                        do {
                            if(movName == "00.mov") {
                                //                                print("make Thumb")
                                try self.fileManager.copyItemAtPath(String(format:"%@/000.jpg", jpgPath), toPath: String(format:"%@/thumb.jpg", self.workFolder!))
                            }
                        }catch {
                            
                        }
                        
                    }
                }
                self.stopCamera()
                let cameraVC = self.storyboard?.instantiateViewControllerWithIdentifier("GifMakerViewController") as? GifMakerViewController
                self.editBar.setImage(UIImage(named: "plus"), forState: .Normal)
                self.editBarView.hidden = true
                self.btnLoad.enabled = true
                if self.ghostToggle {
                    self.ghostToggle = false
                    self.ghostLayer.removeFromSuperview()
                    self.ghostLayer = nil
                }
                self.btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
                cameraVC?.workFolder = self.workFolder
                cameraVC?.gifsFolder = self.gifsFolder
                cameraVC?.gifName = self.gifName
                cameraVC?.arr_recoding_time = self.arr_recording_time
                self.workFolder = nil
                
                self.appdelegate.testNavi.navigationBarHidden = true
                self.appdelegate.testNavi.pushViewController(cameraVC!, animated: true)
                self.backViewShow(false)
            })
        } catch {
            // 에러 화면 띄울 것
        }
    }
    
    func longPress(sender:UILongPressGestureRecognizer!){
        if arr_recording_time.count == 0 {
            return
        }
        if deleteToggle {
            return
        }
        deleteToggle = true
        let alert = UIAlertView(title: "", message: self.appdelegate.ment["delete_all"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue, otherButtonTitles: self.appdelegate.ment["popup_cancel"].stringValue)
        alert.show()
        //        print("longPress on")
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            captureBar.deleteAll()
            num_of_capture = 0
            arr_recording_time.removeAll()
            self.videoRatioBtn.enabled = true
            self.btn_picker.enabled = true
            self.btnLoad.enabled = true
            total_recording_time = 0
            deleteState = 0
            captureDelete.setImage(UIImage(named: "delete"), forState: .Normal)
            deleteToggle = false
            if ghostLayer != nil {
                ghostLayer.removeFromSuperview()
                ghostLayer = nil
                ghostToggle = false
                btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
            }
            if total_recording_time > 0.6 {
                self.btnNext.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }else {
                self.btnNext.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            }
            
            do {
                let flist = try fileManager.contentsOfDirectoryAtPath(workFolder!)
                for movName in flist {
                    print(workFolder)
                    print("get ",movName)
                    if movName.hasSuffix(".mov") {
                        let name = movName.stringByReplacingOccurrencesOfString(".mov", withString: "")
                        let Path = String(format:"%@/%@.mov", arguments:[self.workFolder!, name])
                        try fileManager.removeItemAtPath(Path)
                        print("Path  ",Path)
                    }
                }
                let outputPath = String(format: "%@/ghost.jpg", arguments: [self.workFolder!])
                self.log.log("outputPath   \(outputPath)")
                try fileManager.removeItemAtPath(outputPath)
            }catch {}
            
            
        }
    }
    
    func backViewShow(state : Bool){
        
        if state {
            self.backView.hidden = false
            //            self.view.bringSubviewToFront(self.spring)
            self.spring.startAnimation(true)
            log.log("start")
        }else {
            self.backView.hidden = true
            //            self.view.bringSubviewToFront(self.spring)
            self.spring.stopAnimation(true)
        }
        
        
    }
    
    
    @IBAction func actDelete(sender: AnyObject) {
        if arr_recording_time.count == 0 {
            return
        }
        
        let outputPath = String(format: "%@/%02d.mov", arguments: [tmpFolder!,num_of_capture])
        
        if fileManager.fileExistsAtPath(outputPath) {
            do {
                try fileManager.removeItemAtPath(outputPath)
            } catch {
                
            }
        }
        if deleteState == 0 {
            captureDelete.setImage(UIImage(named: "trash"), forState: .Normal)
            captureBar.subviews[captureBar.subviews.count-1].backgroundColor = UIColor(colorLiteralRed: 0.99, green: 0.41, blue: 0.43, alpha: 1)
            deleteState++
            return
        }
        
        
        if deleteState == 1 {
            captureBar.delete()
            num_of_capture--
            var pathArr = [String]()
            do {
                let flist = try fileManager.contentsOfDirectoryAtPath(workFolder!)
                for movName in flist {
                    //                    print("get ",movName)
                    if movName.hasSuffix(".mov") {
                        let name = movName.stringByReplacingOccurrencesOfString(".mov", withString: "")
                        var Path = String(format:"%@/%@.mov", arguments:[self.workFolder!, name])
                        pathArr.append(Path)
                    }
                }
                
                var removePath = pathArr[pathArr.count-1]
                try fileManager.removeItemAtPath(removePath)
                print("jpgPath ",removePath)
                
            }catch {}
            arr_recording_time.removeAtIndex(arr_recording_time.count-1)
            total_recording_time = 0
            for v in arr_recording_time {
                total_recording_time = total_recording_time + v
            }
            max_recording_this_frame = max_recording_time - total_recording_time
            deleteState = 0
            
            
            
            if arr_recording_time.count == 0 {
                self.videoRatioBtn.enabled = true
                self.btn_picker.enabled = true
                self.btnLoad.enabled = true
                if ghostLayer != nil {
                    self.ghostLayer.removeFromSuperview()
                    self.ghostLayer = nil
                    ghostToggle = false
                    btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
                    do {
                        let outputPath = String(format: "%@/ghost.jpg", arguments: [self.workFolder!])
                        self.log.log("outputPath   \(outputPath)")
                        try fileManager.removeItemAtPath(outputPath)
                    }catch {
                        
                    }
                }
            }
            
            NSThread.sleepForTimeInterval(0.1)
            if ghostToggle {
                changeGhost()
            }
            
            if total_recording_time > 0.6 {
                self.btnNext.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }else {
                self.btnNext.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            }
            captureDelete.setImage(UIImage(named: "delete"), forState: .Normal)
        }
        
    }
    
    @IBAction func actCaptureStart(sender: AnyObject) {
        if is_camera_ready == false {
            return;
        }
        
        if(total_recording_time>=max_recording_time) {
            //            print("max!!!")
            self.videoRatioBtn.enabled = false
            self.btn_picker.enabled = false
            self.btnLoad.enabled = false
            
            return
        }
        
        is_saved = false;
        let outputPath = String(format: "%@/%02d.mov", arguments: [workFolder!,num_of_capture])
        //        print("capture : ",outputPath)
        
        let outputURL = NSURL(fileURLWithPath: outputPath)
        videoDataOutput.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
        
        startTime = NSDate.timeIntervalSinceReferenceDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        
        captureBar.addBar()
        
        if deleteState == 1 {
            captureDelete.setImage(UIImage(named: "delete"), forState: .Normal)
            captureBar.subviews[captureBar.subviews.count-2].backgroundColor = Config.getInstance().color
        }
        
        
    }
    
    @IBAction func actCaptureStop(sender: AnyObject) {
        //        print("end")
        print("",is_saved)
        if(is_saved) {
            
        } else {
            
            is_saved = true
            timer!.invalidate()
            timer = nil
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime: NSTimeInterval = currentTime - startTime
            videoDataOutput.stopRecording()
            
            let outputPath = String(format: "%@/%02d.mov", arguments: [workFolder!,num_of_capture])
            if fileManager.fileExistsAtPath(outputPath) {
                num_of_capture++
                total_recording_time += elapsedTime
                max_recording_this_frame = max_recording_time - total_recording_time
                arr_recording_time.append(elapsedTime)
                
                NSThread.sleepForTimeInterval(0.1)
                if ghostToggle {
                    changeGhost()
                }
            }else {
                captureBar.delete()
            }
            
            
            if arr_recording_time.count > 0 {
                self.btn_picker.enabled = false
                self.videoRatioBtn.enabled = false
                self.btnLoad.enabled = false
            }
            
            log.log("arr_recording_time  \(arr_recording_time)")
            
            if total_recording_time > 0.6 {
                self.btnNext.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }else {
                self.btnNext.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            }
            
        }
    }
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        let elapsedTime: NSTimeInterval = currentTime - startTime
        captureBar.update(elapsedTime)
        
        if(elapsedTime>max_recording_this_frame) {
            total_recording_time += elapsedTime
            max_recording_this_frame = max_recording_time - total_recording_time
            arr_recording_time.append(elapsedTime)
            
            timer!.invalidate()
            timer = nil
            is_saved = true
            
            videoDataOutput.stopRecording()
            print("max.... ",self.total_recording_time)
            btnNext.enabled = true
            self.videoRatioBtn.enabled = false
            self.btn_picker.enabled = false
            self.btnLoad.enabled = false
            self.btnNext.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            return
        }
    }
    var alert : UIAlertView!
    @IBAction func actTempSave(sender: AnyObject) {
        if arr_recording_time.count <= 0 {
            return
        }
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        do {
            let flist = try self.fileManager.contentsOfDirectoryAtPath(workFolder!)
            let Arr = workFolder?.componentsSeparatedByString("/")
            let folder = Arr![Arr!.count-1]
            let tempPath = String(format:"%@/tempSave",arguments: [documentDirectory])
            if fileManager.fileExistsAtPath(tempPath) {
                
            }else {
                try fileManager.createDirectoryAtPath(tempPath, withIntermediateDirectories: false, attributes: nil)
            }
            let savePath = String(format:"%@/tempSave/%@",arguments: [documentDirectory,folder])
            if self.fileManager.fileExistsAtPath(savePath) {
                try self.fileManager.removeItemAtPath(savePath)
            }
            try self.fileManager.copyItemAtPath(workFolder!, toPath: savePath)
            self.log.log("savePath     \(savePath)")
            
            let json_path = String(format: "%@/save.json", arguments: [savePath])
            let json : JSON = ["total_recording_time":total_recording_time,"num_of_capture":num_of_capture,"arr_recording_time":arr_recording_time,"ratio":Config.getInstance().videoRatio]
            
            do {
                
                let data = try json.rawData()
                //Do something you want
                //                //print(json_path)
                if(fileManager.fileExistsAtPath(json_path)) {
                    try fileManager.removeItemAtPath(json_path)
                }
                fileManager.createFileAtPath(json_path, contents: data, attributes: nil)
            } catch let error as NSError {
                //                //print(error.localizedDescription);
            }
            
            
            var mov = [String]()
            var count = 0
            if arr_recording_time.count-1 > 0 {
                count = arr_recording_time.count-1
            }
            
            for movName in flist {
                if movName.hasSuffix(".mov") {
                    mov.append(movName)
                }
            }
            self.log.log("mov[count]   \(mov[count])")
            let movPath = String(format:"%@/%@",arguments: [self.workFolder!,mov[count]])
            self.log.log("movPath     \(movPath)")
            let url = NSURL(fileURLWithPath: movPath)
            let time = CMTimeMakeWithSeconds(arr_recording_time[count]-0.02, 600)
            let asset = AVAsset(URL: url)
            self.log.log("asset \(asset)")
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let tolerance = CMTimeMakeWithSeconds(0.01, 600)
            imageGenerator.requestedTimeToleranceBefore = tolerance
            imageGenerator.requestedTimeToleranceAfter = tolerance
            self.log.log("\(time)")
            
            let outputPath = String(format: "%@/save.jpg", arguments: [savePath])
            self.log.log("outputPath   \(outputPath)")
            self.log.log("aaaaaaaaaaaaaaa")
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            self.log.log("\(imageRef)")
            var image = UIImage(CGImage: imageRef)
            if Config.getInstance().videoRatio == "1:1" {
                image = image.cropToBounds(480, height: 480)
                image = image.resizeImage(CGSize(width: 480, height: 480))
            }else {
                image = image.cropToBounds(480, height: 640)
                image = image.resizeImage(CGSize(width: 480, height: 640))
            }
            UIImageJPEGRepresentation(image, 80)!.writeToFile(outputPath, atomically: true)
            
            alert = UIAlertView(title: "", message: self.appdelegate.ment["camera_tempsave"].stringValue, delegate: nil, cancelButtonTitle: nil)
            alert.show()
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
        }catch {
            print("error",error)
        }
    }
    
    func clearAlert(timer : NSTimer) {
        if alert != nil {
            alert.dismissWithClickedButtonIndex(0, animated: true)
            alert = nil
        }
    }
    
    @IBAction func actImagePicker(sender: UIButton) {
        self.btn_picker.enabled = true
        self.btnLoad.enabled = true
        self.videoRatioBtn.enabled = true
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            //            print("Galeria Imagen")
            
            //            imagePicker!.delegate = self
            //            imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            //            imagePicker!.mediaTypes = [kUTTypeMovie as String] // 5s 이상에서 연사 지원하므로, 연사 옵션 넣어야 함.
            //            imagePicker!.allowsEditing = false
            //            imagePicker?.navigationBar.barTintColor = Config.getInstance().color
            //            imagePicker?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            
            
            
            print("videopicker            adsf;lejfioadsjfeakldjsfe;ioj")
            let videoPicker = self.storyboard?.instantiateViewControllerWithIdentifier("VideoGalleryViewController") as? VideoGalleryViewController
            videoPicker?.cameradelegate = self;
            self.presentViewController(videoPicker!, animated: true, completion: nil);
        }
    }
    
    // 화면 비율 변화시켜 주는 메소드
    @IBAction func changeRatio(sender: UIButton) {
        //print("\(Config.getInstance().videoRatio), \(Config.getInstance().wid), \(Config.getInstance().hei)")
        if Config.getInstance().videoRatio == "1:1" {
            Config.getInstance().videoRatio = "3:4"
        }
        else {
            Config.getInstance().videoRatio = "1:1"
        }
        
        if Config.getInstance().videoRatio == "1:1" {
            sender.setImage(UIImage(named: "icon_camera_11"), forState: .Normal)
            //cameraViewPosY.constant = (Config.getInstance().wid/8)*2
            //cameraView.frame.origin.y = (Config.getInstance().wid/8)*2
            UIView.animateWithDuration(0.1, animations: {
                self.lowerCameraCoverViewHeight.constant = (self.cameraView.frame.height - UIScreen.mainScreen().bounds.width) / 2.0
                self.higherCameraCoverViewHeight.constant = (self.cameraView.frame.height - UIScreen.mainScreen().bounds.width) / 2.0
                self.view.layoutIfNeeded()
            })
            
        }else {
            sender.setImage(UIImage(named: "icon_camera_34"), forState: .Normal)
            UIView.animateWithDuration(0.1, animations: {
                self.lowerCameraCoverViewHeight.constant = 0
                self.higherCameraCoverViewHeight.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        //cameraView.frame.size.width = Config.getInstance().wid
        //cameraView.frame.size.height = Config.getInstance().hei
        /**/
        print(cameraView.frame)
        
        //log.log("cameraView   \(self.cameraView)")
        if(self.ghostLayer != nil) {
            let fileManager = NSFileManager.defaultManager()
            self.ghostLayer.removeFromSuperview()
            let outputPath = String(format: "%@/ghost.jpg", arguments: [self.workFolder!])
            do {
                try fileManager.removeItemAtPath(outputPath)
                
            } catch {
                
            }
            self.btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
        }
        
        if(self.gridLayer != nil)
        {
            UIView.animateWithDuration(0.1, animations: {
                self.gridLayer.frame = CGRectMake(0, self.higherCameraCoverView.frame.height, UIScreen.mainScreen().bounds.width, self.cameraView.frame.height - (self.higherCameraCoverView.frame.height + self.lowerCameraCoverView.frame.height))
                self.view.layoutIfNeeded()
            })
        }
        
        /*self.session.stopRunning()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if Config.getInstance().videoRatio == "1:1" {
        //self.cameraViewPosY.constant = (Config.getInstance().wid/8)*2
        //self.cameraView.bounds.origin.y = (Config.getInstance().wid/8)*2
        //self.cameraView.frame.origin.y = (Config.getInstance().wid/8)*2
        }else {
        //self.cameraViewPosY.constant = 0
        //self.cameraView.bounds.origin.y = 0
        //self.cameraView.frame.origin.y = 0
        }
        let rootLayer :CALayer = self.cameraView.layer
        rootLayer.masksToBounds=true
        self.previewLayer.frame = self.cameraView.bounds
        self.cameraView.clipsToBounds = true
        
        //print("\(self.previewLayer.frame)     camera View      \(self.cameraView)")
        
        rootLayer.addSublayer(self.previewLayer)
        if self.session.running == false {
        self.session.startRunning()
        }
        
        if(self.gridLayer != nil) {
        self.gridLayer.removeFromSuperview();
        self.gridLayer = nil
        self.make_grid();
        }
        })*/
        
        /*dispatch_after(dispatch_time_t(300), dispatch_get_main_queue(), {
        if Config.getInstance().videoRatio == "1:1" {
        self.cameraViewPosY.constant = (Config.getInstance().wid/8)*2
        self.cameraView.bounds.origin.y = (Config.getInstance().wid/8)*2
        self.cameraView.frame.origin.y = (Config.getInstance().wid/8)*2
        }else {
        self.cameraViewPosY.constant = 0
        self.cameraView.bounds.origin.y = 0
        self.cameraView.frame.origin.y = 0
        }
        let rootLayer :CALayer = self.cameraView.layer
        rootLayer.masksToBounds=true
        self.previewLayer.frame = self.cameraView.bounds
        self.cameraView.clipsToBounds = true
        
        //print("\(self.previewLayer.frame)     camera View      \(self.cameraView)")
        
        rootLayer.addSublayer(self.previewLayer)
        if self.session.running == false {
        self.session.startRunning()
        }
        
        if(self.gridLayer != nil) {
        self.gridLayer.removeFromSuperview();
        self.gridLayer = nil
        self.make_grid();
        }
        })*/
    }
    
    // 이전 버튼 눌렀을 때
    @IBAction func moveProfile(sender: UIButton) {
        stopCamera()
        self.total_recording_time = 0
        self.max_recording_this_frame = 5.0
        self.btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
        self.editBar.setImage(UIImage(named: "plus"),forState: .Normal)
        self.workFolder = nil
        self.editBarView.hidden = true
        self.btn_picker.enabled = true
        self.btnLoad.enabled = true
        self.flash_toggle = false
        if self.ghostToggle {
            self.ghostToggle = false
            self.ghostLayer.removeFromSuperview()
            self.ghostLayer = nil
        }
        self.removeTempLoadView()
        self.navigationController?.navigationBarHidden = false
        if !self.appdelegate.myfeed.view.hidden {
            print("myfeed")
            self.navigationController?.navigationBarHidden = true
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var toggle = false
    // 촬영 버튼 눌렀을 때
    @IBAction func startRecording(sender: UIButton) {
        if toggle {
            sender.setImage(UIImage(named: "btn_rec"), forState: .Normal)
            toggle = !toggle
        }else {
            sender.setImage(UIImage(named: "btn_rec_after"), forState: .Normal)
            toggle = !toggle
        }
        controlRecording()
    }
    var flash_toggle = false
    @IBAction func flash_on(sender: UIButton) {
        let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        // check if the device has torch
        
        log.log("cameraview  \(self.cameraView.frame)  bounds   \(cameraView.bounds)")
        //        log.log("\(cameraViewPosY.constant)")
        if(captureDevice.position == AVCaptureDevicePosition.Front) {
            return
        }
        if flash_toggle {
            sender.setImage(UIImage(named: "icon_camera_flash"), forState: .Normal)
            flash_toggle = false
        }else {
            sender.setImage(UIImage(named: "icon_camera_flash_c"), forState: .Normal)
            flash_toggle = true
        }
        
        do {
            try avDevice.lockForConfiguration()
            if(avDevice.torchActive) {
                avDevice.torchMode = AVCaptureTorchMode.Off;
            } else {
                avDevice.torchMode = AVCaptureTorchMode.On
                try avDevice.setTorchModeOnWithLevel(1.0)
            }
            avDevice.unlockForConfiguration()
        } catch {
            return
        }
    }
    
    var ghostToggle = false
    @IBAction func actGhost(sender: AnyObject) {
        if arr_recording_time.count <= 0 {
            return
        }
        var count = 0
        if arr_recording_time.count-1 > 0 {
            print("count > 0 ")
            count = arr_recording_time.count-1
        }else {
            count = 0
        }
        
        var mov = [String]()
        do {
            let flist = try self.fileManager.contentsOfDirectoryAtPath(workFolder!)
            
            for movName in flist {
                if movName.hasSuffix(".mov") {
                    mov.append(movName)
                }
            }
            print("mov Array        ",mov)
            self.log.log("mov[count]   \(mov[count])")
            let movPath = String(format:"%@/%@",arguments: [self.workFolder!,mov[count]])
            self.log.log("movPath     \(movPath)")
            let url = NSURL(fileURLWithPath: movPath)
            let time = CMTimeMakeWithSeconds(arr_recording_time[count]-0.03, 600)
            let asset = AVAsset(URL: url)
            self.log.log("asset \(asset)")
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let tolerance = CMTimeMakeWithSeconds(0.01, 600)
            imageGenerator.requestedTimeToleranceBefore = tolerance
            imageGenerator.requestedTimeToleranceAfter = tolerance
            self.log.log("\(time)")
            
            let outputPath = String(format: "%@/ghost.jpg", arguments: [self.workFolder!])
            self.log.log("outputPath   \(outputPath)")
            if(self.ghostLayer != nil) {
                self.log.log("ghostImage in")
                self.ghostLayer.removeFromSuperview()
                self.ghostLayer = nil
                
                try fileManager.removeItemAtPath(outputPath)
                self.btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
                ghostToggle = false
                return
            }
            self.log.log("aaaaaaaaaaaaaaa")
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            self.log.log("\(imageRef)")
            var image = UIImage(CGImage: imageRef)
            if Config.getInstance().videoRatio == "1:1" {
                image = image.cropToBounds(480, height: 480)
                image = image.resizeImage(CGSize(width: 480, height: 480))
            }else {
                image = image.cropToBounds(480, height: 640)
                image = image.resizeImage(CGSize(width: 480, height: 640))
            }
            
            UIImageJPEGRepresentation(image, 80)!.writeToFile(outputPath, atomically: true)
            
            self.ghostLayer = UIImageView(frame: self.cameraView.bounds)
            ghostToggle = true
            let offset:CGFloat = (self.view.frame.height - self.cameraView.frame.height) / CGFloat(2)
            
            self.ghostLayer.frame.origin.y = lowerCameraCoverViewHeight.constant
            
            self.ghostLayer.image = image.alpha(Config.getInstance().ghostAlpha)
            self.view.addSubview(self.ghostLayer)
            self.view.bringSubviewToFront(self.higherCameraCoverView)
            self.view.bringSubviewToFront(self.lowerCameraCoverView)
            self.view.bringSubviewToFront(self.backView)
            self.view.bringSubviewToFront(self.spring)
            self.view.bringSubviewToFront(self.btnNext)
            self.view.bringSubviewToFront(self.btnback)
            
            self.btnGhost.setImage(UIImage(named: "icon_camera_ghost_c"), forState: .Normal)
            print("Ghost Capture ",self.ghostLayer.image)
            
        }catch {
            print(error)
        }
        
    }
    
    
    func changeGhost(){
        if arr_recording_time.count <= 0 {
            return
        }
        var count = 0
        if arr_recording_time.count-1 > 0 {
            count = arr_recording_time.count-1
        }
        
        var mov = [String]()
        do {
            let flist = try self.fileManager.contentsOfDirectoryAtPath(workFolder!)
            
            for movName in flist {
                if movName.hasSuffix(".mov") {
                    mov.append(movName)
                }
            }
            print("mov array   ",mov)
            self.log.log("mov[count]   \(mov[count])")
            let movPath = String(format:"%@/%@",arguments: [self.workFolder!,mov[count]])
            self.log.log("movPath     \(movPath)")
            let url = NSURL(fileURLWithPath: movPath)
            let time = CMTimeMakeWithSeconds(arr_recording_time[count]-0.03, 600)
            let asset = AVAsset(URL: url)
            self.log.log("asset \(asset)")
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let tolerance = CMTimeMakeWithSeconds(0.01, 600)
            imageGenerator.requestedTimeToleranceBefore = tolerance
            imageGenerator.requestedTimeToleranceAfter = tolerance
            self.log.log("\(time)")
            
            let outputPath = String(format: "%@/ghost.jpg", arguments: [self.workFolder!])
            self.log.log("outputPath   \(outputPath)")
            if(self.ghostLayer != nil) {
                self.log.log("ghostImage in")
                self.ghostLayer.removeFromSuperview()
                self.ghostLayer = nil
                
                try fileManager.removeItemAtPath(outputPath)
                self.btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
            }
            self.log.log("aaaaaaaaaaaaaaa")
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            self.log.log("\(imageRef)")
            var image = UIImage(CGImage: imageRef)
            if Config.getInstance().videoRatio == "1:1" {
                image = image.cropToBounds(480, height: 480)
                image = image.resizeImage(CGSize(width: 480, height: 480))
            }else {
                image = image.cropToBounds(480, height: 640)
                image = image.resizeImage(CGSize(width: 480, height: 640))
            }
            
            UIImageJPEGRepresentation(image, 80)!.writeToFile(outputPath, atomically: true)
            
            self.ghostLayer = UIImageView(frame: self.cameraView.bounds)
            ghostToggle = true
            let offset:CGFloat = (self.view.frame.height - self.cameraView.frame.height) / CGFloat(2)
            
            self.ghostLayer.frame.origin.y = self.cameraView.frame.origin.y
            
            self.ghostLayer.image = image.alpha(Config.getInstance().ghostAlpha)
            self.view.addSubview(self.ghostLayer)
            self.view.bringSubviewToFront(self.backView)
            self.view.bringSubviewToFront(self.spring)
            self.view.bringSubviewToFront(self.btnNext)
            self.view.bringSubviewToFront(self.btnback)
            self.btnGhost.setImage(UIImage(named: "icon_camera_ghost_c"), forState: .Normal)
            print("Ghost Capture ",self.ghostLayer.image)
            
        }catch {
            print("error",error)
        }
    }
    
    @IBAction func toggleSelfi(sender: UIButton) {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            
            if(device.hasMediaType(AVMediaTypeVideo)) {
                if(captureDevice.position == AVCaptureDevicePosition.Back && device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice
                    print("front")
                    
                    if captureDevice != nil {
                        self.session.stopRunning()
                        self.session.removeInput(deviceInput)
                        
                        do {
                            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                        } catch {
                            deviceInput = nil
                        }
                        
                        if session.canAddInput(deviceInput){
                            session.addInput(deviceInput)
                        }
                        self.session.startRunning()
                    }
                    
                    return
                } else if(captureDevice.position == AVCaptureDevicePosition.Front && device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    print("back")
                    if flash_toggle {
                        let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                        do {
                            try avDevice.lockForConfiguration()
                            if(avDevice.torchActive) {
                                avDevice.torchMode = AVCaptureTorchMode.Off;
                            } else {
                                avDevice.torchMode = AVCaptureTorchMode.On
                                try avDevice.setTorchModeOnWithLevel(1.0)
                            }
                            //avDevice.torchMode = avDevice.torchActive ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On
                            avDevice.unlockForConfiguration()
                        } catch {
                            // handle error
                            return
                        }
                    }
                    if captureDevice != nil {
                        self.session.stopRunning()
                        self.session.removeInput(deviceInput)
                        
                        do {
                            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                        } catch {
                            deviceInput = nil
                        }
                        
                        if session.canAddInput(deviceInput){
                            session.addInput(deviceInput)
                        }
                        self.session.startRunning()
                    }
                    return
                } else {
                    
                }
            }
            
            
        }
    }
    
    var gridToggle = false
    @IBAction func toggleGrid(sender: UIButton) {
        if flash_toggle {
            let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            do {
                try avDevice.lockForConfiguration()
                //                if(avDevice.torchActive) {
                //                    avDevice.torchMode = AVCaptureTorchMode.Off;
                //                } else {
                avDevice.torchMode = AVCaptureTorchMode.On
                try avDevice.setTorchModeOnWithLevel(1.0)
                //                }
                //avDevice.torchMode = avDevice.torchActive ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On
                avDevice.unlockForConfiguration()
            } catch {
                // handle error
                return
            }
        }
        if(gridLayer == nil) {
            sender.setImage(UIImage(named: "icon_camera_grid_c"), forState: .Normal)
            make_grid()
        } else {
            sender.setImage(UIImage(named: "icon_camera_grid"), forState: .Normal)
            self.gridLayer.removeFromSuperview()
            self.gridLayer = nil
        }
    }
    
    @IBAction func gifLoad(sender: AnyObject) {
        videoRatioBtn.enabled = true
        self.btnLoad.enabled = true
        self.btn_picker.enabled = true
        
        //        let load = self.storyboard?.instantiateViewControllerWithIdentifier("TempSaveListViewController")as! TempSaveListViewController
        //        self.navigationController?.navigationBarHidden = false
        //        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        //        self.navigationController?.pushViewController(load, animated: true)
        
        if self.editBarViewBottomConst.constant == 0.0// toggle on
        {
            self.editBarViewBottomConst.constant = 30.0
            let view = TempLoadView.instanceFromNib() as! TempLoadView
            view.parentViewController = self
            view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 30, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width + 20)
            
            self.view.addSubview(view)
            self.view.bringSubviewToFront(view)
            view.setConstsToOpenAll(0.1)
        }
        else if self.editBarViewBottomConst.constant == 30.0// toggle off
        {
            self.removeTempLoadView()
        }
    }
    
    func removeTempLoadView()
    {
        self.editBarViewBottomConst.constant = 0.0
        for view in self.view.subviews
        {
            if view.isMemberOfClass(TempLoadView)
            {
                view.removeFromSuperview()
            }
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.log("viewDidLoad")
        let width = self.editBarView.frame.size.width/5
        
        //        self.editButtonWid.constant = width
        //        let width = (self.editBarView.frame.size.width)/5
        self.videoRatioBtn.frame = CGRectMake(width*0, 0, width, 50)
        
        self.gridBtn.frame = CGRectMake(width*1, 0, width, 50)
        self.flashBtn.frame = CGRectMake(width*2, 0, width, 50)
        self.btnGhost.frame = CGRectMake(width*3, 0, width, 50)
        self.saveButton.frame = CGRectMake(width*4, 0, width, 50)
        self.btn_picker.frame = CGRectMake(width*5, 0, width, 50)
        self.btnLoad.frame = CGRectMake(width*6, 0, width, 50)
        self.editBarView.bounces = false
        log.log("\(self.editBarView.frame)  \(self.editBarView.contentSize)   \(self.editBarView.bounds)")
        
        self.btnNext.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        if self.appdelegate.locale != "ko_KR" {
            self.btnNext.frame = CGRectMake(225, 34, 80, 40)
            self.nextWid.constant = 80
        }
        self.editBarView.contentOffset = CGPoint(x: 0, y: 0)
        
        self.editBar.setImage(UIImage(named: "plus"),forState: .Normal)
        self.editBarView.hidden = true
        
        self.btnNext.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        
        
        self.type = "camera"
        imagePicker = UIImagePickerController()
        
        let longpress = UILongPressGestureRecognizer(target: self, action: Selector("longPress:"))
        captureDelete.addGestureRecognizer(longpress)
        self.backView.hidden = true
        
        
        //        self.btn_picker.hidden = true
        
        setupAVCapture()
        self.view.bringSubviewToFront(self.btnback)
        self.view.bringSubviewToFront(self.btnNext)
        self.view.bringSubviewToFront(self.selfiBtn)
        self.view.bringSubviewToFront(self.backView)
        self.view.bringSubviewToFront(self.spring)
        
        self.videoRatioBtn.enabled = true
        
        dispatch_after(dispatch_time_t(UInt64(300)), dispatch_get_main_queue(), {
            Config.getInstance().videoRatio = "3:4"
            self.cameraView.frame.size.width = Config.getInstance().wid
            self.cameraView.frame.size.height = Config.getInstance().hei
        })
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.editBarView.frame.size.width/5
        self.editBarView.contentSize = CGSize(width: width*7, height: 50)
        self.editBarView.contentInset = UIEdgeInsetsZero
        self.editBarView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        log.log("다시 로드중")
        videoRatioBtn.enabled = true
        gridBtn.enabled = true
        btnLoad.enabled = true
        btn_picker.enabled = true
        btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
        gridBtn.setImage(UIImage(named: "icon_camera_grid"), forState: .Normal)
        flashBtn.setImage(UIImage(named: "icon_camera_flash"), forState: .Normal)
        gridToggle = false
        flash_toggle = false
        let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            try avDevice.lockForConfiguration()
            if(avDevice.torchActive) {
                avDevice.torchMode = AVCaptureTorchMode.Off;
            }
        }catch {}
        
        if gridLayer != nil {
            self.gridLayer.removeFromSuperview()
            self.gridLayer = nil
        }
        
        if workFolder == nil {
            //workfolder가 없으면 다시 생성하는 코드
            print("workfolder empty")
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
            let date = dateFormatter.stringFromDate(NSDate())
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            
            dateText = date
            tmpFolder = "\(NSTemporaryDirectory())\(date)"
            workFolder = "\(documentDirectory)/\(date)"
            gifsFolder = "\(documentDirectory)/gifs"
            
            do {
                try fileManager.createDirectoryAtPath(tmpFolder!, withIntermediateDirectories: false, attributes: nil)
                try fileManager.createDirectoryAtPath(workFolder!, withIntermediateDirectories: false, attributes: nil)
                
                if(!fileManager.fileExistsAtPath(gifsFolder!)) {
                    try fileManager.createDirectoryAtPath(gifsFolder!, withIntermediateDirectories: false, attributes: nil)
                }
            } catch let error as NSError {
                //            print(error.localizedDescription);
            }
            gifName = "\(date).gif"
            if Config.getInstance().videoRatio == "1:1" {
                changeRatio(self.videoRatioBtn)
            }
            captureBar.deleteAll()
            num_of_capture = 0
            arr_recording_time.removeAll()
            
            total_recording_time = 0
            self.btnNext.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }else {
            print("workfolder ")
            if loadType == 1 {
                //임시저장에서 불러올 때
                self.videoRatioBtn.enabled = false
                self.btn_picker.enabled = false
                self.btnLoad.enabled = false
                if total_recording_time > 0.6 {
                    self.btnNext.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }else {
                    self.btnNext.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                }
            }
            if self.ratio != nil {
                Config.getInstance().videoRatio = self.ratio
                if Config.getInstance().videoRatio == "1:1" {
                    Config.getInstance().videoRatio = "3:4"
                    self.changeRatio(self.videoRatioBtn)
                }
            }
            
            
        }
        
        //        cameraView.frame.size.width = Config.getInstance().wid
        //        cameraView.frame.size.height = Config.getInstance().hei
        
        self.captureBar.frame.origin.y = cameraView.frame.size.height
        self.editPlusView.frame.origin.y = self.captureBar.frame.origin.y+10
        self.editPlusView.frame.size.height = self.view.frame.size.height - (self.cameraView.frame.height + 50 + 10)
        self.editPlusViewHei.constant = self.view.frame.size.height - (self.cameraView.frame.height + 50 + 10)
        
        print("captureBar   ",self.captureBar.frame,"  ",self.cameraView.frame.size.height)
        print("editPlusView  ",self.editPlusView.frame)
        
        if editBarView.hidden == false {
            actEditBar(self.editBar)
        }
        if(self.ghostLayer != nil) {
            let fileManager = NSFileManager.defaultManager()
            self.ghostLayer.removeFromSuperview()
            let outputPath = String(format: "%@/ghost.jpg", arguments: [self.workFolder!])
            do {
                try fileManager.removeItemAtPath(outputPath)
                
            } catch {
                
            }
        }
        session.startRunning()
        deleteState = 0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("경고경고경고")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]){
        //        print("Picker returned successfully")
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        self.dismissViewControllerAnimated(true, completion: nil)
        if mediaType.isEqualToString(kUTTypeMovie as NSString as String) {
            //            print("동영상 관련 전처리")
            // 이미지 추출 및 편집 뷰 컨트롤러로 이동
            
            let url = info[UIImagePickerControllerMediaURL] as! NSURL
            Config.getInstance().dataType = 1
            openMoviePreview(url)
        } else {
            //            print("연사 관련 전처리")
            // 이미지 추출 및 편집 뷰 컨트롤러로 이동
        }
    }
    
    
    func captureGhost() {
        
        capturePictureWithCompletition({ (image, error) -> Void in
            //            print("videoRatio ",Config.getInstance().videoRatio)
            //            print("capture image ok, image.width: \(image?.size.width), image.height: \(image?.size.height)")
            let outputPath = String(format: "%@/ghost.jpg", arguments: [self.workFolder!])
            //UIImagePNGRepresentation(image!)!.writeToFile(outputPath, atomically: true)
            
            if Config.getInstance().videoRatio == "1:1" {
                image?.cropToBounds(480, height: 480)
                image?.resizeImage(CGSize(width: 480, height: 480))
            }else {
                image?.cropToBounds(480, height: 640)
                image?.resizeImage(CGSize(width: 480, height: 640))
            }
            UIImageJPEGRepresentation(image!, 80)!.writeToFile(outputPath, atomically: true)
            self.session.removeOutput(self.stillImageOutput)
            self.session.commitConfiguration()
            self.getMovieOutput()
            
            self.ghostLayer = UIImageView(frame: self.cameraView.bounds)
            
            let offset:CGFloat = (self.view.frame.height - self.cameraView.frame.height) / CGFloat(2)
            
            self.ghostLayer.frame.origin.y = 0
            
            //let size:CGSize = CGSize(width: self.cameraView.bounds.width, height: self.cameraView.bounds.height)
            self.ghostLayer.image = image?.alpha(Config.getInstance().ghostAlpha)
            self.view.addSubview(self.ghostLayer)
            self.view.bringSubviewToFront(self.backView)
            self.view.bringSubviewToFront(self.spring)
            self.view.bringSubviewToFront(self.btnNext)
            self.view.bringSubviewToFront(self.btnback)
            self.btnGhost.setImage(UIImage(named: "icon_camera_ghost_c"), forState: .Normal)
            print("Ghost Capture ",self.ghostLayer.image)
        })
    }
    
    
    func openMoviePreview(url: NSURL) {
        
        do {
            let flist = try fileManager.contentsOfDirectoryAtPath(workFolder!)
            for movName in flist {
                if movName.hasSuffix(".mov") {
                    let name = movName.stringByReplacingOccurrencesOfString(".mov", withString: "")
                    let Path = String(format:"%@/%@.mov", arguments:[self.workFolder!, name])
                    try fileManager.removeItemAtPath(Path)
                }
            }
        }catch {
            
        }
        
        
        
        let moviePreviewVC = self.storyboard?.instantiateViewControllerWithIdentifier("MoviePreviewViewController") as? MoviePreviewViewController
        moviePreviewVC?.moviePath = url
        moviePreviewVC?.tmpFolder = tmpFolder
        moviePreviewVC?.workFolder = workFolder
        moviePreviewVC?.gifsFolder = gifsFolder
        moviePreviewVC?.gifName = gifName
        
        gridBtn.enabled = true
        btnLoad.enabled = true
        btn_picker.enabled = true
        
        
        btnGhost.setImage(UIImage(named: "icon_camera_ghost"), forState: .Normal)
        editBar.setImage(UIImage(named: "plus"), forState: .Normal)
        editBarView.hidden = true
        print("dddddddddda;lskdfjew;foiasdj;ojf;lsajf;oasdifsajd;lkjlk;j")
        
        
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.pushViewController(moviePreviewVC!, animated: true)
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagepickercontroller cancel")
        self.btn_picker.enabled = true
        self.btnLoad.enabled = true
        self.videoRatioBtn.enabled = true
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    
    
    func capturePictureWithCompletition(imageCompletition: (UIImage?, NSError?) -> Void) {
        dispatch_async(self.sessionQueue, {
            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: {(sample: CMSampleBuffer!, error: NSError!) -> Void in
                if (error == nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Up)
                    imageCompletition(image.imageRotatedByDegrees1(90), nil)
                } else {
                    imageCompletition(nil, error)
                }
            })
        })
    }
    
    func capturePhoto() {
        capturePictureWithCompletition({ (image, error) -> Void in
            //            print("capture image ok, image.width: \(image?.size.width), image.height: \(image?.size.height)")
            Config.getInstance().photoDataArr.append(image!)
        })
    }
    
    func stopPhoto() {
        limitPhotoTimeTimer!.invalidate()
        capturePhotoTimer!.invalidate()
        //let gifVC = self.storyboard?.instantiateViewControllerWithIdentifier("gifVC") as? GIFViewController
        //self.navigationController?.pushViewController(gifVC!, animated: true)
        
        //        print("동글뱅이")
        //        controlLoading(true)
        
        let gifMaker = GifMaker()
        gifMaker.save(Config.getInstance().photoDataArr, outPath: tmpFolder!)
        gifMaker.readyWork(tmpFolder!, workPath: workFolder!, ratio: "")
        
        Config.getInstance().photoDataArr = []
        
        let gifMakerVC = self.storyboard?.instantiateViewControllerWithIdentifier("GifMakerViewController") as? GifMakerViewController
        
        gifMakerVC?.workFolder = workFolder
        gifMakerVC?.gifsFolder = gifsFolder
        gifMakerVC?.gifName = gifName
        //        controlLoading(false)
        
        
        captureTypeBtn.enabled = true
        videoRatioBtn.enabled = true
        //        btn_picker.enabled = true
        
        
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.pushViewController(gifMakerVC!, animated: true)
    }
    
    // 영상 촬영하는 메소드 승일씨 코드 사용 안함.
    func controlRecording() {
        isRecord = !isRecord
        print("controlRecording: \(isRecord)")
        if isRecord {
            captureTypeBtn.enabled = false
            videoRatioBtn.enabled = false
            //            btn_picker.enabled = false
            if captureType == "video" {
                //let outputPath = "\(NSTemporaryDirectory())output.mov"
                let outputPath = String(format: "%@/%@.mov", arguments: [tmpFolder!,dateText!])
                
                let outputURL = NSURL(fileURLWithPath: outputPath)
                videoDataOutput.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
            }
            else {
                Config.getInstance().photoDataArr = Array()
                limitPhotoTimeTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("stopPhoto"), userInfo: nil, repeats: true)
                capturePhotoTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("capturePhoto"), userInfo: nil, repeats: true)
            }
        }
        else {
            captureTypeBtn.enabled = true
            videoRatioBtn.enabled = true
            //            btn_picker.enabled = true
            if captureType == "video" {
                videoDataOutput.stopRecording()
            }
            else {
                stopPhoto()
            }
        }
        Config.getInstance().dataType = 0
    }
    
    
    
    func setupOutputs() {
        if stillImageOutput == nil {
            stillImageOutput = AVCaptureStillImageOutput()
        }
    }
    
    
    
    
    
    
    
    // 영상 편집이 끝나고 미리보기로 넘어가는 메소드
    func exportDidFinish(session: AVAssetExportSession) {
        //        controlLoading(false)
        stopCamera()
        let outputFileURL = session.outputURL
        //        print("exportDidFinish = outputFileURL: \(outputFileURL)")
        // 전승일씨 코드
        //let previewVC = self.storyboard?.instantiateViewControllerWithIdentifier("previewVC") as? PreviewViewController
        // previewVC?.moviePath = outputFileURL
        //self.navigationController?.pushViewController(previewVC!, animated: true)
        
        openMoviePreview(outputFileURL!)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // 카메라 설정 변경1
    func setupAVCapture(){
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginSession()
                        break
                    }
                }
            }
        }
    }
    
    // 카메라 설정 변경2
    func beginSession(){
        var err : NSError? = nil
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        }
        if err != nil {
            //            print("error: \(err?.localizedDescription)")
        }
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPreset1280x720   //AVCaptureSessionPresetHigh
        if session.canAddInput(deviceInput){
            session.addInput(deviceInput)
        }
        videoDataOutput = AVCaptureMovieFileOutput()
        //videoDataOutput.maxRecordedDuration = maxDuration
        if session.canAddOutput(videoDataOutput){
            session.addOutput(videoDataOutput)
        }
        //        print(videoDataOutput)
        session.commitConfiguration()
        videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).enabled = true
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let rootLayer :CALayer = self.cameraView.layer
            rootLayer.masksToBounds = true
            self.previewLayer.frame = self.cameraView.bounds
            self.log.log("카메라 설정 변경 2   \(self.cameraView.frame)")
            self.cameraView.clipsToBounds = true
            rootLayer.addSublayer(self.previewLayer)
            
            if self.session.running == false {
                self.session.startRunning()
            }
        })
    }
    
    
    // 카메라 기능 끄기
    func stopCamera(){
        session.stopRunning()
        //done = false
    }
    
    
    func getMovieOutput() -> AVCaptureMovieFileOutput {
        var shouldReinitializeMovieOutput = videoDataOutput == nil
        if !shouldReinitializeMovieOutput {
            if let connection = videoDataOutput!.connectionWithMediaType(AVMediaTypeVideo) {
                shouldReinitializeMovieOutput = shouldReinitializeMovieOutput || !connection.active
                //                print("_getMovieOutput, shouldReinitializeMovieOutput: \(shouldReinitializeMovieOutput), connection.active: \(connection.active), shouldReinitializeMovieOutput: \(shouldReinitializeMovieOutput)")
            }
        }
        if shouldReinitializeMovieOutput {
            setupAVCapture()
        }
        return videoDataOutput!
    }
    
    
    // 비디오 촬영 끝났을 때 발생하는 이벤트
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        //print("didFinishRecordingToOutputFileAtURL - enter \(error)")
        //isRecord = false
        //controlLoading(true)
        //editMovie(outputFileURL) 승일씨 코드 사용 안함.
        
        //        print("saveed...")
        is_camera_ready = true
        //openMoviePreview(outputFileURL)
    }
    
    // 영상 편집 해주는 메소드
    func editMovie(url: NSURL) {
        let avAsset = AVAsset(URL: url)
        let mixComposition = AVMutableComposition()
        let videoTime = Double(Int(avAsset.duration.value)/Int(avAsset.duration.timescale))
        //        print("editMovie, videoTime: \(videoTime), avAsset.duration: \(avAsset.duration)")
        let assetTime: CMTime
        if videoTime > 15 {
            assetTime = CMTimeMake(9000, 600)
        }
        else {
            assetTime = avAsset.duration
        }
        Config.getInstance().frameCnt = Int(8*videoTime)
        let track = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo,
            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, assetTime),
                ofTrack: avAsset.tracksWithMediaType(AVMediaTypeVideo)[0] ,
                atTime: kCMTimeZero)
        } catch _ {
            //            controlLoading(false)
            //            print("error")
        }
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, assetTime)
        
        //        print("width: \(Config.getInstance().wid), height: \(Config.getInstance().hei)")
        mainInstruction.layerInstructions = [videoCompositionInstructionForTrack(track, asset: avAsset)]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 8)
        
        //        print("aaaaaaaaaa=================")
        //        print(Config.getInstance().wid)
        //        print(Config.getInstance().hei)
        
        var r_wid = Config.getInstance().wid
        var r_hei = Config.getInstance().hei
        
        if(r_wid % 2 != 0) {
            r_wid = r_wid - 1;
        }
        if(r_hei % 2 != 0) {
            r_hei = r_hei - 1;
        }
        //r_wid = 160
        //r_hei = 160
        
        mainComposition.renderSize = CGSize(width: r_wid, height: r_hei)
        
        /*
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let date = dateFormatter.stringFromDate(NSDate())
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let savePath = (documentDirectory as NSString).stringByAppendingPathComponent("mergeVideo-\(date).mov")
        */
        
        let savePath = String(format: "%@/%@.mov", arguments: [tmpFolder!,dateText!])
        
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputURL = NSURL(fileURLWithPath: savePath)
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.shouldOptimizeForNetworkUse = true
        exporter!.videoComposition = mainComposition
        exporter!.exportAsynchronouslyWithCompletionHandler() {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("exportAsynchronouslyWithCompletionHandler: \(exporter!.description)")
                self.exportDidFinish(exporter!)
            })
        }
    }
    
    // 기기 회전 관련(연관 거의 없음)
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
        }
        return (assetOrientation, isPortrait)
    }
    
    // 라이브러리에서 가져온 동영상을 5초와 사이즈 조건에 맞게 편집
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        
        //        print("videoCompositionInstructionForTrack====================")
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
        
        //        print(scaleToFitRatio);
        
        
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
            
            //scaleToFitRatio = scaleToFitRatio/2
            
            //            print((Config.getInstance().hei-UIScreen.mainScreen().bounds.height)/2)
            
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            //            print("scaleToFitRatio",scaleToFitRatio)
            //            print("scaleFactor ",scaleFactor)
            
            let concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, (Config.getInstance().hei-UIScreen.mainScreen().bounds.height)/2))
            instruction.setTransform(concat, atTime: kCMTimeZero)
            
            //            print("=======================")
        } else {
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            
            //            print("scaleFactor ",scaleFactor)
            
            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
            if assetInfo.orientation == .Down {
                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                let windowBounds = UIScreen.mainScreen().bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
            }
            instruction.setTransform(concat, atTime: kCMTimeZero)
        }
        
        return instruction
    }
    
    // 메인 인디케이터 호출해주는 메소드
    //    func controlLoading(val: Bool) {
    //        if val {
    //            _hud!.show(true)
    //        }
    //        else {
    //            _hud!.hide(true)
    //        }
    //    }
    
    
    
    func make_grid() {
        self.gridLayer = UIImageView(frame: self.cameraView.frame)
        log.log("cameraView bounds    \(self.cameraView.bounds)    \(self.cameraView.frame)")
        //        print("전체 뷰 크기")
        //        print(self.view.bounds.size.height)
        
        let offset:CGFloat = (self.view.frame.height - self.cameraView.frame.height) / CGFloat(2)
        //        print(offset)
        
        //        self.gridLayer.frame.origin.y = 0
        
        let size:CGSize = CGSize(width: self.cameraView.bounds.width, height: self.cameraView.bounds.height)
        self.gridLayer.image = self.drawCustomImage(size)
        self.gridLayer.frame = CGRectMake(0, self.higherCameraCoverView.frame.height, UIScreen.mainScreen().bounds.width, self.cameraView.frame.height - (self.higherCameraCoverView.frame.height + self.lowerCameraCoverView.frame.height))
        self.cameraView.addSubview(self.gridLayer)
        log.log("cameraView bounds22222222    \(self.cameraView.bounds)    \(self.cameraView.frame)")
    }
    
    
    // -------------------------------------------------------------------------------
    // Used for drawing the grids ontop of the view port
    // -------------------------------------------------------------------------------
    
    func drawCustomImage(size: CGSize) -> UIImage {
        
        //func drawRect() {
        //CGContextRef context = UIGraphicsGetCurrentContext();
        let opaque = false
        let scale: CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(context, 0.5)
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        //let scale: CGFloat
        let numberOfColumns = 3;
        let numberOfRows = 3;
        
        let columnWidth: CGFloat = self.cameraView.frame.width / CGFloat(numberOfColumns)  ;//self.frame.size.width / (self.numberOfColumns + 1.0);
        
        for(var i = 1; i < numberOfColumns; i++) {
            var startPoint = CGPoint()
            var endPoint = CGPoint()
            
            startPoint.x = columnWidth * CGFloat(i)
            startPoint.y = 0.0
            
            endPoint.x = startPoint.x
            endPoint.y = self.cameraView.frame.height
            
            CGContextMoveToPoint(context, startPoint.x, startPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
            CGContextStrokePath(context)
        }
        
        
        let rowHeight:CGFloat = self.cameraView.frame.height / CGFloat(numberOfRows);
        
        for(var j = 1; j < numberOfRows; j++)
        {
            var startPoint = CGPoint()
            var endPoint = CGPoint()
            
            startPoint.x = 0.0;
            startPoint.y = rowHeight * CGFloat(j);
            
            endPoint.x = self.cameraView.frame.width;
            endPoint.y = startPoint.y;
            
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            CGContextStrokePath(context);
        }
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
}


extension UIImage {
    
    public func alpha(value:CGFloat)->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext();
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -area.size.height);
        CGContextSetBlendMode(ctx, CGBlendMode.Multiply);
        CGContextSetAlpha(ctx, value);
        CGContextDrawImage(ctx, area, self.CGImage);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    public func imageRotatedByDegrees1(degrees: CGFloat) -> UIImage {
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let viewSize: CGSize
        if Config.getInstance().videoRatio == "1:1" {
            if size.width>640 {
                viewSize = CGSizeMake(640, 640)
            }
            else {
                viewSize = CGSizeMake(size.width, size.width)
                //                print("UIImage======================")
                //                print(size.width)
            }
        }
        else {
            if size.height>640 {
                viewSize = CGSizeMake(640, 480)
            }
            else {
                viewSize = CGSizeMake(4*size.width/3, size.width)
            }
        }
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointMake(size.width/2, size.height/2), size: viewSize))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees))
        // Now, draw the rotated/scaled image into the context
        let viewScale: CGFloat
        var maxSize: CGFloat
        if Config.getInstance().videoRatio == "1:1" {
            maxSize = 640
        }
        else {
            maxSize = 480
        }
        if size.height>maxSize {
            viewScale = CGFloat(maxSize/size.height)
        }
        else {
            viewScale = size.height
        }
        CGContextScaleCTM(bitmap, viewScale, -viewScale)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}