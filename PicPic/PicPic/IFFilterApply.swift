//
//  IFFilterApply.swift
//  filter3
//
//  Created by Changho Kim on 2015. 12. 7..
//  Copyright © 2015년 byKim. All rights reserved.
//

import Foundation

class IFFilterApply : GPUImageOutput1 {
    var rawImage:UIImage?
    var stillImageSource:GPUImagePicture1?
    
    var filter:IFImageFilter = IFNormalFilter()
    var sourcePicture1:GPUImagePicture1?
    var sourcePicture2:GPUImagePicture1?
    var sourcePicture3:GPUImagePicture1?
    var sourcePicture4:GPUImagePicture1?
    var sourcePicture5:GPUImagePicture1?
    
    var internalFilter:IFImageFilter = IFNormalFilter()
    var internalSourcePicture1:GPUImagePicture1?
    var internalSourcePicture2:GPUImagePicture1?
    var internalSourcePicture3:GPUImagePicture1?
    var internalSourcePicture4:GPUImagePicture1?
    var internalSourcePicture5:GPUImagePicture1?
    
    
    
    func apply(inout image:UIImage, filterName:String) {
        //self.rotationFilter.removeTarget(self.filter)
        self.stillImageSource = GPUImagePicture1(image: self.rawImage)
        self.stillImageSource?.addTarget(self.filter)
        
        print("before apply filter ",self.stillImageSource)
    
       
        setupFilterName(filterName)
        
        self.filter = self.internalFilter
        
        self.stillImageSource?.addTarget(self.filter)

        
        if(self.internalSourcePicture1 != nil) {
            self.sourcePicture1 = self.internalSourcePicture1
            self.sourcePicture1?.addTarget(self.filter)
        }
        if(self.internalSourcePicture2 != nil) {
            self.sourcePicture2 = self.internalSourcePicture2
            self.sourcePicture2?.addTarget(self.filter)
        }
        if(self.internalSourcePicture3 != nil) {
            self.sourcePicture3 = self.internalSourcePicture3
            self.sourcePicture3?.addTarget(self.filter)
        }
        if(self.internalSourcePicture4 != nil) {
            self.sourcePicture4 = self.internalSourcePicture4
            self.sourcePicture4?.addTarget(self.filter)
        }
        if(self.internalSourcePicture5 != nil) {
            self.sourcePicture5 = self.internalSourcePicture5
            self.sourcePicture5?.addTarget(self.filter)
        }
        
        //print(self.stillImageSource
        
//        self.sourcePicture2 = self.internalSourcePicture2
//        self.sourcePicture3 = self.internalSourcePicture3
//        
//        self.sourcePicture1?.addTarget(self.filter)
//        self.sourcePicture2?.addTarget(self.filter)
//        self.sourcePicture3?.addTarget(self.filter)
        
        self.stillImageSource?.processImage()
        
        image = self.filter.imageFromCurrentlyProcessedOutput()
        
//        let _filter = GPUImageRotationFilter1(rotation: kGPUImageRotateRight1)
//        image = _filter.imageByFilteringImage(image)
        image = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: .Up)
        
        print("after apply filter ",image)
    }
    
    func setupFilterName(filterName:String) {
        if(filterName == "I_AMARO") {
            self.internalFilter = IFAmaroFilter()
            
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "blackboard1024.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "overlayMap.png"))
            self.internalSourcePicture3 = GPUImagePicture1(image: UIImage(named: "amaroMap.png"))
        } else if(filterName == "I_HEFE") {
            self.internalFilter = IFHefeFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "edgeBurn.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "hefeMap.png"))
            self.internalSourcePicture3 = GPUImagePicture1(image: UIImage(named: "hefeGradientMap.png"))
            self.internalSourcePicture4 = GPUImagePicture1(image: UIImage(named: "hefeSoftLight.png"))
            self.internalSourcePicture5 = GPUImagePicture1(image: UIImage(named: "hefeMetal.png"))
        } else if(filterName == "I_NASHVILLE") {
            self.internalFilter = IFNashvilleFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "nashvilleMap"))
        } else if(filterName == "I_SIERRA") {
            self.internalFilter = IFSierraFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "sierraVignette.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "overlayMap.png"))
            self.internalSourcePicture3 = GPUImagePicture1(image: UIImage(named: "sierraMap.png"))
        } else if(filterName == "I_INKWELL") {
            self.internalFilter = IFInkwellFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "inkwellMap.png"))
        } else if(filterName == "I_VALENCIA") {
            self.internalFilter = IFValenciaFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "valenciaMap.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "valenciaGradientMap.png"))
        } else if(filterName == "I_WALDEN") {
            self.internalFilter = IFWaldenFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "waldenMap.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "vignetteMap.png"))
        } else if(filterName == "I_XPROII") {
            self.internalFilter = IFXproIIFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "xproMap.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "vignetteMap.png"))
        } else if(filterName == "I_BRANNAN") {
            self.internalFilter = IFBrannanFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "brannanProcess.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "brannanBlowout.png"))
            self.internalSourcePicture3 = GPUImagePicture1(image: UIImage(named: "brannanContrast.png"))
            self.internalSourcePicture4 = GPUImagePicture1(image: UIImage(named: "brannanLuma.png"))
            self.internalSourcePicture5 = GPUImagePicture1(image: UIImage(named: "brannanScreen.png"))
        } else if(filterName == "I_EARLYBIRD") {
            self.internalFilter = IFEarlybirdFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "earlyBirdCurves.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "earlybirdOverlayMap.png"))
            self.internalSourcePicture3 = GPUImagePicture1(image: UIImage(named: "vignetteMap.png"))
            self.internalSourcePicture4 = GPUImagePicture1(image: UIImage(named: "earlybirdBlowout.png"))
            self.internalSourcePicture5 = GPUImagePicture1(image: UIImage(named: "earlybirdMap.png"))
        } else if(filterName == "I_HUDSON") {
            self.internalFilter = IFHudsonFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "hudsonBackground.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "overlayMap.png"))
            self.internalSourcePicture3 = GPUImagePicture1(image: UIImage(named: "hudsonMap.png"))
        } else if(filterName == "I_LOMO") {
            self.internalFilter = IFLomofiFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "lomoMap.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "vignetteMap.png"))
        } else if(filterName == "I_TOASTER") {
            self.internalFilter = IFToasterFilter()
            self.internalSourcePicture1 = GPUImagePicture1(image: UIImage(named: "toasterMetal.png"))
            self.internalSourcePicture2 = GPUImagePicture1(image: UIImage(named: "toasterSoftLight.png"))
            self.internalSourcePicture3 = GPUImagePicture1(image: UIImage(named: "toasterCurves.png"))
            self.internalSourcePicture4 = GPUImagePicture1(image: UIImage(named: "toasterOverlayMapWarm.png"))
            self.internalSourcePicture5 = GPUImagePicture1(image: UIImage(named: "toasterColorShift.png"))
        }
    }

}
