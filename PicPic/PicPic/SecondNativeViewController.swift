//
//  SecondNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 4..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SecondNativeViewController: UIViewController {

    @IBOutlet weak var followTabButton: UIButton!
    @IBOutlet weak var allTabButton: UIButton!
    @IBOutlet weak var categoryTabButton: UIButton!
    @IBOutlet weak var followTabEnableView: UIView!
    @IBOutlet weak var allTabEnableView: UIView!
    @IBOutlet weak var categoryTabEnableView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var postInfos: Array<[String: AnyObject]> = []
    var postGifData: [String: UIImage] = [:] {
        didSet{
            if postInfos.count == postGifData.count
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                    self._hud.hide(true)
                    self.collectionView.infiniteScrollingView.stopAnimating()
                })
            }
        }
    }
    var currentPage = "1"
    var _hud: MBProgressHUD = MBProgressHUD()
    let enabledColor = UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func followTabTouched() {
        self.followTabButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.allTabButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        self.categoryTabButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        
        self.followTabButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        self.allTabButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        self.categoryTabButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        
        self.followTabEnableView.backgroundColor = self.enabledColor
        self.allTabEnableView.backgroundColor = UIColor.whiteColor()
        self.categoryTabEnableView.backgroundColor = UIColor.whiteColor()
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mes = JSON(["my_id" : appdelegate.email, "page" : "1"])
        appdelegate.doIt(508, message: mes, callback: {(json) in
            print(json)
        })
    }
    
    @IBAction func allTabTouched(sender: AnyObject) {
        self.followTabButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        self.allTabButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.categoryTabButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        
        self.followTabButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        self.allTabButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        self.categoryTabButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        
        self.followTabEnableView.backgroundColor = UIColor.whiteColor()
        self.allTabEnableView.backgroundColor = self.enabledColor
        self.categoryTabEnableView.backgroundColor = UIColor.whiteColor()
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mes = JSON(["my_id" : appdelegate.email, "page" : "1"])
        appdelegate.doIt(521, message: mes, callback: {(json) in
            print(json)
        })
    }
    @IBAction func categoryTabTouched() {
        self.followTabButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        self.allTabButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        self.categoryTabButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        self.followTabButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        self.allTabButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        self.categoryTabButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        
        self.followTabEnableView.backgroundColor = UIColor.whiteColor()
        self.allTabEnableView.backgroundColor = UIColor.whiteColor()
        self.categoryTabEnableView.backgroundColor = self.enabledColor
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
