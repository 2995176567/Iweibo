//
//  WBWebViewController.swift
//  Iweibo
//
//  Created by walker on 2016/12/2.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit

// 网页控制器
class WBWebViewController: WBBaseViewController {

    lazy var webView = UIWebView(frame: UIScreen.main.bounds)
    
    var urlString:String?{
    
        didSet{
            guard let urlString=urlString,
                let url=URL(string:urlString) else {
                return
            }
            
            webView.loadRequest(URLRequest(url: url))
        }
    }
}

extension WBWebViewController{

    override func setupTableView() {
        //super.setupTableView()
        
        navItem.title="网页"
        
        view.insertSubview(webView, belowSubview: navigationBar)
        webView.backgroundColor=UIColor.white
        
        // 设置 contentInset
        webView.scrollView.contentInset.top=navigationBar.bounds.height
    }
}