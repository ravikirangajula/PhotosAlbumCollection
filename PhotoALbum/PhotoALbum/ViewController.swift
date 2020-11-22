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

        horizonatlCOllection.register(DragCollectionViewCell.self, forCellWithReuseIdentifier: DragCollectionViewCell.identifer)
        horizonatlCOllection.collectionViewLayout = MosaicLayout()
        horizonatlCOllection.collectionViewLayout.invalidateLayout()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongGesture))
        self.horizonatlCOllection.addGestureRecognizer(longPressGesture)
        horizonatlCOllection.delegate = self
        horizonatlCOllection.dataSource = self
        if #available(iOS 11.0, *) {
          //  horizonatlCOllection.dragInteractionEnabled = true
        } else {
            // Fallback on earlier versions
        }

        }

    
    // MARK: - Gesture recogniser
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer)
    {
        switch(gesture.state)
        {

        case .began:
            guard let selectedIndexPath = self.horizonatlCOllection.indexPathForItem(at: gesture.location(in: self.horizonatlCOllection)) else
            {
                break
            }

            self.horizonatlCOllection.beginInteractiveMovementForItem(at: selectedIndexPath)

        case .changed:
            self.horizonatlCOllection.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))

        case .ended:
            self.horizonatlCOllection.endInteractiveMovement()

        default:
            self.horizonatlCOllection.cancelInteractiveMovement()
        }
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
    
//    func generateLayout() -> UICollectionViewLayout {
//      // We have three row styles
//      // Style 1: 'Full'
//      // A full width photo
//      // Style 2: 'Main with pair'
//      // A 2/3 width photo with two 1/3 width photos stacked vertically
//      // Style 3: 'Triplet'
//      // Three 1/3 width photos stacked horizontally
//
//      // Syncing badge
//      let syncingBadgeAnchor = NSCollectionLayoutAnchor(edges: [.top, .trailing], fractionalOffset: CGPoint(x: -0.3, y: 0.3))
//      let syncingBadge = NSCollectionLayoutSupplementaryItem(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .absolute(20),
//          heightDimension: .absolute(20)),
//        elementKind: ViewController.syncingBadgeKind,
//        containerAnchor: syncingBadgeAnchor)
//
//      // Main with pair
//      let mainItem = NSCollectionLayoutItem(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .fractionalWidth(2/3),
//          heightDimension: .fractionalHeight(1.0)))
//      mainItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
//
//      let pairItem = NSCollectionLayoutItem(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .fractionalWidth(1.0),
//          heightDimension: .fractionalHeight(0.5)))
//      pairItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
//      let trailingGroup = NSCollectionLayoutGroup.vertical(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .fractionalWidth(1/3),
//          heightDimension: .fractionalHeight(1.0)),
//        subitem: pairItem,
//        count: 2)
//
//      let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .fractionalWidth(1.0),
//          heightDimension: .fractionalWidth(4/9)),
//        subitems: [mainItem, trailingGroup])
//
//      // Triplet
//      let tripletItem = NSCollectionLayoutItem(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .fractionalWidth(1/3),
//          heightDimension: .fractionalHeight(1.0)))
//      tripletItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
//
//      let tripletGroup = NSCollectionLayoutGroup.horizontal(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .fractionalWidth(1.0),
//          heightDimension: .fractionalWidth(2/9)),
//        subitems: [tripletItem, tripletItem, tripletItem])
//
//      // Reversed main with pair
//      let mainWithPairReversedGroup = NSCollectionLayoutGroup.horizontal(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .fractionalWidth(1.0),
//          heightDimension: .fractionalWidth(4/9)),
//        subitems: [trailingGroup, mainItem])
//
//      let nestedGroup = NSCollectionLayoutGroup.vertical(
//        layoutSize: NSCollectionLayoutSize(
//          widthDimension: .fractionalWidth(1.0),
//          heightDimension: .fractionalWidth(16/9)),
//        subitems: [mainWithPairGroup, tripletGroup])
//
//      let section = NSCollectionLayoutSection(group: nestedGroup)
//      let layout = UICollectionViewCompositionalLayout(section: section)
//      return layout
//    }

}

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 3
        let cell = horizonatlCOllection.dequeueReusableCell(withReuseIdentifier: DragCollectionViewCell.identifer, for: indexPath) as! DragCollectionViewCell
        
        if !assets.isEmpty {
            let assetIndex = indexPath.item % assets.count
            let asset = assets[assetIndex]
            let assetIdentifier = asset.localIdentifier

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
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            let temp = assets.remove(at: sourceIndexPath.item)
        assets.insert(temp, at: destinationIndexPath.item)
       // self.imageView.image = imagesArra.first
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = view.frame.size.height
        let width = view.frame.size.width
        // in case you you want the cell to be 40% of your controllers view
        return CGSize(width: width * 0.4, height: height * 0.4)
    }
    
    
}
extension ViewController: selectedImagesDelegate {
    
    func selectedImagesList(_ images: [PHAsset]) {
        
        assets = images
        for object in images {
           // imagesArra .append(convertImageFromAsset(asset: object))
        }
       // horizonatlCOllection.collectionViewLayout.invalidateLayout()

        DispatchQueue.main.async { [weak self]  in
            self?.horizonatlCOllection .reloadData()
            self?.horizonatlCOllection.collectionViewLayout.invalidateLayout()
            self?.horizonatlCOllection.layoutSubviews()

        }

       // let asset = images[0]
       //self.imageView.fetchImageAsset(asset, targetSize: self.imageView.bounds.size, completionHandler: nil)

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


