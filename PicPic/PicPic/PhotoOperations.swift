//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by Richard Turton on 17/04/2015.
//  Copyright (c) 2015 raywenderlich. All rights reserved.
//

import Foundation
import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
  case New, Downloaded, Failed
}

enum Type {
    case interest,Timeline
}

class PhotoRecord {
//    let url:NSURL
    let p_url:NSURL
    let type : Type
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    var gif = UIImage(named: "Placeholder")
    var profile = UIImage(named: "Placeholder")
    var images = [UIImage(named: "Placeholder")]
    var imageurls = [NSURL]()
    
    init(type:Type,p_url:NSURL) {
        self.type = type
        self.p_url = p_url
  }
}

class PendingOperations {
  lazy var downloadsInProgress = Dictionary<NSIndexPath, NSOperation>()
  lazy var downloadQueue:NSOperationQueue = {
    var queue = NSOperationQueue()
    queue.name = "Download queue"
    queue.maxConcurrentOperationCount = 1
    return queue
    }()
  
  lazy var filtrationsInProgress = Dictionary<NSIndexPath, NSOperation>()
  lazy var filtrationQueue:NSOperationQueue = {
    var queue = NSOperationQueue()
    queue.name = "Image Filtration queue"
    queue.maxConcurrentOperationCount = 1
    return queue
    }()
}

class ImageDownloader: NSOperation {
  //1
  let photoRecord: PhotoRecord
  
  //2
  init(photoRecord: PhotoRecord) {
    self.photoRecord = photoRecord
  }
  
  //3
  override func main() {
    //4
    if self.cancelled {
      return
    }
    //5
//    let imageData = NSData(contentsOfURL:self.photoRecord.url)
    let profileData = NSData(contentsOfURL: self.photoRecord.p_url)
    //6
    if self.cancelled {
      return
    }
    
    
    
    if self.photoRecord.imageurls.count > 0 {
        if self.photoRecord.type == Type.interest {
            for var i = 0; i<6; i++ {
                if let data = NSData(contentsOfURL: self.photoRecord.imageurls[i]){
                    self.photoRecord.images[i] = UIImage.gifWithData(data)!
                }
                
            }
        }else {
            for var i = 0; i<self.photoRecord.imageurls.count; i++ {
                if let data = NSData(contentsOfURL: self.photoRecord.imageurls[i]){
                    self.photoRecord.images[i] = UIImage.gifWithData(data)!
                }
                
            }
        }
        
    }
    
    //7
        if profileData?.length > 0 {
            self.photoRecord.profile = UIImage(data: profileData!)
            self.photoRecord.state = .Downloaded
    }
    else
    {
      self.photoRecord.state = .Failed
      self.photoRecord.image = UIImage(named: "Failed")
    }
  }
}

class ImageFiltration: NSOperation {
  let photoRecord: PhotoRecord
  
  init(photoRecord: PhotoRecord) {
    self.photoRecord = photoRecord
  }
  
  override func main () {
    if self.cancelled {
      return
    }
    
    if self.photoRecord.state != .Downloaded {
      return
    }
    
  }
  
  func applySepiaFilter(image:UIImage) -> UIImage? {
    let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
    
    if self.cancelled {
      return nil
    }
    let context = CIContext(options:nil)
    let filter = CIFilter(name:"CISepiaTone")
    filter!.setValue(inputImage, forKey: kCIInputImageKey)
    filter!.setValue(0.8, forKey: "inputIntensity")
    let outputImage = filter!.outputImage
    
    if self.cancelled {
      return nil
    }
    
    let outImage = context.createCGImage(outputImage!, fromRect: outputImage!.extent)
    let returnImage = UIImage(CGImage: outImage)
    return returnImage
  }
}

