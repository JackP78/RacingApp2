//
//  PicCollectCellCollectionViewCell.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 22/01/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

enum AspectRatio {
    case portrait
    case landscape
}

class PicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var entryImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    
    var aspectRatio: AspectRatio?
}
