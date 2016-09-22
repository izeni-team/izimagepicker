//
//  IZImagePicker.swift
//  Pods
//
//  Created by Taylor Allred on 7/28/16.
//
//

import AVFoundation
import Photos
import TOCropViewController

open class IZImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    fileprivate static var currentInstance: IZImagePicker?
    
    fileprivate var parentVC: UIViewController!
    fileprivate var aspectRatio: CGFloat!
    fileprivate var preferFrontCamera: Bool = false
    fileprivate var cameraEnabled: Bool = true
    fileprivate var libraryEnabled: Bool = true
    
    fileprivate var popoverSource: UIView! //iPad
    
    fileprivate var callback: ((_ image: UIImage) -> Void)! // This is required
    fileprivate var cancelled: (() -> Void)? // This is not required
    
    fileprivate var cameraPermissionGranted: Bool {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
    }
    
    fileprivate var libraryPermissionGranted: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    fileprivate var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    fileprivate var isLibraryAvaiable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    fileprivate var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    fileprivate override init() {}
    
    open static func pickImage(vc: UIViewController, useCamera: Bool = true, useLibrary: Bool = true, preferFrontCamera: Bool = true, iPadPopoverSource: UIView, aspectRatio: CGFloat = 1, callback: @escaping (_ image: UIImage) -> Void, cancelled: (() -> Void)? = nil) {
        assert(currentInstance == nil, "You can't pick two images at the same time. Wait for the other picker to close first.")
        guard currentInstance == nil else {
            cancelled?()
            return
        }
        
        let newImagePicker = IZImagePicker()
        currentInstance = newImagePicker
        newImagePicker.pickImage(vc: vc, useCamera: useCamera, useLibrary: useLibrary, preferFrontCamera: preferFrontCamera, iPadPopoverSource: iPadPopoverSource, aspectRatio: aspectRatio)
        newImagePicker.callback = callback
        newImagePicker.cancelled = cancelled
    }
    
    fileprivate func pickImage(vc: UIViewController, useCamera: Bool, useLibrary: Bool, preferFrontCamera: Bool, iPadPopoverSource: UIView, aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
        self.popoverSource = iPadPopoverSource
        self.preferFrontCamera = preferFrontCamera
        self.cameraEnabled = useCamera
        self.libraryEnabled = useLibrary
        parentVC = vc
        
        showPickerSourceAlert()
    }
    
    // MARK: - Camera Action
    
    fileprivate func takePhoto() {
        if cameraPermissionGranted {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera //Defaults to .PhotoLibrary
            if preferFrontCamera && UIImagePickerController.isCameraDeviceAvailable(.front) {
                picker.cameraDevice = .front
            }
            show(picker)
        } else {
            requestCameraPermission()
        }
    }
    
    // MARK: - Library Action
    
    fileprivate func pickLibraryPhoto() {
        if libraryPermissionGranted {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            show(picker)
        } else {
            requestLibraryPermission()
        }
    }
    
    //MARK: - Permissions
    
    fileprivate func requestCameraPermission() {
        var authorization = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if !isCameraAvailable {
            authorization = .restricted
        }
        switch authorization {
        case .denied:
            deniedAlert(accessType: "Camera")
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { _ in
                DispatchQueue.main.async(execute: { 
                    self.takePhoto()
                })
            })
        default: break
        }
    }
    
    fileprivate func requestLibraryPermission() {
        var authorization = PHPhotoLibrary.authorizationStatus()
        if !isLibraryAvaiable {
            authorization = .restricted
        }
        
        switch authorization {
        case .denied:
            deniedAlert(accessType: "Photo Library")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (allow) in
                DispatchQueue.main.async(execute: { 
                    self.pickLibraryPhoto()
                })
            })
        default: break
        }
    }
    
    // MARK: - Alerts
    
    fileprivate func show(_ vc: UIViewController) {
        DispatchQueue.main.async { 
            let alert = vc as? UIAlertController
            NSLog("(5) %p", alert ?? NSNull())
            if self.isIpad && alert?.preferredStyle == .actionSheet {
                let popover = UIPopoverController(contentViewController: vc)
                popover.present(from: self.popoverSource.bounds, in: self.popoverSource, permittedArrowDirections: .any, animated: true)
            } else {
                self.parentVC.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func showPickerSourceAlert() {
        let alert = UIAlertController()
        NSLog("(4) %p", alert)
        
        if isCameraAvailable && cameraEnabled {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                self.takePhoto()
            }))
        }
        
        if isLibraryAvaiable && libraryEnabled {
            alert.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
                self.pickLibraryPhoto()
            }))
        }
        
        if alert.actions.count == 1 {
            if cameraEnabled {
                takePhoto()
            } else {
                pickLibraryPhoto()
            }
        } else if alert.actions.count == 2 {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.didCancel()
            }))
            show(alert)
        } else {
            restrictedAlert(accessType: "Camera and Photo Library")
        }
    }
    
    fileprivate func restrictedAlert(accessType: String) {
        let authAlert = UIAlertController(title: "\(accessType) Access is Restricted", message: "\(getAppName()) could not access the \(accessType) on this device.", preferredStyle: .alert)
        NSLog("(3) %p", authAlert)
        authAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.didCancel()
        }))
        show(authAlert)
    }
    
    fileprivate func deniedAlert(accessType: String) {
        let authAlert = UIAlertController(title: "\(accessType) Access is Denied", message: "\(getAppName()) does not have access to your \(accessType). You can enable access in privacy settings.", preferredStyle: .alert)
        NSLog("(2) %p", authAlert)
        authAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(authAlert)
    }
    
    //MARK: - Helpers
    
    fileprivate func getAppName() -> String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    
    //MARK: - Cropper
    fileprivate func presentCropViewController(_ image: UIImage) {
        let cropViewController = TOCropViewController(croppingStyle: .circular, image: image)
        cropViewController?.delegate = self
        self.parentVC.present(cropViewController!, animated: true, completion: nil)
    }
    
    public func cropViewController(_ cropViewController: TOCropViewController!, didCropToCircularImage image: UIImage!, with cropRect: CGRect, angle: Int) {
        self.callback(image)
        cropViewController.dismiss(animated: true, completion: nil)
        IZImagePicker.currentInstance = nil
    }
    
    fileprivate func didCancel() {
        cancelled?()
        IZImagePicker.currentInstance = nil
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            presentCropViewController(image)
        }
    }
    
    open func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        didCancel()
    }
}
