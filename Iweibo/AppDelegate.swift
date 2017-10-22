//
//  AppDelegate.swift
//  myweibo
//
//  Created by Walker on 16/11/3.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit
import UserNotifications
import SVProgressHUD
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupAddition()
        
        window = UIWindow()
        window?.backgroundColor = UIColor.white
        
        //动态获取命名空间 - 用于多人开发
//        let clsName=Bundle.main.namespace+"."+"ViewController"
//        let cls=NSClassFromString(clsName) as? UIViewController.Type
//        let vc = cls?.init()
//        window?.rootViewController=vc
        
        window?.rootViewController = WBMainViewController()
        
        window?.makeKeyAndVisible()
        
        loadAppInfo()
        
        return true
    }
}

// 设置应用程序额外信息
extension AppDelegate{
    
    func setupAddition(){
        
        //设置 SVProgressHUD 最小解除时间
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        
        // 设置网络加载指示器－－－运营商旁边的加载圆圈
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        
        
        // 获取用户权限显示通知［上方的提示条／声音／badgeNumber］
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]){ (success,error) in
                print("授权 "+(success ? "成功" : "失败"))
            }
        } else {
            // Fallback on earlier versions
            // 10.0 以下
            let notifySettings = UIUserNotificationSettings(types:[.alert, .badge, .sound],categories:nil)
            
            UIApplication.shared.registerUserNotificationSettings(notifySettings)
        }
    }
}

// MARK: -从服务器加载应用程序信息
extension AppDelegate{
    
    func loadAppInfo(){
        
        // 模拟异步
        DispatchQueue.global().async {
            
            let url = Bundle.main.url(forResource: "main.json", withExtension: nil)
            
            //转为二进制数据
            let data = NSData(contentsOf: url!)
            
            //写入磁盘－－－取沙盒目录
            let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            let jsonPath = (docDir as NSString).appendingPathComponent("main.json")
            
            data?.write(toFile: jsonPath, atomically: true)
            
            print("应用程序加载完毕 \(jsonPath)")
        }
    }
}