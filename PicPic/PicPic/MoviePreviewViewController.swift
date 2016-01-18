//
//  MoviePreviewViewController.swift
//  cameraTester
//
//  Created by 찬누리 박 on 2015. 11. 19..
//  Copyright © 2015년 picpic. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import SpringIndicator

class MoviePreviewViewController : SubViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var timeLimit = 5.0 as Float
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var spring: SpringIndicator!
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet var btn_next: UIButton!
    @IBOutlet var btn_prev: UIButton!
    let fileManager = NSFileManager.defaultManager()
    
    @IBOutlet var movieView: UIView!
    
    @IBOutlet var labelStart: UILabel!
    @IBOutlet var labelEnd: UILabel!
    
    @IBOutlet var sliderStart: UISlider!
    @IBOutlet var sliderEnd: UISlider!
    @IBOutlet var btn_play_select: UIButton!
    
    @IBOutlet weak var startMent: UILabel!
    @IBOutlet weak var endMent: UILabel!
    
    var moviePlayer : AVPlayer?
    var moviePath: NSURL?
    var asset : AVAsset?
    
    var tmpFolder:String?
    var workFolder:String?
    var gifsFolder:String?
    var gifName:String?
    var _hud: MBProgressHUD?
    var indicator : SpringIndicator?
    var ghostLayer:UIImageView?
    @IBOutlet weak var movieViewHei: NSLayoutConstraint!
    let gifMaker = GifMaker()
    //    let log = LogPrint()
    @IBOutlet weak var nextWid: NSLayoutConstraint!
    
    func setGhost(path:String,frame:CGRect) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let image = UIImage(contentsOfFile: path)
            self.ghostLayer = UIImageView(frame: frame)
            //////print(""무비 뷰 크기")
            //print("self.movieView.bounds)
            
            //            self.ghostLayer!.frame.origin.x = self.movieView.frame.origin.x
            //            self.ghostLayer!.frame.origin.y = self.movieView.frame.origin.y
            
            //print("self.ghostLayer?.bounds)
            //let size:CGSize = CGSize(width: self.cameraView.bounds.width, height: self.cameraView.bounds.height)
            self.ghostLayer!.image = image?.alpha(Config.getInstance().ghostAlpha)
            self.view.addSubview(self.ghostLayer!)
            self.view.bringSubviewToFront(self.backView)
            self.view.bringSubviewToFront(self.spring)
            self.view.bringSubviewToFront(self.btn_next)
            self.view.bringSubviewToFront(self.btn_prev)
            
        }
        
    }
    
    @IBAction func actPrev(sender: AnyObject) {
        moviePlayer?.rate = 0
        moviePlayer = nil
        asset = nil
        
        print("workfolder = ",self.appdelegate.camera.workFolder)
        self.appdelegate.camera.workFolder = nil
        
        // tmp폴더의 추출되었던 mov나 jpg 등 삭제 코드 추가
        self.appdelegate.testNavi.navigationBarHidden = false
        if !self.appdelegate.myfeed.view.hidden {
            self.appdelegate.testNavi.navigationBarHidden = true
        }
        self.appdelegate.testNavi.popToRootViewControllerAnimated(true)
    }
    
    func backViewShow(state : Bool){
        
        if state {
            self.backView.hidden = false
            //            self.view.bringSubviewToFront(self.spring)
            self.spring.startAnimation()
        }else {
            self.backView.hidden = true
            //            self.view.bringSubviewToFront(self.spring)
            self.spring.stopAnimation(true)
        }
        
        
    }
    
    @IBAction func actNext(sender: UIButton) {
        
        
        
        //        if ((self.sliderStart.value)>timeLimit) {
        //            let alert = UIAlertController(title: "", message: self.appdelegate.ment["camera_video_setting"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
        //            alert.addAction(UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default, handler: nil))
        //            presentViewController(alert, animated: true, completion: nil)
        //            return
        //        }
        
        
        let start = Double(self.sliderStart.value)
        let end = Double(self.sliderStart.value + self.sliderEnd.value)
        self.backViewShow(true)
        
        //////print(""backView : \(self.backView.hidden)")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let gifMaker = GifMaker()
                let outoutPath = String(format:"%@/00.mov", arguments:[self.workFolder!])
                //print("self.moviePath)
                //let url = NSURL(fileURLWithPath: moviePath)
                let avAsset = AVAsset(URL: self.moviePath!)
                //AVAssetExportPreset1280x720
                let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPreset1280x720)
                exportSession?.outputURL = NSURL(fileURLWithPath: outoutPath)
                exportSession?.outputFileType = AVFileTypeQuickTimeMovie
                
                let range = CMTimeRangeMake(CMTimeMakeWithSeconds(start,600), CMTimeMakeWithSeconds(end,600))
                
                exportSession?.timeRange = range
                
                exportSession!.shouldOptimizeForNetworkUse = true
                //exportSession!.videoComposition = mainComposition
                exportSession!.exportAsynchronouslyWithCompletionHandler() {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //////print(""exportAsynchronouslyWithCompletionHandler: \(exportSession!.description)")
                        
                        
                        self.gifMaker.movSplit(self.moviePath!, time_start: start, time_end: end, outputPath: String(format: "%@/00", arguments: [self.workFolder!]))
                        
                        
                        do {
                            //////print(""make Thumb")
                            let jpgPath = outoutPath.stringByReplacingOccurrencesOfString(".mov", withString: "")
                            //print("jpgPath)
                            try self.fileManager.copyItemAtPath(String(format:"%@/000.jpg", jpgPath), toPath: String(format:"%@/thumb.jpg", self.workFolder!))
                        }catch {
                            
                        }
                        self.backViewShow(false)
                        let gifMakerVC = self.storyboard?.instantiateViewControllerWithIdentifier("GifMakerViewController") as? GifMakerViewController
                        
                        gifMakerVC?.workFolder = self.workFolder
                        gifMakerVC?.gifsFolder = self.gifsFolder
                        gifMakerVC?.gifName = self.gifName
                        gifMakerVC?.arr_recoding_time.append(end-start)
                        
                        //        controlLoading(false)
                        //        loading.stopAnimating()
                        self.appdelegate.testNavi.pushViewController(gifMakerVC!, animated: true)
                    })
                }
            })
        }
        
    }
    
    @IBAction func actPlaySelect(sender: UIButton) {
        //        //////print(""구간 재생")
        self.moviePlayer?.rate = 0
        
        //let seekTime = NSValue(CMTime: CMTimeMake(Int64(self.sliderEnd.value), 1))
        let seekTime = NSValue(CMTime: CMTimeMake(Int64(self.sliderStart.value + self.sliderEnd.value), 1))
        let seekTime_start = CMTimeMake(Int64(self.sliderStart.value), 1)
        
        moviePlayer!.seekToTime(seekTime_start, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        moviePlayer!.play()
        
        moviePlayer?.addBoundaryTimeObserverForTimes([seekTime], queue: nil, usingBlock:{
            self.moviePlayer?.rate = 0
        })
        
        
    }
    
    
    
    
    @IBAction func sliderStartValueChange(sender: UISlider) {
        self.moviePlayer?.rate = 0
        let asset = AVAsset(URL: moviePath!)
        
        //영상의 끝
        if(Double(sender.value + self.sliderEnd.value) > CMTimeGetSeconds(asset.duration) - 0.1) {
            let alert = UIAlertController(title: "", message: self.appdelegate.ment["camera_setting"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                sender.value = self.sliderStart.value - 0.1
            })
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        //btnPlaySetTitle()
        
        self.labelStart.text = NSString(format: "%.1f", sender.value) as String
        
        moviePlayer?.rate = 0 // stop
        
        let seekTime : CMTime = CMTimeMake(Int64(sender.value), 1)
        //moviePlayer!.seekToTime(seekTime)
        moviePlayer!.seekToTime(seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func btnPlaySetTitle() {
        let txt = "구간재생 (" + self.labelEnd.text! + ")"
        
        self.btn_play_select.setTitle(txt, forState: UIControlState.Normal)
    }
    
    
    @IBAction func sliderEndValueChange(sender: UISlider) {
        moviePlayer?.rate = 0
        let asset = AVAsset(URL: moviePath!)
        
        //영상의 끝
        if(Double(sender.value + self.sliderStart.value) > CMTimeGetSeconds(asset.duration) - 0.1) {
            let alert = UIAlertController(title: "", message: self.appdelegate.ment["camera_setting"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                sender.value = self.sliderEnd.value - 0.1
            })
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        //1초 이하
        if(sender.value < 1)
        {
            let alert = UIAlertController(title: "", message: self.appdelegate.ment["camera_endpoint"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                sender.value = self.sliderEnd.value + 0.1
            })
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
        
        self.labelEnd.text = NSString(format: "%.1f", sender.value) as String
        
        let txt = "구간재생 (" + String(format: "%.1f", sender.value) + ")"
        self.btn_play_select.setTitle(txt, forState: UIControlState.Normal)
        
        moviePlayer?.rate = 0 // stop
        
        /*let seekTime : CMTime = CMTimeMake(Int64(sender.value), 1)
        moviePlayer!.seekToTime(seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)*/
    }
    
    func playVideo() {
        
        print("moviePath")
        
        
        moviePlayer = AVPlayer(URL: moviePath!)
        let playerLayer = AVPlayerLayer(player: moviePlayer)
        
        //        playerLayer.frame = movieView.frame;
        //        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        //        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        let asset = AVAsset(URL: moviePath!)
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        let ratio = Config.getInstance().videoRatio
        
        let movieFrameRect:CGRect?
        
        if(Config.getInstance().dataType == 1) {
            //////print(""원본 비율 유지")
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
            //            let _height = Config.getInstance().wid*assetTrack.naturalSize.height/assetTrack.naturalSize.width
            movieFrameRect = CGRectMake(0, 0, Config.getInstance().wid, Config.getInstance().wid)
        } else {
            if(ratio == "1:1") {
                print("1:1")
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                movieFrameRect = CGRectMake(0, 0, Config.getInstance().wid, Config.getInstance().wid)
            } else {
                print("3:4")
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                //print("assetTrack.naturalSize)
                
                if(assetTrack.naturalSize.width>assetTrack.naturalSize.height) {
                    print("aaaaaaa")
                    let posX = Config.getInstance().wid/8
                    movieFrameRect = CGRectMake(posX, 0, Config.getInstance().wid*3/4, Config.getInstance().wid)
                } else {
                    print("bbbbbbbbbb")
                    let posY = Config.getInstance().wid/8
                    print(posY)
                    movieFrameRect = CGRectMake(0, posY, Config.getInstance().wid, Config.getInstance().wid*3/4)
                    
                }
                // 무비 영상 수정 삽입
            }
        }
        //        //print("movieFrameRect)
        
        playerLayer.frame = movieFrameRect!
        print("playerLayer",playerLayer.frame)
        
        
        movieView.layer.addSublayer(playerLayer)
        
        moviePlayer?.play()
        
        
        let time_total = CMTimeGetSeconds(asset.duration)
        
        var time_end = Double(timeLimit);
        if(time_total < time_end) {
            time_end = time_total
        }
        
        
        //        //print("time_end)
        
        self.sliderStart.minimumValue = 0
        self.sliderStart.maximumValue = Float((time_total)-0.1)
        self.sliderStart.value = 0
        
        self.sliderEnd.minimumValue = 0.1
        self.sliderEnd.maximumValue = 5
        self.sliderEnd.value = 1.0
        
        //self.sliderEnd.value = 10
        
        
        self.labelStart.text = "0"
        self.labelEnd.text = "1"
        
        let imgPath = String(format: "%@/ghost.jpg", arguments:[workFolder!])
        //        setGhost(imgPath,frame: movieFrameRect!)
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.type = "movie"
        self.startMent.text = self.appdelegate.ment["camera_startMent"].stringValue
        self.endMent.text = "지속시간"
        self.btn_next.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        
        if self.appdelegate.locale != "ko_KR" {
            self.btn_next.frame = CGRectMake(225, 34, 80, 33)
            self.nextWid.constant = 80
        }
        print("moviePreview")
        
        _hud = MBProgressHUD()
        _hud!.mode = MBProgressHUDModeIndeterminate
        view.addSubview(_hud!)
        controlLoading(false)
        
        self.backView.hidden = true
        //        self.movieViewHei.constant = Config.getInstance().hei
        
        playVideo()
        //        self.movieView.hidden = true
        
    }
    
    func controlLoading(val: Bool) {
        if val {
            _hud!.show(true)
        }
        else {
            _hud!.hide(true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        btnPlaySetTitle()
    }
    
    
}