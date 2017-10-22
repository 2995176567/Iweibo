//
//  WBWelcome.swift
//  myweibo
//
//  Created by Walker on 16/11/15.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit
import SDWebImage

//欢迎视图
class WBWelcomeView: UIView {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var bottomCons: NSLayoutConstraint!

    class func welcomeView() -> WBWelcomeView{
    
        let nib = UINib(nibName: "WBWelcomeView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBWelcomeView
        
        // 从XIB 加载的视图 默认是600*600
        v.frame = UIScreen.main.bounds
        
        return v
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 提示：initWithCode 只是刚刚从xib的二进制文件将视图数据加载完成
        //还没有和代码连线建立起关系，所以开发时，千万不要在这个方法中处理UI
        
        //print("initWithCoder..2+\(iconView)")
    }
    
    override func awakeFromNib() {
        
        //print("initWithCoder..1+\(iconView)")
        guard let urlString = WBNetworkManager.shared.userAccount.avatar_large,
            let url = URL(string:urlString) else{
        
                return
        }
        
        //设置头像 - 如果网络图像没有下载完成，先显示站位图像
        // 如果不指定占位图像，之前设置的图像会被清空
        iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar_default_big"))
    }
    
    //视图添加到 window 上，表示视图已经显示
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        // 视图是使用自动布局设置的，只是设置了约束
        // 当视图被添加到窗口上时，根据父视图的大小，计算约束值，更新控件位置
        // layoutIfNeeded 会直接按照当前的约束直接更新控件位置
        // 执行之后，控件所在位置，就是xib 中布局的位置
        self.layoutIfNeeded()
        
        bottomCons.constant = bounds.size.height-200
        
        // 如果控件们的 frame 还没有计算好，所有的约束会一起动画
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        
                    //更新约束
                    self.layoutIfNeeded()
        }){ (_) in
            
            UIView.animate(withDuration: 1.0, animations: { 
                self.tipLabel.alpha = 1
            },completion:{ (_) in
            
                self.removeFromSuperview()
            })
        }
    }
}
