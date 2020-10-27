//
//  CameraCustomView.swift
//  PhotoALbum
//
//  Created by Ravikiran Gajula (HLB) on 23/10/2020.
//

import UIKit

class CameraCustomView: UIView {

    public var captureImage: (()->())?
    var selectFromGallery: (()->())?
    var chageCamera: (()->Void)?

    
    @IBOutlet weak var horizontalCollection: UICollectionView!
    @IBOutlet weak var photogallery: UIButton!
    @IBOutlet weak var capture: UIButton!
    @IBOutlet var contentView: UIView!
    
    
    class func instanceFromNib() -> CameraCustomView {
            let view = UINib(nibName: "CameraCustomView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CameraCustomView
            return view
    }
    
    // MARK: - Initializations
    override init(frame: CGRect) {
        super.init(frame: frame)
        /// never call
        // initCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
    }
    
    func initCommon() {
        
        contentView                                           = loadViewFromNib()
        contentView.frame                                     = self.bounds
       contentView.autoresizingMask                          = [.flexibleHeight, .flexibleWidth]
       contentView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(contentView)
//        horizontalCollection.layer.borderColor = UIColor.green.cgColor
//        horizontalCollection.layer.borderWidth = 2.0
//
//        contentView.layer.borderColor = UIColor.blue.cgColor
//        contentView.layer.borderWidth = 2.0

    }

    private func loadViewFromNib() -> UIView {
        let bundle  = Bundle(for: type(of: self))
        let nib     = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return UIView()
        }
        return nibView
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        chageCamera?()
    }
    @IBAction func captureBtnClicked(_ sender: Any) {
        captureImage?()
    }
    
    @IBAction func showAlbnum(_ sender: Any) {
        selectFromGallery?()
    }
    
}
