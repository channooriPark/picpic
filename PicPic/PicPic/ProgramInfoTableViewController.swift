//
//  ProgramInfoTableViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 4..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class ProgramInfoTableViewController: UITableViewController {

    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var personprotected: UILabel!
    @IBOutlet weak var policyLabel: UILabel!
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.appdelegate.ment["settings_program_info"].stringValue
        
        serviceLabel.text = self.appdelegate.ment["settings_program_info_service_agreement"].stringValue
        personprotected.text = self.appdelegate.ment["settings_program_info_privacy_policy"].stringValue
        policyLabel.text = self.appdelegate.ment["settings_program_info_operational_policy"].stringValue
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
