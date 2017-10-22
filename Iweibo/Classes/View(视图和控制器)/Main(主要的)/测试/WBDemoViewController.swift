//
//  WBDemoViewController.swift
//  myweibo
//
//  Created by Walker on 16/11/3.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit

class WBDemoViewController: WBBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置标题
        title="第 \(navigationController?.childViewControllers.count ?? 0) 个"
    }
    
    // MARK -监听方法
    /// 继续 push一个新的控制器
    @objc func showNext(){
        
        let vc = WBDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension WBDemoViewController{
    
    //重写父类方法
    override func setupTableView() {
        super.setupTableView()
        
        //设置右侧的导航栏
        navItem.rightBarButtonItem = UIBarButtonItem(title: "下一个", target: self, action: #selector(showNext))
    }
}
