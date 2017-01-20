//
//  ColorCell.swift
//  colorfill
//
//  Created by 齐 on 2016/12/4.
//  Copyright © 2016年 Qi. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    var color:UIColor?{
        didSet{
            self.backgroundColor=color
        }
    }
    override var isSelected: Bool{
        didSet{
            if isSelected{
                self.layer.borderWidth=2
                self.layer.borderColor=UIColor.white.cgColor
                
            }
            else{
                self.layer.borderWidth=0
            }
        }
    }
    
}
