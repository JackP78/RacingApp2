//
//  RunnerDetailCell.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 08/09/2015.
//  Copyright © 2015 Jack McAuliffe. All rights reserved.
//

import UIKit

class RunnerDetailCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clothNumber: UILabel!
    @IBOutlet weak var silksImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
