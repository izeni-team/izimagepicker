# IZImagePicker

<!--[![CI Status](http://img.shields.io/travis/Izeni/IZImagePicker.svg?style=flat)](https://travis-ci.org/Izeni/IZImagePicker)
[![Version](https://img.shields.io/cocoapods/v/IZImagePicker.svg?style=flat)](http://cocoapods.org/pods/IZImagePicker)
[![License](https://img.shields.io/cocoapods/l/IZImagePicker.svg?style=flat)](http://cocoapods.org/pods/IZImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/IZImagePicker.svg?style=flat)](http://cocoapods.org/pods/IZImagePicker) -->

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To use IZImagePicker:

```
class MyViewController: UIViewController {
   ...
   @IBAction func changeProfileImageTapped() {
       IZImagePicker.pickImage(vc: self, useCamera: true, useLibrary: true, preferFrontCamera: true, iPadPopoverSource: view, aspectRatio: 1, callback: { (image) in
            self.uploadProfileImage(image)
            })
   }
   ...
}
```

## Requirements

Currently none.

## Installation

IZImagePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "IZImagePicker"
```

## Author

Izeni, iznei.com, tallred@izeni.com

## License

IZImagePicker is available under the MIT license. See the LICENSE file for more info.
