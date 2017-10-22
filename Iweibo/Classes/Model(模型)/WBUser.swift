//
//  WBUser.swift
//  Iweibo
//
//  Created by walker on 2016/11/26.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit

/// 微博用户模型
class WBUser: NSObject {
    
    /// 用户id
    var id:Int64=0
    
    /// 用户昵称
    var screen_name:String?
    
    /// 用户头像地址（中图），50*50像素
    var profile_image_url:String?
    
    /// 验证类型，-1:没有验证，0，验证，2，3，5：企业验证，220:达人
    var verified_type:Int=0
    
    /// 会员等级0-6
    var mbrank:Int=0
    
    //便于调试
    override var description: String{
        return yy_modelDescription()
    }
}
