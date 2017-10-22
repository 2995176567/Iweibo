//
//  WBNewFeatureView.swift
//  myweibo
//
//  Created by Walker on 16/11/15.
//  Copyright © 2016年 Walker. All rights reserved.
//

import UIKit

// 新特性视图
class WBNewFeatureView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    /// 进入微博
    @IBAction func enterStatus() {
        
        removeFromSuperview()
    }
    
    class func newFeatureView() -> WBNewFeatureView{
        
        let nib = UINib(nibName: "WBNewFeatureView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBNewFeatureView
        
        // 从XIB 加载的视图 默认是600*600
        v.frame = UIScreen.main.bounds
        
        return v
    }
    
    override func awakeFromNib() {
        
        // 如果使用自动布局设置界面，从XIB的默认加载600*600
        let count = 4
        let rect = UIScreen.main.bounds
        
        for i in 0..<count{
        
            let imageName = "new_feature_\(i+1)"
            let iv = UIImageView(image: UIImage(named: imageName))
            
            //设置大小
            iv.frame = rect.offsetBy(dx: CGFloat(i)*rect.width, dy: 0)
        
            scrollView.addSubview(iv)
        }
        
        //指定scrollView的属性
        scrollView.contentSize = CGSize(width: CGFloat(count+1)*rect.width, height: rect.height)
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.delegate = self
        
        //隐藏按钮
        enterButton.isHidden = true
    }
}

extension WBNewFeatureView:UIScrollViewDelegate{

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //滚动到最后一屏，让视图删除
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        //print(page)
        
        //判断是否最后一页
        if page == scrollView.subviews.count {
            
            removeFromSuperview()
        }
        
        //如果是倒数第二页，显示按钮
        enterButton.isHidden = (page != scrollView.subviews.count-1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //一旦滚动，隐藏按钮
        enterButton.isHidden=true
        
        //计算当前的偏移量
        let page = Int(scrollView.contentOffset.x/scrollView.bounds.width+0.5)
        
        //设置分页控件
        pageControl.currentPage = page
        
        //分页控件的隐藏
        pageControl.isHidden = (page==scrollView.subviews.count)
    }
}