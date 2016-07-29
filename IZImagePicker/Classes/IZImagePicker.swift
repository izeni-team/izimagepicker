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

public class IZImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    private static var currentInstance: IZImagePicker?
    
    private var parentVC: UIViewController!
    private var aspectRatio: CGFloat!
    private var preferFrontCamera: Bool = false
    private var cameraEnabled: Bool = true
    private var libraryEnabled: Bool = true
    
    private var popoverSource: UIView! //iPad
    
    private var callback: ((image: UIImage) -> Void)! // This is required
    private var cancelled: (() -> Void)? // This is not required
    
    private var cameraPermissionGranted: Bool {
        return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized
    }
    
    private var libraryPermissionGranted: Bool {
        return PHPhotoLibrary.authorizationStatus() == .Authorized
    }
    
    private var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    private var isLibraryAvaiable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
    }
    
    private var isIpad: Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
    private override init() {}
    
    public static func pickImage(vc vc: UIViewController, useCamera: Bool = true, useLibrary: Bool = true, preferFrontCamera: Bool = true, iPadPopoverSource: UIView, aspectRatio: CGFloat = 1, callback: (image: UIImage) -> Void, cancelled: (() -> Void)? = nil) {
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
    
    private func pickImage(vc vc: UIViewController, useCamera: Bool, useLibrary: Bool, preferFrontCamera: Bool, iPadPopoverSource: UIView, aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
        self.popoverSource = iPadPopoverSource
        self.preferFrontCamera = preferFrontCamera
        self.cameraEnabled = useCamera
        self.libraryEnabled = useLibrary
        parentVC = vc
        
        showPickerSourceAlert()
    }
    
    // MARK: - Camera Action
    
    private func takePhoto() {
        if cameraPermissionGranted {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .Camera //Defaults to .PhotoLibrary
            if preferFrontCamera && UIImagePickerController.isCameraDeviceAvailable(.Front) {
                picker.cameraDevice = .Front
            }
            show(picker)
        } else {
            requestCameraPermission()
        }
    }
    
    // MARK: - Library Action
    
    private func pickLibraryPhoto() {
        if libraryPermissionGranted {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .PhotoLibrary
            show(picker)
        } else {
            requestLibraryPermission()
        }
    }
    
    //MARK: - Permissions
    
    private func requestCameraPermission() {
        var authorization = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if !isCameraAvailable {
            authorization = .Restricted
        }
        switch authorization {
        case .Denied:
            deniedAlert("Camera")
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { _ in
                dispatch_async(dispatch_get_main_queue(), { 
                    self.takePhoto()
                })
            })
        default: break
        }
    }
    
    private func requestLibraryPermission() {
        var authorization = PHPhotoLibrary.authorizationStatus()
        if !isLibraryAvaiable {
            authorization = .Restricted
        }
        
        switch authorization {
        case .Denied:
            deniedAlert("Photo Library")
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization({ (allow) in
                dispatch_async(dispatch_get_main_queue(), { 
                    self.pickLibraryPhoto()
                })
            })
        default: break
        }
    }
    
    // MARK: - Alerts
    
    private func show(vc: UIViewController) {
        dispatch_async(dispatch_get_main_queue()) { 
            let alert = vc as? UIAlertController
            if self.isIpad && alert?.preferredStyle == .ActionSheet {
                let popover = UIPopoverController(contentViewController: vc)
                popover.presentPopoverFromRect(self.popoverSource.bounds, inView: self.popoverSource, permittedArrowDirections: .Any, animated: true)
            } else {
                self.parentVC.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    private func showPickerSourceAlert() {
        let alert = UIAlertController()
        if isCameraAvailable && cameraEnabled {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in
                self.takePhoto()
            }))
        }
        if isLibraryAvaiable && libraryEnabled {
            alert.addAction(UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in
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
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
                self.didCancel()
            }))
            show(alert)
        } else {
            restrictedAlert("Camera and Photo Library")
        }
    }
    
    private func restrictedAlert(accessType: String) {
        let authAlert = UIAlertController(title: "\(accessType) Access is Restricted", message: "\(getAppName()) could not access the \(accessType) on this device.", preferredStyle: .Alert)
        authAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in
            self.didCancel()
        }))
        show(authAlert)
    }
    
    private func deniedAlert(accessType: String) {
        let authAlert = UIAlertController(title: "\(accessType) Access is Denied", message: "\(getAppName()) does not have access to your \(accessType). You can enable access in privacy settings.", preferredStyle: .Alert)
        authAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        show(authAlert)
    }
    
    //MARK: - Helpers
    
    private func getAppName() -> String {
        return NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
    }
    
    //MARK: - Cropper
    private func presentCropViewController(image: UIImage) {
        let cropViewController = TOCropViewController(croppingStyle: .Circular, image: image)
        cropViewController.delegate = self
        self.parentVC.presentViewController(cropViewController, animated: true, completion: nil)
    }
    
    public func cropViewController(cropViewController: TOCropViewController!, didCropToCircularImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        //image is the new cropped image.
        self.callback(image: image)
        cropViewController.dismissViewControllerAnimated(true, completion: nil)
        IZImagePicker.currentInstance = nil
    }
    
    private func didCancel() {
        cancelled?()
        IZImagePicker.currentInstance = nil
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        presentCropViewController(image)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        didCancel()
    }
}