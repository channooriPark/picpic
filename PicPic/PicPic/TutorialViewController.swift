//
//  TutorialViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 8..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var coment: UILabel!
    @IBOutlet weak var gifImage: UIImageView!
    
    var gifFileName : String!
    var comentText : String!
    
    var imageFileName : String!
    var pageIndex : Int!
    @IBOutlet weak var gifImageWid: NSLayoutConstraint!
    
    @IBOutlet weak var textViewSpace: NSLayoutConstraint!
    @IBOutlet weak var gifImageSpace: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("",self.view.frame.size.width)
        if self.view.frame.size.width == 320.0 {
            
        }else if self.view.frame.size.width == 375.0 {
            textViewSpace.constant = 100
            coment.font = UIFont(name: "Helvetica", size: 22)
        }else {
            textViewSpace.constant = 120
            gifImageSpace.constant = 230
            coment.font = UIFont(name: "Helvetica", size: 23)
        }
        gifImageWid.constant = self.view.frame.size.width
        ImageView.image = UIImage(named: imageFileName)
        gifImage.image = UIImage.gifWithName(gifFileName)
        coment.text = comentText
        
        print("font ",coment)
        print("space ",textViewSpace.constant)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
