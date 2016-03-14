//
//  SettingProfileChangeViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 3..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingProfileChangeViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var loading: UIActivityIndicatorView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var photolibarary: UIButton!
    @IBOutlet weak var camera: UIButton!
    var uploadImage : UIImage!
    var imageToggle : Bool = false
    @IBOutlet weak var completeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.appdelegate.ment["settings_public_setting_change_profile"].stringValue
        completeButton.setTitle(self.appdelegate.ment["complete"].stringValue, forState: .Normal)
        

        loading.hidden = true
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        // Do any additional setup after loading the view.
    }
    
    func backToMyFeed(){
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func libarary(sender: AnyObject) {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else {
            let alertCamera = UIAlertView(title: "", message: "해당 디바이스에 카메라가 없습니다.", delegate:self, cancelButtonTitle: "확인")
            alertCamera.show()
        }
        
    }
    @IBAction func camera(sender: AnyObject) {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else {
            let alertCamera = UIAlertView(title: "", message: "해당 디바이스에 카메라가 없습니다.", delegate:self, cancelButtonTitle: "확인")
            alertCamera.show()
        }
    }

    @IBAction func complete(sender: AnyObject) {
        if self.imageToggle {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let date = NSDate()
            let currentdate = formatter.stringFromDate(date)
            let filename = "\(self.appdelegate.email)_\(currentdate).jpg"
//            print(filename)
            if self.profileImage.image != nil {
                myImageUploadRequest(self.profileImage.image!, filename: filename)
            }else {
                myImageUploadRequest(nil, filename: "noprofile.png")
            }
    }
    
    
        
    }
    
    func myfeed(filename : String){
        let message : JSON = ["myId":self.appdelegate.email,"url":filename]
//        let connection = URLConnection(serviceCode: 207, message: message)
//        let readData = connection.connection()
        self.appdelegate.doIt(207, message: message) { (readData) -> () in
            if readData["msg"].string! == "success" {
                let alert = UIAlertView(title: self.appdelegate.ment["settings_public_setting_change_profile"].stringValue, message: self.appdelegate.ment["profile_complete"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                alert.show()
            }else {
                let alert = UIAlertView(title: self.appdelegate.ment["settings_public_setting_change_profile"].stringValue, message: self.appdelegate.ment["profile_tryagain"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                alert.show()
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.uploadImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        profileImage.contentMode = .ScaleAspectFit
        profileImage.image = convert_profile_picture(self.uploadImage)
        self.imageToggle = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if viewController == self.appdelegate.myfeed {
            self.navigationController?.navigationBarHidden = true
        }
    }
    
    
    func convert_profile_picture(image: UIImage) -> UIImage {
        
        var image2:UIImage = cropToBounds(image, width: 1024,height: 1024)
        if(image.imageOrientation == UIImageOrientation.Right) {
            image2 = image2.imageRotatedByDegrees1(90.0)
            //print("image right")
        } else if(image.imageOrientation == UIImageOrientation.Left) {
            image2 = image2.imageRotatedByDegrees1(-90.0)
            //print("image left")
        } else if(image.imageOrientation == UIImageOrientation.Up) {
//            image2 = image2.imageRotatedByDegrees1(180.0)
            //print("image up")
        } else if(image.imageOrientation == UIImageOrientation.Down) {
            //print("image down")
        }
        
        if(true) {
            //return image2;
        }
        
        //        let size = CGSize(width: 1024, height: 1024)
        //        let image4: UIImage = resizeImage(image2, targetSize: size)
        
        return image2
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(heightRatio, heightRatio)
        } else {
            newSize = CGSizeMake(widthRatio,  widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, targetSize.width, targetSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        //let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)!
        
        let image:UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    

}


extension SettingProfileChangeViewController : UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            self.appdelegate.window?.rootViewController = self.appdelegate.contentview
        }
    }
}



extension SettingProfileChangeViewController {
    func myImageUploadRequest(image: UIImage!, filename : String)
    {
        var state = false
        var imageData : NSData!
        if image != nil {
            imageData = UIImageJPEGRepresentation(image, 1)!
        }else {
            let imageURL = ImageURL()
            let url = NSURL(string: imageURL.imageurl("noprofile.png"))
            let data = NSData(contentsOfURL: url!)
            imageData = data
        }
        
        if(imageData==nil)  { return; }
//        NSLog("image data OK")
        let myUrl = NSURL(string: "http://gif.picpic.world/uploadToServerForPicPic.php");
        //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
        
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        NSLog("Yes")
        
        
        
        request.HTTPBody = createBodyWithParameters(nil, filePathKey: "uploaded_file", imageDataKey: imageData!, boundary: boundary,filename: filename)
        
        self.loading.hidden = false
        self.loading.startAnimating()
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
//                print("error=\(error)")
                return
            }
            
            // You can print out response object
//            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("****** response data = \(responseString!)")
            
            
            state = true
            if state {
                self.loading.stopAnimating()
                self.loading.hidden = true
                self.myfeed(filename)
            }
            
            var err: NSError?
            do {
                var json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            }catch{
//                print(error)
            }
            
            /*
            if let parseJSON = json {
            var firstNameValue = parseJSON["firstName"] as? String
            println("firstNameValue: \(firstNameValue)")
            }
            */
            
        }
        task.resume()
//        print("imageupload??")
    }
    
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String,filename:String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
//        NSLog("body")
        return body
    }
}
