//
//  SuggestionTableViewCell.swift
//  MovieDatabase
//
//  Created by Emir Zecevic on 10/7/20.
//

import UIKit

class SuggestionTableViewCell: UITableViewCell {

    @IBOutlet weak var suggestionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
