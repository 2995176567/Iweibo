//
//  WBComposeViewController.swift
//  Iweibo
//
//  Created by walker on 2016/11/29.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit
import SVProgressHUD

class WBComposeViewController: UIViewController {

    /// 文本编辑视图
    @IBOutlet weak var textView: WBComposeTextView!
    /// 底部工具栏
    @IBOutlet weak var toolbar: UIToolbar!
    /// 发布按钮
    @IBOutlet var sendButton: UIButton!
    /// 标题标签
    @IBOutlet var titleLabel: UILabel!
    // 工具栏底部约束
    @IBOutlet weak var toolbarButtonCons: NSLayoutConstraint!
    
    lazy var emoticonView:CZEmoticonInputView=CZEmoticonInputView.inputView { [weak self] (emoticon) in
        
        self?.textView.insertEmoticon(em:emoticon)
    }
    
    // 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // 监听键盘通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // 激活键盘
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 关闭键盘
        textView.resignFirstResponder()
    }
    
    // 键盘监听
    @objc private func keyboardChanged(n:Notification){
    
        //print(n.userInfo)
        // 目标 rect
        guard let rect = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let duration=(n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else{
        
            return
        }
        
        // 设置底部约束的高度
        let offset = view.bounds.height - rect.origin.y
        
        // 更新底部约束
        toolbarButtonCons.constant=offset
        // 动画更新约束
        UIView.animate(withDuration: duration){
            self.view.layoutIfNeeded()
        }
    }

    @objc func close(){
        dismiss(animated: true, completion: nil)
    }
    
    // 按钮监听方法
    /// 发布微博
    @IBAction func postStatus() {
        
        //获取发送给服务器的表情微博文字
        let text = textView.emoticonText
        
        // 发布微博---临时测试带图片的微博
        let image:UIImage? = nil//UIImage(named: "icon_small_kangaroo_loading_1")
        
        WBNetworkManager.shared.postStatus(text: text,image:image){ (result,isSuccess) in
            //print(result as Any)
            
            // 修改样式
            SVProgressHUD.setDefaultStyle(.dark)
            
            let message=isSuccess ? "发布成功" : "网络不给力"
            
            SVProgressHUD.showInfo(withStatus: message)
            
            //如果成功，延迟一段时间关闭当前窗口
            if isSuccess{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1){
                    
                    // 恢复样式
                    SVProgressHUD.setDefaultStyle(.light)
                    
                    self.close()
                }
            }
        }
    }
    
    // 切换表情键盘
    @objc func emoticonKeyboard(){
        //  测试键盘视图 -视图的宽度可以随便，就是屏幕的宽度
//        let keyboardView=UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 253))
//        keyboardView.backgroundColor=UIColor.blue
        // 设置键盘视图
        textView.inputView=(textView.inputView==nil) ? emoticonView :nil
        // 刷新键盘视图
        textView.reloadInputViews()
    }
 }

extension WBComposeViewController:UITextViewDelegate{
    
    // 文本视图文字变化
    func textViewDidChangeSelection(_ textView: UITextView) {
        sendButton.isEnabled=textView.hasText
    }
    
//    lazy var sendButton:UIButton={
//    
//        let btn = UIButton()
//        
//        btn.setTitle("发布", for: [])
//        btn.titleLabel?.font=UIFont.systemFont(ofSize: 14)
//        
//        // 设置标题颜色
//        btn.setTitleColor(UIColor.white, for: [])
//        btn.setTitleColor(UIColor.gray, for: .disabled)
//        
//        // 设置背景图片
//        btn.setBackgroundImage(UIImage(named:"common_button_orange"), for: [])
//        btn.setBackgroundImage(UIImage(named:"common_button_orange_highlighted"), for: .highlighted)
//        btn.setBackgroundImage(UIImage(named:"common_button_white_disable"), for: .disabled)
//        
//        // 设置大小
//        btn.frame=CGRect(x: 0, y: 0, width: 45, height: 35)
//        
//        return btn
//    
//    }()

}

private extension WBComposeViewController{
    
    func setupUI(){
        view.backgroundColor=UIColor.white
        
        setupNavigationBar()
        
        setupToolbar()
    }
    
    /// 设置工具栏
    func setupToolbar(){
        
        let itemSettings = [["imageName": "compose_toolbar_picture"],
                            ["imageName": "compose_mentionbutton_background"],
                            ["imageName": "compose_trendbutton_background"],
                            ["imageName": "compose_emoticonbutton_background", "actionName": "emoticonKeyboard"],
                            ["imageName": "compose_add_background"]]
        
        //遍历数组
        var items=[UIBarButtonItem]()
        for s in itemSettings{
            
            guard let imageName=s["imageName"] else{
                continue
            }
            
            let image=UIImage(named: imageName)
            let imageHL=UIImage(named: imageName+"_highlighted")
        
            let btn = UIButton()
            
            btn.setImage(image, for: [])
            btn.setImage(imageHL, for: .highlighted)
            
            btn.sizeToFit()
            
            // 判断actionName
            if let actionName = s["actionName"]{
                //给按钮添加监听方法
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }
            
            // 追加按钮
            items.append(UIBarButtonItem(customView: btn))
            
            //追加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        
        // 删除末尾弹簧
        items.removeLast()
        
        toolbar.items=items
    }
    
    // 设置导航栏
    func setupNavigationBar(){
        navigationItem.leftBarButtonItem=UIBarButtonItem(title: "关闭", target: self, action: #selector(close))
    
        // 设置发送按钮
        navigationItem.rightBarButtonItem=UIBarButtonItem(customView: sendButton)
    
        // 设置标题视图
        navigationItem.titleView=titleLabel
        
        sendButton.isEnabled=false
    }
}