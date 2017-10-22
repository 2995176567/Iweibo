//
//  WBStatusPictureView.swift
//  Iweibo
//
//  Created by walker on 2016/11/27.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit

class WBStatusPictureView: UIView {
    
    var viewModel:WBStatusViewModel?{
    
        didSet{
            calcViewSize()
            //设置urls
            urls=viewModel?.picURLs
        }
    }
    
    /// 根据视图模型的配图视图大小，调整显示内容
    private func calcViewSize(){
        
        //处理高度
        //单图，根据配图视图的大小，修改subview[0] 的高度
        if viewModel?.picURLs?.count==1 {
            
            let viewSize = viewModel?.pictureViewSize ?? CGSize()
            //获取第0个图像视图
            let v = subviews[0]
            v.frame = CGRect(x: 0,
                             y: WBStatusPictureViewOutterMargin,
                             width: viewSize.width,
                             height: viewSize.height-WBStatusPictureViewOutterMargin)
        }else{
        
            // 多图(无图)，回复subview[0]的宽度，保证9宫格的完整布局
            let v = subviews[0]
            
            v.frame=CGRect(x: 0,
                           y: WBStatusPictureViewOutterMargin,
                           width: WBStatusPictureItemWidth,
                           height: WBStatusPictureItemWidth)
        }
        
        // 修改高度约束
        heightCons.constant=viewModel?.pictureViewSize.height ?? 0
    }
    
    /// 配图视图数组
    private var urls:[WBStatusPicture]?{
        
        didSet{
            // 隐藏所有的imageview
            for v in subviews{
                v.isHidden=true
            }
            
            //设置图像
            var index=0
            for url in urls ?? []{
            
                //获得对应索引的imageview
                let iv = subviews[index] as! UIImageView
                
                // 4张图像处理
                if index == 1 && urls?.count == 4 {
                    index += 1
                }
                
                //设置图像
                iv.cz_setImage(urlString: url.thumbnail_pic, placeholderImage: nil)
                
                // 判断是否是 gif,根据扩展名
                iv.subviews[0].isHidden=(((url.thumbnail_pic ?? "") as NSString).pathExtension.lowercased() != "gif")
                
                // 显示图像
                iv.isHidden=false
                index += 1
            }
        }
    }
    
    @IBOutlet weak var heightCons:NSLayoutConstraint!
    
    override func awakeFromNib() {
        setupUI()
    }
    
    // 监听方法
    /// @param selectedIndex    选中照片索引
    /// @param urls             浏览照片 URL 字符串数组
    /// @param parentImageViews 父视图的图像视图数组，用户展现和解除转场动画参照
    @objc func tapImageView(tap:UITapGestureRecognizer){
        
        guard let iv = tap.view,
        let picURLs=viewModel?.picURLs else{
            return
        }
        
        var selectedIndex=iv.tag
        
        // 针对4张图处理
        if picURLs.count==4 && selectedIndex>1{
            selectedIndex -= 1
        }
        
        let urls=(picURLs as NSArray).value(forKey: "largePic") as! [String]
        
        // 处理可见的图像视图
        var imageViewList=[UIImageView]()
        
        for iv in subviews as! [UIImageView]{
        
            if !iv.isHidden{
                imageViewList.append(iv)
            }
        }
        
        print(selectedIndex)
        
        // 发送通知
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: WBStatusCellBrowserPhotoNotification),
            object: self,
            userInfo: [WBStatusCellBrowserPhotoURLsKey:urls,
                       WBStatusCellBrowserPhotoSelectedIndexKey:selectedIndex,
                       WBStatusCellBrowserPhotoImageViewsKey:imageViewList])
    }
}

// MARK: - 设置界面
extension WBStatusPictureView{

    // Cell 中 所有的控件都是提前准备好
    // 设置的时候，根据数据决定是否显示
    // 不要动态创建控件
    func setupUI(){
        
        // 设置背景颜色
        backgroundColor=superview?.backgroundColor
        
        // 超出边界的内容不显示
        clipsToBounds=true
    
        let count = 3
        let rect = CGRect(x: 0,
                          y: WBStatusPictureViewOutterMargin,
                          width: WBStatusPictureItemWidth,
                          height: WBStatusPictureItemWidth)
        //循环创建9个imageView
        for i in 0..<count*count {
            let iv = UIImageView()
            
            //设置 contentMode
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds=true
        
            //iv.backgroundColor=UIColor.red
            
            //行 --y
            let row = CGFloat(i/count)
            
            // 列 --x
            let col = CGFloat(i%count)
            
            let xoffset=col*(WBStatusPictureItemWidth+WBStatusPictureViewInnerMargin)
            
            let yoffset=row*(WBStatusPictureItemWidth+WBStatusPictureViewInnerMargin)
            
            iv.frame=rect.offsetBy(dx: xoffset, dy: yoffset)
            
            addSubview(iv)
            
            // 让 imageView 能够接收用户交互
            iv.isUserInteractionEnabled=true
            //添加手势识别
            let tap=UITapGestureRecognizer(target: self, action: #selector(tapImageView))
            
            iv.addGestureRecognizer(tap)
            
            // 设置iamgeVIew 的tag
            iv.tag=i
            
            addGifView(iv: iv)
        }
    }

    //  向图片添加 gif 提示图像
    private func addGifView(iv:UIImageView){
    
        let gifImageView = UIImageView(image: UIImage(named: "timeline_image_gif"))
        
        iv.addSubview(gifImageView)
        
        // 自动布局
        gifImageView.translatesAutoresizingMaskIntoConstraints=false
        
        iv.addConstraint(NSLayoutConstraint(
            item: gifImageView,
            attribute: .right,
            relatedBy: .equal,
            toItem: iv,
            attribute: .right,
            multiplier: 1.0,
            constant: 0))
        
        iv.addConstraint(NSLayoutConstraint(
            item: gifImageView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: iv,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
    }
}