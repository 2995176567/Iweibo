//
//  WBMainViewController.swift
//  myweibo
//
//  Created by Walker on 16/11/3.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 主控制器
class WBMainViewController: UITabBarController {
    
    //定时器
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildControllers()
        setupComposeButton()
        setupTimer()
   
        setupNewfeatureViews()
        
        // 设置代理
        delegate = self
        
        // 注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(userLongin), name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: nil)
    }
    
    deinit {
        //销毁时钟
        timer?.invalidate()
        
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    // portrait ：竖屏    landscape ：横屏
    //使用代码控制
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    // 监听方法
    @objc private func userLongin(n:Notification){
        print("用户登录通知 \(n)")
        
        var when = DispatchTime.now()
        
        //判断 n.object 是否有值，如果有值，提示用户重新登录
        if n.object != nil {
        
            SVProgressHUD.setDefaultMaskType(.gradient)
            
            SVProgressHUD.showInfo(withStatus: "用户登录已经超时，需要重新登录")
            
            //修改延迟时间
            when = DispatchTime.now()+2
        }
        
        DispatchQueue.main.asyncAfter(deadline: when){

            SVProgressHUD.setDefaultMaskType(.clear)
            
            // 展现登录控制器 --通常会和 UINavigationController 连用，方便返回
            let nav = UINavigationController(rootViewController: WBOAuthViewController())
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    // MARK: - 私有控件
    ///撰写按钮
    lazy var composeButton: UIButton = UIButton.cz_imageButton(
        "tabbar_compose_icon_add",backgroundImageName:"tabbar_compose_button"
    )
    
    // MARK: -监听方法
    /// 撰写微博
    @objc func composeStatus(){
        print("撰写微博")
        
        //判断是否登录
        //实例化视图
        let v = WBComposeTypeView.compseTypeView()
        
        //显示视图
        v.show{ [weak v] (clsName) in
            
            print(clsName as Any)
            //展现撰写微博控制器
            guard let clsName=clsName,
            let cls=NSClassFromString(Bundle.main.namespace+"."+clsName) as? UIViewController.Type else{
                
                v?.removeFromSuperview()
                return
            }
            
            let vc = cls.init()
            
            let nav=UINavigationController(rootViewController: vc)
            
            // 让导航控制器强行更新约束
            nav.view.layoutIfNeeded()
            
            self.present(nav, animated: true){
                //
                v?.removeFromSuperview()
            }
        }
    }
}

extension WBMainViewController{

    func setupNewfeatureViews(){
        
        //判断是否登录
        if !WBNetworkManager.shared.userLogon{
            return
        }
        
        //检查版本是否更新
        let v = isNewVersion ? WBNewFeatureView.newFeatureView() : WBWelcomeView.welcomeView()
        
        //如果更新，显示新特性。否则欢迎
        //v.frame = view.bounds
        
        //添加视图
        view.addSubview(v)
    }

    //版本号
    private var isNewVersion:Bool{
        
        //获取当前版本号
        print(Bundle.main.infoDictionary as Any)
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        print("当前版本："+currentVersion)
        
        //保存在Document［理想保存在用户偏好］目录中之前的版本号
        let path:String = ("version" as NSString).cz_appendDocumentDir()
        let sandboxVersion = (try? String(contentsOfFile:path)) ?? ""
        
        print("沙盒版本："+sandboxVersion)
        
        //将当前的版本号保存到沙盒
        try? currentVersion.write(toFile: path, atomically: true, encoding: .utf8)
        
        // 返回两个版本号是否一致
        return currentVersion != sandboxVersion
    }
}

extension WBMainViewController:UITabBarControllerDelegate{
    
    //UIViewController  目标控制器
    //return 是否切换到目标控制器
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        print("将要切换到 \(viewController)")
        
        // 获取控制器在数组中的索引
        let idx=(childViewControllers as NSArray).index(of: viewController)
        
        //判断当前索引是首页，同时idx 也是首页，重复点击首页的按钮
        if selectedIndex == 0 && idx == selectedIndex{
            print("点击首页")
            
            //获取控制器－－－让表格滚动到顶部
            let nav = childViewControllers[0] as! UINavigationController
            let vc = nav.childViewControllers[0] as! WBHomeViewController
            
            // 滚动到顶部
            vc.tableView?.setContentOffset(CGPoint(x:0,y:-64), animated: true)
            
            //刷新数据---增加延迟，是保证表格先滚动到顶部在刷新
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                vc.loadData()
            })
            
            // 清除 tabItem 的badgeNumber
            vc.tabBarItem.badgeValue=nil
            UIApplication.shared.applicationIconBadgeNumber=0
        }
        //判断目标控制器是否是 UIViewController
        return !viewController.isMember(of: UIViewController.self)
    }
}

/// 时钟相关方法
extension WBMainViewController{

    // 定义时钟
    func setupTimer(){
        
        // 时间间隔建议长些
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer(){
        
        if !WBNetworkManager.shared.userLogon{
            return
        }
        
        WBNetworkManager.shared.unreadCount{ (count) in
            
            print("检测到 \(count) 条新微博")
            
            // 设置 首页 tabBaritem
            self.tabBar.items?[0].badgeValue = count>0 ? "\(count)" : nil
        
            // 设置 app 的badgeNumber  8.0 后授权以后才显示
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
}

// MARK:  －设置界面
extension WBMainViewController{
    
    //设置撰写按钮
    func setupComposeButton(){
        tabBar.addSubview(composeButton)
        
        //计算按钮的宽度
        let count = CGFloat(childViewControllers.count)
        //将向内缩进的宽度
        let w = tabBar.bounds.width/count
        
        //正数向内缩进，负数向外扩展
        composeButton.frame = tabBar.bounds.insetBy(dx: 2*w, dy: 0)
        
        print("按钮宽度 \(composeButton.bounds.width)")
        
        //按钮监听方法
        composeButton.addTarget(self, action: #selector(composeStatus), for: .touchUpInside)
    }
    
    /// 设置所有子控制器
    func setupChildControllers(){
        
        //写入磁盘－－－取沙盒目录
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let jsonPath = (docDir as NSString).appendingPathComponent("main.json")
        
        //加载data
        var data = NSData(contentsOfFile: jsonPath)
        
        //判断 data 是否有内容，如果没有，说明本地沙盒没有文件
        if data == nil {
            let path = Bundle.main.path(forResource: "main.json", ofType: nil)
            
            data = NSData(contentsOfFile: path!)
        }
        
        //反序列化
        // 从 Boudle 加载配置 json
        guard let array = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [[String:Any]]
            else {
                
            return
        }
        
        // 遍历数组，循环创建控制器数组
        var arrayM = [UIViewController]()
        for dict in array! {
            arrayM.append(controller(dict: dict))
        }
        
        //设置 tabBar 的子控制器
        viewControllers = arrayM
    }
    
    /// 信息字典  －－子控制器
    private func controller(dict:[String:Any]) ->UIViewController{
        
        //获取字典内容
        guard let clsName = dict["clsName"] as? String,
            let title = dict["title"] as? String,
            let imageName = dict["imageName"] as? String,
            let cls = NSClassFromString(Bundle.main.namespace + "." + clsName) as? WBBaseViewController.Type,
            let visitorDict = dict["visitorInfo"] as? [String:String]
            else{
        
            return UIViewController()
        }
        
        //创建视图控制器
        let vc = cls.init()
        
        vc.title = title
        
        // 设置控制访客信息字典
        vc.visitorInfoDictionary=visitorDict
        
        // 设置图像
        vc.tabBarItem.image = UIImage(named:"tabbar_"+imageName)
        vc.tabBarItem.selectedImage = UIImage(named: "tabbar_"+imageName+"_selected")?.withRenderingMode(.alwaysOriginal)
        
        //设置 tabbar 的标题字体
        vc.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.orange],for: .highlighted)
        //设置字体 －－－系统默认是12号字
        vc.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12)],for: UIControlState(rawValue:0))
    
        // 实例化导航控制器的时候，会调用 push 方法 将 rootVC 压栈
        let nav = WBVavigationController(rootViewController: vc)
        
        return nav
    }
}