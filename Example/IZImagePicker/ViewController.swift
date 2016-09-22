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
        NSLog("ViewController.viewDidLoad: %p", self)
        IZImagePicker.pickImage(vc: self, useCamera: true, useLibrary: true, preferFrontCamera: false, iPadPopoverSource: view, aspectRatio: 1, callback: { (image) in
            print("Got image")
            self.image.image = image
        }) {
            print("CANCEL")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

}

