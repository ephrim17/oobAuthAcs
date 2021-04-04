//
//  countryTableViewCell.swift
//  oobAuthAcs
//
//  Created by LOB4 on 12/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class countryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var countryCode: UILabel!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    
}
