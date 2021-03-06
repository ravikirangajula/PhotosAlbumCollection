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
    
    @IBOutlet weak var horizonatlCOllection: UICollectionView!
    static let syncingBadgeKind = "syncing-badge-kind"

    var imagesArra = [UIImage]()
    var assets = [PHAsset]()

    var tempImage =  #imageLiteral(resourceName: "icon_placeholder_home_2")
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
        horizonatlCOllection.collectionViewLayout = MosaicGridLayout()
        horizonatlCOllection.register(DragCollectionViewCell.self, forCellWithReuseIdentifier: DragCollectionViewCell.identifer)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongGesture))
        self.horizonatlCOllection.addGestureRecognizer(longPressGesture)
        horizonatlCOllection.delegate = self
        horizonatlCOllection.dataSource = self
        }

    
    // MARK: - Gesture recogniser
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let indexPath = self.horizonatlCOllection.indexPathForItem(at: gesture.location(in: self.horizonatlCOllection)) else {
                return
            }
            self.horizonatlCOllection.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            self.horizonatlCOllection.updateInteractiveMovementTargetPosition(gesture.location(in: self.horizonatlCOllection))
        case .ended:
            self.horizonatlCOllection.endInteractiveMovement()
        default:
            self.horizonatlCOllection.cancelInteractiveMovement()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.horizonatlCOllection.collectionViewLayout.invalidateLayout()

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

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count

    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = horizonatlCOllection.dequeueReusableCell(withReuseIdentifier: DragCollectionViewCell.identifer, for: indexPath) as? DragCollectionViewCell
            else { preconditionFailure("Failed to load collection view cell") }
        if !assets.isEmpty {
            let assetIndex = indexPath.item % assets.count
            let asset = assets[assetIndex]
            let assetIdentifier = asset.localIdentifier
            cell.backgroundColor = .white
            cell.assetIdentifier = assetIdentifier

            PHImageManager.default().requestImage(for: asset, targetSize: cell.frame.size,
                                                  contentMode: .aspectFill, options: nil) { (image, hashable)  in
                                                    if let loadedImage = image, let cellIdentifier = cell.assetIdentifier {

                                                        // Verify that the cell still has the same asset identifier,
                                                        // so the image in a reused cell is not overwritten.
                                                        if cellIdentifier == assetIdentifier {
                                                            cell.imageView.image = loadedImage
                                                        }
                                                    }
            }
        } else {
          //  cell.imageView.image = #imageLiteral(resourceName: "maintenance_page")
        }

        return cell
 
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            let temp = assets.remove(at: sourceIndexPath.item)
        assets.insert(temp, at: destinationIndexPath.item)
       // self.imageView.image = imagesArra.first
        
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let height = view.frame.size.height
//        let width = view.frame.size.width
//        // in case you you want the cell to be 40% of your controllers view
//        return CGSize(width: width * 0.4, height: height * 0.4)
//    }
    
    
}
extension ViewController: selectedImagesDelegate {
    
    func selectedImagesList(_ images: [PHAsset]) {
        assets = images
       // self.horizonatlCOllection.collectionViewLayout.invalidateLayout()
       // self.horizonatlCOllection.layoutIfNeeded()
        self.horizonatlCOllection.reloadData()
//        UIView.animate(withDuration: 0.1, animations: {
//            self.view.setNeedsLayout()
//        }, completion: { completion in
//            if completion {
//                self.horizonatlCOllection.collectionViewLayout.invalidateLayout()
//            }
//        })
    }
    
    func convertImageFromAsset(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result!
        })
        return image
    }
    
}



extension ViewController : UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
      return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
      return true
    }
}
