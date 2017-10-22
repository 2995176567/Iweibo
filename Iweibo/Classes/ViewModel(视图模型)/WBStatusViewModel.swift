//
//  WBStatusViewModel.swift
//  Iweibo
//
//  Created by walker on 2016/11/26.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import Foundation
/**
     如果没有任何父类，如果希望在开发时调试，输出调试信息，需要
        1、遵守CustomStringConvertible
        2、实现description
 
 关于表格的性能优化
    尽量少计算，所有需要的素材提前计算好
    控件上不要设置圆角半径，所有图形渲染的属性，都要注意
    不要动态创建控件，所有需要的控件，都要提前创建好，在显示的时候，根据数据隐藏／显示
    Cell 中控件的层次越少越好，数量越少越好
 
  */

/// 单条微博的视图模型
class WBStatusViewModel:CustomStringConvertible {
    
    /// 微博模型
    var status:WBStatus
    
    /// 会员图标 --储存型属性（用内存换 cpu）
    var memberIcon:UIImage?
    
    /// 验证类型，-1:没有验证，0，验证，2，3，5：企业验证，220:达人
    var vipIcon:UIImage?
    
    /// 转发文字
    var retweetedStr:String?
    
    /// 评论文字
    var commentStr:String?
    
    /// 点赞数
    var likeStr:String?
    
    /// 配图视图大小
    var pictureViewSize=CGSize()
    
    /// 如果是被转发的微博，原创微博一定没有图
    var picURLs:[WBStatusPicture]?{
        //如果有被转发的微博，返回被转发微博的配图
        //如果没有被转发的微博，返回原创微博的配图
        //如果都没有，返回nil
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    
    // 微博正文的属性文本
    var statusAttrtext:NSAttributedString?
    
    /// 被转发微博的属性文本
    var retweetedAttrtext:NSAttributedString?
    
    /// 行高
    var rowHeight:CGFloat=0
    
    /// 构造函数
    ///
    /// - Parameter model: 微博模型
    init(model:WBStatus){
        self.status=model
        
        //common_icon_membership_level1
        // 会员等级0-6
        if (model.user?.mbrank)! > 0 && (model.user?.mbrank)! < 7 {
            let imageName="common_icon_membership_level\(model.user?.mbrank ?? 1)"
        
            memberIcon=UIImage(named: imageName)
        }
        
        //验证图标
        switch model.user?.verified_type ?? -1{
        case 0:
            vipIcon=UIImage(named: "avatar_vip")
        case 2,3,5:
            vipIcon=UIImage(named: "avatar_enterprise_vip")
        case 220:
            vipIcon=UIImage(named: "avatar_grassroot")
        default:
            break
        }
        
        // 设置超过1w的数字
        //model.reposts_count=Int(arc4random_uniform(100000))
        
        //设置底部计数字符串
        retweetedStr=countString(count: model.reposts_count, defaultStr: "转发")
        commentStr=countString(count: model.comments_count, defaultStr: "评论")
        likeStr=countString(count: model.attitudes_count, defaultStr: "赞")
        //有原创计算原创的，有转发的就计算转发的
        pictureViewSize=calcPictureViewSize(count: picURLs?.count)
        
        // 设置微博文本
        let originalFont=UIFont.systemFont(ofSize: 15)
        let retweetedFont=UIFont.systemFont(ofSize: 14)

        // 微博正文的属性文本
        statusAttrtext=CZEmoticonManager.shared.emoticonString(string:model.text ?? "", font: originalFont)
        
        // 设置被转发微博的文字
        let rText = "@" + (status.retweeted_status?.user?.screen_name ?? "") + ":" + (status.retweeted_status?.text ?? "")
        
        retweetedAttrtext=CZEmoticonManager.shared.emoticonString(string:rText,font:retweetedFont)
        
        //计算行高
        updateRowHeight()
    }
    
    var description: String{
        return status.description
    }
    
    /// 根据当前视图模型内容计算行高
    func updateRowHeight(){
        // 原创微博
        //被转发微博

        let margin:CGFloat=12
        let iconHeight:CGFloat=34
        let toolbarHeight:CGFloat=35
        
        var height:CGFloat=0
        
        let viewSize = CGSize(width: UIScreen.cz_screenWidth()-2*margin, height:CGFloat(MAXFLOAT))
        
        //计算顶部位置
        height=2*margin+iconHeight+margin
        
        //正文属性文本的高度
        if let text = statusAttrtext {
            
            //预期尺寸，宽度固定，高度尽量大
            //选项，换行文本，统一使用usesLineFragmentOrigin
            //attributes：指定字体字典
            height += text.boundingRect(with: viewSize,
                                            options: [.usesLineFragmentOrigin],
                                            context: nil).height
        }
        
        //判断是否转发微博
        if status.retweeted_status != nil {
            
            height += 2*margin
            
            //转发文本的高度
            if let text = retweetedAttrtext {
                
                height += text.boundingRect(with: viewSize,
                                                options: [.usesLineFragmentOrigin],
                                                context: nil).height
            }
        }
        
        // 配图视图
        height += pictureViewSize.height
        
        height += margin
        
        //底部工具栏
        height += toolbarHeight
        
        //使用属性记录
        rowHeight = height
    }
    
    
    /// 使用单个图像，更新配图视图大小----是缩略图
    /// 长微博---特别长
    /// - Parameter image: 网络缓存的单张图像
    func updateSingleImageSize(image:UIImage){
    
        var size = image.size
        
        //过宽图像处理
        let maxWidth:CGFloat=200
        let minWidth:CGFloat=40
        
        if size.width > maxWidth {
            //设置最大宽度
            size.width=200
            
            //等比例调整宽度
            size.height = size.width * image.size.height/image.size.width
        }
        
        // 过窄的人图像处理
        if size.width < minWidth {
           
            size.width=minWidth
            // 要特殊处理高度
            size.height = size.width * image.size.height/image.size.width/4
        }

        // 过高图片处理
        if size.height > 200{
        
            size.height=200
        }
    
        //尺寸，需要增加顶部的12个点，
        size.height+=WBStatusPictureViewOutterMargin
        
        //重新设置配图视图大小
        pictureViewSize = size
        
        //更新行高
        updateRowHeight()
    }
    
    /// 计算指定数量的图片对应的配图视图大小
    ///
    /// - Parameter count: 配图数量
    /// - Returns: 配图视图的大小
    private func calcPictureViewSize(count:Int?) -> CGSize{
        
        if count == 0 || count == nil {
            return CGSize()
        }
        
        //计算高度
        //计算行数 1-9
        let row = (count! - 1) / 3 + 1
        
        //根据行数算高度
        let height = WBStatusPictureViewOutterMargin + CGFloat(row) * WBStatusPictureItemWidth + CGFloat(row-1) * WBStatusPictureViewInnerMargin
        
        return CGSize(width: WBStatusPictureViewWidth, height: height)
    }
    
    /// 给定一个数字，返回一个对应的描述结果
    /// - defaultStr 默认字符串，转发／评论／赞
    /// - Returns: 描述结果
    ///数量等于0，显示默认标题
    /// 超过 10000   显示 x.xx 万。   <10000,显示实际数字
    private func countString(count:Int,defaultStr:String) -> String{
        
        if count == 0 {
            return defaultStr
        }
        
        if count < 10000 {
        
            return count.description
        }
        
        return String(format:"%.02f 万",Double(count/10000))
    }
}
