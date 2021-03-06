//
//  VideoGalleryViewController.swift
//  PicPic
//
//  Created by JIS-MAC on 1/12/16.
//  Copyright © 2016 찬누리 박. All rights reserved.
//

import UIKit
import Foundation
import Photos
import MediaPlayer


private let DKVideoAssetIdentifier = "DKVideoAssetIdentifier"
//"DKVideoAssetIdentifier"


enum imageType {
    case JPG
    case GIF
}

class VideoGalleryViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextheight: NSLayoutConstraint!
    @IBOutlet weak var nextWidth: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
    internal var cameradelegate: CameraViewController!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    private var groups: [String]?
    private var selectedGroup: String?
    private var defaultAssetGroup: PHAssetCollectionSubtype?
    
    internal var selectedAsset : DKAsset?
    var workFolder : String!

    private var itemSize: CGSize!
    
    private var player:MPMoviePlayerController?
    var selectType : String!
    var imgType : imageType!
    var arr:[UIImage] = []
    var duration = NSTimeInterval(1)
    var url : NSURL!
    
    /// The types of PHAssetCollection to display in the picker.
    var assetGroupTypes: [PHAssetCollectionSubtype] = [
        .SmartAlbumUserLibrary,
        .SmartAlbumFavorites,
        .AlbumRegular
        ]
    
    private lazy var assetFetchOptions: PHFetchOptions = {
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return assetFetchOptions
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextButton.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        if self.appdelegate.locale != "ko_KR" {
            self.nextButton.frame = CGRectMake(225, 34, 80, 40)
            self.nextWidth.constant = 80
        }

        
        self.collectionView!.registerClass(DKVideoAssetCell.self, forCellWithReuseIdentifier: DKVideoAssetIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        
        let interval: CGFloat = 10
        layout.minimumInteritemSpacing = interval
        layout.minimumLineSpacing = interval
        
        let screenWidth = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        let itemWidth = (screenWidth - interval * 4) / 3
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        self.itemSize = layout.itemSize
        
        
        getImageManager().groupDataManager.assetGroupTypes = self.assetGroupTypes
        self.assetFetchOptions.predicate = NSPredicate(format: "(mediaType == %d) || (mediaType == %d)", PHAssetMediaType.Video.rawValue,PHAssetCollectionType.Album.rawValue)
        getImageManager().groupDataManager.assetFetchOptions = self.assetFetchOptions
        
        self.collectionView.allowsMultipleSelection = false
        
        self.loadGroups()

    }
    
    
    private lazy var groupImageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .Opportunistic
        options.resizeMode = .Exact;
        
        return options
    }()
    
    @IBAction func onBtnPrev(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onBtnNext(sender: UIButton) {
        print("next")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if (self.selectedAsset != nil) {
            if self.selectType == "video" {
                self.selectedAsset!.fetchAVAssetWithCompleteBlock { (avAsset) in
                    dispatch_async(dispatch_get_main_queue(), { () in
                        self.selectVideo(avAsset!.URL)
                    })
                }
            }else {
                self.selectedAsset?.fetchOriginalImageWithCompleteBlock({ (image, info) in
                    
                    self.selectImage(image!, type: self.imgType)
                })
            }
            
        }
    }
    
    
    class DKAssetCell: UICollectionViewCell {
        
        class DKImageCheckView: UIView {
            
            private lazy var checkImageView: UIImageView = {
                let imageView = UIImageView(image: DKImageResource.checkedImage())
                
                return imageView
            }()
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                
                self.addSubview(checkImageView)
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                self.checkImageView.frame = self.bounds
            }
            
        } /* DKImageCheckView */
        
        private var asset: DKAsset!
        
        private let thumbnailImageView: UIImageView = {
            let thumbnailImageView = UIImageView()
            thumbnailImageView.contentMode = .ScaleAspectFill
            thumbnailImageView.clipsToBounds = true
            
            return thumbnailImageView
        }()
        
        private let checkView = DKImageCheckView()
        
        override var selected: Bool {
            didSet {
                checkView.hidden = !super.selected
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.thumbnailImageView.frame = self.bounds
            self.contentView.addSubview(self.thumbnailImageView)
            self.contentView.addSubview(checkView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.thumbnailImageView.frame = self.bounds
            checkView.frame = self.thumbnailImageView.frame
        }
        
    } /* DKAssetCell */
    
    class DKVideoAssetCell: DKAssetCell {
        
        override var asset: DKAsset! {
            didSet {
                let videoDurationLabel = self.videoInfoView.viewWithTag(-1) as! UILabel
                if asset.duration != nil {
                    let minutes: Int = Int(asset.duration!) / 60
                    let seconds: Int = Int(asset.duration!) % 60
                    videoDurationLabel.text = String(format: "\(minutes):%02d", seconds)
                }
            }
        }
        
        override var selected: Bool {
            didSet {
                if super.selected {
                    self.videoInfoView.backgroundColor = UIColor(red: 20 / 255, green: 129 / 255, blue: 252 / 255, alpha: 0)
                } else {
                    self.videoInfoView.backgroundColor = UIColor(white: 0.0, alpha: 0)
                }
            }
        }
        
        private lazy var videoInfoView: UIView = {
            let videoInfoView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
            
            let videoDurationLabel = UILabel()
            videoDurationLabel.tag = -1
            videoDurationLabel.textAlignment = .Right
            videoDurationLabel.font = UIFont.systemFontOfSize(12)
            videoDurationLabel.textColor = UIColor.whiteColor()
            videoInfoView.addSubview(videoDurationLabel)
            videoDurationLabel.frame = CGRect(x: 0, y: 0, width: videoInfoView.bounds.width - 7, height: videoInfoView.bounds.height)
            videoDurationLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            return videoInfoView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.contentView.addSubview(videoInfoView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let height: CGFloat = 30
            self.videoInfoView.frame = CGRect(x: 0, y: self.contentView.bounds.height - height,
                width: self.contentView.bounds.width, height: height)
        }
        
    }
    
    internal func loadGroups() {
        
        getImageManager().groupDataManager.addObserver(self)
        getImageManager().groupDataManager.fetchGroups { [weak self] groups, error in
            guard let strongSelf = self else { return }
            if error == nil {
                strongSelf.groups = groups!
                strongSelf.selectedGroup = strongSelf.defaultAssetGroupOfAppropriate()
            }
        }
    }
    
    private func defaultAssetGroupOfAppropriate() -> String? {
        if let groups = self.groups {
            if let defaultAssetGroup = self.defaultAssetGroup {
                for groupId in groups {
                    let group = getImageManager().groupDataManager.fetchGroupWithGroupId(groupId)
                    if defaultAssetGroup == group.originalCollection.assetCollectionSubtype {
                        return groupId
                    }
                }
            }
            return self.groups!.first
        }
        return nil
    }
    
    
    func playVideo(videoURL: NSURL) {
        
        if (self.player != nil) {
            self.player?.stop()
            self.player = nil
        }
        for view in self.preview.subviews {
            view.removeFromSuperview()
        }
        
        let player = MPMoviePlayerController(contentURL: videoURL)
        player.movieSourceType = .File
        player.controlStyle = .None
        player.fullscreen = false
        player.repeatMode = MPMovieRepeatMode.One
        player.scalingMode = MPMovieScalingMode.AspectFill
        
        player.view.frame = self.preview.bounds
        self.preview.addSubview(player.view)
        
        player.prepareToPlay()
        player.play()
        
        self.player = player
    }
    
    func image(url : NSURL , type : imageType ,image : UIImage!){
        if (self.player != nil) {
            self.player?.stop()
            self.player = nil
        }
        for view in self.preview.subviews {
            view.removeFromSuperview()
        }
        
        var imageView = UIImageView()
        imageView.frame = self.preview.bounds
        self.preview.addSubview(imageView)
        print("imagein")
        if type == .GIF {
            print("gif image")
            imageView.image = UIImage.gifWithData(NSData(contentsOfURL: url)!)
            
        }else {
            imageView.image = image
        }
        
    }
    
    func selectVideo(videoURL:NSURL) {
        Config.getInstance().dataType = 1
        self.cameradelegate.openMoviePreview(videoURL)
    }
    
    func selectImage(image : UIImage, type : imageType) {
        Config.getInstance().dataType = 1
        if type == imageType.JPG {
            self.cameradelegate.selectImage(image, type: type)
        }else {
            
            let asset = self.selectedAsset?.originalAsset
            asset?.requestContentEditingInputWithOptions(PHContentEditingInputRequestOptions(), completionHandler: { (input, _) in
                let url = input?.fullSizeImageURL
                let gg = CGImageSourceCreateWithURL(url!, nil)
                UIImage.animatedInfoWithSource(gg!, frames: &self.arr, duration: &self.duration)
                self.url = url!
                
                var index = 0
                var fileName = String(format: "%@/00",arguments:[self.workFolder!])
                if !self.cameradelegate.fileManager.fileExistsAtPath(fileName) {
                    do {
                        fileName = fileName + ".mov"
                        self.cameradelegate.fileManager.createFileAtPath(fileName, contents: nil, attributes: nil)
                        fileName = String(format: "%@/00",arguments:[self.workFolder!])
                        try self.cameradelegate.fileManager.createDirectoryAtPath(fileName, withIntermediateDirectories: false, attributes: nil)
                    }catch {
                        
                    }
                }
                
                for img in self.arr {
                    print(img)
                    let fileName = String(format: "%@/00",arguments:[self.workFolder!])
                    let savePath = String(format: "%@/00/%03d.jpg", arguments: [self.workFolder!,Int(index)])
                    UIImageJPEGRepresentation(img, 100)!.writeToFile(savePath, atomically: true)
                    index++
                }
                print(self.workFolder!)
            })
            self.cameradelegate.selectGIF(self.url)
        }
    }
    
    
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let selectedGroup = self.selectedGroup else { return 0 }
        
        let group = getImageManager().groupDataManager.fetchGroupWithGroupId(selectedGroup)
        print("group count   ",group.totalCount)
        if group.totalCount == 0 {
            let alert = UIAlertController(title: "", message: self.appdelegate.ment["video_not_search"].stringValue, preferredStyle: .Alert)
            let complete = UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default, handler: { (complete) -> Void in
                self.onBtnPrev(self.backButton)
            })
            alert.addAction(complete)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        return group.totalCount ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        return self.assetCellForIndexPath(indexPath)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.itemSize
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let frame : CGRect = self.view.frame
        let margin  = (frame.width - self.itemSize.width * 3) / 4.0
        return UIEdgeInsetsMake(margin, margin, margin, margin) // margin between cells
    }
    
    func assetCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let assetIndex = indexPath.row
        let group = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroup!)
        
        let asset = getImageManager().groupDataManager.fetchAssetWithGroup(group, index: assetIndex)
        
        var cell: DKAssetCell!
        var identifier: String!
        
        identifier = DKVideoAssetIdentifier
        
        
        cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! DKAssetCell
        cell.asset = asset
        let tag = indexPath.row + 1
        cell.tag = tag
        asset.fetchImageWithSize(self.itemSize.toPixel(), options: self.groupImageRequestOptions) { image, info in
            if cell.tag == tag {
                cell.thumbnailImageView.image = image
            }
        }
        
        if (self.selectedAsset == asset) {
            cell.selected = true
            self.collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        } else {
            cell.selected = false
            self.collectionView!.deselectItemAtIndexPath(indexPath, animated: false)
        }
        
        return cell
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let selectedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset
        self.selectedAsset = selectedAsset
        print(self.selectedAsset.debugDescription)
        if self.selectedAsset?.duration == nil {
            self.selectedAsset?.fetchOriginalImageWithCompleteBlock({ (image, info) in
                print(info)
                var urlInfo = info!["PHImageFileURLKey"] as! NSURL
                let fielutikey : String = info!["PHImageFileUTIKey"] as! String
                let str = fielutikey.componentsSeparatedByString(".")
                print(urlInfo)
                print(str)
                var img : UIImage!
                if str[str.count-1] == "gif" {
                    self.imgType = imageType.GIF
                    img = nil
                    
                    let asset = self.selectedAsset?.originalAsset
                    asset?.requestContentEditingInputWithOptions(PHContentEditingInputRequestOptions(), completionHandler: { (input, _) in
                        let url = input?.fullSizeImageURL
                        let gg = CGImageSourceCreateWithURL(url!, nil)
                        UIImage.animatedInfoWithSource(gg!, frames: &self.arr, duration: &self.duration)
                        self.url = url!
                        self.image(url!,type: self.imgType,image: img)
                    })
                }else {
                    self.imgType = imageType.JPG
                    img = image
                    self.image(urlInfo,type: self.imgType,image: img)
                }
                self.selectType = "image"
            })
        }else {
            self.selectedAsset!.fetchAVAssetWithCompleteBlock { (avAsset) in
                dispatch_async(dispatch_get_main_queue(), { () in
                    print(avAsset?.URL)
                    self.playVideo(avAsset!.URL)
                    self.selectType = "video"
                })
            }
        }
    }
    
}