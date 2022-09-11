//
//  CoverCollectionViewCell.swift
//  MP3 Player
//
//  Created by ILYA Paraskevich on 6.09.22.
//

import UIKit

class CoverCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coverBackgroundView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coverImageView.layer.cornerRadius = 15
        coverImageView.layer.masksToBounds = true
        
        coverBackgroundView.layer.cornerRadius = 15
        coverBackgroundView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor
        coverBackgroundView.layer.borderWidth = 0.5
        coverBackgroundView.layer.masksToBounds = true
        
        isUserInteractionEnabled = false
    }

    func setupCell(with songCover: String) {
        coverImageView.image = UIImage(named: songCover)
    }
    
}
