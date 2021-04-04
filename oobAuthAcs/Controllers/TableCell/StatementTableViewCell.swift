//
//  StatementTableViewCell.swift
//  oobAuthAcs
//
//  Created by LOB4 on 02/12/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class StatementTableViewCell: UITableViewCell {

    @IBOutlet weak var merchantName: UILabel!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var txnAmount: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
