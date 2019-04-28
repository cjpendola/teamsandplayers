//
//  ProfileTableViewCell.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit

protocol ProfileTableViewCellDelegate {
    func selectPhotoButton()
}

class ProfileTableViewCell: UITableViewCell {
    
    var delegate: ProfileTableViewCellDelegate?
    
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        delegate?.selectPhotoButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
