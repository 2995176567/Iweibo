//
//  WBStatusToolBar.swift
//  Iweibo
//
//  Created by walker on 2016/11/27.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit

class WBStatusToolBar: UIView {
    
    var viewModel:WBStatusViewModel?{
    
        didSet{
//            retweentedButton.setTitle("\(viewModel?.status.reposts_count)", for: [])
//            commentButton.setTitle("\(viewModel?.status.comments_count)", for: [])
//            likeButton.setTitle("\(viewModel?.status.attitudes_count)", for: [])
        
            retweentedButton.setTitle(viewModel?.retweetedStr, for: [])
            commentButton.setTitle(viewModel?.commentStr, for: [])
            likeButton.setTitle(viewModel?.likeStr, for: [])
        }
    }
    
    /// 转发
    @IBOutlet weak var retweentedButton: UIButton!
    /// 评论
    @IBOutlet weak var commentButton: UIButton!
    /// 点赞
    @IBOutlet weak var likeButton: UIButton!
}
