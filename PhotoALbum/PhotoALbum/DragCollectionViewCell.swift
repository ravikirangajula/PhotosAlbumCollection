//
//  DragCollectionViewCell.swift
//  PhotoALbum
//
//  Created by Gajula RaviKiran on 09/11/2020.
//

import UIKit

class DragCollectionViewCell: UICollectionViewCell {
   
  //  @IBOutlet weak var imageView: UIImageView!
    static let identifer = "kMosaicCollectionViewCell"
    var imageView = UIImageView()
    var assetIdentifier: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.autoresizesSubviews = true
        
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = 10

        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 10
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(imageView)
      //  imageView.layer.borderWidth = 2.0
     //   imageView.layer.borderColor = UIColor.red.cgColor
        // Use a random background color.
        let redColor = CGFloat(arc4random_uniform(255)) / 255.0
        let greenColor = CGFloat(arc4random_uniform(255)) / 255.0
        let blueColor = CGFloat(arc4random_uniform(255)) / 255.0
        self.backgroundColor = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        assetIdentifier = nil
    }
    
}
