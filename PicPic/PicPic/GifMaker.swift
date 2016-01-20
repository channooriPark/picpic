//
//  GifMaker.swift
//  cameraTester
//
//  Created by Changho Kim on 2015. 11. 19..
//  Copyright © 2015년 picpic. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import SpringIndicator


class GifMaker {
    let log = LogPrint()
    var progressView : UIProgressView!
    
    private struct Constants {
        static let TimeInterval: Int32 = 600
        static let Tolerance = 0.01
        static let FrameRate = 12.0 //5.0 //10.0
    }
    
    
    func checkPath(path:String) {
        let fileManager = NSFileManager.defaultManager()
        do {
            if(!fileManager.fileExistsAtPath(path)) {
                try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
            }
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    func checkPathFromName(fullPath:String) {
        
        //let range = fullPath.r
        
    }
    
    func thumbFromMov(inputPath:String, outputPath imagePath:String) {
//        print("moviePath : ",inputPath)
//        print("imagePath : ",imagePath)
        let asset = AVAsset(URL: NSURL(fileURLWithPath: inputPath))
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(0, Constants.TimeInterval)
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            var img = UIImage(CGImage: imageRef)
//            print(img.size)
            let width = img.size.width
            var height = img.size.height
            
            if(Config.getInstance().videoRatio == "1:1") {
                height = width
            } else {
                height = width * 4 / 3
            }
            
            img = img.cropToBounds(Double(width), height: Double(height))
            
            UIImageJPEGRepresentation(img, 80)!.writeToFile(imagePath, atomically: true)
        } catch let error as NSError {
            print("An error occurred: \(error)")
        }
    }
    
    func movSplit(url:NSURL, time_start:Double, var time_end:Double, outputPath path:String) {
        
        let fileManager = NSFileManager.defaultManager()
        do {
            if(!fileManager.fileExistsAtPath(path)) {
                try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
                
            }
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        
        let asset = AVAsset(URL: url)
        self.log.log("asset   \(asset)")
        let time_total = CMTimeGetSeconds(asset.duration)
        if(time_total < time_end || time_end == 0) {
            time_end = time_total
        }
        
        let frameCount = Int(CMTimeGetSeconds(asset.duration) * Constants.FrameRate)
        var timePoints: [TimePoint] = []
        
        let movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        let increment = Float(movieLength) / Float(frameCount)
        
        let frame_start = Int(time_start * Constants.FrameRate)
        let frame_end = Int(time_end * Constants.FrameRate)
        
        
        for frameNumber in frame_start ..< frame_end {
            let seconds: Float64 = Float64(increment) * Float64(frameNumber)
            let time = CMTimeMakeWithSeconds(seconds, Constants.TimeInterval)
            timePoints.append(time)
        }
        
        if(timePoints.count == 0 && time_end>0) {
            let time = CMTimeMakeWithSeconds(time_start, Constants.TimeInterval)
            timePoints.append(time)
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let tolerance = CMTimeMakeWithSeconds(Constants.Tolerance, Constants.TimeInterval)
        imageGenerator.requestedTimeToleranceBefore = tolerance
        imageGenerator.requestedTimeToleranceAfter = tolerance
        
        var indx = 0;
        for time in timePoints {
            do {
                let fileName = String(format: "%03d.jpg",Int(indx))
                let imagePath = "\(path)/\(fileName)"
                let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
                var img = UIImage(CGImage: imageRef)
                if(Config.getInstance().dataType==0) {
                //카메라 촬영
                if(Config.getInstance().videoRatio == "1:1") {
                    var width = Double(img.size.width)
                    if(img.size.height<img.size.width) {
                        width = Double(img.size.height)
                    }
                    
                    img = img.cropToBounds(width, height: width)
//                    img = img.cropToBounds(480, height: 480)
                    
                    if( Double(Config.getInstance().wid) < width) {
                        img = img.resizeImage(CGSize(width: 480, height: 480))
                    }
                } else {
//                    self.log.log("log.log img size\(img.size)")
                    var width = Double(img.size.width)
                    if(img.size.height<img.size.width) {
                        width = Double(img.size.height)
                    }
                    let height = width*4/3
                    
                    img = img.cropToBounds(width, height: height)
//                    img = img.cropToBounds(480, height: 640)
                    
                    if( Double(Config.getInstance().wid) < width) {
                        img = img.resizeImage(CGSize(width: 480, height: 640))
                    }
                }
                } else {
                    //갤러리에서 동영상 선택
                    self.log.log("log.log img size\(img.size)")
                    if(img.size.width > img.size.height) { //가로로 자르기
                        let imgRatio = Float((img.size.width) / (img.size.height))
                        let ratio = Float(4.0/3.0)
                        self.log.log("imgRatio  :  \(imgRatio)  ratio : \(ratio)")
                        if(imgRatio > ratio) { // 세로 기준
                            
                            /*var width = Double(img.size.width)
                            if(img.size.height<img.size.width) {
                                width = Double(img.size.height)
                            }*/
                            let width = Double (img.size.height*CGFloat(4/3) )
                            let height = Double (img.size.height)
                            
                            print("img 세로기준 datatype 1 ",img.size.width,"x",img.size.height)
                            print(width,"x",height)
                            
                            img = img.cropToBounds(720, height: 720)
//                            if( Double(Config.getInstance().wid) < width) {
                                img = img.resizeImage(CGSize(width: 640, height: 360))
//                            }
                            /*
                            img = img.resizeImage(CGSize(width: 640, height: 360))
                            let cropSize = CGSize(width:img!.size.height*4/3, height:img!.size.height)
                            let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*3/4)
                            
                            makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: reSize)*/
                        } else { // 가로 기준
//                            print("5")
                            
                            var width = Double(img.size.width)
                            if(img.size.height<img.size.width) {
                                width = Double(img.size.height)
                            }
                            let height = width*3/4
                            
                            print("img 가로기준 ",img.size.width,"x",img.size.height)
                            print(width,"x",height)
                            
                            img = img.cropToBounds(width, height: height)
                            if( Double(Config.getInstance().wid) < width) {
                                img = img.resizeImage(CGSize(width: 640, height: 480))
                            }
                            
                            /*
                            let cropSize = CGSize(width:img!.size.width, height:img!.size.width*3/4)
                            let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*3/4)
                            
                            makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: reSize)*/
                        }
                    } else { // 세로로 자르기
                        let imgRatio = Float((img.size.height) / (img.size.width))
                        let ratio = Float(4.0/3.0)
                        
                        if(imgRatio > ratio) { // 가로 기준
//                            print("6")
                            
                            var width = Double(img.size.width)
                            if(img.size.height<img.size.width) {
                                width = Double(img.size.height)
                            }
                            let height = width*4/3
                            
                            img = img.cropToBounds(width, height: height)
                            if( Double(Config.getInstance().wid) < width) {
                                img = img.resizeImage(CGSize(width: 480, height: 640))
                            }
                            
                            /*
                            let cropSize = CGSize(width:img!.size.width, height:img!.size.width*4/3)
                            
                            print(cropSize)
                            //let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*4/3)
                            
                            makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: nil)*/
                            
                        } else { // 세로 기준
//                            print("7")
                            
                            /*var width = Double(img.size.width)
                            if(img.size.height<img.size.width) {
                                width = Double(img.size.height)
                            }
                            let height = width*4/3*/
                            
                            let width = Double (img.size.height*CGFloat(4/3) )
                            let height = Double (img.size.height)
                            
                            img = img.cropToBounds(width, height: height)
                            if( Double(Config.getInstance().wid) < width) {
                                img = img.resizeImage(CGSize(width: 480, height: 640))
                            }
                            
                            /*
                            let cropSize = CGSize(width:img!.size.height*4/3, height:img!.size.height)
                            let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*4/3)
                            
                            makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: reSize)*/
                        }
                    }
                    
                }
                
                UIImageJPEGRepresentation(img, 80)!.writeToFile(imagePath, atomically: true)
            } catch let error as NSError {
                print("An error occurred: \(error)")
            }
            indx++
        }
//        print("dddddddddddddd")
    }
    
    func makeJpegs(tmpPath:String, workPath:String, cropSize:CGSize?, reSize:CGSize?) {
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(tmpPath)!
        
        while let element = enumerator.nextObject() as? String {
            if element.hasSuffix("jpg") { // checks the extension
                let path = "\(tmpPath)/\(element)"
                let dest = "\(workPath)/\(element)"
                
                var img = UIImage(contentsOfFile: path);
                
                if(cropSize != nil) {
//                    print(cro÷pSize)
                    img = img?.cropToBounds(Double(cropSize!.width), height: Double(cropSize!.height))
                }
                if(reSize != nil) {
                    img = img?.resizeImage(reSize!)
                }
                UIImageJPEGRepresentation(img!, 100)!.writeToFile(dest, atomically: true)
            }
        }
        
//        print("ggggg÷÷gggggggggggg")
    }
    
    func readyWork(tmpPath:String, workPath:String, ratio:String) {
        let fileManager = NSFileManager.defaultManager()
        do {
            if(!fileManager.fileExistsAtPath(workPath)) {
                try fileManager.createDirectoryAtPath(workPath, withIntermediateDirectories: false, attributes: nil)
            }
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        let imgPath = "\(tmpPath)/000.jpg"
        let img = UIImage(contentsOfFile: imgPath)
        
//        print("Config.getInstance().dataType ",Config.getInstance().dataType)
//        print("Config.getInstance().videoRatio ",Config.getInstance().videoRatio)
        if(Config.getInstance().dataType==0) {
            if(Config.getInstance().videoRatio == "1:1") {
                if(img?.size.width>img?.size.height) {
//                    print("1")
                    let cropSize = CGSize(width:img!.size.height, height:img!.size.height)
                    let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid)
                    
                    makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: reSize)
                } else {
//                    print("2")
                    let cropSize = CGSize(width:img!.size.width, height:img!.size.width)
                    let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid)
//                    print("\(reSize)     \(cropSize)")
                    makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: reSize)
                }
            } else {
                
                
                if(img?.size.width > img?.size.height) { //가로로 자르기
//                    print("3")
                    let imgRatio = Float((img?.size.width)! / (img?.size.height)!)
                    let ratio = Float(4.0/3.0)
                    
                    if(imgRatio > ratio) { // 세로 기준
//                        print("4")
                        let cropSize = CGSize(width:img!.size.height*4/3, height:img!.size.height)
                        let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*3/4)
                        
                        makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: reSize)
                    } else { // 가로 기준
//                        print("5")
                        let cropSize = CGSize(width:img!.size.width, height:img!.size.width*3/4)
                        let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*3/4)
                        
                        makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: reSize)
                    }
                } else { // 세로로 자르기
                    let imgRatio = Float((img?.size.height)! / (img?.size.width)!)
                    let ratio = Float(4.0/3.0)
                    
                    if(imgRatio > ratio) { // 가로 기준
//                        print("6")
                        let cropSize = CGSize(width:img!.size.width, height:img!.size.width*4/3)
                        
//                        print(cropSize)
                        //let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*4/3)
                        
                        makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: nil)
                        
                    } else { // 세로 기준
//                        print("7")
                        let cropSize = CGSize(width:img!.size.height*4/3, height:img!.size.height)
                        let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*4/3)
                        
                        makeJpegs(tmpPath, workPath: workPath, cropSize: cropSize, reSize: reSize)
                    }
                }
                
                
            }
        } else {
            if(img?.size.width>Config.getInstance().wid) {
//                print("리사이징 코드 삽입")
                //let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(tmpPath)!
                
                let reSize = CGSize(width: Config.getInstance().wid, height: Config.getInstance().wid*(img?.size.height)!/(img?.size.width)!)
                
                makeJpegs(tmpPath, workPath: workPath, cropSize: nil, reSize: reSize)
                /*
                while let element = enumerator.nextObject() as? String {
                    if element.hasSuffix("jpg") { // checks the extension
                        let path = "\(tmpPath)/\(element)"
                        let dest = "\(workPath)/\(element)"
                        
                        var img = UIImage(contentsOfFile: path);
                        img = img?.resizeImage(reSize)
                        
                        UIImageJPEGRepresentation(img!, 100)!.writeToFile(dest, atomically: true)
                    }
                }*/
            } else {
//                print("work 폴더로 복사")
                
                let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(tmpPath)!
                
                while let element = enumerator.nextObject() as? String {
                    if element.hasSuffix("jpg") { // checks the extension
                        let path = "\(tmpPath)/\(element)"
                        let dest = "\(workPath)/\(element)"
                        
                        do {
                            try fileManager.copyItemAtPath(path, toPath: dest)
                        } catch let error as NSError {
                            print(error.localizedDescription);
                        }
                    }
                }
            }
        }
        
    }
    
    func save(photoDataArr:Array<UIImage>, outPath:String) {
        var indx = 0;
        for img in photoDataArr {
//            print("iamge Size",img.size)
            let savePath = String(format: "%@/%03d.jpg", arguments: [outPath,Int(indx)])
            UIImageJPEGRepresentation(img, 100)!.writeToFile(savePath, atomically: true)
            indx++
        }
    }
    
    func creat(photoDataArr:Array<UIImage>, delayTime:Float, gifPath:String) {
        let fileManager = NSFileManager.defaultManager()

        let regift_photo: Regift_photo = Regift_photo(sourceArray: photoDataArr, delayTime: delayTime)
        
        let output = regift_photo.createGif()
//        print("output ",output?.path)
        
        do {
            try fileManager.copyItemAtPath((output?.path)!, toPath: gifPath)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    func makeImage(bottomImage:UIImage, ghostPath:String, scratchPath:String, filter:CIFilter?, subtitle:UIView?) -> UIImage {
        let fileManager = NSFileManager.defaultManager()
        
        let size = bottomImage.size
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(size)
        
        
        
        bottomImage.drawInRect(areaSize)
        
        if fileManager.fileExistsAtPath(ghostPath) {
            let ghost_img = UIImage(contentsOfFile: ghostPath)
            ghost_img!.drawInRect(areaSize, blendMode: CGBlendMode.Multiply, alpha: Config.getInstance().ghostAlpha)
        }
        
        if fileManager.fileExistsAtPath(scratchPath) {
            let scratch_img = UIImage(contentsOfFile: scratchPath)
            scratch_img!.drawInRect(areaSize)
        }
        
        
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        if filter != nil {
            applyFilter(&newImage, filter: filter!)
        }
        
        UIGraphicsBeginImageContext(size)
        
        newImage.drawInRect(areaSize)
        if subtitle != nil {
            subtitle!.drawViewHierarchyInRect(areaSize, afterScreenUpdates: true)
        }
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func make2(photoDataArr:[UIImage], delayTime:Float, gifPath:String, workFolder:String,subtitle:UIView?,warterMark : Bool) {
        
        var saveArr = photoDataArr
        
        let fileManager = NSFileManager.defaultManager()
//        print("run make2")
//        print("imga count ",photoDataArr.count)
//        print("delay Time : ",delayTime)
        let ghostPath = String(format: "%@/ghost.jpg", arguments: [workFolder])
        let scratchPath = String(format: "%@/scratch.png", arguments: [workFolder])
        
        
        if( fileManager.fileExistsAtPath(ghostPath) || fileManager.fileExistsAtPath(scratchPath) || subtitle != nil) {
            for var i=0;i<photoDataArr.count;i++ {
                let bottomImage = photoDataArr[i]
                let size = bottomImage.size
                let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                UIGraphicsBeginImageContext(size)
                
                
                
                bottomImage.drawInRect(areaSize)
                
                if fileManager.fileExistsAtPath(ghostPath) {
                    let ghost_img = UIImage(contentsOfFile: ghostPath)
                    ghost_img!.drawInRect(areaSize, blendMode: CGBlendMode.Multiply, alpha: Config.getInstance().ghostAlpha)
                }
                
                if fileManager.fileExistsAtPath(scratchPath) {
                    let scratch_img = UIImage(contentsOfFile: scratchPath)
                    scratch_img!.drawInRect(areaSize)
                }
                
                
                var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
//                if filter != nil {
//                    applyFilter(&newImage, filter: filter!)
//                }
                
                UIGraphicsBeginImageContext(size)
                
                newImage.drawInRect(areaSize)
                if subtitle != nil {
                    subtitle!.drawViewHierarchyInRect(areaSize, afterScreenUpdates: true)
                }
                
                if warterMark {
//                    print("warterMark")
                    let warter = UIImage(named: "watermark")
                    let warterRect = CGRectMake(areaSize.width-158, areaSize.height-58, 148, 48)
                    warter?.drawInRect(warterRect)
                }
                
                newImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()

                saveArr[i] = newImage
            }
     
        } else {
//            if(filter != nil) {
//                for var i=0;i<photoDataArr.count;i++ {
//                    var bottomImage = photoDataArr[i]
//                    
//                    applyFilter(&bottomImage, filter: filter!)
//                    
//                    saveArr[i] = bottomImage
//                }
//            } else {
//                
//            }
        }
        let regift_photo: Regift_photo = Regift_photo(sourceArray: saveArr, delayTime: delayTime)
        
        let output = regift_photo.createGif()
//        print("output ",output?.path)
        
        do {
            if fileManager.fileExistsAtPath(gifPath) {
//                print("있어요")
//                print(gifPath)
                try fileManager.removeItemAtPath(gifPath)
                //delete file code
            }
//            print("gifPath ",gifPath)
            try fileManager.copyItemAtPath((output?.path)!, toPath: gifPath)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
    }
    
    
    func make2(photoDataArr:[[UIImage]], delayTime:Float, gifPath:String, workFolder:String,subtitle:[[MyView]]?,warterMark : Bool,imageCheck : [Int:Int]?, canvas : UIView?,playType : Int,allText:[MyView]?) {
        
        var saveArr = photoDataArr
        var saveArr1 = [UIImage]()
        let fileManager = NSFileManager.defaultManager()
//        let ghostPath = String(format: "%@/ghost.jpg", arguments: [workFolder])
        let scratchPath = String(format: "%@/scratch.jpg", arguments: [workFolder])

        
        var eraserImage = UIImage()
        var masked:CGImageRef!
        let imageRef = photoDataArr[0][0].CGImage
        if let maskRef = UIImage(contentsOfFile: scratchPath)?.CGImage {
            let mask:CGImageRef = CGImageMaskCreate(CGImageGetWidth(maskRef), CGImageGetHeight(maskRef), CGImageGetBitsPerComponent(maskRef), CGImageGetBitsPerPixel(maskRef), CGImageGetBytesPerRow(maskRef), CGImageGetDataProvider(maskRef), nil, true)!
            
            masked = CGImageCreateWithMask(imageRef, mask)!
            eraserImage = UIImage(CGImage: masked)
        }
        
        
        
        
        
        
        
        if canvas?.subviews.count > 0 {
            for view in  (canvas?.subviews)! {
                view.removeFromSuperview()
            }
        }
        
        if( fileManager.fileExistsAtPath(scratchPath) || subtitle != nil) {
            if playType == 1 {
                for var i=photoDataArr.count-1;i>=0;i-- {
                    for var j=photoDataArr[i].count-1;j>=0;j-- {
                        
                        let bottomImage = photoDataArr[i][j]
                        let size = bottomImage.size
                        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        
                        UIGraphicsBeginImageContext(size)
                        
                        bottomImage.drawInRect(areaSize)
                        
//                        if fileManager.fileExistsAtPath(ghostPath) {
//                            let ghost_img = UIImage(contentsOfFile: ghostPath)
//                            ghost_img!.drawInRect(areaSize, blendMode: CGBlendMode.Multiply, alpha: Config.getInstance().ghostAlpha)
//                        }
                        
                        if fileManager.fileExistsAtPath(scratchPath) {
                            let scratch_img = eraserImage
                            scratch_img.drawInRect(areaSize)
                        }
                        
                        
                        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        //                if filter != nil {
                        //                    applyFilter(&newImage, filter: filter!)
                        //                }
                        
                        UIGraphicsBeginImageContext(size)
                        
                        newImage.drawInRect(areaSize)
                        
                        if subtitle != nil {
                            if subtitle![0].count > 0 {
                                if canvas?.subviews.count > 0 {
                                    for view in (canvas?.subviews)! {
                                        view.removeFromSuperview()
                                    }
                                }
                                for text in subtitle![0] {
                                    canvas?.addSubview(text)
                                }
                            }
                            
                            //preIndex 이전 프레임 / current 현재프레임
                            log.log("subview change")
                            for view in (canvas?.subviews)! {
                                view.removeFromSuperview()
                            }
                            if subtitle![i].count > 0 {
                                for text in subtitle![i] {
                                    canvas?.addSubview(text)
                                }
                            }
                            
                            
                            //                    }
                            canvas!.drawViewHierarchyInRect(areaSize, afterScreenUpdates: true)
                        }
                        
                        if warterMark {
                            //                    print("warterMark")
                            let warter = UIImage(named: "watermark")
                            let warterRect = CGRectMake(areaSize.width-155, areaSize.height-58, 145, 48)
                            warter?.drawInRect(warterRect)
                        }
                        
                        newImage = UIGraphicsGetImageFromCurrentImageContext()
                        
                        UIGraphicsEndImageContext()
                        
                        saveArr[i][j] = newImage
                        saveArr1.append(saveArr[i][j])
                    }
                    
                }
            }else {
                for var i=0;i<photoDataArr.count;i++ {
                    for var j=0;j<photoDataArr[i].count;j++ {
                        if playType == 1 {
                            i = photoDataArr.count - (i+1)
                            j = photoDataArr[i].count - (j+1)
                            log.log("i \(i)")
                            log.log("j \(j)")
                        }
                        
                        let bottomImage = photoDataArr[i][j]
                        let size = bottomImage.size
                        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        
                        UIGraphicsBeginImageContext(size)
                        
                        bottomImage.drawInRect(areaSize)
                        
//                        if fileManager.fileExistsAtPath(ghostPath) {
//                            let ghost_img = UIImage(contentsOfFile: ghostPath)
//                            ghost_img!.drawInRect(areaSize, blendMode: CGBlendMode.Multiply, alpha: Config.getInstance().ghostAlpha)
//                        }
                        
                        if fileManager.fileExistsAtPath(scratchPath) {
                            let scratch_img = eraserImage
                            scratch_img.drawInRect(areaSize)
                        }
                        
                        
                        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        //                if filter != nil {
                        //                    applyFilter(&newImage, filter: filter!)
                        //                }
                        
                        UIGraphicsBeginImageContext(size)
                        
                        newImage.drawInRect(areaSize)
                        
                        if subtitle != nil {
                            if subtitle![0].count > 0 {
                                if canvas?.subviews.count > 0 {
                                    for view in (canvas?.subviews)! {
                                        view.removeFromSuperview()
                                    }
                                }
                                for text in subtitle![0] {
                                    canvas?.addSubview(text)
                                }
                            }
                            
                            //preIndex 이전 프레임 / current 현재프레임
                            log.log("subview change")
                            for view in (canvas?.subviews)! {
                                view.removeFromSuperview()
                            }
                            if subtitle![i].count > 0 {
                                for text in subtitle![i] {
                                    canvas?.addSubview(text)
                                }
                            }
                            if let all = allText {
                                for alltext in all {
                                    canvas?.addSubview(alltext)
                                }
                            }
                            
                            canvas!.drawViewHierarchyInRect(areaSize, afterScreenUpdates: true)
                        }
                        
                        if warterMark {
                            //                    print("warterMark")
                            let warter = UIImage(named: "watermark")
                            let warterRect = CGRectMake(areaSize.width-131, areaSize.height-44, 121, 38)
                            warter?.drawInRect(warterRect)
                        }
                        
                        newImage = UIGraphicsGetImageFromCurrentImageContext()
                        
                        UIGraphicsEndImageContext()
                        
                        saveArr[i][j] = newImage
                        saveArr1.append(saveArr[i][j])
                    }
                    
                }
            }
            
            
            log.log("saveArr1.count \(saveArr1.count)")
        } else {
            //            if(filter != nil) {
            //                for var i=0;i<photoDataArr.count;i++ {
            //                    var bottomImage = photoDataArr[i]
            //
            //                    applyFilter(&bottomImage, filter: filter!)
            //
            //                    saveArr[i] = bottomImage
            //                }
            //            } else {
            //
            //            }
        }
        //let regift_photo: Regift_photo = Regift_photo(sourceArray: saveArr1, delayTime: delayTime)
        
        //let output = regift_photo.createGif()
        //        print("output ",output?.path)
        print(gifPath)
        
        do {
            if fileManager.fileExistsAtPath(gifPath) {
                //                print("있어요")
                //                print(gifPath)
                try fileManager.removeItemAtPath(gifPath)
                //delete file code
            }
            //            print("gifPath ",gifPath)
            //try fileManager.copyItemAtPath((output?.path)!, toPath: gifPath)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        let agifencPtr:UnsafeMutablePointer<QAGIFHandle> = UnsafeMutablePointer.alloc(sizeof(QAGIFHandle))
        
        let path = gifPath.substringWithRange(gifPath.startIndex ..< gifPath.endIndex.advancedBy(-22))
        print(path)

        //var buffer = UnsafeMutablePointer<Int8>(path.UTF8String)
        
        var buffer = UnsafeMutablePointer<Int8>(NSString(string: gifPath).UTF8String)
        
        QAGIFEncInitHandle(agifencPtr)
        // set agif encoder delay time
        QAGIFEncSetDelay(agifencPtr, Int32(delayTime * 1000))
        // set agif encoder dispose method
        QAGIFEncSetDispose(agifencPtr, 0)
        
        // set agif encoder x, y position
        QAGIFEncSetPosition(agifencPtr, 0, 0)
        // set agif encoder repeat value
        QAGIFEncSetRepeat(agifencPtr, -1)
        
        // set transparent
        QAGIFEncSetTransparent(agifencPtr, 0)
        
        // set writer
        QAGIFEncSetWriteFunc(agifencPtr, 2)
        // set dither
        QAGIFEncSetDither(agifencPtr, 1)
        
        // set task nb
        QAGIFEncSetMaxTaskTP(agifencPtr, 4)
        
        // set agif encoding file name
        var ret = QAGIFEncStart(agifencPtr, buffer)
        
        let wdt:Int32 = Int32(saveArr1.first!.size.width)
        let hgt:Int32 = Int32(saveArr1.first!.size.height)
        
        let qbite = UnsafeMutablePointer<QBYTE>.alloc( Int(wdt*hgt*4) )
        
        
        for var i=0;i<saveArr1.count;i++ {
            //arr의 uiimage를 버퍼에 담아 전달
            let image = saveArr1[i] as UIImage
            let cgImage = image.CGImage
            
            let width = Int(image.size.width)
            let height = Int(image.size.height)
            let bitsPerComponent = 8 // 2
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            
            let colorSpace = CGColorSpaceCreateDeviceRGB() // 3
            var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
            bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
            
            let imageContext = CGBitmapContextCreate(qbite, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
            
            
            CGContextDrawImage(imageContext, CGRect(origin: CGPointZero, size: image.size), cgImage)
            
            QAGIFEncAddFrameFast(agifencPtr, qbite, BITMAP_FORMAT_RGBA_8888, wdt,hgt);
            
        }
        
        QAGIFEncFinish(agifencPtr, 1)
        
        
    }
    
    
    
    
    func make(photoDataArr:[UIImage], delayTime:Float, gifPath:String, workFolder:String,filter:CIFilter?) {
        let fileManager = NSFileManager.defaultManager()
        
//        print("imga count ",photoDataArr.count)
//        print("delay Time : ",delayTime)
        let ghostPath = String(format: "%@/ghost.jpg", arguments: [workFolder])
        if fileManager.fileExistsAtPath(ghostPath) {
//            print("have ghost")
            
            var ghost_img = UIImage(contentsOfFile: ghostPath)
            
            if filter != nil {
                applyFilter(&ghost_img!, filter: filter!)
            }
            
            var saveArr = photoDataArr
            
            for var i=0;i<photoDataArr.count;i++ {
                var bottomImage = photoDataArr[i]
                let size = bottomImage.size
                
                if filter != nil {
                    applyFilter(&bottomImage, filter: filter!)
                }
                
                UIGraphicsBeginImageContext(size)
                
                let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                bottomImage.drawInRect(areaSize)
                
                ghost_img!.drawInRect(areaSize, blendMode: CGBlendMode.Multiply, alpha: Config.getInstance().ghostAlpha)
                
                let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                saveArr[i] = newImage
            }
            
            let regift_photo: Regift_photo = Regift_photo(sourceArray: saveArr, delayTime: delayTime)
            
            let output = regift_photo.createGif()
//            print("output ",output?.path)
            
            do {
                try fileManager.copyItemAtPath((output?.path)!, toPath: gifPath)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
            
        } else {
            
            let regift_photo: Regift_photo = Regift_photo(sourceArray: photoDataArr, delayTime: delayTime)
            
            let output = regift_photo.createGif()
//            print("output ",output?.path)
            
            do {
                try fileManager.copyItemAtPath((output?.path)!, toPath: gifPath)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
    
    
    func applyFilter(inout image:UIImage, filter:CIFilter) {
        filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        let ctx = CIContext(options:nil)
        let outputImage = ctx.createCGImage(filter.outputImage!, fromRect:filter.outputImage!.extent)
        image = UIImage(CGImage: outputImage)
    }
    
    
}

extension UIImage {
    
    
    public func resizeImage(targetSize: CGSize) -> UIImage {
//        print("targetSize ",targetSize)
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        
        
        
        
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(widthRatio*self.size.width, widthRatio*self.size.height)
        } else {
            newSize = CGSizeMake(heightRatio*self.size.width, heightRatio*self.size.height)
        }
//        print("newSize ",newSize)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, targetSize.width, targetSize.height)
        
//        print("newSize ",newSize," image size ",self.size)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    public func cropToBounds(width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: self.CGImage!)
        
//        print("contextImage ",contextImage.size.width,"x",contextImage.size.height)
        
        let contextSize: CGSize = contextImage.size
        
//        print("contextSize ",contextSize)
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        posX = (contextSize.width - cgwidth) / 2
        posY = (contextSize.height - cgheight) / 2
        
        // See what size is longer and create the center off of that
        
        if Config.getInstance().videoRatio == "1:1" {
            if contextSize.width > contextSize.height {
//                print("aaaaaaaaaaaa")
                posX = ((contextSize.width - contextSize.height) / 2)
                posY = 0
                cgwidth = contextSize.height
                cgheight = contextSize.height
            } else {
//                print("bbbbbbbbbbbbbb")
                posX = 0
                posY = ((contextSize.height - contextSize.width) / 2)
                cgwidth = contextSize.width
                cgheight = contextSize.width
            }
        } else {
            if contextSize.width > contextSize.height {
//                print("ccccccccccccc")
                cgwidth = contextSize.height*4/3
                cgheight = contextSize.height
                
                posX = ((contextSize.width - cgwidth) / 2)
                posY = 0
                
            } else {
//                print("ddddddddddddddd")
                cgwidth = contextSize.width
                cgheight = contextSize.width * 4/3
                
                posX = 0
                posY = ((contextSize.height - cgheight) / 2)
            }
        }
        
        
//        print(posX," ",posY," ",cgwidth," ",cgheight)
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
//        let rect: CGRect = CGRectMake(0, 0, cgwidth, cgheight)
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        //let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)!
        
        
        let _scale = self.scale
        let _orientation = self.imageOrientation
//        print(_scale, "  ", _orientation ,"  ")
        
        let image:UIImage = UIImage(CGImage: imageRef, scale: _scale, orientation: _orientation)
//        print("image size ",image.size)
//        print("image   ",image)
        return image
    }
    
}
