//
//  WhetherCell.swift
//  WeatherTask
//
//  Created by Rodney Pinto on 23/09/24.
//

import UIKit

class WhetherCell: UITableViewCell {
    
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var cloudLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
