//
//  FeedCell.swift
//  SnapChatFirebaseClone
//
//  Created by Enes Talha Yılmaz on 13.03.2023.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var lblFeedUsername: UILabel!
    @IBOutlet weak var ivFeed: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
