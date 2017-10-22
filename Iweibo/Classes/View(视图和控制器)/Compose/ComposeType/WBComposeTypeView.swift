//
//  WBComposeTypeView.swift
//  Iweibo
//
//  Created by walker on 2016/11/29.
//  Copyright © 2016年 greejoy. All rights reserved.
//

import UIKit
import pop

/// 撰写微博类型视图
class WBComposeTypeView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    /// 关闭按钮约束
    @IBOutlet weak var closeButtonCenterXCons: NSLayoutConstraint!
    /// 返回前一页按钮约束
    @IBOutlet weak var returnButtonCenterXCons: NSLayoutConstraint!
    /// 返回前一页按钮
    @IBOutlet weak var returnButton: UIButton!
    
    //按钮数组数组
    let buttonsInfo = [
                              ["imageName": "tabbar_compose_idea", "title": "文字", "clsName": "WBComposeViewController"],
                              ["imageName": "tabbar_compose_photo", "title": "照片/视频"],
                              ["imageName": "tabbar_compose_weibo", "title": "长微博"],
                              ["imageName": "tabbar_compose_lbs", "title": "签到"],
                              ["imageName": "tabbar_compose_review", "title": "点评"],
                              ["imageName": "tabbar_compose_more", "title": "更多", "actionName": "clickMore"],
                              ["imageName": "tabbar_compose_friend", "title": "好友圈"],
                              ["imageName": "tabbar_compose_wbcamera", "title": "微博相机"],
                              ["imageName": "tabbar_compose_music", "title": "音乐"],
                              ["imageName": "tabbar_compose_shooting", "title": "拍摄"]
    ]
    
    //完成回调
    private var completionBlock:((_ clsName:String?)->())?
    
    //实例化方法
    class func compseTypeView() -> WBComposeTypeView{
    
        let nib = UINib(nibName: "WBComposeTypeView", bundle: nil)
        //从xib加载完成视图，就会调用awakeFromNib
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeView
        
        //  xib 加载默认是 600*600
        v.frame=UIScreen.main.bounds
        
        v.setupUI()
        
        return v
    }
    
    /// 显示当前视图
    func show(completion:@escaping (_ clsName:String?)->()){
        
        //记录闭包
        completionBlock=completion
        
        //将当前视图添加到
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else{
        
            return
        }
        
        //添加视图
        vc.view.addSubview(self)
        
        //开始动画
        showCurrentView()
    }

    //监听方法
    @objc func clickButton(selectedButton:WBComposeTypeButton){
                
        //判断当前显示的视图
        let page = Int(scrollView.contentOffset.x/scrollView.bounds.width)
        let v = scrollView.subviews[page]
        
        //遍历当前视图--选中的按钮放大，没有选中的按钮放小
        for (i,btn) in v.subviews.enumerated(){
            
            //缩放动画
            let scaleAnim:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            let scale=(selectedButton==btn) ? 2 : 0.2
            
            scaleAnim.toValue=NSValue(cgPoint:CGPoint(x:scale,y:scale))
            scaleAnim.duration=0.5
            
            btn.pop_add(scaleAnim, forKey: nil)
            
            //渐变动画---动画组
            let alphaAnim:POPBasicAnimation=POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            
            alphaAnim.toValue=0.2
            alphaAnim.duration=0.5
            
            btn.pop_add(alphaAnim, forKey: nil)
            
            //添加动画监听
            if i==0{
                alphaAnim.completionBlock={ _,_ in
                
                    //需要执行回调
                    print("完成回调控制器")
                    
                    self.completionBlock?(selectedButton.clsName)
                }
            }
        }
    }
    
    //点击更多按钮
    @objc func clickMore(){
    
        print("点击更多")
        // 滚动到第二页
        scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width,y:0), animated: true)
        //处理底部按钮，让两个按钮分开
        returnButton.isHidden=false
        
        let margin = scrollView.bounds.width/6
        
        closeButtonCenterXCons.constant += margin
        returnButtonCenterXCons.constant -= margin
        
        UIView.animate(withDuration: 0.25){
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func clickReturn() {
        // 将滚动视图滚动到第一页
        scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        
        closeButtonCenterXCons.constant=0
        returnButtonCenterXCons.constant=0
        
        UIView.animate(withDuration: 0.25,animations:{
            self.layoutIfNeeded()
            self.returnButton.alpha=0
        }){ _ in
             //让两个按钮合并
            self.returnButton.isHidden=true
            self.returnButton.alpha=1
        }
    }
    
    /// 关闭视图
    @IBAction func close() {
        //removeFromSuperview()
        hideButtons()
    }
}


// MARK: - 动画方法扩展
private extension WBComposeTypeView{
    
    //消除动画
    func hideButtons(){
        
        //根据contentOffset 判断当前显示的子视图
        let page = Int(scrollView.contentOffset.x/scrollView.bounds.width)
        let v = scrollView.subviews[page]
        
        //遍历v 中的所有按钮
        for (i,btn) in v.subviews.enumerated().reversed(){
        
            //创建动画
            let anim:POPSpringAnimation=POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        
            //设置动画属性
            anim.fromValue=btn.center.y
            anim.toValue=btn.center.y+350
            
            //设置时间
            anim.beginTime=CACurrentMediaTime()+CFTimeInterval(v.subviews.count - i)*0.025
            
            //添加动画
            btn.layer.pop_add(anim, forKey: nil)
            
            //监听第0个按钮
            if i==0 {
                anim.completionBlock={ _,_ in
                    
                    self.hideCurrentView()
                }
            }
        }
        
        //隐藏当前视图--开始时间
    }
    
    //隐藏当前视图
    private func hideCurrentView(){
        //创建动画
        let anim:POPBasicAnimation=POPBasicAnimation(propertyNamed: kPOPViewAlpha)
    
        anim.fromValue=1
        anim.toValue=0
        anim.duration=0.25
        
        pop_add(anim, forKey: nil)
        
        //完成监听方法
        anim.completionBlock={ _,_ in
        
            self.removeFromSuperview()
        }
    }
    
    //动画显示当前视图
    func showCurrentView(){
     
        //创建动画
        let anim:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        
        anim.fromValue=0
        anim.toValue=1
        anim.duration=0.25
        
        //添加到视图
        pop_add(anim, forKey: nil)
        
        //添加按钮动画
        showButtons()
    }
    
    //弹力显示所有按钮
    private func showButtons(){
    
        //获取scrollview的子视图的第0个视图
        let v = scrollView.subviews[0]
        
        //遍历v中的所有按钮
        for (i,btn) in v.subviews.enumerated(){
            //创建动画
            let anim:POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            
            //设置动画属性
            anim.fromValue=btn.center.y+350
            anim.toValue=btn.center.y
            //弹力系数
            anim.springBounciness=8
            //弹力速度
            anim.springSpeed=8
            
            //设置动画启动时间
            anim.beginTime=CACurrentMediaTime()+CFTimeInterval(i)*0.025
            
            //添加动画
            btn.pop_add(anim, forKey: nil)
        }
    }
}

// private 让extention中的所有方法都是私有的
private extension WBComposeTypeView{
    
    func setupUI(){
        
        //强行更新布局
        layoutIfNeeded()
        
        //向screllView添加视图
        let rect = scrollView.bounds
        
        let width = scrollView.bounds.width
        for i in 0..<2{
            
            let v = UIView(frame: rect.offsetBy(dx: CGFloat(i)*width, dy: 0))
            //向视图添加按钮
            addButton(v: v, idx: i*6)
            
            //将视图添加到scrollView
            scrollView.addSubview(v)
        }
        
        //设置scrollview
        scrollView.contentSize=CGSize(width: 2*width, height: 0)
        scrollView.showsVerticalScrollIndicator=false
        scrollView.showsHorizontalScrollIndicator=false
        scrollView.bounces=false
        
        //禁用滚动
        scrollView.isScrollEnabled=false
    }
    
    /// 向 v 中添加按钮，按钮的数组索引从idx开始
    func addButton(v:UIView,idx:Int){
        
        let count = 6
        //从idx开始添加6个按钮
        for i in idx..<(idx+count){
            
            if i >= buttonsInfo.count {
                break
            }
            
            //从数组字典中取图像名称和title
            let dict = buttonsInfo[i]
            
            guard let imageName = dict["imageName"],let title = dict["title"] else{
                continue
            }
            
            // 创建按钮
            let btn = WBComposeTypeButton.composeTypeButton(imageName: imageName, title: title)
            
            //添加视图
            v.addSubview(btn)
            
            //添加监听方法
            if let actionName = dict["actionName"]{
                
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }else{
            
                btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            }
            
            //设置展现的类名---不需要判断
            btn.clsName=dict["clsName"]
        }
        
        //遍历视图的子视图，布局按钮
        let btnSize = CGSize(width: 100, height: 100)
        let margin = (v.bounds.width-3*btnSize.width)/4
        
        for (i, btn) in v.subviews.enumerated(){
        
            let y:CGFloat = (i>2) ? (v.bounds.height-btnSize.height) : 0
            let col = i%3
            let x = CGFloat(col+1)*margin + CGFloat(col)*btnSize.width
            
            btn.frame=CGRect(x: x, y: y, width: btnSize.width, height: btnSize.height)
        }
    }
}
