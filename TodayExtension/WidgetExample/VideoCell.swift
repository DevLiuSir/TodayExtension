//
//  VideoCell.swift
//  WidgetExample
//
//  Created by Liu Chuan on 2018/5/2.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    
    /// 电影名
    @IBOutlet weak var videoTitle: UILabel!
    
    /// 电影图片
    @IBOutlet weak var videoImage: UIImageView!
    
    /// 类型ID
    @IBOutlet weak var typeID: UILabel!
    
    
    // MARK: - 加载nib时候调用
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 设置图片的圆角
        videoImage.layer.cornerRadius = 10
        videoImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
