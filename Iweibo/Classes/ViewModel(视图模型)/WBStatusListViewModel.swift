//
//  WBStatusListViewModel.swift
//  myweibo
//
//  Created by Walker on 16/11/5.
//  Copyright © 2016年 Walker. All rights reserved.
//

import Foundation
import SDWebImage

/// 上拉刷新最大尝试次数
let maxPullupTryTime = 3

///  微博列表视图模型-------需要使用 KVC 或字典转模型设置对象值，类就要继承 NSObject
// 负责微博的数据处理
class WBStatusListViewModel {
    
    /// 微博视图模型数组懒加载
    lazy var statusList = [WBStatusViewModel]()
    
    /// 上拉刷新错误加载
    private var pullupErrorTimes = 0
    
    //pullup 是否上拉刷新
    func loadStatus(pullup:Bool, completion:@escaping (_ isSuccess:Bool,_ shouldRefresh: Bool)->()){
        
        // 判断是否是上拉刷新，并且检查错误
        if pullup && pullupErrorTimes > maxPullupTryTime {
            completion(false,false)
            return
        }
        
        //since_id 取出数组中第一条微博的 ID
        let since_id = pullup ? 0 : (statusList.first?.status.id ?? 0)
        
        // 上拉刷新，取出数组的最后一条微博的id
        let max_id = !pullup ? 0 : (statusList.last?.status.id ?? 0)
        
        // 让数据访问层加载数据
        WBStatusListDAL.loadStatus(since_id: since_id, max_id: max_id){ (list,isSuccess) in
            
        // 发起网络请求，加载微博数据（字典的数组）
//        WBNetworkManager.shared.statusList(since_id: since_id,max_id: max_id){ (list ,isSuccess) in
            
            //判断网络请求是否成功
            if !isSuccess{
                completion(false, false)
                return
            }
            
            //字典转模型（所有第三方框架都支持嵌套的字典转模型）
            //定义结果可变数组
            var array=[WBStatusViewModel]()
            
            //遍历服务器返回的字典数组，字典转模型
            for dict in list ?? [] {
                
                //print(dict["pic_urls"] as Any)
                
                //创建微博模型
                guard let model = WBStatus.yy_model(with: dict) else{
                    continue
                }
                
                //将视图模型添加到数组
                array.append(WBStatusViewModel(model:model))
            }
            print("刷新到 \(array.count) 条数据  \(array)")
        
            // 拼接数据
            if pullup {
                
                // 上拉刷新
                self.statusList += array
                
            }else{
                // 下拉刷新
                self.statusList = array + self.statusList
            }
            
            // 判断上拉刷新的数据量
            if pullup && array.count == 0 {
                
                self.pullupErrorTimes += 1
                
                completion(isSuccess, false)
            }else{
                
                self.cacheSingleImage(list: array,finished: completion)
            
                // 完成回调
                //completion(isSuccess,true)
            }
        }
    }
    
    /// 缓存本次下载微博数据数组中的单张图像
    /// - 应该缓存完单张图像，并且修改过配图是的大小之后，在回调，不能够保证表格等比例显示单张图像
    /// - Parameter list: 本次下载的视图模型数组
    private func cacheSingleImage(list:[WBStatusViewModel],finished:@escaping (_ isSuccess:Bool,_ shouldRefresh: Bool)->()){
        
        //调度组
        let group=DispatchGroup()
        
        //记录数据长度
        var length = 0
    
        // 遍历数组，查找微博数组中有单张图像，进行缓存
        for vm in list {
        
            if vm.picURLs?.count  != 1 {
            
                continue
            }
        
            //获取图像模型--只有一张图片
            guard let pic = vm.picURLs?[0].thumbnail_pic,
                let url = URL(string:pic) else{
                    continue
            }
            
           // print("要缓存的 URL 是 \(url)")
            
            // 下载图像
            //downloadImage 是 SDWebImage 的核心方法
            //图形下载完成之后，会自动保存在沙盒中，文件路径是url的md5
            //如果沙盒中已经存在缓存的图像，后续使用SD通过URL加载图像，都会加载沙盒的图像
            //不会发起网络请求，同时，回调方法，同样会调用
            // 如果要缓存的图像累计很大，要找后台要接口
            
            //入组
            group.enter()
            
            SDWebImageManager.shared().downloadImage(with: url, options: [], progress: nil, completed: { (image, _, _, _, _) in
                
                //将图像转换成二进制数据
                if let image = image,
                    let data=UIImagePNGRepresentation(image){
                    //NSData 是length属性
                    length += data.count
                    
                    vm.updateSingleImageSize(image: image)
                }
                
                print("缓存的图像是 \(String(describing: image))长度 \(length)")
                
                //出组---一定要放在最后
                group.leave()
            })
        }
    
        // 监听调度组情况
        group.notify(queue: DispatchQueue.main){
            print("图像缓存完成 \(length/1024) K")
            
            // 执行闭包回调
            finished(true, true)
        }
    }
}
