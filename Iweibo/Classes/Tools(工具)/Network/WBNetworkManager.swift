//
//  WBNetworkManager.swift
//  myweibo
//
//  Created by Walker on 16/11/5.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit

import AFNetworking


/// Swift 的枚举支持任意数据类型
/// swift / enum 在 OC 中 都只支持整数

// 返回状态码：405，不支持网络请求方法
enum WBHTTPMethod{
    case GET
    case POST
}

// 网络管理工具
class WBNetworkManager: AFHTTPSessionManager {
    
    /// 静态区 ／常量 ／闭包
    // 在第一次访问时，执行闭包，并且将结果保存在 shared 常量中
    static let shared:WBNetworkManager = {
        //实例化对象
        let instance = WBNetworkManager()
        
        //设置相应反序列化支持的类型
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        return instance
    }()
    
    // 用户账户的懒加载属性
    lazy var userAccount = WBUserAccount()
    
    // 用户登录标记
    var userLogon :Bool{
        return userAccount.access_token != nil
    }
    
    /// 专门负责拼接 token 的网络请求
    ///
    /// - Parameters:
    ///   - method: get/post
    ///   - URLString: URLString
    ///   - parameters: 参数字典
    ///   - name: 上传文件使用的字段名，默认为nil，就不是上传文件
    ///   - data: 上传文件的二进制数据，默认为nil，不上传文件
    ///   - completion: 完成回调
    func tokenRequest(method:WBHTTPMethod = .GET,URLString:String,parameters:[String:Any]?,name:String?=nil,data:Data?=nil,completion:@escaping (_ json:Any?,_ isSuccess:Bool)->()){
        
        //处理 token 字典
        guard let token = userAccount.access_token else {
            
            //发送通知，提示用户登录
            print("没有token，需要登录！")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:WBUserShouldLoginNotification), object: nil)
            
            completion(nil,false)
            
            return
        }
        
        var parameters = parameters
        if parameters == nil {
            // 实例化字典
            parameters = [String:Any]()
        }
        
        // 设置参数字典
        parameters!["access_token"] = token
        
        // 判断 name 和 data
        if let name=name,let data=data{
            //上传文件
            upload(URLString: URLString, parameters: parameters, data: data, name: name, completion: completion)
        }else{
            
             // 调用 request 发起真正的网络请求
            request(method:method, URLString: URLString, parameters: parameters, completion: completion)
        }
    }
    
    /// 封装 AVNF 上传文件，上传文件必须是post  
    /// Data--二进制数据,name--接收上传数据的服务器字段
    func upload(URLString:String,parameters:[String:Any]?,data:Data,name:String,completion:@escaping (_ json:Any?,_ isSuccess:Bool)->()){
        
        post(URLString, parameters: parameters, constructingBodyWith:{ (formData) in
            
            //创建 formData
            /**
             data:要上传的二进制数据
             name:服务器接收数据的字段名
             fileName：保存在服务器的文件名
             mimeType：告诉服务器文件的类型
          */
            formData.appendPart(withFileData: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
            
            },progress:nil,success:{ (_,json) in
                 completion(json,true)
            }){ (task,error) in
                
                if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                    print("token 过期了")
                    
                    // 发送通知（谁接受到通知谁就处理）
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: "bad token")
                }
                
                print("网路请求错误 \(error)")
                
                completion(nil,false)
            }
    }

    /// 使用一个函数封装 AFN 的 GET ／ POST 请求
    func request(method:WBHTTPMethod = .GET,URLString:String,parameters:[String:Any]?,completion:@escaping (_ json:Any?,_ isSuccess:Bool)->()){
        
        //成功回调
        let success = { (task: URLSessionDataTask,json:Any?) -> () in
        
            completion(json,true)
        }
        
        //失败回调
        let failure = { (task:URLSessionDataTask?,error:Error) -> () in
            
            // 针对 403 处理用户 token 过期
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("token 过期了")
                
                // 发送通知（谁接受到通知谁就处理）
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: "bad token")
            }
            
            print("网路请求错误 \(error)")
            
            completion(nil,false)
        }
        
        if method == .GET{
            
            get(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }else{
            post(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}
