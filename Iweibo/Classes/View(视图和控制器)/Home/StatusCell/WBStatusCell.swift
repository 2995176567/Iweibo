//
//  WBStatusCell.swift
//  Iweibo
//
//  Created by walker on 2016/11/26.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit

// 微博 Cell 的协议
@objc protocol WBStatusCellDelegate:NSObjectProtocol {
    // 微博 Cell 选中 URL 字符串
    @objc optional func statusCellDidSelectedURLString(cell:WBStatusCell,urlString:String)
}


// 微博 Cell
class WBStatusCell: UITableViewCell {
    /// 代理属性
    weak var delegate:WBStatusCellDelegate?

    /// 微博视图模型
    var viewModel:WBStatusViewModel?{
        didSet{
            //设置微博文本
            statusLabel?.attributedText=viewModel?.statusAttrtext
            // 设置被转发微博的文字
            retweetedLabel?.attributedText=viewModel?.retweetedAttrtext
            
            // 设置姓名
            nameLabel.text=viewModel?.status.user?.screen_name
        
            // 设置会员图标
            memberIconView.image=viewModel?.memberIcon
            
            //验证图标
            vipiconView.image=viewModel?.vipIcon
            
            //用户头像
            iconView.cz_setImage(urlString: viewModel?.status.user?.profile_image_url, placeholderImage: UIImage(named: "avatar_default_big"),isAvatar: true)
            
            /// 底部工具栏
            toolBar.viewModel=viewModel
            
            //配图视图模型
            pictureView.viewModel=viewModel
            
            // 测试修改配图视图的高度
            //pictureView.heightCons.constant=viewModel?.pictureViewSize.height ?? 0
            
            //设置配图视图的uRL 数据
            
            // 测试4张图像
//            if (viewModel?.status.pic_urls?.count)! > 4{
//                //修改数组
//                var picURLs=viewModel!.status.pic_urls!
//                picURLs.removeSubrange((picURLs.startIndex+4)..<picURLs.endIndex)
//                
//                pictureView.urls=picURLs
//            
//            }else{
//                pictureView.urls=viewModel?.status.pic_urls
//
//            }
            //设置配图（被转发和原创）
            //pictureView.urls=viewModel?.picURLs

            
            //设置来源
            sourceLabel.text=viewModel?.status.source
            
            // 设置时间
            timeLabel.text=viewModel?.status.createDate?.cz_dateDescription
        }
    }
    
    /// 头像
    @IBOutlet weak var iconView: UIImageView!
    
    /// 姓名
    @IBOutlet weak var nameLabel: UILabel!
    
    /// 会员图标
    @IBOutlet weak var memberIconView: UIImageView!
    
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
 
    /// 来源
    @IBOutlet weak var sourceLabel: UILabel!
    
    /// 验证图标
    @IBOutlet weak var vipiconView: UIImageView!
    
    /// 微博正文
    @IBOutlet weak var statusLabel: FFLabel!
    
    /// 底部工具栏
    @IBOutlet weak var toolBar: WBStatusToolBar!
    
    /// 配图视图
    @IBOutlet weak var pictureView: WBStatusPictureView!
    
    /// 被转发微博的标签 - 原创微博没有此控件，一定要用 ‘？’
    @IBOutlet weak var retweetedLabel: FFLabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 离屏渲染----异步绘制
        self.layer.drawsAsynchronously=true
        
        // 珊格化---异步绘制后，会生成一张独立的图像，cell在屏幕滚动的时候，本质上是这张图片
        // cell优化，要尽量减少图层化，相当于一层
        //停止滚动后，可以接受监听
        self.layer.shouldRasterize=true
        
        //使用珊格化必须指定分辨率
        self.layer.rasterizationScale=UIScreen.main.scale
        
        // 设置微博文本代理
        statusLabel.delegate=self
        retweetedLabel?.delegate=self
    }
}

extension WBStatusCell:FFLabelDelegate{

    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        
        //判断是不是URL
        if !text.hasPrefix("http://"){
            return
        }
        
        delegate?.statusCellDidSelectedURLString?(cell: self, urlString: text)
    }
}