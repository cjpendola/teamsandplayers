//
//  PlayerTableViewCell.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/28/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
        
        @IBOutlet weak var playerimageView: UIImageView!
        @IBOutlet weak var nameLabel: UILabel!
        
        var player: Player? {
            didSet {
                updateViews()
            }
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }
        
        func updateViews() {
            guard let player = player else { print("player is nil") ; return }
            self.nameLabel.text = player.name
        }
}
