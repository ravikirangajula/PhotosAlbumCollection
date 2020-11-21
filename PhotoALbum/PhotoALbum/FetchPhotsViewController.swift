//
//  FetchPhotsViewController.swift
//  PhotoALbum
//
//  Created by Ravikiran Gajula (HLB) on 17/10/2020.
//

import UIKit
import Photos

extension AlbumCollectionViewController {

    
    func fetchAssets() {
        // 1
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
          NSSortDescriptor(
            key: "creationDate",
            ascending: false)
        ]
        // 2
        
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        // 3
        smartAlbums = PHAssetCollection.fetchAssetCollections(
          with: .smartAlbum,
          subtype: .albumRegular,
          options: nil)
        // 4
        userCollections = PHAssetCollection.fetchAssetCollections(
          with: .album,
          subtype: .albumRegular,
          options: nil)
        
        print("all count == \(allPhotos.count)")
        print("userCollections == \(userCollections.count)")
        print("smartAlbums == \(smartAlbums.count)")
    }
    

}

extension AlbumCollectionViewController: PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // 1
        guard let change = changeInstance.changeDetails(for: allPhotos) else {
          return
        }
        DispatchQueue.main.sync {
            allPhotos = change.fetchResultAfterChanges
            albumCollection.reloadData()
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if self.imagePicker.sourceType == .camera {
                guard let selectedImage = info[.originalImage] as? UIImage else {
                     print("Image not found!")
                     return
                 }
                UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(self.saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
                self.capturedImages.append(selectedImage)
                self.captureView.horizontalCollection.reloadData()
            }
    }
    
    //MARK: - Add image to Library
    /// Process photo saving result
    @objc func saveImage(_ image: UIImage,
                     didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("ERROR: \(error)")
        } else {
            print("Success")

        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
