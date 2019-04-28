//
//  TeamTableViewCell.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit


class TeamTableViewCell: UITableViewCell {

    @IBOutlet weak var teamimageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var team: Team? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //teamimageView.layer.cornerRadius = 5
    }
    
    func updateViews() {
        guard let team = team else { print("team is nil") ; return }
        self.nameLabel.text = team.name
    }
}
