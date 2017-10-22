//
//  WBVavigationController.swift
//  myweibo
//
//  Created by Walker on 16/11/3.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit

class WBVavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isHidden=true
    }
    
    // viewController 是被 push 的控制器 ，设置他的左侧的按钮作为返回按钮
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        print(viewController)
        //如果不是栈底控制器才需要隐藏，根控制器不需要处理
        if childViewControllers.count>0{
            // 隐藏底部的 tabbar
            viewController.hidesBottomBarWhenPushed=true
            
            //判断控制器的类型
            if let vc = viewController as? WBBaseViewController{
                
                var title = "返回"
                // 判断控制的级数，只有一个子控制器是，显示栈底的标题
                if childViewControllers.count == 1 {
                    
                    //显示首页的标题
                    title = childViewControllers.first?.title ?? "返回"
                }
                
                //取出自定义的navItem ,设置左侧按钮作为返回按钮
                vc.navItem.leftBarButtonItem=UIBarButtonItem(title: title, target: self, action: #selector(popToParent),isBack: true)
            }
        }
        
        // 重写 push 方法，所有的push动作都会调用此方法
        super.pushViewController(viewController, animated: true)
    }

    /// pop返回到上一级控制器
    @objc private func popToParent(){
        popViewController(animated: true)
    }
}
