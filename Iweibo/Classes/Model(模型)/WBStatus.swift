//
//  WBStatus.swift
//  myweibo
//
//  Created by Walker on 16/11/5.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit
import YYModel

// 微博数据模型
class WBStatus: NSObject {
    
    /// 64位机器是64位，32位机器是32位
    var id: Int64 = 0
    ///  微博信息内容
    var text:String?
    
    /// 微博创建时间字符串
    var created_at:String?{
    
        didSet{
            createDate=Date.cz_sinaDate(string: created_at ?? "")
        }
    }
    
    /// 微博创建日期
    var createDate:Date?
    
    /// 微博来源--发布微博使用的客户端
    var source:String?{
        didSet{
            //重新计算来源并且保存
            source="来自于 "+(source?.cz_href()?.text ?? "")
        }
    }
    
    /// 转发数
    var reposts_count:Int=0
    
    /// 评论数
    var comments_count:Int=0
    
    /// 点赞数
    var attitudes_count:Int=0
        
    /// 微博的用户  --必须和服务器的返回 KEY 要一一对应
    var user:WBUser?
    
    /// 被转发的原创微博
    var retweeted_status:WBStatus?
    
    /// 微博配图模型数组
    var pic_urls: [WBStatusPicture]?
    
    /// 重写 计算型属性
    override var description: String{
        return yy_modelDescription()
    }
    
    ///类函数 -》 告诉第三方框架yy_Model如果遇到数组类型的属性，数组存放的对象是什么类
    /// NSArray中保存对象类型通常是id类型
    /// OC 中的泛型是swift推出后，苹果为了兼容给oc增加的
    /// 从运行时角度，仍然不知道数组中应该存放什么类型的对象
    class func modelContainerPropertyGenericClass() -> [String:AnyClass]{
    
        return ["pic_urls":WBStatusPicture.self]
    }
}
