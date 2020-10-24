//
//  ViewController.swift
//  PhotoALbum
//
//  Created by Ravikiran Gajula (HLB) on 16/10/2020.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func showAlbum(_ sender: Any) {
        getImage(fromSourceType: .photoLibrary)
    }
    
    @IBOutlet weak var imagview3: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBAction func savePhot(_ sender: Any) {
        getImage(fromSourceType: .savedPhotosAlbum)
    }
    
    @IBAction func showNext(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { (status) in
            print("Status: \(status)")
            if status == .authorized {
                DispatchQueue.main.sync {
                    let vc = AlbumCollectionViewController()
                    vc.delegate = self
                    self.show(vc, sender: self)
                }
            } else if status == .denied {
                DispatchQueue.main.sync { self.showAlert() }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Permission Required", message: "Allow this app to access photos in settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Default action"), style: .default, handler: { _ in
            self.navigateToSettings()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func navigateToSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

extension ViewController: selectedImagesDelegate {
    
    func selectedImagesList(_ images: [PHAsset]) {
        let asset = images[0]
        self.imageView.fetchImageAsset(asset, targetSize: self.imageView.bounds.size, completionHandler: nil)
        let asset1 = images[1]
        self.imageView2.fetchImageAsset(asset1, targetSize: self.imageView.bounds.size, completionHandler: nil)
        let asset2 = images[2]
        self.imagview3.fetchImageAsset(asset2, targetSize: self.imageView.bounds.size, completionHandler: nil)
    }
    
}

