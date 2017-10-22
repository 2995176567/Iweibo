//
//  WBTitleButton.swift
//  myweibo
//
//  Created by Walker on 16/11/15.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit

class WBTitleButton: UIButton {

    init(title:String?) {
        super.init(frame: CGRect())
        
        if title == nil {
            setTitle("首页",for:[])
        }else{
            setTitle(title!+" ", for: [])
            //设置图像
            setImage(UIImage(named:"navigationbar_arrow_down"), for: [])
            setImage(UIImage(named:"navigationbar_arrow_up"), for: .selected)
        }
        
        // 设置字体和颜色
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(UIColor.darkGray, for: [])
        
        //设置大小
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///重新布局子视图
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let titleLabel = titleLabel,let imageView=imageView else{
            return
        }
        
        titleLabel.frame.origin.x=0
        imageView.frame.origin.x=titleLabel.bounds.width
    }
}
