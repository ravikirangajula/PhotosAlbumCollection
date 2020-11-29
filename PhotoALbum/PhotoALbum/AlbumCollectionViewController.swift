//
//  AlbumCollectionViewController.swift
//  PhotoALbum
//
//  Created by Ravikiran Gajula (HLB) on 16/10/2020.
//

import UIKit
import Photos

protocol selectedImagesDelegate: class  {
    func selectedImagesList(_ images: [PHAsset])
}

class AlbumCollectionViewController: UIViewController {
    
    @IBOutlet weak var captureView: CameraCustomView!
    let termText = "you can change app access to your photos any time. Manage"
    let term = "Manage"
    var maxcount = 20
    
    @IBOutlet weak var managelabel: UILabel!
    var allPhotos = PHFetchResult<PHAsset>()
    var smartAlbums = PHFetchResult<PHAssetCollection>()
    var userCollections = PHFetchResult<PHAssetCollection>()
    let bannerlabel = UILabel()
    var imagePicker = UIImagePickerController()
    weak var delegate:selectedImagesDelegate?
    var capturedImages = [UIImage]()
    
    @IBOutlet weak var albumCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        
        self.edgesForExtendedLayout = []
        setLabel()
        albumCollection.register(UINib(nibName: "ALbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ALbumCollectionViewCell.identifier)
        albumCollection.allowsSelection = true
        albumCollection.allowsMultipleSelection = true
//        if #available(iOS 14.0, *) {
//            albumCollection.allowsSelectionDuringEditing = true
//        } else {
//            // Fallback on earlier versions
//        }
     
        
        captureView.horizontalCollection.register(UINib(nibName: "CapturedImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CapturedImagesCollectionViewCell.identifier)
        captureView.horizontalCollection.delegate = self
        captureView.horizontalCollection.dataSource = self
        
        captureView.isHidden = true
        PHPhotoLibrary.requestAuthorization { (status) in
            print("Status: \(status)")
        }
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        albumCollection.delegate = self
        albumCollection.dataSource = self
        self.edgesForExtendedLayout = []
        fetchAssets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.edgesForExtendedLayout = []
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissBanner()
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    @IBAction func nexyBtnClicked(_ sender: Any) {
        
        guard let indexPaths: [IndexPath] = albumCollection.indexPathsForSelectedItems else { return }
        let indexes = indexPaths.map({ $0.item - 1})
        let neware = indexes.map { allPhotos[$0] }
        delegate?.selectedImagesList(neware)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func createFlashBtn() {
        let flashBtn = UIButton()
        if #available(iOS 11.0, *) {
            let topSaferArea = self.parent?.view.safeAreaInsets.top ?? 0
        } else {
            // Fallback on earlier versions
        }

        flashBtn.frame = CGRect(x: self.view.frame.size.width - 35, y: 40, width: 28, height: 28)
        flashBtn.setBackgroundImage(#imageLiteral(resourceName: "flash"), for: .normal)
        flashBtn.addTarget(self, action: #selector(flashMode), for: .touchUpInside)
        self.imagePicker.view.addSubview(flashBtn)
    }

    private func createCancelBtn() {
        let cancelBtn = UIButton()
        if #available(iOS 11.0, *) {
            let topSaferArea = self.parent?.view.safeAreaInsets.top ?? 0
        } else {
            // Fallback on earlier versions
        }
        cancelBtn.frame = CGRect(x: 25, y:40, width: 28, height: 28)
        cancelBtn.setBackgroundImage(#imageLiteral(resourceName: "close"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        self.imagePicker.view.addSubview(cancelBtn)
    }
    @objc func flashMode() {
        
        if imagePicker.cameraFlashMode == .on {
            self.imagePicker.cameraFlashMode = .off
        } else {
            imagePicker.cameraFlashMode = .on
        }
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AlbumCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.albumCollection {
            
            return allPhotos.count + 1
        } else {
            return capturedImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.albumCollection {
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ALbumCollectionViewCell.identifier,
                    for: indexPath) as? ALbumCollectionViewCell else {
                fatalError("Unable to dequeue PhotoCollectionViewCell")
            }
            cell.imageView.isUserInteractionEnabled = true

            if indexPath.item == 0 {
                cell.imageView.image = #imageLiteral(resourceName: "icon_insertad_photo_add")

            } else {
                let asset = allPhotos[indexPath.item  - 1]
                cell.imageView.fetchImageAsset(asset, targetSize: cell.imageView.bounds.size, completionHandler: nil)
                cell.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTap(tapper:))))
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CapturedImagesCollectionViewCell.identifier,
                    for: indexPath) as? CapturedImagesCollectionViewCell else {
                fatalError("Unable to dequeue PhotoCollectionViewCell")
            }
            cell.imageView.image = capturedImages[indexPath.item]
            return cell
        }
    }
    
    @objc func dismissKeyboard() {
        showPhotoCaptureView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // print("items= \(albumCollection.indexPathsForSelectedItems)")
        if indexPath.item == 0 {
            showPhotoCaptureView()
            collectionView.deselectItem(at: indexPath, animated: true)
           return
        }
        let items = albumCollection.indexPathsForSelectedItems
        //print("items= \(items)")
        if items?.count ?? 0 > maxcount {
            self.baneerView()
            self.perform(#selector(dismissBanner), with: self, afterDelay: 5)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if albumCollection.indexPathsForSelectedItems?.count ?? 0 == maxcount {
            baneerView()
            self.perform(#selector(dismissBanner), with: self, afterDelay: 5)
        }
        return albumCollection.indexPathsForSelectedItems?.count ?? 0 <= maxcount - 1
    }
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    @objc func didTap(tapper:UIGestureRecognizer) {
      if let cell = tapper.view as? UICollectionViewCell{
        if let index = albumCollection.indexPath(for: cell) {
          if albumCollection.indexPathsForSelectedItems?.contains(index) ?? false {
            albumCollection.deselectItem(at: index, animated: true)
            cell.isSelected = false
          }else{
            let items = albumCollection.indexPathsForSelectedItems
            print("items= \(items)")
            if items?.count ?? 0 > maxcount - 1 {
                self.baneerView()
                self.perform(#selector(dismissBanner), with: self, afterDelay: 5)
                return
            }
            albumCollection.selectItem(at: index, animated: true, scrollPosition: [])
            cell.isSelected = true

          }
        }
      }
    }
}


extension AlbumCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == albumCollection {
            return CollectionViewFlowLayoutType(.photos, frame: view.frame).sizeForItem
        } else {
            return CGSize(width: 80, height: 80)

        }
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == albumCollection {
            return CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets

        } else {
            return UIEdgeInsets(top: 4.0, left: 2.0, bottom: 4.0, right: 2.0)
        }
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets.left
        
    }
    
}

extension AlbumCollectionViewController {
    
    func baneerView() {
        
        bannerlabel.frame = CGRect(x: 0, y: self.navigationController?.navigationBar.frame.size.height ?? 60, width: self.view.bounds.size.width, height: 60)
        bannerlabel.backgroundColor = UIColor.gray
        bannerlabel.text = "you can select maximum of \(maxcount)"
        bannerlabel.textAlignment = .center
        self.navigationController?.navigationBar.addSubview(bannerlabel)
    }
    @objc func dismissBanner() {
        guard let navSub = self.navigationController?.navigationBar.subviews else {
            return
        }
        for bannerView in navSub {
            if bannerView == bannerlabel {
                bannerlabel.removeFromSuperview()
            }
        }
    }
    func setLabel() {
        
        let formattedText = String.format(strings: [term],
                                          boldFont: UIFont.boldSystemFont(ofSize: 15),
                                          boldColor: UIColor.blue,
                                          inString: termText,
                                          font: UIFont.systemFont(ofSize: 15),
                                          color: UIColor.black)
        managelabel.attributedText = formattedText
        managelabel.numberOfLines = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
        managelabel.addGestureRecognizer(tap)
        managelabel.isUserInteractionEnabled = true
        //managelabel.textAlignment = .left
    }
    
    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
        let termString = termText as NSString
        let termRange = termString.range(of: term)
        //  let policyRange = termString.range(of: policy)
        
        let tapLocation = gesture.location(in: managelabel)
        let index = managelabel.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        if checkRange(termRange, contain: index) == true {
            handleViewTermOfUse()
            return
        }
        
        //        if checkRange(policyRange, contain: index) {
        //            handleViewPrivacy()
        //            return
        //        }
    }
    
    func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }
    
    func handleViewTermOfUse(){
        navigateToSettings()
    }
    
    private func navigateToSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    func handleViewPrivacy() {
        
    }
    
    func showPhotoCaptureView() {
        captureView.isHidden = false
        getImage(fromSourceType: .camera)
        createFlashBtn()
        createCancelBtn()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Default action"), style: .default, handler: { _ in
            self.navigateToSettings()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//photos
extension AlbumCollectionViewController {
    
    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            imagePicker.sourceType = sourceType
            // imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = false

            var topSaferArea:CGFloat = 0
            var bottomSaferArea:CGFloat = 0
            //  let translate = CGAffineTransform(translationX: 0.0, y: 100)
            if #available(iOS 11.0, *) {
                topSaferArea = self.parent?.view.safeAreaInsets.top ?? 0
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 11.0, *) {
                 bottomSaferArea = self.parent?.view.safeAreaInsets.bottom ?? 0
            } else {
                // Fallback on earlier versions
            }
            //imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0.0, y: saferArea + bottomSaferArea)
            //imagePicker.cameraViewTransform = translate
            //  captureView?.frame = imagep
            //var scale = translate.scaledBy(x: 0.5, y: 0.5)
            // imagePicker.cameraViewTransform  = scale
           // imagePicker.cameraViewTransform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            let screenSize = UIScreen.main.bounds.size
            let aspectRatio:CGFloat = 4.0/3.0
            let camHeight = screenSize.width * aspectRatio
            let scale = screenSize.height/camHeight
             let safeHeights = topSaferArea + bottomSaferArea
            let deductheights = camHeight + 160
            let yhae = screenSize.height - (deductheights + topSaferArea)
            imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0, y:yhae)
           // imagePicker.cameraViewTransform = CGAffineTransform(scaleX: scale, y: scale)

            captureView.frame = CGRect(x: 0, y: self.imagePicker.view.frame.size.height - 160 - bottomSaferArea, width: self.view.frame.size.width, height: 160)
            listenForCalls()
            imagePicker.cameraOverlayView = captureView
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    func listenForCalls() {
        
        captureView.captureImage = { [weak self] in
            guard let self = self else {
                return
            }
            self.imagePicker.takePicture()
        }
        
        captureView.selectFromGallery = { [weak self] in
            self?.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    self?.albumCollection.reloadData()
                }
                
            })
            //self?.imagePicker.cameraFlashMode = .on
        }
        
        captureView.chageCamera = { [weak self] in
            guard let self = self else {
                return
            }
            if self.imagePicker.cameraDevice == .front {
                self.imagePicker.cameraDevice = .rear
            } else {
                self.imagePicker.cameraDevice = .front
            }
        }

        
    }
    
}


extension String {
    
    static func format(strings: [String],
                       boldFont: UIFont = UIFont.boldSystemFont(ofSize: 14),
                       boldColor: UIColor = UIColor.blue,
                       inString string: String,
                       font: UIFont = UIFont.systemFont(ofSize: 14),
                       color: UIColor = UIColor.black) -> NSAttributedString {
        let attributedString =
            NSMutableAttributedString(string: string,
                                      attributes: [
                                        NSAttributedString.Key.font: font,
                                        NSAttributedString.Key.foregroundColor: color])
        let boldFontAttribute = [NSAttributedString.Key.font: boldFont, NSAttributedString.Key.foregroundColor: boldColor]
        for bold in strings {
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: bold))
        }
        return attributedString
    }
}

extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
