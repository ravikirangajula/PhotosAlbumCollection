//
//  ALbumCollectionViewCell.swift
//  PhotoALbum
//
//  Created by Ravikiran Gajula (HLB) on 17/10/2020.
//

import UIKit

class ALbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    static let identifier = "aLbumCollectionViewCell"
    
    override var isSelected: Bool {
        didSet {
            checkMarkImage.isHidden = !self.isSelected
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkMarkImage.isHidden = true
        self.imageView.layer.borderColor = UIColor.red.cgColor
        self.imageView.layer.borderWidth = 2.0
    }
    @IBOutlet weak var checkMarkImage: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
        checkMarkImage.isHidden = true
    }

    func itemsSelected(selectedIndex: Int)  {
        checkMarkImage.isHidden = self.isSelected
    }
}
