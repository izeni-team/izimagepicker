//
//  ViewController.swift
//  IZImagePicker
//
//  Created by Izeni on 07/27/2016.
//  Copyright (c) 2016 Izeni. All rights reserved.
//

import UIKit
import IZImagePicker

class ViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        IZImagePicker.pickImage(vc: self, useCamera: true, useLibrary: true, preferFrontCamera: false, iPadPopoverSource: view, aspectRatio: 1, callback: { (image) in
            self.image.image = image
            }) { 
                print("CANCELD")
        }
    }

}

