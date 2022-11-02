//
//  DetailsCell.swift
//  SampleCoreData
//
//  Created by Mac-OBS-41 on 20/02/22.
//

import UIKit

class DetailsCell: UITableViewCell {
    
    //OUTLET PROPERTIES
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var contactNoLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
