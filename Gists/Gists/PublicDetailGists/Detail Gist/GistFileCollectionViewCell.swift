//
//  GistFileCollectionViewCell.swift
//  Gists
//
//  Created by Ivan Babich on 27/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import UIKit

class GistFileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    func configureCell(fileModel: FilePlainModel) {
        fileNameLabel.text = fileModel.fileName
        typeLabel.text = fileModel.type
        languageLabel.text = fileModel.language
        sizeLabel.text = "\(fileModel.size)"
    }
}
