//
//  AddProductViewController.swift
//  TESTIBMSPEECH
//
//  Created by Artemiy Galkin on 11/13/16.
//  Copyright © 2016 Artemiy Galkin. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AddProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var chooseImgBtn: UIButton!
    let imagePicker = UIImagePickerController()
    var image: UIImage?
    var currentDay: String!
    
    @IBAction func chooseImgBtnPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Image Source", message: "Please select the image source.", preferredStyle: .alert)
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action: UIAlertAction) in
            
            guard PHPhotoLibrary.authorizationStatus() == .authorized else {
                PHPhotoLibrary.requestAuthorization {status in
                    if status == .authorized {
                        DispatchQueue.main.async {
                            self.showCameraController(sourceType: .photoLibrary)
                        }
                    } else {
                        self.displayAlert(controller: self, title: "No gallery available", message: "Please authorize access to the photo gallery")
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                self.showCameraController(sourceType: .photoLibrary)
            }
        }
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (action: UIAlertAction) in
            
            guard AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized else {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            self.showCameraController(sourceType: .camera)
                        }
                    } else {
                        self.displayAlert(controller: self, title: "No camera available", message: "Please authorize access to the camera")
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                self.showCameraController(sourceType: .camera)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(photoLibrary)
        alertController.addAction(camera)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func displayAlert(controller: UIViewController, title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        controller.present(alertController, animated: true, completion: nil)
        
    }
    
    func showCameraController(sourceType: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        
        self.present(picker, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chooseImgBtn.layer.cornerRadius = 5
        self.imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = pickedImage
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goto_confirmadd", sender: self)
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goto_confirmadd"){
            let secondViewController = segue.destination as! ConfirmProductViewController
            secondViewController.image = self.image
            secondViewController.currentDay = self.currentDay
        }
        
    }
    
}
