//
//  CapturePhotoViewController.swift
//  PhotoALbum
//
//  Created by Ravikiran Gajula (HLB) on 18/10/2020.
//

import UIKit

class CapturePhotoViewController: UIViewController {

    var imagePicker = UIImagePickerController()

    @IBOutlet weak var captureView: CameraCustomView!
    var capturedImages = [UIImage]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        captureView.horizontalCollection.register(UINib(nibName: "CapturedImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CapturedImagesCollectionViewCell.identifier)
        captureView.horizontalCollection.delegate = self
        captureView.horizontalCollection.dataSource = self
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        getImage(fromSourceType: .camera)

    }
    
    @IBAction func capturePhoto(_ sender: Any) {
        imagePicker.takePicture()
    }
    func customViewForImagePicker(imagePicker: UIImagePickerController!) -> UIView {
            // TODO: - Assigning the view to the telemetry panel does not work
    // let view:UIView = self.telemetryPanel
    // view.backgroundColor = UIColor.whiteColor()
    // view.alpha = 0.25
    // return view

            // Creating the view programmatically overlays it
            let cameraAspectRatio:CGFloat = 4.0 / 3.0;
        let screenSize = UIScreen.main.bounds.size
            let imageWidth = floorf(Float(screenSize.width) * Float(cameraAspectRatio))
        let view: UIView = UIView()
        view.frame = CGRect(x: 0, y: 200, width: CGFloat(imageWidth), height: 65)
          //  let view: UIView = UIView(frame: CGRectMake(0, screenSize.height-65, CGFloat(imageWidth), 65))
        view.backgroundColor = UIColor.white
            view.alpha = 0.25
            return view

        }
    
    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                        imagePicker =  UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = sourceType
                       // imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = false
            imagePicker.view.layer.borderColor = UIColor.green.cgColor
            imagePicker.view.layer.borderWidth = 2.0
            imagePicker.view.backgroundColor = UIColor.yellow

            imagePicker.cameraOverlayView?.layer.borderColor = UIColor.red.cgColor
            imagePicker.cameraOverlayView?.layer.borderWidth = 2.0
          //  let translate = CGAffineTransform(translationX: 0.0, y: 100)
        //  imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0.0, y: 50.0)
            //imagePicker.cameraViewTransform = translate
          //  captureView?.frame = imagep
            //var scale = translate.scaledBy(x: 0.5, y: 0.5)
           // imagePicker.cameraViewTransform  = scale
            captureView.frame = CGRect(x: 0, y: self.view.frame.size.height - 200, width: self.view.frame.size.width, height: 200)
             listenForCalls()
            imagePicker.cameraOverlayView = captureView
            self.present(imagePicker, animated: true, completion: nil)
    
                    }
//        }
    }


}

extension CapturePhotoViewController {
    
    func listenForCalls() {
        
        captureView.captureImage = { [weak self] in
            guard let self = self else {
                return
            }
            self.imagePicker.takePicture()
        }
        
        captureView.selectFromGallery = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
    }
}

extension CapturePhotoViewController:  UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage]
        capturedImages.append(image as! UIImage)
        captureView.horizontalCollection.reloadData()
    }
}


extension CapturePhotoViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CapturedImagesCollectionViewCell.identifier,
                for: indexPath) as? CapturedImagesCollectionViewCell else {
            fatalError("Unable to dequeue PhotoCollectionViewCell")
        }
        cell.imageView.image = capturedImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    
}

extension CapturePhotoViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CollectionViewFlowLayoutType(.photos, frame: view.frame).sizeForItem
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets.left
        
    }
    
}
