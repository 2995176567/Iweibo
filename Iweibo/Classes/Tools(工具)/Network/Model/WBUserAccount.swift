//
//  WBUserAccount.swift
//  myweibo
//
//  Created by Walker on 16/11/6.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit

private let accountFile:NSString = "useraccount.json"

//用户账户信息
class WBUserAccount:NSObject{

    //访问令牌
    var access_token:String?
    
    // 用户代号
    var uid:String?
    
    //过期日期 单位s  －－－－开发者5年－－用户3天
    var expires_in: TimeInterval = 0.0{
        didSet{
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    
    }
    // 过期日期
    var expiresDate:Date?
    
    
    // 用户昵称
    var screen_name:String?
    
    // 用户头像
    var avatar_large:String?
    
    
    
    
    
    
    override var description:String {
        return yy_modelDescription()
    }
    
    
    override init(){
    
        super.init()
        
        // 从磁盘中读取保存到文件
        guard let path = accountFile.cz_appendDocumentDir(),
            let data = NSData(contentsOfFile: path),
            let dict = try? JSONSerialization.jsonObject(with: data as Data, options: []) as? [String:Any]
        
        else{
        
            return
        }
        
        
        // 使用字典设置属性
        yy_modelSet(with: dict ?? [:])
        
        print("从沙盒加载用户信息 \(self)")
        
        //测试过期日期
        //expiresDate = Date(timeIntervalSinceNow: -3600*24)
        
        //print(expiresDate as Any)
        
        // 判断 token 是否过期  orderedDescending 降序    现在expiresDate比现在时间小
        if expiresDate?.compare(Date()) != .orderedDescending {
        
            print("账户过期")
            
            access_token = nil
            uid = nil
            
            // 删除账户文件
            try? FileManager.default.removeItem(atPath: path)
            
            
        }
        
        print("账户正常 \(self)")
        
    
    }
    
    
    
    
    
    
    //偏好设置（小）
    //沙盒 － 归档／plist／json
    //数据库（FMDB/CoreData）
    //钥匙串访问（小／自动加密－－需要使用框架 SSKeychain）
    func saveAccount(){
        
        // 模型转字典
        var dict = (self.yy_modelToJSONObject() as? [String:Any]) ?? [:]
        
        //需要删除 expires_in
        dict.removeValue(forKey: "expires_in")
        
        // 序列化----写入磁盘
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),let filePath = accountFile.cz_appendDocumentDir() else{
        
            return
        }

        
        //写入磁盘
        (data as NSData).write(toFile: filePath, atomically: true)
        
    
        print("用户账户保存成功 \(filePath)")
    }
    
    

}
