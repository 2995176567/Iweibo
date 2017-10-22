//
//  WBStatusPicture.swift
//  Iweibo
//
//  Created by walker on 2016/11/27.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit

/// 微博配图模型
class WBStatusPicture: NSObject {
    
    /// 缩略图地址
    var thumbnail_pic:String?{
    
        didSet{
            //print(thumbnail_pic)
            // 设置大尺寸图片
            largePic=thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/large/")
            
            //更改缩略图地址
            thumbnail_pic=thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/wap360/")
        }
    }
    
    /// 大尺寸图片
    var largePic:String?
    
    override var description: String{
        return yy_modelDescription()
    }
}
