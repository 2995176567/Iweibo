//
//  WBBaseViewController.swift
//  myweibo
//
//  Created by Walker on 16/11/3.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit

class WBBaseViewController: UIViewController {
    
    /// 访客视图信息字典
    var visitorInfoDictionary:[String:String]?
    /// 表格视图 －－－如果用户没有登陆就不创建
    var tableView:UITableView?
    /// 刷新控件
    var refreshController:CZRefreshControl?
    /// 上拉刷新标记
    var isPullup = false
    /// 自定义导航条
    lazy var navigationBar = UINavigationBar(frame:CGRect(x: 0, y: 20, width: UIScreen.cz_screenWidth(), height: 44))
    //自定义的导航条目  －－以后设置导航栏内容，统一使用 navItem 
    lazy var navItem = UINavigationItem()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        WBNetworkManager.shared.userLogon ? loadData() : ()
        
        // 注册通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loginSuccess),
            name: NSNotification.Name(rawValue: WBUserLoginSuccessedNotification),
            object: nil)
        
        //loadData()
    }
    
    deinit {
    
        // 注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //重写 title 的 setter
    override var title: String?{
        didSet{
            navItem.title=title
        }
    }
    
    // 加载数据 － 具体的实现由子类负责
    @objc func loadData(){
        //如果子类不实现任何方法，默认关闭刷新控件
        refreshController?.endRefreshing()
    }
        
    private func setupUI(){
        
        view.backgroundColor = UIColor.cz_random()
    
        //取消自动缩进  --隐藏了导航栏，会缩进 20个点
        automaticallyAdjustsScrollViewInsets=false
        
        setupNavigationBar()
        
        WBNetworkManager.shared.userLogon ? setupTableView() : setupVisitorView()
    
    }
}

// MARK: -访客视图监听方法
extension WBBaseViewController{
    
    @objc func loginSuccess(n:Notification){
    
        print("登录成功 \(n)")
        //登录前左边是注册，右边是登录
        navItem.leftBarButtonItem=nil
        navItem.rightBarButtonItem=nil
    
        //更新 UI   将访客视图替换为表格视图，
        //在访问 view 的getter 时，如果 view ＝＝nil 会调用 loadView －》 viewDidLoad
        view = nil
        
        // 注销通知  ----避免重复注册(执行viewDidLoad会注册一次)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func login(){
                
        // 发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:WBUserShouldLoginNotification), object: nil)
    }
    
    @objc func register(){
        
        print("用户注册")
    }
}

// MARK: -设置界面
extension WBBaseViewController{
    
    /// 设置访客视图
    func setupVisitorView(){
        
        let visitorView = WBVisitorView(frame: view.bounds)
        
        //visitorView.backgroundColor = UIColor.cz_random()
        
        view.insertSubview(visitorView, belowSubview: navigationBar)
        
        // 设置访客视图信息
        visitorView.visitorInfo=visitorInfoDictionary
        
        // 添加访客视图按钮的监听方法
        visitorView.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        visitorView.registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        
        // 设置导航条按钮
        navItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(register))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(login))
    }
    
    /// 设置表格视图
    func setupTableView(){
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        
        view.insertSubview(tableView!, belowSubview: navigationBar)
        
        // 设置数据源&代理 －》 目的：子类直接实现数据源方法
        tableView?.dataSource=self
        tableView?.delegate=self
        
        // 设置内容缩进
        tableView?.contentInset = UIEdgeInsets(
            top: navigationBar.bounds.height, left: 0,
            bottom: tabBarController?.tabBar.bounds.height ?? 49,
            right: 0)
        
        // 修改指示器缩进－－－滑动条
        tableView?.scrollIndicatorInsets = tableView!.contentInset
        
        // 设置刷新控件  －－实例化控件
        refreshController = CZRefreshControl()
        
        //添加到表格视图
        tableView?.addSubview(refreshController!)
        
        //添加监听方法
        refreshController?.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    /// 设置导航条
    func setupNavigationBar(){
        
        //添加导航条
        view.addSubview(navigationBar)
        
        //将 item 设置给 bar
        navigationBar.items=[navItem]
        
        // 设置 navBar 的渲染颜色
        navigationBar.barTintColor = UIColor.cz_color(withHex: 0xF6F6F6)
        
        //设置 navBar 的字体颜色
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.darkGray]
        
        // 3> 设置系统按钮的文字渲染颜色
        navigationBar.tintColor = UIColor.orange
    }
}

// MARK: -UITableViewDataSource,UITableViewDelegate
extension WBBaseViewController:UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    // 基类只是准备方法，子类负责具体的实现
    // 子类的数据源方法不需要 super＋
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 10
    }
    
    // 在显示最后一行的时候，上拉刷新
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        
        let section=tableView.numberOfSections - 1
        
        if row < 0 || section < 0 {
            return
        }
        
        //行数
        let count = tableView.numberOfRows(inSection: section)
        
        if row == (count-1) && !isPullup{
            
            print("上拉刷新")
            isPullup = true
            
            //开始刷新
            loadData()
        }
    }
}