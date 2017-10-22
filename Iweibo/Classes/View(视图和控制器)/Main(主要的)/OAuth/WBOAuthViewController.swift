//
//  WBOAuthViewController.swift
//  myweibo
//
//  Created by Walker on 16/11/6.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit
import SVProgressHUD

// 通过 webview 加载新浪授权页面控制器
class WBOAuthViewController: UIViewController {
    
    private lazy var webView = UIWebView()
    
    override func loadView() {
        view=webView
        view.backgroundColor = UIColor.white
        // 取消滚动视图
        webView.scrollView.isScrollEnabled = false
        //设置代理
        webView.delegate = self
        // 设置导航栏
        title = "登录新浪微博"
        
        // 设置导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", target: self, action: #selector(close), isBack: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", target: self, action: #selector(autoFill))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //加载授权页面 --访问资源
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(WBAppKey)&redirect_uri=\(WBRedirectURI)"
        
        guard let url = URL(string: urlString) else{
            return
        }
        
        //建立请求
        let request = URLRequest(url: url)
        
        //加载请求
        webView.loadRequest(request)
    }
    
    // MARK: -监听方法
    @objc func close(){
        
        SVProgressHUD.dismiss()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func autoFill(){
        
        //准备 js
        let js="document.getElementById('userId').value = '320553500@qq.com'; document.getElementById('passwd').value = '&Raidy@350';"
        
        // 让 webview 执行 js
        webView.stringByEvaluatingJavaScript(from: js)
    }
}

extension WBOAuthViewController:UIWebViewDelegate{

    /// webView
    ///
    /// - Parameters:
    ///   - webView: webView
    ///   - request: 要加载的请求
    ///   - navigationType: 导航类型
    /// - Returns: 是否加载
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if request.url?.absoluteString.hasPrefix(WBRedirectURI) == false {
            return true
        }
        
        print("加载请求 －－－\(String(describing: request.url?.absoluteString))")
        // 获取？后面的内容
        print("加载请求 －－－\(String(describing: request.url?.query))")
        
        // 字符串中是否有code 有，则授权成功
        if request.url?.query?.hasPrefix("code=") == false{
            print("取消授权")
            close()
            return false
        }
        
        let code = request.url?.query?.substring(from:"code=".endIndex) ?? ""
        
        WBNetworkManager.shared.loadAccessToken(code: code){ (isSuccess) in
        
            if !isSuccess {
            
                SVProgressHUD.showInfo(withStatus: "网络请求失败")
            }else{
                            
                // 跳转界面（单例）  ----- 通过通知跳转－－－不关心有没有监听者
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:WBUserLoginSuccessedNotification), object: nil)
                
                //关闭窗口
                self.close()
            }
        }
        return false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}