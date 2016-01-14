//
//  GenderViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 9..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class GenderViewController: UIViewController {

    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var femaileButton: UIButton!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var checkGender : Bool = false
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var imageHei: NSLayoutConstraint!
    
    @IBOutlet weak var textSpace: NSLayoutConstraint!
    @IBOutlet weak var genderSpace: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.view.frame.size.width == 320.0 {
            
        }else if self.view.frame.size.width == 375.0 {
            imageHei.constant = 260
            genderSpace.constant = 20
            textSpace.constant = 20
        }else {
            imageHei.constant = 260
            genderSpace.constant = 20
            textSpace.constant = 20
        }
        
        
        gender.text = self.appdelegate.ment["join_sex"].stringValue
        nextButton.setTitle(self.appdelegate.ment["join_next"].stringValue, forState: .Normal)
        nextButton.enabled=false
        nextButton.setTitleColor(UIColor(netHex: 0xb9b0ff), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func femaileSelected(sender: AnyObject) {
        femaileButton.setImage(UIImage(named: "icon_join_female_c"), forState: UIControlState.Normal)
        mailButton.setImage(UIImage(named: "icon_join_male"), forState: UIControlState.Normal)
        self.appdelegate.userData["sex"].string = "W"
        checkGender = true
        nextButton.enabled = true
    }
    
    
    @IBAction func maleSelected(sender: AnyObject) {
        mailButton.setImage(UIImage(named: "icon_join_male_c"), forState: UIControlState.Normal)
        femaileButton.setImage(UIImage(named: "icon_join_female"), forState: UIControlState.Normal)
        self.appdelegate.userData["sex"].string = "M"
        checkGender = true
        nextButton.enabled = true
        nextButton.setTitleColor(UIColor(colorLiteralRed: 0.41, green: 0.50, blue: 1.0, alpha: 1.0), forState: .Normal)
    }
    @IBAction func NextStep(sender: AnyObject) {
        if checkGender {
            self.performSegueWithIdentifier("GoToUsername", sender: self)
        }
        
    }
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    

    }
