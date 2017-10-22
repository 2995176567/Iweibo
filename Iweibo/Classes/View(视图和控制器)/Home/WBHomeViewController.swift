//
//  WBHomeViewController.swift
//  myweibo
//
//  Created by Walker on 16/11/3.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit

// 原创微博可重用 cell ID
private let originalCellId = "originalCellId"
//被转发微博的可重用 cell id
private let retweetedCellId="retweetedCellId"

class WBHomeViewController: WBBaseViewController {
    
    // 列表视图模型
    lazy var listViewModel = WBStatusListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(browserPhoto),
            name: NSNotification.Name(rawValue: WBStatusCellBrowserPhotoNotification),
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 浏览照片监听方法
    @objc private func browserPhoto(n:Notification){
        
        // 从通知的 userInfo 提取参数
        guard let selectedIndex=n.userInfo?[WBStatusCellBrowserPhotoSelectedIndexKey] as? Int,
        let urls=n.userInfo?[WBStatusCellBrowserPhotoURLsKey] as? [String],
        let imageViewList=n.userInfo?[WBStatusCellBrowserPhotoImageViewsKey] as? [UIImageView]
        else{
            return
        
        }

        // 展现照片浏览器
        let vc = HMPhotoBrowserController.photoBrowser(
            withSelectedIndex: selectedIndex,
            urls: urls,
            parentImageViews: imageViewList)
        
        present(vc, animated: true, completion: nil)
    }
    
    //加载数据
    override func loadData() {
        
        refreshController?.beginRefreshing()
        
      //  print("准备刷新，最后一条 \(self.listViewModel.statusList.last?.text)")
        
        listViewModel.loadStatus(pullup: self.isPullup){ (isSuccess,hasMorePullup) in
            //
            print("加载数据结束")
            
            //结束刷新
            self.refreshController?.endRefreshing()
            //恢复上拉刷新标记
            self.isPullup=false
            
            if hasMorePullup{
                
                //刷新表格
                self.tableView?.reloadData()
            }
        }
    }
    
    //显示好友
    @objc func showFriends(){
        print(#function)
        
        let vc=WBDemoViewController()
        
        //隐藏下面的tabbar
        vc.hidesBottomBarWhenPushed=true
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: -表格数据源方法   具体的数据源方法实现，不需要 super
extension WBHomeViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //取视图模型，根据视图模型判断可重用 cell
        let vm=listViewModel.statusList[indexPath.row]
        
        let cellId=(vm.status.retweeted_status != nil) ? retweetedCellId :originalCellId
        // 取cell
        let cell=tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WBStatusCell
        
       // 设置 cell
        cell.viewModel=vm
        
        // 设置代理
        cell.delegate=self
        
        // 返回 cell
        return cell
    }
    // 父类必须实现代理方法，子类才能够重写，swift 3.0
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //根据indexPath 获取视图模型
        let vm = listViewModel.statusList[indexPath.row]
        
        //返回计算好的行高
        return vm.rowHeight
    }
}

extension WBHomeViewController:WBStatusCellDelegate{
    
    func statusCellDidSelectedURLString(cell: WBStatusCell, urlString: String) {
                
        let vc = WBWebViewController()
        
        vc.urlString=urlString
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 设置界面
extension WBHomeViewController{
    
    override func setupTableView() {
        super.setupTableView()
        
        // 设置导航栏按钮
        //无法高亮
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "好友", style: .plain, target: self, action: #selector(showFriends))
        
        navItem.leftBarButtonItem = UIBarButtonItem(title: "好友", target: self, action: #selector(showFriends))
        
        // 注册原型 cell
        tableView?.register(UINib(nibName:"WBStatusNormalCell",bundle:nil), forCellReuseIdentifier: originalCellId)
        
        tableView?.register(UINib(nibName:"WBStatusRetweetedCell",bundle:nil), forCellReuseIdentifier: retweetedCellId)
        
//        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
//        
//        tableView?.register(UINib(nibName: "WBStatusNormalCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        //设置行高
        //tableView?.rowHeight=UITableViewAutomaticDimension
        tableView?.estimatedRowHeight=300
        
        //取消分隔线
        tableView?.separatorStyle = .none
        
        setupNavTitle()
    }

    //设置导航栏标题
    private func setupNavTitle(){
        
        let title = WBNetworkManager.shared.userAccount.screen_name
        
        let button = WBTitleButton(title: title)
       
        navItem.titleView = button
        
        button.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
    }
    
    @objc func clickTitleButton(btn:UIButton){
    
        //设置选中状态
        btn.isSelected = !btn.isSelected
    }
}
