//
//  WBComposeTypeButton.swift
//  Iweibo
//
//  Created by walker on 2016/11/29.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit
//UIControl 内置了 touchupInside 事件响应
class WBComposeTypeButton: UIControl {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    
    //点击按钮要展示控制器的类型
    var clsName:String?
    
    // 使用图像名称／标题创建按钮，按钮布局从xib加载
    class func composeTypeButton(imageName:String,title:String) -> WBComposeTypeButton {
    
        let nib = UINib(nibName: "WBComposeTypeButton", bundle: nil)
        
        let btn = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeButton
        
        btn.imageView.image=UIImage(named: imageName)
        btn.titleLable.text=title
        
        return btn
    }
}
