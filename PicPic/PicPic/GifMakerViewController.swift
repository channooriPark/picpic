//
//  GifMakerViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 20..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import SwiftyJSON
import SpringIndicator

class GifMakerViewController : SubViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource ,UIAlertViewDelegate{
    
    
    let default_delay = Float(0.2) // Gif 기본 Delay 값
    
    var tmpFolder:String?
    var workFolder:String?
    var gifsFolder:String?
    var gifName:String?
    
    var ghostPath:String?
    var scratchPath:String?
    
    var playType = 0
    var collectionType = 0 // 0:필터 1:이미지리스트
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var imagePicker: UIImagePickerController?
    //    var ghostLayer:UIImageView?
    var _hud: MBProgressHUD?
    var alert : UIAlertView!
    var progressView : UIProgressView!
    
    var gifView:GifView = GifView()
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var sliderDelay: UISlider!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var frameSlider: UISlider!
    @IBOutlet weak var playSpeedText: UILabel!
    @IBOutlet weak var frameText: UILabel!
    
    @IBOutlet var btnNext: UIButton!
    @IBOutlet weak var btnPre: UIButton!
    
    @IBOutlet var btnBasic: UIButton!
    @IBOutlet var btnPlayType: UIButton!
    @IBOutlet var btnFilters: UIButton!
    @IBOutlet var btnEditor: UIButton!
    @IBOutlet weak var btnText: UIButton!
    
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnDrop: UIButton!
    @IBOutlet weak var editorCancle: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var btnEraser: UIButton!
    
    @IBOutlet weak var playSpeed: UIView!
    @IBOutlet weak var editplus: UIView!
    @IBOutlet weak var basicButtonView: UIView!
    @IBOutlet weak var imageHei: NSLayoutConstraint!
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var textEditView: UIView!
    @IBOutlet weak var conformView: UIView!
    @IBOutlet weak var eraserView: UIView!
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var addText: UIButton!
    @IBOutlet weak var changeFont: UIButton!
    
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var eraserSlider: UISlider!
    @IBOutlet weak var waterMark: UIButton!
    var waterToggle = true
    
    @IBOutlet weak var colorViewHei: NSLayoutConstraint!
    @IBOutlet weak var conformViewHei: NSLayoutConstraint!
    @IBOutlet weak var completeHei: NSLayoutConstraint!
    @IBOutlet weak var cancleHei: NSLayoutConstraint!
    @IBOutlet weak var textEditViewHei: NSLayoutConstraint!
    @IBOutlet weak var addTextHei: NSLayoutConstraint!
    @IBOutlet weak var changeFontHei: NSLayoutConstraint!
    
    @IBOutlet weak var collectionHei: NSLayoutConstraint!
    @IBOutlet weak var playspeedHei: NSLayoutConstraint!
    @IBOutlet weak var eraserViewHei: NSLayoutConstraint!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var imagePosY: NSLayoutConstraint!
    @IBOutlet weak var nextWid: NSLayoutConstraint!
    @IBOutlet weak var eraserSliderTop: NSLayoutConstraint!
    
    var previewTimer:NSTimer?
    var canvas : UIView!
    var text:MyView!
    var allText = [MyView]()
    var myViewArr = [UIView]()
    var textArr = [[MyView]]()
    
    var old_text:String?
    var old_fontname:String?
    var old_frame:CGRect?
    var old_transform:CGAffineTransform!
    var old_bounds:CGRect!
    var old_color:String!
    
    var ori_mov : [String] = [String]()
    
    
    var movNames:[String] = []
    
    var collections:[UIImage] = []
    
    var images: [UIImage] = []
    var imagePaths: [String] = []
    var filterButtonName:[String] = []
    var imageLoading = false
    var gifMaker = GifMaker()
    //var filter:CIFilter?
    
    var filterCurrent:String = "None"
    var filterSet:String = "None"
    
    var selectedCellIndex = -1
    let log = LogPrint()
    var colorArray : NSArray!
    var colorButton = [UIButton]()
    
    
    
    var lastPoint = CGPoint.zero
    var red: CGFloat = 255.0
    var green: CGFloat = 255.0
    var blue: CGFloat = 255.0
    var brushWidth: CGFloat = 20.0
    var opacity: CGFloat = 2.0
    
    var drawImage = UIImageView()
    var frontImage = UIImageView()
    var historyImg:[UIImage] = []
    var mouseSwiped:Bool?
    var mouseMoved:Int?
    
    var imageArr = [[UIImage]]()
    var imagePathArr = [[String]]()
    
    var playImageArr = [[UIImage]]()
    var playImagePathArr = [[String]]()
    var interval : NSTimeInterval = 0
    var imageCheck = [Int:Int]()
    var cellArr = [Int]()
    var tempFront : UIImage!
    var maskImage = UIImageView()
    @IBOutlet weak var spring: SpringIndicator!
    @IBOutlet weak var editScroll: UIScrollView!
    @IBOutlet weak var editwid: NSLayoutConstraint!
    @IBOutlet weak var undoHei: NSLayoutConstraint!
    @IBOutlet weak var undoTop: NSLayoutConstraint!
    var progressContainerView : UIView!
    var arr_recoding_time:[Double] = [Double]()
    var in_type : Int = 0 // 0이면 카메라 1이면 저장리스트
    var addImage : Bool = false
    
    override func viewDidDisappear(animated: Bool) {
        self.view = nil
        filterCurrent = ""
    }
    
    func delayValue() -> Float {
        return 0.1 / self.sliderDelay.value
    }
    
    func drag(sender:UIPanGestureRecognizer){
        let p = sender.locationInView(colorView)
        let wid = self.view.bounds.size.width/20
        let test = Int(p.x/wid)
        selectColor(colorButton[test])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnNext.setTitle(self.appdelegate.ment["complete1"].stringValue, forState: .Normal)
        self.type = "maker"
        imageHei.constant = Config.getInstance().hei
        
        self.gifView.frame = CGRectMake(self.image.frame.origin.x, self.image.frame.origin.y, self.view.bounds.size.width, self.imageHei.constant)
        self.view.addSubview(self.gifView)
        
        self.progressContainerView = UIView(frame: CGRectMake(0,0, UIScreen.mainScreen().bounds.width - 20, 50))
        self.progressContainerView!.center = self.gifView.center
        self.progressContainerView!.backgroundColor = UIColor.darkGrayColor()
        
        self.progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
        self.progressView!.frame = CGRectMake(10, 10, self.view.frame.width - 50, 10)
        
        self.progressView!.tintColor = UIColor(red: 129 / 255, green: 1, blue: 1, alpha: 1.0)
        self.progressView!.trackTintColor = UIColor.darkGrayColor();
        self.progressView!.progress = 0.0
        
        
        let progressLabel = UILabel(frame: CGRectMake(20, 20, 0, 0))
        progressLabel.font = UIFont.systemFontOfSize(12.0)
        progressLabel.textColor = UIColor.whiteColor()
        progressLabel.text = "0%"
        progressLabel.sizeToFit()
        
        self.progressContainerView!.addSubview(self.progressView!)
        self.progressContainerView!.addSubview(progressLabel)
        self.view.addSubview(self.progressContainerView!)
        self.progressContainerView!.hidden = true
        
        
        //        //print("imageSize : ",self.imageHei.constant)
        //        //print("view width : ",Config.getInstance().wid)
        //        //print("height : " , imageHei.constant)
        self.canvas = UIView(frame: CGRectMake(self.image.frame.origin.x, self.image.frame.origin.y, self.view.bounds.size.width, self.imageHei.constant))
        self.canvas.clipsToBounds = true
        self.view.addSubview(canvas)
        let path = NSBundle.mainBundle().pathForResource("colorPalette", ofType: "plist")
        self.colorArray = NSArray(contentsOfFile: path!)
        
        
        self.eraserSlider.value = Float(brushWidth)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        canvas.addGestureRecognizer(tap)
        
        
        var width = self.basicButtonView.frame.size.width/4
        self.btnBasic.frame = CGRectMake(0, 0, width , 50)
        self.btnPlayType.frame = CGRectMake(width*1, 0, width, 50)
        self.btnFilters.frame = CGRectMake(width*2, 0, width, 50)
        self.btnEditor.frame = CGRectMake(width*3, 0, width, 50)
        
        
        //        width = (self.editScroll.frame.size.width)/6
        width = 70
        self.editorCancle.frame = CGRectMake(0, 0, 50, 50)
        
        self.btnDrop.frame = CGRectMake(width*0, 0, width, 50)
        self.btnCopy.frame = CGRectMake(width*1, 0, width, 50)
        self.btnEraser.frame = CGRectMake(width*2, 0, width, 50)
        self.btnText.frame = CGRectMake(width*3, 0, width, 50)
        self.saveButton.frame = CGRectMake(width*4, 0, width, 50)
        self.btnAdd.frame = CGRectMake(width*5, 0, width, 50)
        self.editScroll.bounces = false
        
        //        width = (self.editplus.frame.size.width)/5
        //        self.editorCancle.frame = CGRectMake(width*0, 0, width, 50)
        //        self.btnDrop.frame = CGRectMake(width*1, 0, width, 50)
        //        self.btnText.frame = CGRectMake(width*2, 0, width, 50)
        ////        self.btnAdd.frame = CGRectMake((50+width)*2, 0, width, 50)
        //        self.saveButton.frame = CGRectMake(width*3, 0, width, 50)
        
        self.playSpeed.frame.origin.y = 4*UIScreen.mainScreen().bounds.width/3
        //        //print(self.playSpeed.frame.origin.y)
        self.playspeedHei.constant = self.view.frame.size.height - (self.playSpeed.frame.origin.y+50)
        self.collectionView.frame.origin.y = self.playSpeed.frame.origin.y
        self.collectionHei.constant = self.playspeedHei.constant
        self.eraserView.frame.origin.y = self.playSpeed.frame.origin.y
        self.eraserViewHei.constant = self.playspeedHei.constant
        //        //print(self.collectionHei.constant)
        
        var colorindex = 0
        let wid = self.view.bounds.size.width/20
        let count = colorArray.count
        
        if let colorlist = self.colorArray {
            for var i=0; i<count; i++ {
                let button = UIButton(type: .System)
                button.frame = CGRectMake(wid*CGFloat(i), 0, 30, 50)
                button.backgroundColor = hexStringToUIColor(colorArray[colorindex] as! String)
                button.addTarget(self, action: Selector("selectColor:"), forControlEvents: .TouchDown)
                self.colorView.addSubview(button)
                colorindex++
                colorButton.append(button)
            }
        }
        let drag = UIPanGestureRecognizer(target: self, action: "drag:")
        colorView.addGestureRecognizer(drag)
        
        self.collectionView.hidden = true
        self.editplus.hidden = true
        self.playSpeed.hidden = false
        self.basicButtonView.hidden = false
        self.colorView.hidden = true
        self.textEditView.hidden = true
        self.conformView.hidden = true
        self.eraserView.hidden = true
        
        //slider revers
        self.sliderDelay.minimumValue = 0.1
        self.sliderDelay.maximumValue = 0.5
        self.sliderDelay.value = default_delay
        self.sliderDelay.transform = CGAffineTransformRotate(self.sliderDelay.transform, CGFloat(180.0/180*M_PI))
        self.sliderDelay.maximumTrackTintColor = Config.getInstance().color
        self.sliderDelay.tintColor = UIColor.lightGrayColor()
        if self.view.frame.size.width == 375.0 {
            self.eraserSliderTop.constant = 20
            self.undoHei.constant -= 5
            self.undoTop.constant += 7
        }else {
            self.eraserSliderTop.constant = 10
        }
        
        let fileManager = NSFileManager.defaultManager()
        //        //print(workFolder)
        let nib = UINib(nibName: "collCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        (self.collectionView.collectionViewLayout as! RAReorderableLayout).scrollDirection = .Horizontal
        //self.applyGradation()
        
        self.ghostPath = String(format: "%@/ghost.jpg", arguments:[workFolder!])
        self.scratchPath = String(format: "%@/scratch.jpg", arguments:[workFolder!])
        
        let json_path = String(format: "%@/db.json", arguments: [workFolder!])
        
        if(fileManager.fileExistsAtPath(json_path)) {
            in_type = 1
            let jsonData:NSData = NSData(contentsOfFile: json_path)!
            let json = JSON(data:jsonData)
            log.log("json Data \(json)")
            if let version = json["version"].bool {
                if version {
                    self.sliderDelay.value = Float(json["delay"].string!)!
                    if let items = json["files"].array {
                        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                        log.log("\(items)")
                        for item in items {
                            if let file_name = item.string {
                                let name = documentDirectory+"/"+file_name
                                var arr:[UIImage] = []
                                var pathArr:[String] = []
                                print("name   ",name)
                                movNames.append(name)
                                if let enumerator = fileManager.enumeratorAtPath(name){
                                    while let element = enumerator.nextObject() as? String {
                                        let imgPath = String(format: "%@/%@", arguments: [name,element]) //"\(workFolder)/\(element)"
                                        let img = UIImage(contentsOfFile: imgPath)
                                        print("imgPath   ",imgPath)
                                        arr.append(img!)
                                        pathArr.append(imgPath)
                                    }
                                    self.imageArr.append(arr)
                                    self.imagePathArr.append(pathArr)
                                }
                            }
                        }
                        print(imagePathArr)
                        make_gif()
                        log.log("\(imagePathArr)")
                    }
                    self.waterToggle = json["watermark"].boolValue
                    if json["watermark"].boolValue {
                        self.waterMark.setImage(UIImage(named: "watermark"), forState: .Normal)
                    }else {
                        self.waterMark.setImage(UIImage(named: "no_mark"), forState: .Normal)
                    }
                    //                    let imgPath = String(format: "%@/ghost.jpg", arguments:[workFolder!])
                    //                    if fileManager.fileExistsAtPath(imgPath) {
                    //                        setGhost(imgPath)
                    //                    }
                    if(json["direction"]=="normal") {
                        playType = 0
                    } else {
                        playType = 1
                        imagePaths = imagePaths.reverse()
                    }
                    if(json["filter"].string! != "None") {
                        self.filterCurrent = json["filter"].string!
                        //                        if let tmepImage = self.ghostLayer?.image {
                        //                            var temp = tmepImage
                        //                            applyFilter(&temp, filterName: self.filterCurrent)
                        //                            self.ghostLayer!.image = temp
                        //                        }
                        log.log("\(filterCurrent)")
                        previewTimer?.invalidate()
                        previewTimer = nil
                        playImageArr = [[UIImage]]()
                        for var i=0; i<frameimagepathArr.count; i++ {
                            playImageArr.append([])
                            for var j=0; j<frameimagepathArr[i].count; j++ {
                                var image:UIImage? = UIImage(contentsOfFile: frameimagepathArr[i][j])
                                applyFilter(&image!, filterName: self.filterCurrent)
                                playImageArr[i].append(image!)
                                image = nil
                            }
                            
                        }
                        log.log("\(playImageArr.count)")
                        self.insetAllFram()
                        selectedCellIndex = -1
                        frameIndex = 0
                        currentIndex1 = 0
                        interval = Double(self.sliderDelay.value)
                        previewTimer?.invalidate()
                        previewTimer = nil
                        previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
                    } else {
                        make_gif()
                    }
                    if json["subtitle"].array!.count > 0 {
                        log.log("asdjfo;eija;lveoianfl;kj;j;oasfj")
                        var newView : MyView!
                        self.textArr = [[MyView]]()
                        if let sub = json["subtitle"].array {
                            for var i=0; i<sub.count; i++ {
                                self.textArr.append([])
                                for var j=0; j<sub[i].count; j++ {
                                    if let _ = sub[i][j]["frame"]["x"].float {
                                        newView = MyView(frame: CGRectMake(CGFloat(sub[i][j]["frame"]["x"].float!), CGFloat(sub[i][j]["frame"]["y"].float!), CGFloat(sub[i][j]["frame"]["width"].float!), CGFloat(sub[i][j]["frame"]["height"].float!)))
                                        newView.text = sub[i][j]["text"].string!
                                        newView.fontName = sub[i][j]["font"].string!
                                        newView.bounds = CGRectMake(CGFloat(sub[i][j]["bounds"]["x"].float!), CGFloat(sub[i][j]["bounds"]["y"].float!), CGFloat(sub[i][j]["bounds"]["width"].float!), CGFloat(sub[i][j]["bounds"]["height"].float!))
                                        newView.transform = CGAffineTransform(a: CGFloat(sub[i][j]["transform"]["a"].float!), b: CGFloat(sub[i][j]["transform"]["b"].float!), c: CGFloat(sub[i][j]["transform"]["c"].float!), d: CGFloat(sub[i][j]["transform"]["d"].float!), tx: CGFloat(sub[i][j]["transform"]["tx"].float!), ty: CGFloat(sub[i][j]["transform"]["ty"].float!))
                                        log.log("\(newView.transform)")
                                        newView.color = sub[i][j]["color"].string!
                                        newView.regen()
                                        newView.deselected()
                                        newView.label?.addTarget(self, action: "didSelect:", forControlEvents: .TouchUpInside)
                                        newView.btn_remove?.addTarget(self, action: Selector("remove:"), forControlEvents: .TouchUpInside)
                                        self.textArr[i].append(newView)
                                    }
                                }
                            }
                        }
                    }
                    
                    if json["allText"].array!.count > 0 {
                        if let all = json["allText"].array {
                            if all.count > 0 {
                                log.log("alltext count > 0")
                                for var i = 0; i<all.count; i++ {
                                    let alltext = all[i]
                                    log.log("\(alltext.string)")
                                    if alltext.string != "" {
                                        if let _ = alltext["frame"]["y"].float {
                                            let newView = MyView(frame: CGRectMake(CGFloat(alltext["frame"]["x"].float!), CGFloat(alltext["frame"]["y"].float!), CGFloat(alltext["frame"]["width"].float!), CGFloat(alltext["frame"]["height"].float!)))
                                            newView.text = alltext["text"].string!
                                            newView.fontName = alltext["font"].string!
                                            newView.bounds = CGRectMake(CGFloat(alltext["bounds"]["x"].float!), CGFloat(alltext["bounds"]["y"].float!), CGFloat(alltext["bounds"]["width"].float!), CGFloat(alltext["bounds"]["height"].float!))
                                            newView.transform = CGAffineTransform(a: CGFloat(alltext["transform"]["a"].float!), b: CGFloat(alltext["transform"]["b"].float!), c: CGFloat(alltext["transform"]["c"].float!), d: CGFloat(alltext["transform"]["d"].float!), tx: CGFloat(alltext["transform"]["tx"].float!), ty: CGFloat(alltext["transform"]["ty"].float!))
                                            log.log("\(newView.transform)")
                                            newView.color = alltext["color"].string!
                                            newView.regen()
                                            newView.deselected()
                                            newView.label?.addTarget(self, action: "didSelect:", forControlEvents: .TouchUpInside)
                                            newView.btn_remove?.addTarget(self, action: Selector("remove:"), forControlEvents: .TouchUpInside)
                                            allText.append(newView)
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                }
                //                make_gif()/
                log.log("daksdhfewkjf;aj;eiowjasd;fjeio")
                
            }else{
                self.sliderDelay.value = Float(json["delay"].string!)!
                if let items = json["files"].array {
                    for item in items {
                        if let file_name = item.string {
                            var arr:[UIImage] = []
                            var pathArr:[String] = []
                            movNames.append(file_name)
                            if let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(file_name){
                                while let element = enumerator.nextObject() as? String {
                                    let imgPath = String(format: "%@/%@", arguments: [file_name,element]) //"\(workFolder)/\(element)"
                                    let img = UIImage(contentsOfFile: imgPath)
                                    arr.append(img!)
                                    pathArr.append(imgPath)
                                }
                                self.imageArr.append(arr)
                                self.imagePathArr.append(pathArr)
                            }
                        }
                    }
                    make_gif()
                }
                self.waterToggle = json["watermark"].boolValue
                if json["watermark"].boolValue {
                    self.waterMark.setImage(UIImage(named: "watermark"), forState: .Normal)
                }else {
                    self.waterMark.setImage(UIImage(named: "no_mark"), forState: .Normal)
                }
                //                let imgPath = String(format: "%@/ghost.jpg", arguments:[workFolder!])
                //                if fileManager.fileExistsAtPath(imgPath) {
                //                    setGhost(imgPath)
                //                }
                if(json["direction"]=="normal") {
                    playType = 0
                } else {
                    playType = 1
                    //                    images = images.reverse()
                    imagePaths = imagePaths.reverse()
                }
                if(json["filter"].string! != "None") {
                    //                    var tmepImage = self.ghostLayer?.image!
                    self.filterCurrent = json["filter"].string!
                    let filter = getFilterByName(self.filterCurrent)
                    image.image = UIImage(contentsOfFile: imagePaths[0])
                    applyFilter(&image.image!, filterName: self.filterCurrent)
                    //                    applyFilter(&tmepImage!, filterName: self.filterCurrent)
                    //                    self.ghostLayer!.image = tmepImage
                } else {
                    make_gif()
                }
                if json["subtitle"].array!.count > 0 {
                    for sub in json["subtitle"].array! {
                        if let temp = sub[]["frame"]["x"].float {
                            let newView = MyView(frame: CGRectMake(CGFloat(sub[]["frame"]["x"].float!), CGFloat(sub[]["frame"]["y"].float!), CGFloat(sub[]["frame"]["width"].float!), CGFloat(sub[]["frame"]["height"].float!)))
                            newView.text = sub[]["text"].string!
                            newView.fontName = sub[]["font"].string!
                            newView.bounds = CGRectMake(CGFloat(sub[]["bounds"]["x"].float!), CGFloat(sub[]["bounds"]["y"].float!), CGFloat(sub[]["bounds"]["width"].float!), CGFloat(sub[]["bounds"]["height"].float!))
                            newView.transform = CGAffineTransform(a: CGFloat(sub[]["transform"]["a"].float!), b: CGFloat(sub[]["transform"]["b"].float!), c: CGFloat(sub[]["transform"]["c"].float!), d: CGFloat(sub[]["transform"]["d"].float!), tx: CGFloat(sub[]["transform"]["tx"].float!), ty: CGFloat(sub[]["transform"]["ty"].float!))
                            log.log("\(newView.transform)")
                            newView.color = sub[]["color"].string!
                            newView.regen()
                            newView.deselected()
                            newView.label?.addTarget(self, action: "didSelect:", forControlEvents: .TouchUpInside)
                            newView.btn_remove?.addTarget(self, action: Selector("remove:"), forControlEvents: .TouchUpInside)
                            self.canvas.addSubview(newView)
                        }
                    }
                }
            }
            
            if fileManager.fileExistsAtPath(scratchPath!) {
                let mask = UIImage(contentsOfFile: scratchPath!) // 기본 마스크 이미지,
                // workFolder에 mask.jpg가 저장되어있으면 해당 mask를 로드한다. 필터 처리되었으면 필터처리함.
                // 필터를 변경시에 front이미지에 필터를 처리하고, mask()를 실행하여 처리..
                
                maskImage.frame = gifView.frame
                log.log("maskImage frame  \(maskImage.frame)")
                maskImage.image = mask
                maskImage.backgroundColor = UIColor.blackColor()
                maskImage.contentMode = .ScaleAspectFill
                
                frontImage.frame = gifView.frame
                //                frontImage.frame.size = CGSize(width: self.image.frame.size.width, height: round(self.image.frame.size.height))
                var eraserImage = playImageArr[0][0]
                let filter = GPUImageBrightnessFilter()
                filter.brightness = 0.01
                eraserImage = filter.imageByFilteringImage(eraserImage)
                applyFilter(&eraserImage, filterName: self.filterCurrent)
                frontImage.image = eraserImage
                self.view.addSubview(frontImage)
                self.mask()
                log.log("mask 있어")
            }else {
                let mask = UIImage(named:"mask.jpg") // 기본 마스크 이미지,
                // workFolder에 mask.jpg가 저장되어있으면 해당 mask를 로드한다. 필터 처리되었으면 필터처리함.
                // 필터를 변경시에 front이미지에 필터를 처리하고, mask()를 실행하여 처리..
                
                maskImage.frame = gifView.frame
                log.log("maskImage frame  \(maskImage.frame)")
                maskImage.image = mask
                maskImage.backgroundColor = UIColor.blackColor()
                maskImage.contentMode = .ScaleAspectFill
            }
            make_gif()
        } else {
            //            let imgPath = String(format: "%@/ghost.jpg", arguments:[workFolder!])
            //            if fileManager.fileExistsAtPath(imgPath) {
            //                setGhost(imgPath)
            //            }
            let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(workFolder!)!
            movNames = [String]()
            imageArr = [[UIImage]]()
            imagePathArr = [[String]]()
            
            while let element = enumerator.nextObject() as? String {
                if element.hasSuffix("mov") {
                    
                    var arr:[UIImage] = []
                    var pathArr:[String] = []
                    var imgPath = element.stringByReplacingOccurrencesOfString(".mov", withString: "")
                    
                    
                    imgPath = String(format:"%@/%@", arguments : [workFolder!,imgPath])
                    
                    movNames.append(imgPath)
                    
                    let enumerator2:NSDirectoryEnumerator = fileManager.enumeratorAtPath(imgPath)!
                    while let element2 = enumerator2.nextObject() as? String{
                        let _imgPath = String(format:"%@/%@", arguments : [imgPath,element2])
                        log.log("imgPath             \(_imgPath)")
                        arr.append(UIImage(contentsOfFile: _imgPath)!)
                        pathArr.append(_imgPath)
                    }
                    imageArr.append(arr)
                    imagePathArr.append(pathArr)
                    log.log("movNames \(movNames)")
                    log.log("imagePathArr.count \(pathArr.count)")
                }
            }
            
            if !addImage {
                ori_mov = movNames
            }
            
            make_gif()
            var mask = UIImage(named:"mask.jpg") // 기본 마스크 이미지,
            
            mask = mask?.resizeImage(playImageArr[0][0].size)
            log.log("mask image        \(mask)")
            // workFolder에 mask.jpg가 저장되어있으면 해당 mask를 로드한다. 필터 처리되었으면 필터처리함.
            // 필터를 변경시에 front이미지에 필터를 처리하고, mask()를 실행하여 처리..
            maskImage.frame = gifView.frame
            log.log("maskImage frame  \(maskImage.frame)")
            maskImage.image = mask
            maskImage.backgroundColor = UIColor.blackColor()
            maskImage.contentMode = .ScaleAspectFill
            self.canvas.frame = gifView.frame
        }
        
        
        
        
        filterButtonName.append("None")
        filterButtonName.append("I_AMARO")
        filterButtonName.append("I_HEFE")
        filterButtonName.append("I_NASHVILLE")
        filterButtonName.append("I_SIERRA")
        filterButtonName.append("I_INKWELL")
        filterButtonName.append("I_VALENCIA")
        filterButtonName.append("I_WALDEN")
        filterButtonName.append("I_XPROII")
        filterButtonName.append("BRIGHTNESS")
        filterButtonName.append("I_BRANNAN")
        filterButtonName.append("I_EARLYBIRD")
        filterButtonName.append("I_HUDSON")
        filterButtonName.append("I_LOMO")
        filterButtonName.append("I_TOASTER")
        filterButtonName.append("VIGNETTE")
        filterButtonName.append("TONE_CURVE")
        filterButtonName.append("LOOKUP_AMATORKA")
        
        self.colorView.frame.origin.y = self.image.frame.size.height
        self.view.bringSubviewToFront(self.canvas)
        self.view.bringSubviewToFront(self.btnNext)
        self.view.bringSubviewToFront(self.btnPre)
        self.view.bringSubviewToFront(self.waterMark)
        self.view.bringSubviewToFront(self.spring)
        self.view.bringSubviewToFront(self.progressView!)
    }
    
    
    
    
    func DismissKeyboard(){
        log.log("dismisskeyboard")
        self.text?.input_text?.endEditing(true)
        if self.text != nil {
            
        }
    }
    
    @IBAction func saveGIF(sender: AnyObject) {
        
        let fileManager = NSFileManager.defaultManager()
        var savePaths = imagePaths
        
        let json_path = String(format: "%@/db.json", arguments: [workFolder!])
        
        var filename = gifName?.stringByReplacingOccurrencesOfString(".gif", withString: "")
        filename = filename?.stringByReplacingOccurrencesOfString(gifsFolder!, withString: "")
        
        let slider_value = String(format:"%f",self.sliderDelay.value)
        var direction = "normal"
        if(self.playType == 1) {
            direction = "reverse"
            savePaths = savePaths.reverse()
        }
        
        let tmp = String(format: "%@/", arguments:[workFolder!])
        
        
        
        
        for var i=0;i<savePaths.count;i++ {
            
            
            savePaths[i] = savePaths[i].stringByReplacingOccurrencesOfString(tmp, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        var files = [String]()
        for file in movNames {
            let temp = file.componentsSeparatedByString("/")
            files.append("\(temp[temp.count-2])/\(temp[temp.count-1])")
        }
        
        
        
        var json:JSON = ["version":true,"name":filename!,"filter":self.filterCurrent,"files":files,"delay":slider_value,"direction":direction,"subtitle":"","watermark":self.waterToggle,"allText":""]
        
        var arr = textArr
        var json_arr:JSON = [[""],[""],[""],[""],[""]]
        if(arr.count == 4) {
            json_arr = [[""],[""],[""],[""]]
        } else if(arr.count == 3) {
            json_arr = [[""],[""],[""]]
        }else if(arr.count == 2) {
            json_arr = [[""],[""]]
        } else if(arr.count == 1) {
            json_arr = [[""]]
        }
        json["subtitle"] = json_arr
        for var i=0; i<arr.count; i++ {
            for var j=0;j<arr[i].count;j++ {
                let v = arr[i][j]
                
                json["subtitle"][i][j] = JSON(["text":v.text,"color":v.color,"font":v.fontName,"frame":"","bounds":"","transform":""])
                
                json["subtitle"][i][j]["frame"] = JSON(["x":v.frame.origin.x,"y":v.frame.origin.y,"width":v.frame.size.width,"height":v.frame.size.height])
                
                json["subtitle"][i][j]["bounds"] = JSON(["x":v.bounds.origin.x,"y":v.bounds.origin.y,"width":v.bounds.size.width,"height":v.bounds.size.height])
                
                json["subtitle"][i][j]["transform"] = JSON(["a":v.transform.a,"b":v.transform.b,"c":v.transform.c,"d":v.transform.d,"tx":v.transform.tx,"ty":v.transform.ty])
            }
        }
        
        
        var allarr = allText
        var alljson_arr:JSON = [[""],[""],[""]]
        
        if(allarr.count == 4) {
            alljson_arr = [[""],[""],[""],[""]]
        } else if(allarr.count == 3) {
            alljson_arr = [[""],[""],[""]]
        }else if(allarr.count == 2) {
            alljson_arr = [[""],[""]]
        } else if(allarr.count == 1) {
            alljson_arr = [[""]]
        }
        json["allText"] = alljson_arr
        for var i=0; i<allarr.count; i++ {
            let v = allarr[i]
            json["allText"][i] = JSON(["text":v.text,"color":v.color,"font":v.fontName,"frame":"","bounds":"","transform":""])
            
            json["allText"][i]["frame"] = JSON(["x":v.frame.origin.x,"y":v.frame.origin.y,"width":v.frame.size.width,"height":v.frame.size.height])
            
            json["allText"][i]["bounds"] = JSON(["x":v.bounds.origin.x,"y":v.bounds.origin.y,"width":v.bounds.size.width,"height":v.bounds.size.height])
            
            json["allText"][i]["transform"] = JSON(["a":v.transform.a,"b":v.transform.b,"c":v.transform.c,"d":view.transform.d,"tx":v.transform.tx,"ty":v.transform.ty])
        }
        
        
        
        print("save to file s",json)
        do {
            
            let data = try json.rawData()
            //Do something you want
            if(fileManager.fileExistsAtPath(json_path)) {
                try fileManager.removeItemAtPath(json_path)
            }
            fileManager.createFileAtPath(json_path, contents: data, attributes: nil)
        } catch let error as NSError {
        }
        savePaths.removeAll()
        
        alert = UIAlertView(title: "", message: self.appdelegate.ment["camera_tempsave"].stringValue, delegate: self, cancelButtonTitle: nil)
        alert.show()
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
        
    }
    
    func selectColor(sender:UIButton!){
        if text != nil {
            text?.color = (sender.backgroundColor?.toHexString())!
            text?.regen()
        }
    }
    
    @IBAction func actWaterMark(sender: AnyObject) {
        if waterToggle {
            self.waterMark.setImage(UIImage(named: "no_mark"), forState: .Normal)
            self.waterToggle = false
        }else {
            self.waterMark.setImage(UIImage(named: "watermark"), forState: .Normal)
            self.waterToggle = true
        }
    }
    
    
    func clearAlert(timer : NSTimer) {
        if alert != nil {
            alert.dismissWithClickedButtonIndex(0, animated: true)
            alert = nil
        }
    }
    
    
    @IBAction func changeEraser(sender: AnyObject) {
        brushWidth = CGFloat(eraserSlider.value)
    }
    
    
    @IBAction func actEraser(sender: AnyObject) {
        //        self.canvas.hidden = true
        eraserD = false
        if self.view.frame.size.width == 320.0 {
            textEditViewHei.constant = 70
            addTextHei.constant = 70
            changeFontHei.constant = 70
            
            conformViewHei.constant = 50
            completeHei.constant = 50
            cancleHei.constant = 50
        }
        
        self.btnNext.enabled = false
        self.btnPre.enabled = false
        
        self.collectionView.hidden = true
        self.editplus.hidden = true
        self.playSpeed.hidden = true
        self.basicButtonView.hidden = true
        self.colorView.hidden = true
        self.textEditView.hidden = true
        self.conformView.hidden = false
        self.eraserView.hidden = false
        self.waterMark.enabled = false
        
        if frontImage.image == nil {
            frontImage.frame = self.image.frame
            frontImage.frame.size = CGSize(width: self.image.frame.size.width, height: round(self.image.frame.size.height))
            log.log("frontImage frame \(frontImage.frame)")
            var eraserImage = playImageArr[0][0]
            let filter = GPUImageBrightnessFilter()
            filter.brightness = 0.01
            eraserImage = filter.imageByFilteringImage(eraserImage)
            applyFilter(&eraserImage, filterName: self.filterCurrent)
            frontImage.image = eraserImage
            self.view.addSubview(frontImage)
            mask()
            log.log("\(self.maskImage.frame)")
        }else {
            self.view.addSubview(frontImage)
        }
        self.view.bringSubviewToFront(canvas)
    }
    
    func initFilterButtons() {
        
    }
    
    @IBAction func actBasic(sender: AnyObject) {
        //        //print("재생 속도만 보이게 함")
        self.collectionView.hidden = true
        self.editplus.hidden = true
        self.playSpeed.hidden = false
        self.basicButtonView.hidden = false
        self.colorView.hidden = true
        self.textEditView.hidden = true
        self.conformView.hidden = true
        self.eraserView.hidden = true
        
        self.btnBasic.setImage(UIImage(named: "icon_control_control_c"), forState: .Normal)
        self.btnFilters.setImage(UIImage(named: "icon_control_filter"), forState: .Normal)
        self.btnEditor.setImage(UIImage(named: "icon_control_plus"), forState: .Normal)
        
    }
    
    var textcount = 0
    @IBAction func actText(sender: AnyObject) {
        if selectedCellIndex == -1 {
            //print("not selected")
            let alert = UIAlertView(title: "", message: self.appdelegate.ment["camera_not_frame"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
            alert.show()
            return
        }
        
        if selectedCellIndex == 0 && allText.count == 5 {
            let alert = UIAlertView(title: "", message: self.appdelegate.ment["camera_addText_alertMessage"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
            alert.show()
            return
        }
        
        previewTimer?.invalidate()
        previewTimer = nil
        
        if self.view.frame.size.width == 320.0 {
            textEditViewHei.constant = 50
            addTextHei.constant = textEditViewHei.constant
            changeFontHei.constant = textEditViewHei.constant
            
            conformViewHei.constant = 50
            completeHei.constant = 50
            cancleHei.constant = 50
        }
        
        self.colorView.hidden = false
        self.textEditView.hidden = false
        self.conformView.hidden = false
        
        self.collectionView.hidden = true
        self.editplus.hidden = true
        self.playSpeed.hidden = true
        self.basicButtonView.hidden = true
        self.eraserView.hidden = true
        
        let viewText : NSString = "PicPic"
        let widthSzie : CGSize = viewText.sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(30)])
        
        let width = widthSzie.width + 20
        let height = CGFloat(50)
        
        let pointX = (Config.getInstance().wid - width) / 2
        var pointY = Config.getInstance().wid/2
        
        if image.frame.size.width > image.frame.size.height {
            pointY = (image.frame.size.height/2)-25
        }
        
        if(text != nil) {
            text?.deselected()
        }
        var newView : MyView!
        newView = MyView(frame: CGRectMake(pointX, pointY, width, height))
        //newView.backgroundColor = UIColor.brownColor()
        //newView.text = self.textField.text!
        newView.text = "PicPic"
        newView.fontName = "Helvetica"
        newView.regen()
        newView.deselected()
        
        newView.label?.addTarget(self, action: "didSelect:", forControlEvents: .TouchUpInside)
        newView.btn_remove?.addTarget(self, action: Selector("remove:"), forControlEvents: .TouchUpInside)
        
        if selectedCellIndex == 0 {
            //전체 프레임에 추가
            newView.index = allText.count
            allText.append(newView)
            self.canvas.addSubview(newView)
            didSelect(newView.label!)
            log.log("alltext count    \(allText.count)")
        }else {
            //각 프레임에 텍스트 추가
            if textArr.count > 0 {
                for view in self.textArr[selectedCellIndex-1] {
                    self.canvas.addSubview(view)
                }
            }
            if self.textArr[selectedCellIndex-1].count == 5 {
                let alert = UIAlertView(title: "", message: self.appdelegate.ment["camera_addText_alertMessage"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                alert.show()
                newView = nil
                return
            }
            
            
            if self.textArr.count > 0 {
                if self.textArr[selectedCellIndex-1].count > 0 {
                    textcount = self.textArr[selectedCellIndex-1].count-1
                }
            }
            self.textArr[selectedCellIndex-1].append(newView)
            if self.textArr[selectedCellIndex-1].count > 0 {
                newView.index = self.textArr[selectedCellIndex-1].count-1
            }else {
                newView.index = 0
            }
            self.canvas.addSubview(newView)
            didSelect(newView.label!)
        }
        
        log.log("\(self.frontImage.frame)        \(self.colorView.frame)")
    }
    
    
    func remove(sender:UIButton!){
        if previewTimer != nil {
            previewTimer?.invalidate()
            previewTimer = nil
        }
        log.log("remove GIFMAKERVIEWCONTROLLER")
        if selectedCellIndex == 0 {
            allText.removeAtIndex(text.index)
        }else if selectedCellIndex > 0 {
            log.log("select text remove index \(text.index)")
            textArr[selectedCellIndex-1].removeAtIndex(text.index)
        }
        
        self.text = nil
        
        self.colorView.hidden = true
        self.textEditView.hidden = true
        self.conformView.hidden = true
        
        self.playSpeed.hidden = true
        self.basicButtonView.hidden = true
        
        self.editplus.hidden = false
        self.collectionView.hidden = false
        self.eraserView.hidden = true
        
        self.old_text = nil
        self.old_frame = nil
        self.old_fontname = nil
        self.old_transform = nil
        self.old_bounds = nil
        self.old_color = nil
        frameIndex = 0
        currentIndex1 = 0
        interval = Double(self.sliderDelay.value)
        previewTimer?.invalidate()
        previewTimer = nil
        previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
    }
    
    func didSelect(sender : UIButton) {
        if eraserView.hidden == false {
            return
        }
        
        
        if selectedCellIndex == -1 {
            //print("not selected")
            let alert = UIAlertView(title: "", message: self.appdelegate.ment["camera_not_frame"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
            alert.show()
            return
        }else if selectedCellIndex == 0 {
            previewTimer?.invalidate()
            previewTimer = nil
            
            log.log("selectedCell Index == 0")
            if textArr.count > 0 {
                for view in self.canvas.subviews {
                    view.removeFromSuperview()
                }
                for view in self.allText {
                    self.canvas.addSubview(view)
                }
            }
            
            if text != nil {
                text.deselected()
            }
            
            text = sender.superview as? MyView
            log.log("canvas subview \(self.canvas.subviews)")
            log.log("text \(text)")
            text.selected()
            if old_text == nil {
                self.old_text = text.input_text?.text
                self.old_frame = text.frame
                self.old_fontname = text.input_text?.font?.familyName
                self.old_transform = text.transform
                self.old_bounds = text.bounds
                old_color = text.input_text?.textColor?.toHexString()
            }
        }else {
            previewTimer?.invalidate()
            previewTimer = nil
            log.log("selectedCell Index > 0")
            if selectedCellIndex > 0 {
                if textArr.count > 0 {
                    for view in self.canvas.subviews {
                        view.removeFromSuperview()
                    }
                    for view in self.textArr[selectedCellIndex-1] {
                        self.canvas.addSubview(view)
                    }
                }
            }
            
            
            if(text == nil) {
            } else {
                text?.deselected()
            }
            text = sender.superview as? MyView
            text?.selected()
            log.log("text index \(text.index)")
            if old_text == nil {
                self.old_text = text.input_text?.text
                self.old_frame = text.frame
                self.old_fontname = text.input_text?.font?.familyName
                self.old_transform = text.transform
                self.old_bounds = text.bounds
                old_color = text.input_text?.textColor?.toHexString()
            }
        }
        
        
        
        
        self.colorView.hidden = false
        self.textEditView.hidden = false
        self.conformView.hidden = false
        
        self.playSpeed.hidden = true
        self.basicButtonView.hidden = true
        
        self.editplus.hidden = true
        self.collectionView.hidden = true
        self.eraserView.hidden = true
    }
    
    @IBAction func actUndo(sender: AnyObject) {
        //        if(historyImg.count > 0) {
        //            frontImage.image = historyImg[historyImg.count-1]
        //            historyImg.removeAtIndex(historyImg.count-1)
        //        }
        if(historyImg.count > 0) {
            print("undo ")
            print(historyImg.count)
            let maskImg = historyImg[historyImg.count-1]
            historyImg.removeAtIndex(historyImg.count-1)
            maskImage.image = maskImg
            mask()
        }
    }
    
    var eraserD = false
    @IBAction func actDeleteEraser(sender: AnyObject) {
        self.frontImage.image = playImageArr[0][0]
        maskImage.image = UIImage(named: "mask.jpg")
        mask()
        eraserD = true
    }
    
    
    func getFilterByName(name: String) -> CIFilter! {
        if name == "None" {
            return nil
        }
        //        //print("getFilterByName is ",name)
        let filter = CIFilter(name: name)
        if(name == "CIVignette") {
            filter!.setValue(2, forKey: kCIInputIntensityKey)
            filter!.setValue(10, forKey: kCIInputRadiusKey)
        }
        filterSet = name
        return filter!
    }
    
    
    
    @IBAction func actPlayType(sender: UIButton) {
        if(playType == 0) { // 역방향 재생
            self.btnPlayType.setImage(UIImage(named: "icon_control_reverseplay_c"), forState: .Normal)
            playType = 1
            imagePaths = imagePaths.reverse();
            for view in self.canvas.subviews {
                view.removeFromSuperview()
            }
            
            frameIndex = 0
            currentIndex1 = 0
            interval = Double(self.sliderDelay.value)
            previewTimer?.invalidate()
            previewTimer = nil
            previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
            
        } else {
            self.btnPlayType.setImage(UIImage(named: "icon_control_reverseplay"), forState: .Normal)
            playType = 0 // 순방향 재생
            imagePaths = imagePaths.reverse();
            frameIndex = 0
            currentIndex1 = 0
            for view in self.canvas.subviews {
                view.removeFromSuperview()
            }
            interval = Double(self.sliderDelay.value)
            previewTimer?.invalidate()
            previewTimer = nil
            previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
        }
    }
    @IBAction func actEditor(sender: UIButton) {
        //        //print("에디터 오픈")
        self.collectionView.hidden = false
        self.editplus.hidden = false
        self.playSpeed.hidden = true
        self.basicButtonView.hidden = true
        self.colorView.hidden = true
        self.textEditView.hidden = true
        self.conformView.hidden = true
        self.eraserView.hidden = true
        
        collectionType = 1
        
        var mArr:[UIImage] = []
        for movName in movNames {
            //            //print(movName)
            let movPath = String(format:"%@/000.jpg", arguments:[movName])
            if let img = UIImage(contentsOfFile: movPath){
                mArr.append(img)
            }else {
                let fileManager = NSFileManager.defaultManager()
                do {
                    var movPath = String(format:"%@", arguments:[movName])
                    
                    try fileManager.removeItemAtPath(movPath) // 폴더 삭제
                    
                    movPath = String(format:"%@.mov", arguments:[movName])
                    try fileManager.removeItemAtPath(movPath) // mov 파일 삭제
                    
                    
                    imageArr.removeAll()
                    imagePathArr.removeAll()
                    let fileManager = NSFileManager.defaultManager()
                    let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(workFolder!)!
                    while let element = enumerator.nextObject() as? String {
                        if element.hasSuffix("mov") {
                            
                            var arr:[UIImage] = []
                            var pathArr:[String] = []
                            var imgPath = element.stringByReplacingOccurrencesOfString(".mov", withString: "")
                            
                            
                            imgPath = String(format:"%@/%@", arguments : [workFolder!,imgPath])
                            
                            movNames.append(imgPath)
                            
                            let enumerator2:NSDirectoryEnumerator = fileManager.enumeratorAtPath(imgPath)!
                            while let element2 = enumerator2.nextObject() as? String{
                                let _imgPath = String(format:"%@/%@", arguments : [imgPath,element2])
                                arr.append(UIImage(contentsOfFile: _imgPath)!)
                                pathArr.append(_imgPath)
                            }
                            imageArr.append(arr)
                            imagePathArr.append(pathArr)
                            make_gif()
                        }
                    }
                } catch {
                    
                }
            }
            
        }
        for view in self.canvas.subviews {
            view.removeFromSuperview()
        }
        frameIndex = 0
        currentIndex1 = 0
        selectedCellIndex = 0
        interval = Double(self.sliderDelay.value)
        previewTimer?.invalidate()
        previewTimer = nil
        previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
        collections = []
        collections = mArr
        collections.insert(UIImage(named: "allframe")!, atIndex: 0)
        self.collectionView.reloadData()
        
    }
    
    func edit() {
        self.collectionView.hidden = false
        if let _ = self.editplus {
            self.editplus.hidden = false
            self.playSpeed.hidden = true
            self.basicButtonView.hidden = true
            self.colorView.hidden = true
            self.textEditView.hidden = true
            self.conformView.hidden = true
            self.eraserView.hidden = true
        }
        collectionType = 1
        
        var mArr:[UIImage] = []
        for movName in movNames {
            //            //print(movName)
            let movPath = String(format:"%@/000.jpg", arguments:[movName])
            if let img = UIImage(contentsOfFile: movPath){
                mArr.append(img)
            }else {
                let fileManager = NSFileManager.defaultManager()
                do {
                    var movPath = String(format:"%@", arguments:[movName])
                    
                    try fileManager.removeItemAtPath(movPath) // 폴더 삭제
                    
                    movPath = String(format:"%@.mov", arguments:[movName])
                    try fileManager.removeItemAtPath(movPath) // mov 파일 삭제
                    
                    
                    imageArr.removeAll()
                    imagePathArr.removeAll()
                    let fileManager = NSFileManager.defaultManager()
                    let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(workFolder!)!
                    while let element = enumerator.nextObject() as? String {
                        if element.hasSuffix("mov") {
                            
                            var arr:[UIImage] = []
                            var pathArr:[String] = []
                            var imgPath = element.stringByReplacingOccurrencesOfString(".mov", withString: "")
                            
                            
                            imgPath = String(format:"%@/%@", arguments : [workFolder!,imgPath])
                            
                            movNames.append(imgPath)
                            
                            let enumerator2:NSDirectoryEnumerator = fileManager.enumeratorAtPath(imgPath)!
                            while let element2 = enumerator2.nextObject() as? String{
                                let _imgPath = String(format:"%@/%@", arguments : [imgPath,element2])
                                arr.append(UIImage(contentsOfFile: _imgPath)!)
                                pathArr.append(_imgPath)
                            }
                            imageArr.append(arr)
                            imagePathArr.append(pathArr)
                            make_gif()
                        }
                    }
                } catch {
                    
                }
            }
            
        }
        for view in self.canvas.subviews {
            view.removeFromSuperview()
        }
        frameIndex = 0
        currentIndex1 = 0
        selectedCellIndex = 0
        interval = Double(self.sliderDelay.value)
        previewTimer?.invalidate()
        previewTimer = nil
        previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
        collections = []
        collections = mArr
        collections.insert(UIImage(named: "allframe")!, atIndex: 0)
        self.collectionView.reloadData()
    }
    
    var filterState = false
    @IBAction func actFilter(sender: UIButton) {
        collectionType = 0
        selectedCellIndex = -1
        collections = []
        
        
        self.collectionView.hidden = false
        self.editplus.hidden = true
        self.playSpeed.hidden = true
        self.basicButtonView.hidden = false
        filterState = true
        
        self.btnFilters.setImage(UIImage(named: "icon_control_filter_c"), forState: .Normal)
        self.btnBasic.setImage(UIImage(named: "icon_control_control"), forState: .Normal)
        
        
        for filterName in filterButtonName {
            var image = playImageArr[0][0]
            if filterName == "None"  {
            }else {
                applyFilter(&image, filterName: filterName)
            }
            collections.append(image)
        }
        self.collectionView.reloadData()
        frameIndex = 0
        currentIndex1 = 0
    }
    
    //    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    //        if buttonIndex == alertView.cancelButtonIndex {
    //            collectionType = 0
    //            selectedCellIndex = -1
    //            collections = []
    //            frontImage.image = nil
    //            tempFront = nil
    //
    //            self.collectionView.hidden = false
    //            self.editplus.hidden = true
    //            self.playSpeed.hidden = true
    //            self.basicButtonView.hidden = false
    //            filterState = true
    //
    //            self.btnFilters.setImage(UIImage(named: "icon_control_filter_c"), forState: .Normal)
    //            self.btnBasic.setImage(UIImage(named: "icon_control_control"), forState: .Normal)
    //
    //
    //            for filterName in filterButtonName {
    //                var image = playImageArr[0][0]
    //                if filterName == "None"  {
    //                }else {
    //                    applyFilter(&image, filterName: filterName)
    //                }
    //                collections.append(image)
    //        }
    //    }
    //
    //        self.collectionView.reloadData()
    //        frameIndex = 0
    //        currentIndex1 = 0
    //    }
    
    
    //프레임 복사
    @IBAction func actCopy(sender: AnyObject) {
        var total_time : Double = 0.0
        
        for time in arr_recoding_time {
            total_time += time
        }
        log.log("total_time \(total_time)")
        var imgarr = [UIImage]()
        var patharr = [String]()
        //total time이 5초 미만일때만 가능
        
        let fileManager = NSFileManager.defaultManager()
        do {
            let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(workFolder!)!
            var aaa = 0
            while let element = enumerator.nextObject() as? String {
                if element.hasSuffix("mov") {
                    let imgPath = element.stringByReplacingOccurrencesOfString(".mov", withString: "")
                    let _imgPath = Int(imgPath)
                    if _imgPath > aaa {
                        aaa = _imgPath!
                    }
                }
            }
            aaa += 1
            let fileManager = NSFileManager.defaultManager()
            var imageName = 0
            
            if selectedCellIndex == 0 {
                //전체프레임
                total_time = total_time * 2
                if total_time <= 5.0 {
                    let count = imagePathArr.count
                    for var i = 0 ; i<count; i++ {
                        imgarr = [UIImage]()
                        patharr = [String]()
                        self.log.log("\(imagePathArr.count)     \(i)       \(count)")
                        var fileName = String(format: "%@/%02d",arguments:[workFolder!,aaa])
                        if(!fileManager.fileExistsAtPath(fileName)) {
                            try fileManager.copyItemAtPath(movNames[i]+".mov", toPath: fileName+".mov")
                            movNames.append(fileName)
                            arr_recoding_time.append(arr_recoding_time[i])
                            fileName = String(format: "%@/%02d",arguments:[workFolder!,aaa])
                            log.log("fileName  \(fileName)")
                            try fileManager.createDirectoryAtPath(fileName, withIntermediateDirectories: false, attributes: nil)
                        }
                        imageName = 0
                        if textArr[i].count > 0 {
                            textArr.append(textArr[i])
                        }
                        
                        
                        for var j=0; j<imagePathArr[i].count; j++ {
                            self.log.log("imagePath    \(imagePathArr[i][j])")
                            fileName = String(format: "%@/%02d",arguments:[workFolder!,aaa])
                            fileName = String(format: "%@/%03d.jpg", arguments: [fileName,imageName])
                            try fileManager.copyItemAtPath(imagePathArr[i][j], toPath: fileName)
                            imgarr.append(UIImage(contentsOfFile: fileName)!)
                            patharr.append(fileName)
                            imageName++
                        }
                        collections.append(UIImage(contentsOfFile: imagePathArr[i][0])!)
                        imageArr.append(imgarr)
                        imagePathArr.append(patharr)
                        aaa++
                    }
                    make_gif()
                    collectionView.reloadData()
                }else {
                    //5초 이상일시 alert 띄우기
                    self.log.log("5초 이상")
                    alert = UIAlertView(title: "", message: self.appdelegate.ment["add_not_images"].stringValue, delegate: self, cancelButtonTitle: nil)
                    alert.show()
                    NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
                }
                log.log("\(movNames)")
            }else {
                //각 프레임별로 선택했을시
                total_time = total_time + arr_recoding_time[selectedCellIndex-1]
                if total_time <= 5.0 {
                    var fileName = String(format: "%@/%02d",arguments:[workFolder!,aaa])
                    log.log("fileName      \(fileName)")
                    if(!fileManager.fileExistsAtPath(fileName)) {
                        try fileManager.copyItemAtPath(movNames[selectedCellIndex-1]+".mov", toPath: fileName+".mov")
                        movNames.append(fileName)
                        arr_recoding_time.append(arr_recoding_time[selectedCellIndex-1])
                        fileName = String(format: "%@/%02d",arguments:[workFolder!,aaa])
                        log.log("fileName  \(fileName)")
                        try fileManager.createDirectoryAtPath(fileName, withIntermediateDirectories: false, attributes: nil)
                    }
                    for var j=0; j<imagePathArr[selectedCellIndex-1].count; j++ {
                        //                            self.log.log("image path count  \(imagePathArr[selectedCellIndex-1].count)")
                        //                            self.log.log("frame image Path      \(imagePathArr[selectedCellIndex-1][j])")
                        fileName = String(format: "%@/%02d",arguments:[workFolder!,aaa])
                        self.log.log("fileName \(fileName)")
                        fileName = String(format: "%@/%03d.jpg", arguments: [fileName,imageName])
                        try fileManager.copyItemAtPath(imagePathArr[selectedCellIndex-1][j], toPath: fileName)
                        imgarr.append(UIImage(contentsOfFile: fileName)!)
                        patharr.append(fileName)
                        imageName++
                    }
                    if textArr[selectedCellIndex-1].count > 0 {
                        textArr.append(textArr[selectedCellIndex-1])
                    }
                    imageArr.append(imgarr)
                    imagePathArr.append(patharr)
                    collections.append(UIImage(contentsOfFile: imagePathArr[selectedCellIndex-1][0])!)
                    make_gif()
                    collectionView.reloadData()
                    addImage = true
                }else {
                    //5초 이상일시 alert 띄우기
                    self.log.log("5초 이상")
                    alert = UIAlertView(title: "", message: self.appdelegate.ment["add_not_images"].stringValue, delegate: self, cancelButtonTitle: nil)
                    alert.show()
                    NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
                }
            }
        }catch {
            log.log("Error      \(error)")
        }
        
        
    }
    
    @IBAction func actNext(sender: UIButton) {
        
        if filterState
        {
            self.progressContainerView!.hidden = false
            self.view.bringSubviewToFront(self.progressContainerView!)
        }
        
        previewTimer?.invalidate()
        previewTimer = nil
        /*self.view.bringSubviewToFront(spring)
        self.spring.startAnimation(true)*/
        //NSThread.sleepForTimeInterval(0.3)
        
        if text != nil {
            text.deselected()
            text = nil
        }
        
        let path = String(format: "%@/%@", arguments: [gifsFolder!,gifName!])
        
        var imgArr = [UIImage]()
        var tempArr = [[UIImage]]()
        tempArr = playImageArr
        
        let progress = 1.0 / Float(tempArr.count)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for var i=0; i<tempArr.count; i++ {
                for var j=0; j<tempArr[i].count; j++ {
                    self.applyFilter(&tempArr[i][j], filterName: self.filterCurrent)
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.progressView?.progress += progress
                    for view in self.progressContainerView!.subviews
                    {
                        if view.isMemberOfClass(UILabel)
                        {
                            let progress = Int(self.progressView!.progress * 100.0)
                            (view as! UILabel).text = "\(progress) %"
                            (view as! UILabel).sizeToFit()
                        }
                    }
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                if self.textArr.count > 0 {
                    self.gifMaker.make2(tempArr, delayTime: self.sliderDelay.value, gifPath: path, workFolder: self.workFolder!, subtitle: self.textArr, warterMark: self.waterToggle, imageCheck: self.imageCheck, canvas: self.canvas,playType: self.playType,allText: self.allText)
                    
                }
                let gifVC = self.storyboard?.instantiateViewControllerWithIdentifier("gifVC") as? GIFViewController
                self.appdelegate.testNavi.navigationBarHidden = false
                gifVC?.moviePath = NSURL(string: path)
                //        //print(path)
                self.appdelegate.testNavi.pushViewController(gifVC!, animated: true)
            })
        })
    }
    
    @IBAction func back(sender: AnyObject) {
        previewTimer?.invalidate()
        previewTimer = nil
        let fileManager = NSFileManager.defaultManager()
        
        if in_type == 0 {
            //카메라로 촬영 후에 들어왔을 때
            let db = String(format: "%@/db.json", arguments: [workFolder!])
            if fileManager.fileExistsAtPath(db) {
                self.navigationController?.navigationBarHidden = false
                if self.appdelegate.main.view.hidden == false {
                    //self.appdelegate.main.fire()
                    self.appdelegate.main.refresh()
                }else if self.appdelegate.second.view.hidden == false {
                    if self.appdelegate.second.webState == "follow" {
                        self.appdelegate.second.following()
                    }else if self.appdelegate.second.webState == "all" {
                        self.appdelegate.second.all()
                    }else if self.appdelegate.second.webState == "category" {
                        
                    }
                }else if self.appdelegate.myfeed.view.hidden == false {
                    self.appdelegate.myfeed.fire()
                    self.navigationController?.navigationBarHidden = true
                }
                frontImage.image = nil
                self.navigationController?.popToRootViewControllerAnimated(true)
            }else {
                //카메라로 촬영 후에 들어왔을 때
                let count = movNames.count - ori_mov.count
                log.log("movNames.count \(movNames.count)   ori_mov.count   \(ori_mov.count)")
                log.log("cunt         \(count)")
                if count > 0 {
                    //프레임을 복사했다가 다시 뒤로 돌아 갈때
                    for var i = ori_mov.count; i<movNames.count; i++ {
                        do {
                            try fileManager.removeItemAtPath(movNames[i])
                            log.log("folder Name \(movNames[i])")
                            let path = String(format: "%@.mov", arguments: [movNames[i]])
                            log.log("mov Name \(path)")
                            try fileManager.removeItemAtPath(path)
                        }catch {}
                    }
                }
                self.appdelegate.camera.workFolder = self.workFolder
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else {
            //편집 불러오기로 들어왔을 때
            self.navigationController?.navigationBarHidden = false
            if self.appdelegate.main.view.hidden == false {
                //self.appdelegate.main.fire()
                self.appdelegate.main.refresh()
            }else if self.appdelegate.second.view.hidden == false {
                if self.appdelegate.second.webState == "follow" {
                    self.appdelegate.second.following()
                }else if self.appdelegate.second.webState == "all" {
                    self.appdelegate.second.all()
                }else if self.appdelegate.second.webState == "category" {
                    
                }
            }else if self.appdelegate.myfeed.view.hidden == false {
                self.appdelegate.myfeed.fire()
                self.navigationController?.navigationBarHidden = true
            }
            frontImage.image = nil
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }
    
    
    @IBAction func actImageAdd(sender: UIButton) {
        if(imagePicker == nil) {
            imagePicker = UIImagePickerController()
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            //            //print("Galeria Imagen")
            previewTimer?.invalidate()
            previewTimer = nil
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker!.mediaTypes = [kUTTypeImage as String] // 5s 이상에서 연사 지원하므로, 연사 옵션 넣어야 함.
            imagePicker!.allowsEditing = false
            imagePicker?.navigationBar.barTintColor = Config.getInstance().color
            imagePicker?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            //picker!.modalPresentationStyle = .Custom
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func actImageDrop(sender: UIButton) {
        if(collectionType == 0) {
            return
        }
        if(selectedCellIndex == -1) {
        }else if selectedCellIndex == 0 {
            return
        }else {
            
            //프레임이 1개이면 return
            if playImageArr.count == 1 {
                return
            }
            
            previewTimer?.invalidate()
            previewTimer = nil
            
            self.collections.removeAtIndex(selectedCellIndex)
            //            self.imagePaths.removeAtIndex(selectedCellIndex)
            self.playImageArr.removeAtIndex(selectedCellIndex-1)
            self.imageArr.removeAtIndex(selectedCellIndex-1)
            self.imagePathArr.removeAtIndex(selectedCellIndex-1)
            self.textArr.removeAtIndex(selectedCellIndex-1)
            self.cellArr.removeAtIndex(selectedCellIndex)
            self.arr_recoding_time.removeAtIndex(selectedCellIndex-1)
            log.log("cellArr.count \(cellArr.count)")
            let movName = movNames[selectedCellIndex-1]
            log.log("movNames \(movNames)    count \(movNames.count)")
            self.movNames.removeAtIndex(selectedCellIndex-1)
            
            let fileManager = NSFileManager.defaultManager()
            do {
                var movPath = String(format:"%@", arguments:[movName])
                movPath = movPath.stringByReplacingOccurrencesOfString(".mov", withString: "")
                log.log("movPath \(movPath)")
                try fileManager.removeItemAtPath(movPath) // 폴더 삭제
                
                movPath = String(format:"%@", arguments:[movName])
                log.log("movPath \(movPath)")
                try fileManager.removeItemAtPath(movPath) // mov 파일 삭제
            } catch {
                
            }
            selectedCellIndex = 0
            setPlayArr()
            self.collectionView.reloadData()
            self.image.image = UIImage(contentsOfFile: self.imagePaths[0])
            
            
        }
    }
    
    
    @IBAction func sliderValueChange(sender: UISlider) {
        if(imageLoading) {
            
        } else {
            make_gif()
            imageLoading = false
        }
    }
    
    @IBAction func actEditorCancle(sender: AnyObject) {
        selectedCellIndex = -1
        for view in self.canvas.subviews {
            view.removeFromSuperview()
        }
        collectionType = 0
        actBasic(sender)
        frameIndex = 0
        currentIndex1 = 0
        interval = Double(self.sliderDelay.value)
        previewTimer?.invalidate()
        previewTimer = nil
        previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
        self.view.bringSubviewToFront(self.waterMark)
    }
    
    //Text Editor Cancle
    @IBAction func actCancle(sender: AnyObject) {
        if self.textEditView.hidden == false {
            self.collectionView.hidden = false
            self.editplus.hidden = false
            self.playSpeed.hidden = true
            self.basicButtonView.hidden = true
            self.colorView.hidden = true
            self.textEditView.hidden = true
            self.conformView.hidden = true
            self.eraserView.hidden = true
            if self.old_text != nil {
                text.input_text?.text = self.old_text
                text.frame = self.old_frame!
                text.input_text?.font? = UIFont(name: self.old_fontname!, size: 30)!
                text.bounds = old_bounds
                text.input_text?.textColor = hexStringToUIColor(old_color)
                text.transform = old_transform
            }
            
            //        text.input_text?.transform = self.old_trasform
            self.old_text = nil
            self.old_frame = nil
            self.old_fontname = nil
            self.old_transform = nil
            self.old_bounds = nil
            self.old_color = nil
            if text != nil {
                text.deselected()
            }
            for view in self.canvas.subviews {
                view.removeFromSuperview()
            }
            currentIndex1 = 0
            interval = Double(self.sliderDelay.value)
            previewTimer?.invalidate()
            previewTimer = nil
            previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
        }else if self.eraserView.hidden == false {
            //editorview
            self.canvas.hidden = false
            self.btnNext.enabled = true
            self.btnPre.enabled = true
            self.collectionView.hidden = false
            self.editplus.hidden = false
            self.playSpeed.hidden = true
            self.basicButtonView.hidden = true
            self.colorView.hidden = true
            self.textEditView.hidden = true
            self.conformView.hidden = true
            self.eraserView.hidden = true
            self.frontImage.removeFromSuperview()
            self.view.bringSubviewToFront(self.waterMark)
        }
        self.waterMark.enabled = true
        self.view.bringSubviewToFront(self.waterMark)
        self.view.bringSubviewToFront(btnPre)
        self.view.bringSubviewToFront(btnNext)
    }
    
    @IBAction func actComplete(sender: AnyObject) {
        
        if selectedCellIndex > 0 {
            if textArr.count > 0 {
                self.textArr[selectedCellIndex-1].removeAll()
                for view in self.canvas.subviews {
                    self.textArr[selectedCellIndex-1].append(view as! MyView)
                }
            }
        }
        
        
        if self.textEditView.hidden == false {
            self.collectionView.hidden = false
            self.editplus.hidden = false
            self.playSpeed.hidden = true
            self.basicButtonView.hidden = true
            self.colorView.hidden = true
            self.textEditView.hidden = true
            self.conformView.hidden = true
            self.eraserView.hidden = true
            if text != nil {
                text.deselected()
            }
            self.old_text = nil
            self.old_frame = nil
            self.old_fontname = nil
            self.old_transform = nil
            self.old_bounds = nil
            self.old_color = nil
            for view in self.canvas.subviews {
                view.removeFromSuperview()
            }
            frameIndex = 0
            currentIndex1 = 0
            interval = Double(self.sliderDelay.value)
            previewTimer?.invalidate()
            previewTimer = nil
            previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
            self.view.bringSubviewToFront(self.waterMark)
        }else if self.eraserView.hidden == false {
            
            self.canvas.hidden = false
            self.btnNext.enabled = true
            self.btnPre.enabled = true
            self.collectionView.hidden = false
            self.editplus.hidden = false
            self.playSpeed.hidden = true
            self.basicButtonView.hidden = true
            self.colorView.hidden = true
            self.textEditView.hidden = true
            self.conformView.hidden = true
            self.eraserView.hidden = true
            self.view.bringSubviewToFront(canvas)
            self.view.bringSubviewToFront(btnNext)
            self.view.bringSubviewToFront(btnPre)
            self.waterMark.enabled = true
            self.view.bringSubviewToFront(self.waterMark)
            
            if eraserD {
                frontImage.image = nil
            }else {
                if historyImg.count <= 0 {
                    frontImage.image = nil
                    frontImage.removeFromSuperview()
                    return
                }
                self.tempFront = frontImage.image
                do {
                    let fileManager = NSFileManager.defaultManager()
                    if(fileManager.fileExistsAtPath(scratchPath!)) {
                        try fileManager.removeItemAtPath(scratchPath!)
                    }
                    //                    UIImagePNGRepresentation(frontImage.image!)?.writeToFile(scratchPath!, atomically: true)
                    UIImageJPEGRepresentation(maskImage.image!, 100)!.writeToFile(scratchPath!, atomically: true)
                } catch let error as NSError {
                    //                //print(error.localizedDescription);
                }
            }
            
            
            
        }
        self.view.bringSubviewToFront(btnPre)
        self.view.bringSubviewToFront(btnNext)
    }
    
    @IBAction func actFont(sender: AnyObject) {
        //        //print("actFont")
        let font = FontViewController()
        font.view.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 200)
        font.gif = self
        font.font = font
        //        font.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        //        self.presentViewController(font, animated: true, completion: nil)
        self.view.addSubview(font.view)
        UIView.animateWithDuration(0.5, delay: 0.1, options: .CurveEaseOut, animations: { () -> Void in
            var frame = font.view.frame
            frame.origin.x = 0
            frame.origin.y = self.view.bounds.size.height-200
            font.view.frame = frame
            }) { (finished) -> Void in
                //                //print("complete")
        }
        
    }
    
    
    @IBAction func actEditText(sender: AnyObject) {
        if self.text != nil {
            self.text?.input_text?.becomeFirstResponder()
        }else {
            let alert = UIAlertView(title: "", message: self.appdelegate.ment["camera_addText_select"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
            alert.show()
        }
    }
    
    var playArr:[UIImage] = []
    
    func make_gif() {
        setPlayArr()
    }
    
    
    var currentIndex = 0
    
    //image path 배열
    var frameimagepathArr = [[String]]()
    
    func setPlayArr() {
        imagePaths = []
        
        playImageArr = [[UIImage]]()
        playImagePathArr = [[String]]()
        frameimagepathArr = [[String]]()
        cellArr = [Int]()
        
        var step = 0
        
        var keyStep = 0;
        if( self.frameSlider.value == 1) {
            keyStep = 6
        } else if(self.frameSlider.value == 2) {
            keyStep = 3
        } else {
            keyStep = 1
        }
        
        for var i=0;i<imageArr.count;i++ {
            let _imgArr = imageArr[i] as Array
            var nImgArr:[UIImage] = []
            var nImgPathArr:[String] = []
            var is_new = true
            step = 0
            for var j=0;j<_imgArr.count;j++ {
                
                if(step % keyStep == 0) {
                    nImgArr.append(_imgArr[j])
                    log.log("_imgArr[\(i)][\(j)]      \(_imgArr[j])")
                    if is_new {
                        is_new = false
                        images.append(_imgArr[j])
                    }
                    
                    images.append(_imgArr[j])
                    imagePaths.append(imagePathArr[i][j])
                    nImgPathArr.append(imagePathArr[i][j])
                    var count = 0
                    if images.count != 0 {
                        count = images.count-1
                    }
                    imageCheck[count] = i
                }
                step++
            }
            if nImgArr.count > 0 {
                playImageArr.append(nImgArr)
                frameimagepathArr.append(nImgPathArr)
            }
        }
        
        let imgSize = playImageArr[0][0].size
        
        if imgSize.width > imgSize.height {
            let nWidth = UIScreen.mainScreen().bounds.width;
            let nHeight = nWidth * (imgSize.height) / (imgSize.width)
            let posY = (Config.getInstance().wid/8)*3
            self.gifView.frame = CGRectMake(0, posY, nWidth, nHeight)
            self.image.frame = CGRectMake(0, posY, nWidth, nHeight)
            imageHei.constant = nHeight
            imagePosY.constant = posY
        }
        
        
        insetAllFram()
        
        if filterCurrent != "None" {
            playImageArr = [[UIImage]]()
            for var i=0; i<frameimagepathArr.count; i++ {
                playImageArr.append([])
                for var j=0; j<frameimagepathArr[i].count; j++ {
                    var image:UIImage? = UIImage(contentsOfFile: frameimagepathArr[i][j])
                    applyFilter(&image!, filterName: self.filterCurrent)
                    playImageArr[i].append(image!)
                    image = nil
                }
                
            }
        }
        
        if( playType == 1) {
            imagePaths = imagePaths.reverse()
        } else {
            
        }
        for view in self.canvas.subviews {
            view.removeFromSuperview()
        }
        frameIndex = 0
        currentIndex1 = 0
        interval = Double(self.sliderDelay.value)
        previewTimer?.invalidate()
        previewTimer = nil
        previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
        if playImageArr[0][0].size.width > playImageArr[0][0].size.height {
            let nWidth = UIScreen.mainScreen().bounds.width;
            let nHeight = nWidth * (imgSize.height) / (imgSize.width)
            let posY = Config.getInstance().wid/8*2-10
            self.gifView.frame = CGRectMake(0, posY, nWidth, nHeight)
            self.imageHei.constant = nHeight
            self.imagePosY.constant = posY
        }else if playImageArr[0][0].size.width == playImageArr[0][0].size.height {
            self.image.frame.origin.y = (UIScreen.mainScreen().bounds.width/8)*2
            self.imagePosY.constant = (UIScreen.mainScreen().bounds.width/8)*2
            self.gifView.frame.origin.y = (UIScreen.mainScreen().bounds.width/8)*2
        }
        self.view.bringSubviewToFront(self.waterMark)
        
    }
    
    func insetAllFram(){
        cellArr = [Int]()
        log.log("insetAllFram in")
        for var i=0; i<playImageArr.count; i++ {
            if playImageArr.count == 1 {
                textArr.append([])
            }else if textArr.count < playImageArr.count {
                textArr.append([])
            }
            cellArr.append(0)
        }
        cellArr.append(0)
    }
    
    var currentIndex1 = 0
    var frameIndex = 0
    var preFrame = 0
    //frame plat Method
    func nextImage() {
        if selectedCellIndex <= 0 { //전체 재생일 경우
            if frameIndex > playImageArr.count-1 {
                frameIndex = 0
                currentIndex1 = 0
            }
        }else {
            //프레임 선택시
            if(currentIndex1 == playImageArr[selectedCellIndex-1].count) {
                currentIndex1 = 0
            }
        }
        if selectedCellIndex > 0 { //collectionView Selected 했을때
            for view in self.canvas.subviews {
                view.removeFromSuperview()
            }
            if allText.count > 0 {
                for view in self.allText {
                    self.canvas.addSubview(view)
                }
            }
            if textArr.count > 0 {
                //텍스트가 있을 때
                if textArr[selectedCellIndex-1].count > 0 {
                    for var i=0; i<textArr[selectedCellIndex-1].count; i++ {
                        self.canvas.addSubview(textArr[selectedCellIndex-1][i])
                    }
                }
            }else {
                let count = textArr.count - (selectedCellIndex)
                if textArr[count].count > 0 {
                    for view in self.canvas.subviews {
                        view.removeFromSuperview()
                    }
                    for var i=0; i<textArr[count].count; i++ {
                        self.canvas.addSubview(textArr[count][i])
                    }
                }
            }
        }else {  //selectedCellIndex == -1 전체 재생
            if playType == 0 {
                //순재생
                if textArr.count > 0 {
                    if textArr[frameIndex].count > 0 {
                        for view in self.canvas.subviews {
                            view.removeFromSuperview()
                        }
                        for var i=0; i<textArr[frameIndex].count; i++ {
                            
                            self.canvas.addSubview(textArr[frameIndex][i])
                        }
                    }else{
                        for view in self.canvas.subviews {
                            view.removeFromSuperview()
                        }
                    }
                }
                if textArr.count > 0 {
                    if textArr[frameIndex].count > 0 {
                        for view in self.canvas.subviews {
                            view.removeFromSuperview()
                        }
                        for var i=0; i<textArr[frameIndex].count; i++ {
                            self.canvas.addSubview(textArr[frameIndex][i])
                        }
                    }
                }
                if allText.count > 0 {
                    for alltext in allText {
                        self.canvas.addSubview(alltext)
                    }
                }
                
            }else {
                //역재생
                print("역재생   ",frameIndex)
                let count = textArr.count - (frameIndex+1)
                if textArr.count > 0 {
                    if textArr[count].count > 0 {
                        for view in self.canvas.subviews {
                            view.removeFromSuperview()
                        }
                        for var i=0; i<textArr[count].count; i++ {
                            self.canvas.addSubview(textArr[count][i])
                        }
                    }else{
                        for view in self.canvas.subviews {
                            view.removeFromSuperview()
                        }
                    }
                }
                if allText.count > 0 {
                    for alltext in allText {
                        self.canvas.addSubview(alltext)
                    }
                }
            }
        }
        if selectedCellIndex <= 0 {
            if playType == 0 {
                if playImageArr[frameIndex].count > 0 {
                    image.image = playImageArr[frameIndex][currentIndex1]
                }
                
            }else {
                let reverseframeIndex = playImageArr.count - (frameIndex+1)
                let reversecurrentIndex1 = playImageArr[reverseframeIndex].count - (currentIndex1+1)
                if playImageArr[reverseframeIndex].count > 0 {
                    image.image = playImageArr[reverseframeIndex][reversecurrentIndex1]
                }
                
            }
            
        }else {
            if playType == 0 {
                if playImageArr[selectedCellIndex-1].count > 0 {
                    image.image = playImageArr[selectedCellIndex-1][currentIndex1]
                }
                
            }else {
                let reversecurrentIndex1 = playImageArr[selectedCellIndex-1].count - (currentIndex1+1)
                if playImageArr[selectedCellIndex-1].count > 0 {
                    image.image = playImageArr[selectedCellIndex-1][reversecurrentIndex1]
                }
                
            }
            
        }
        currentIndex1++
        if selectedCellIndex <= 0 {
            if playType == 0 {
                if(currentIndex1 >= playImageArr[frameIndex].count) {
                    frameIndex++
                    currentIndex1 = 0
                }
            }else {
                let reverseframeIndex = playImageArr.count - (frameIndex+1)
                let reversecurrentIndex1 = playImageArr[reverseframeIndex].count - (currentIndex1+1)
                if(currentIndex1 >= playImageArr[reverseframeIndex].count) {
                    frameIndex++
                    currentIndex1 = 0
                }
            }
            
            
        }
        
    }
    
    // 프레임 갯수 변경
    @IBAction func frameChange(sender: UISlider) {
        sender.value = round(sender.value)
        currentIndex1 = 0
        setPlayArr()
        
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.editScroll.contentSize = CGSizeMake(420, 50)
        self.automaticallyAdjustsScrollViewInsets = false // collection view 에서 상단 마진 관련
    }
    
    func getFilter(index : Int) -> String! {
        if(index == 0) {
            return nil // 필터 미적용
        }
        
        let filterName = self.filterButtonName[index];
        let filter = CIFilter(name: filterName)
        if(filterName == "CIVignette") {
            filter!.setValue(2, forKey: kCIInputIntensityKey)
            filter!.setValue(10, forKey: kCIInputRadiusKey)
        }
        filterSet = filterName
        return filterSet
    }
    
    //필터 적용 Method
    func applyFilter(inout image:UIImage, filterName:String) {
        if(filterName == "BRIGHTNESS") {
            let filter = GPUImageBrightnessFilter()
            filter.brightness = 0.1
            image = filter.imageByFilteringImage(image)
        } else if(filterName=="VIGNETTE") {
            let filter = GPUImageVignetteFilter()
            filter.vignetteCenter = CGPoint(x: 0.5,y: 0.5)
            filter.vignetteColor = GPUVector3(one: 0.0,two: 0.0,three: 0.0)
            filter.vignetteStart = 0.3
            filter.vignetteEnd = 0.75
            image = filter.imageByFilteringImage(image)
        } else if(filterName=="TONE_CURVE") {
            let filter = GPUImageToneCurveFilter()
            filter.setPointsWithACV("tone_cuver_sample")
            image = filter.imageByFilteringImage(image)
        } else if(filterName=="LOOKUP_AMATORKA") {
            let filter = GPUImageAmatorkaFilter()
            image = filter.imageByFilteringImage(image)
        } else if(filterName.hasPrefix("I_")) {
            let filter = IFFilterApply()
            filter.rawImage = image
            filter.apply(&image, filterName: filterName)
        } else if(filterName.hasPrefix("CI")) {
            let filter = CIFilter(name: filterName)
            filter!.setValue(CIImage(image: image), forKey: kCIInputImageKey)
            let ctx = CIContext(options:nil)
            let outputImage = ctx.createCGImage(filter!.outputImage!, fromRect:filter!.outputImage!.extent)
            image = UIImage(CGImage: outputImage)
        }
    }
    
    var filterT = false
    
    //collection view 셀 선택
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        if(collectionType == 0) {
            previewTimer?.invalidate()
            previewTimer = nil
            
            let filter = getFilter(indexPath.item)
            
            if filter != nil {
                self.filterCurrent = filter
            }else {
                self.filterCurrent = "None"
            }
            
            playImageArr = [[UIImage]]()
            
            
            for var i=0; i<frameimagepathArr.count; i++ {
                playImageArr.append([])
                for var j=0; j<frameimagepathArr[i].count; j++ {
                    var image:UIImage? = UIImage(contentsOfFile: frameimagepathArr[i][j])
                    if filter != nil {
                        self.log.log("image \(image)")
                        applyFilter(&image!, filterName: self.filterCurrent)
                    }
                    playImageArr[i].append(image!)
                    image = nil
                }
                
            }
            
            if let front = self.frontImage.image {
                var image:UIImage? = front
                applyFilter(&image!, filterName: self.filterCurrent)
                self.frontImage.image = image
                image = nil
                mask()
            }
            
            self.insetAllFram()
            selectedCellIndex = -1
            for view in self.canvas.subviews {
                view.removeFromSuperview()
            }
            frameIndex = 0
            currentIndex1 = 0
            interval = Double(self.sliderDelay.value)
            previewTimer?.invalidate()
            previewTimer = nil
            previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
            let cell2 = collectionView.cellForItemAtIndexPath(indexPath)
            cell2!.layer.borderColor = Config.getInstance().color.CGColor
            
        } else {
            // 이미지 프레임 편집기
            previewTimer?.invalidate()
            previewTimer = nil
            selectedCellIndex = indexPath.item
            
            if selectedCellIndex == 0 {
                for var i=0; i<cellArr.count; i++ {
                    cellArr[i] = 1
                    if i == 0 { cellArr[i] = 0 }
                    let temp = NSIndexPath(forRow: i, inSection: 0)
                    if let cell2 = collectionView.cellForItemAtIndexPath(temp){
                        cell2.layer.borderColor = Config.getInstance().color.CGColor
                    }
                }
            }else {
                log.log("cellArr.count \(cellArr.count)")
                for var i=0; i<cellArr.count; i++ {
                    cellArr[i] = 0
                    let temp = NSIndexPath(forRow: i, inSection: 0)
                    self.log.log("temp \(temp)")
                    if let cell2 = collectionView.cellForItemAtIndexPath(temp) {
                        cell2.layer.borderColor = UIColor.blackColor().CGColor
                    }
                    
                }
            }
            if selectedCellIndex > 0 {
                if textArr.count > 0 {
                    for view in self.canvas.subviews {
                        view.removeFromSuperview()
                    }
                    for view in self.textArr[selectedCellIndex-1] {
                        self.canvas.addSubview(view)
                    }
                }
            }
            
            let cell2 = collectionView.cellForItemAtIndexPath(indexPath)
            if cellArr[selectedCellIndex] == 0 {
                cellArr[selectedCellIndex] = 1
                cell2!.layer.borderColor = Config.getInstance().color.CGColor
            }else {
                cellArr[selectedCellIndex] = 0
                cell2!.layer.borderColor = UIColor.blackColor().CGColor
            }
            
            for view in self.canvas.subviews {
                view.removeFromSuperview()
            }
            
            if selectedCellIndex == 0 { frameIndex = 0 }
            frameIndex = 0
            currentIndex1 = 0
            interval = Double(self.sliderDelay.value)
            previewTimer?.invalidate()
            previewTimer = nil
            previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
        }
        self.view.bringSubviewToFront(self.waterMark)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath){
        if let cell2 = collectionView.cellForItemAtIndexPath(indexPath) {
            cell2.layer.borderColor = UIColor.blackColor().CGColor
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSizeZero
        }else {
            return CGSizeMake(CGRectGetWidth(collectionView.bounds),90)
        }
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
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("collCell", forIndexPath: indexPath) as! RACollectionViewCell
        
        cell.imageView.image = self.collections[indexPath.item]
        cell.layer.borderWidth = 3.0;
        cell.layer.borderColor = UIColor.blackColor().CGColor
        if collectionType == 1 {
            log.log("cellArr \(cellArr.count)")
            //            selectedCellIndex = 0
            log.log("indexPath row \(indexPath.row)")
            self.cellArr[indexPath.row] = 1
            cellindex = indexPath.row
            if selectedCellIndex > 0 {
                cell.layer.borderColor = UIColor.blackColor().CGColor
                if indexPath.row == selectedCellIndex {
                    cell.layer.borderColor = Config.getInstance().color.CGColor
                }
            }else {
                cell.layer.borderColor = Config.getInstance().color.CGColor
            }
            
        }
        
        //cell.layer.borderColor = UIColor.blueColor().CGColor
        return cell
    }
    
    var cellindex = 0
    
    // 드래그앤 드롭 지원 여부
    func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(collectionType == 0) {
            return false
        } else {
            if indexPath.row == 0 {
                return false
            }else {
                return true
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, canMoveToIndexPath: NSIndexPath) -> Bool {
        log.log("canMoveToIndexPath  \(canMoveToIndexPath.row)")
        if canMoveToIndexPath.row == 0 {
            return false
        }else {
            return true
        }
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        
        
        if atIndexPath.row == 0 || toIndexPath.row == 0 {
            collectionView.reloadData()
            return
        }
        previewTimer?.invalidate()
        previewTimer = nil
        
        
        
        print("\(atIndexPath.row)            \(toIndexPath.row)")
        print("\(atIndexPath.item)            \(toIndexPath.item)")
        
        
        let photo = self.collections.removeAtIndex(atIndexPath.item)
        self.collections.insert(photo, atIndex: toIndexPath.item)
        
        let path = self.imagePaths.removeAtIndex(atIndexPath.item-1)
        self.imagePaths.insert(path, atIndex: toIndexPath.item-1)
        
        let mov = self.movNames.removeAtIndex(atIndexPath.item-1)
        self.movNames.insert(mov, atIndex: toIndexPath.item-1)
        
        let image = self.playImageArr.removeAtIndex(atIndexPath.item-1)
        self.playImageArr.insert(image, atIndex: toIndexPath.item-1)
        
        let text = self.textArr.removeAtIndex(atIndexPath.item-1)
        self.textArr.insert(text, atIndex: toIndexPath.item-1)
        
        let imagePath = self.frameimagepathArr.removeAtIndex(atIndexPath.item-1)
        self.frameimagepathArr.insert(imagePath, atIndex: toIndexPath.item-1)
        collectionView.reloadData()
        selectedCellIndex = toIndexPath.item-1
        for view in self.canvas.subviews {
            view.removeFromSuperview()
        }
        frameIndex = 0
        currentIndex1 = 0
        interval = Double(self.sliderDelay.value)
        previewTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextImage"), userInfo: nil, repeats: true)
    }
    
    //    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
    //        return UIEdgeInsetsMake(0.0, 100.0, 100.0, 100.0)
    //    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(80.0, 80.0)   // jis
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
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.eraserView.hidden == true {
            return
        }
        mouseSwiped = false
        
        if let touch = touches.first {
            lastPoint = touch.locationInView(self.frontImage)
            
            if(historyImg.count==10) {
                historyImg.removeAtIndex(0)
            }
            
            let newCgIm = CGImageCreateCopy(maskImage.image?.CGImage)
            if(newCgIm != nil) {
                let newImage = UIImage(CGImage: newCgIm!)
                historyImg.append(newImage)
            }
            print("save history ",historyImg.count)
        }
        
        print("touch count",touches.first?.tapCount)
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(maskImage.frame.size)
        let context = UIGraphicsGetCurrentContext()
        maskImage.image?.drawInRect(CGRect(x: 0, y: 0, width: maskImage.frame.size.width, height: maskImage.frame.size.height))
        log.log("drawLineForm aaaaaaaaaaaaaaaaaaaaaaaaa \(maskImage.frame)")
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        log.log("\(fromPoint.x)   \(fromPoint.y)")
        log.log("\(toPoint.x)     \(toPoint.y)")
        
        // 3
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, .Normal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        maskImage.image = UIGraphicsGetImageFromCurrentImageContext()
        maskImage.alpha = opacity
        UIGraphicsEndImageContext()
        
        mask()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 6
        if self.eraserView.hidden == true {
            return
        }
        eraserD = false
        mouseSwiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(frontImage)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
        
    }
    
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.eraserView.hidden == true {
            return
        }
        
        if mouseSwiped == false {
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        //        if mouseSwiped == false {
        //            // draw a single point
        //            drawLineFrom(lastPoint, toPoint: lastPoint)
        //        }
        
    }
    
    func mask() {
        var eraserImage = playImageArr[0][0]
        let filter = GPUImageBrightnessFilter()
        filter.brightness = 0.02
        applyFilter(&eraserImage, filterName: self.filterCurrent)
        let imageRef = eraserImage.CGImage
        let maskRef = maskImage.image?.CGImage
        
        let mask:CGImageRef = CGImageMaskCreate(CGImageGetWidth(maskRef), CGImageGetHeight(maskRef), CGImageGetBitsPerComponent(maskRef), CGImageGetBitsPerPixel(maskRef), CGImageGetBytesPerRow(maskRef), CGImageGetDataProvider(maskRef), nil, true)!
        
        let masked:CGImageRef = CGImageCreateWithMask(imageRef, mask)!
        
        self.frontImage.image = UIImage(CGImage: masked)
        log.log("frontImage mask \(frontImage.image!)")
        self.view.bringSubviewToFront(canvas)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]){
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        self.dismissViewControllerAnimated(true, completion: nil)
        if mediaType.isEqualToString(kUTTypeMovie as NSString as String) {
            
        } else {
            //print("연사 관련 전처리")
            // 이미지 추출 및 편집 뷰 컨트롤러로 이동
            //mov 파일과 폴더 생성 20151218 박찬누리
            if var pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let fileManager = NSFileManager.defaultManager()
                do {
                    let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(workFolder!)!
                    
                    var aaa = 0
                    while let element = enumerator.nextObject() as? String {
                        if element.hasSuffix("mov") {
                            
                            let imgPath = element.stringByReplacingOccurrencesOfString(".mov", withString: "")
                            
                            let _imgPath = Int(imgPath)
                            
                            if _imgPath > aaa {
                                aaa = _imgPath!
                            }
                            
                        }
                    }
                    
                    aaa += 1
                    let fileManager = NSFileManager.defaultManager()
                    var fileName = String(format: "%@/%02d",arguments:[workFolder!,aaa])
                    if(!fileManager.fileExistsAtPath(fileName)) {
                        fileName = fileName + ".mov"
                        fileManager.createFileAtPath(fileName, contents: nil, attributes: nil)
                        fileName = String(format: "%@/%02d",arguments:[workFolder!,aaa])
                        movNames.append(fileName)
                        addImage = true
                        try fileManager.createDirectoryAtPath(fileName, withIntermediateDirectories: false, attributes: nil)
                        
                    }
                    
                    //이미지 사이즈 변경및 자르기
                    let bImage = playImageArr[0][0]
                    if(bImage.size.width<bImage.size.height) {
                        pickedImage = pickedImage.resizeImage(CGSize(width:480,  height:640))
                        
                        pickedImage = pickedImage.cropToBounds(480, height:640)
                    } else {
                        pickedImage = pickedImage.resizeImage(CGSize(width:480,  height:480))
                        
                        pickedImage = pickedImage.cropToBounds(480, height:480)
                    }
                    
                    fileName = fileName+"/000.jpg"
                    UIImageJPEGRepresentation(pickedImage, 80)!.writeToFile(fileName, atomically: true)
                    
                    log.log("sliderDelay \(sliderDelay.value)")
                    log.log("playImageArr.count \(playImageArr.count)")
                    
                    if(self.selectedCellIndex != -1) && self.selectedCellIndex > 0 {
                        var pickedImageArr = [UIImage]()
                        var pickedImagePathArr = [String]()
                        
                        pickedImageArr.append(pickedImage)
                        pickedImagePathArr.append(fileName)
                        playImageArr.insert(pickedImageArr, atIndex: self.selectedCellIndex)
                        frameimagepathArr.insert(pickedImagePathArr, atIndex: self.selectedCellIndex)
                        imagePaths.insert(fileName, atIndex: self.selectedCellIndex)
                        collections.insert(pickedImage, atIndex: self.selectedCellIndex)
                        cellArr.insert(1, atIndex: self.selectedCellIndex)
                    } else {
                        var pickedImageArr = [UIImage]()
                        var pickedImagePathArr = [String]()
                        pickedImageArr.append(pickedImage)
                        pickedImagePathArr.append(fileName)
                        playImageArr.append(pickedImageArr)
                        frameimagepathArr.append(pickedImagePathArr)
                        imagePaths.append(fileName)
                        collections.append(pickedImage)
                        cellArr.append(0)
                    }
                    self.collectionView.reloadData()
                    self.edit()
                } catch {
                    
                }
            }
        }
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
}


class RACollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var gradientLayer: CAGradientLayer?
    var hilightedCover: UIView!
    override var highlighted: Bool {
        didSet {
            self.hilightedCover.hidden = !self.highlighted
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.hilightedCover.frame = self.bounds
        self.applyGradation(self.imageView)
    }
    
    private func configure() {
        self.imageView = UIImageView()
        self.imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.imageView)
        
        self.hilightedCover = UIView()
        self.hilightedCover.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.hilightedCover.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.hilightedCover.hidden = true
        self.addSubview(self.hilightedCover)
    }
    
    private func applyGradation(gradientView: UIView!) {
        self.gradientLayer?.removeFromSuperlayer()
        self.gradientLayer = nil
        
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer!.frame = gradientView.bounds
        
        let mainColor = UIColor(white: 0, alpha: 0.3).CGColor
        let subColor = UIColor.clearColor().CGColor
        self.gradientLayer!.colors = [subColor, mainColor]
        self.gradientLayer!.locations = [0, 1]
        
        gradientView.layer.addSublayer(self.gradientLayer!)
    }
    
    
}

extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"%06x", rgb) as String
    }
}