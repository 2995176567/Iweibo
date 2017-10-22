//
//  WBNetworkManage+Extension.swift
//  myweibo
//
//  Created by Walker on 16/11/5.
//  Copyright © 2016年 Walker. All rights reserved.
//

import Foundation

// MARK: -封装新浪微博的网络请求
extension WBNetworkManager{
    
    // 加载微博数据字典数组  －－完成回调
    // since_id    若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    // max_id   若指定此参数，则返回ID小于或等于max_id的微博，默认为0
    func statusList(since_id:Int64 = 0,max_id:Int64 = 0, completion:@escaping (_ list:[[String:Any]]?,_ isSuccess:Bool) -> ()){
        
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        let params=["since_id":since_id,"max_id":(max_id>0 ? max_id-1 :0)]
        
        tokenRequest(URLString: urlString, parameters: params ) { (json,isSuccess) in
           
            let jsonp = json as? [String:Any]
            
            let result = jsonp?["statuses"] as? [[String:Any]]
            
            completion(result,isSuccess)
        }
    }
    
    /// 返回微博的未读数量
    func unreadCount(completion:@escaping (_ count:Int)->()){
        
        guard let uid = userAccount.uid else{
            return
        }
    
        let urlString = "https://rm.api.weibo.com/2/remind/unread_count.json"
        
        let params = ["uid":uid]
        
        tokenRequest(URLString: urlString, parameters: params){ (json,isSuccess) in
            
            let dict = json as? [String:Any]
            let count = dict?["status"] as? Int
            
            completion(count ?? 0)
        }
    }
}

// MARK: - 发布微博
extension WBNetworkManager{
    /// 发布微博
    /// - Parameters:
    ///   - text: 要发布的文本
    ///   - image: 要上传的图像,可以为nil
    ///   - completion: 完成回调
    func postStatus(text:String,image:UIImage?, completion:@escaping (_ result:[String:Any]?,_ isSuccess:Bool) -> ()){
        
        let urlString:String
        if image==nil{
            // 根据是否有图像，选择不同的借口地址
            urlString = "https://api.weibo.com/2/statuses/update.json"
    
        }else{
            urlString="https://upload.api.weibo.com/2/statuses/upload.json"
        }
        
        //参数字典
        let params = ["status":text]
        
        // 如果图像不为空，需要设置 name 和 data
        var name:String?
        var data:Data?
        
        if image != nil {
        
            name = "pic"
            data=UIImagePNGRepresentation(image!)
        }
        
        //发起网络请求
        tokenRequest(method: .POST, URLString: urlString, parameters: params, name: name, data: data){
            (json,isSuccess) in
            
            completion(json as? [String:Any], isSuccess)
        }
    }
}

// 用户信息
extension WBNetworkManager{

    // 用户信息加载
    func loadUserInfo(completion:@escaping (_ dict:[String:Any]) -> ()){
    
        guard let uid = userAccount.uid else {
            return
        }
        
        let urlString = "https://api.weibo.com/2/users/show.json"
        
        let params = ["uid":uid]
        
        //发起网络请求
        tokenRequest(URLString: urlString, parameters: params){ (json,isSuccess) in
        
            //完成回调
            completion((json as? [String:Any]) ?? [:])
        }
    }
}

// OAuth 验证
extension WBNetworkManager{

    /// - Parameters:  加载token
    ///   - code: 授权码
    ///   - completion: 完成回调
    func loadAccessToken(code:String,completion:@escaping (_ isSuccess:Bool)->()){
    
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        let params = [
            "client_id":WBAppKey,
            "client_secret":WBAppSecret,
            "grant_type":"authorization_code",
            "code":code,
            "redirect_uri":WBRedirectURI
        ]
        
        //发起网络请求
        request(method: .POST, URLString: urlString, parameters: params){ (json,isSuccess) in
            
            //设置 userAccount 的属性 --- 用字典设置模型
            self.userAccount.yy_modelSet(with: (json as? [String:Any]) ?? [:])
            
            //加载用户当前信息
            self.loadUserInfo(completion: { (dict) in
                //print(dict)
                
                self.userAccount.yy_modelSet(with: dict)
                
                print(self.userAccount)

                //保存模型
                self.userAccount.saveAccount()
                
                // 加载完用户信息，在完成回调
                completion(isSuccess)
            })
        }
    }
}