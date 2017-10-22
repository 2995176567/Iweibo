//
//  UIImageView+WebImage.swift
//  Iweibo
//
//  Created by walker on 2016/11/27.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import SDWebImage

extension UIImageView{

    /// 隔离 SDWebImage 设置图像函数
    ///
    /// - Parameters:
    ///   - urlString: urlString
    ///   - placeholderImage: 占位图像
    ///    -isAvatar:是否头像
    func cz_setImage(urlString:String?,placeholderImage:UIImage?,isAvatar:Bool=false){
        
        //处理url
        guard let urlString=urlString,let url = URL(string:urlString) else {
            //设置占位符
            image = placeholderImage
            return
        }
    
        // 可选项只是用在swift
        sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil){ [weak self] (image,_,_,_) in
        
            //完成回调--判断是否是头像
            if isAvatar{
                self?.image = image?.cz_avatarImage(size: self?.bounds.size)
            }
        }
    }
}
