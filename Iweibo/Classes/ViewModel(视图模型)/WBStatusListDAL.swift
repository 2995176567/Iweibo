//
//  WBStatusListDAL.swift
//  Iweibo
//
//  Created by walker on 2016/12/5.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import Foundation

/// 数据访问层----处理数据库和网络数据，返回微博的[字典数组]
class WBStatusListDAL{
    
    /// 从本地数据库或网络加载数据
    ///
    /// - Parameters:
    ///   - since_id: 下拉刷新
    ///   - max_id: 上拉刷新
    ///   - completion: 完成回调（微博的字典数组，是否成功）
    class func loadStatus(since_id: Int64 = 0, max_id: Int64 = 0,completion:@escaping (_ list:[[String:Any]]?,_ isSuccess:Bool) -> ()){
    
        guard let userId = WBNetworkManager.shared.userAccount.uid else{
        
            return
        }
        
        // 检查本地数据，如果有，直接返回
        let array = CZSQLiteManager.shared.loadStatus(userId: userId, since_id: since_id, max_id: max_id)
        
        // 判断数组的数量 []
        if array.count>0{
            completion(array, true)
            return
        }
        
        // 加载网络数据
        WBNetworkManager.shared.statusList(since_id: since_id, max_id: max_id){ (list,isSuccess) in
            // 判断网络请求是否为空
            if !isSuccess {
                completion(nil, false)
                return
            }
            
            guard let list = list else{
                completion(nil, isSuccess)
                return
            }
            
            // 加载完成之后，将网络数据[数据字典]，写入数据库
            CZSQLiteManager.shared.updateStatus(userId: userId, array: list)
        
            // 返回网络数据
            completion(list, isSuccess)
        }
    }
}
