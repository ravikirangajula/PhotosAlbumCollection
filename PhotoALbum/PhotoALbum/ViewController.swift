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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imagview3: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    var imagesArra = [UIImage]()
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
       // horizonatlCOllection.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView2.isUserInteractionEnabled = true
        imageView2.isHidden = true
        imagview3.isHidden = true
        horizonatlCOllection.delegate = self
        horizonatlCOllection.dataSource = self
        
        if #available(iOS 11.0, *) {
            let dragInteraction = UIDragInteraction(delegate: self)
            dragInteraction.isEnabled = true
            imagview3.addInteraction(dragInteraction)
            imageView2.addInteraction(dragInteraction)

            let dropInteraction = UIDropInteraction(delegate: self)
            imageView.addInteraction(dropInteraction)
           // imageView2.addInteraction(dropInteraction)
           // imagview3.addInteraction(dropInteraction)
        } else {
            // Fallback on earlier versions
        }
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongGesture))
        self.horizonatlCOllection.addGestureRecognizer(longPressGesture)
        horizonatlCOllection.delegate = self
        horizonatlCOllection.dataSource = self
//        horizonatlCOllection.dragDelegate = self
//        horizonatlCOllection.dropDelegate = self
       // horizonatlCOllection.dragInteractionEnabled = true
        // Do any additional setup after loading the view.
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
}

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArra.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 3
        let cell = horizonatlCOllection.dequeueReusableCell(withReuseIdentifier: "dragCell", for: indexPath) as! DragCollectionViewCell
        
        // Configure the cell
        cell.imageView.image = imagesArra[indexPath.row]

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            let temp = imagesArra.remove(at: sourceIndexPath.item)
           imagesArra.insert(temp, at: destinationIndexPath.item)
        self.imageView.image = imagesArra.first
        
    }
}
extension ViewController: selectedImagesDelegate {
    
    func selectedImagesList(_ images: [PHAsset]) {
        
        for object in images {
            imagesArra .append(convertImageFromAsset(asset: object))
        }
        horizonatlCOllection .reloadData()
        let asset = images[0]
       self.imageView.fetchImageAsset(asset, targetSize: self.imageView.bounds.size, completionHandler: nil)
//        let asset1 = images[1]
//        self.imageView2.fetchImageAsset(asset1, targetSize: self.imageView.bounds.size, completionHandler: nil)
//        let asset2 = images[2]
//        self.imagview3.fetchImageAsset(asset2, targetSize: self.imageView.bounds.size, completionHandler: nil)
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

extension ViewController: UIDropInteractionDelegate {
    // Drop Interaction
    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // 1
        for dragItem in session.items {
            // 2
            if #available(iOS 11.0, *) {
                dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { object, error in
                    // 3
                    guard error == nil else { return print("Failed to load our dragged item") }
                    guard let draggedImage = object as? UIImage else { return }
                    // 4
                    DispatchQueue.main.async {
                        self.tempImage = self.imageView.image ?? #imageLiteral(resourceName: "icon_insertad_photo_add")
                        self.imageView2.image = self.imageView.image
                        self.imageView.image = draggedImage
                    }
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }

    }


extension ViewController: UIDragInteractionDelegate {
    // Drag Interaction
    @available(iOS 11.0, *)
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let centerPoint = session.location(in: self.view)
        guard let image = imageView2.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        return [item]
}
}


