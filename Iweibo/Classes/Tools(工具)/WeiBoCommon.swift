//
//  WeiBoCommon.swift
//  myweibo
//
//  Created by Walker on 16/11/6.
//  Copyright © 2016年 Walker. All rights reserved.
//

import Foundation

// MARK: -全局通知定义通知

//应用程序id
let WBAppKey = "3183777600"
//应用程序加密信息（开发者可以申请修改）
let WBAppSecret = "e641b8167d0ea329395bd3b30bd1db5b"
//回调地址 －－登录完成跳转的路径
let WBRedirectURI = "http://baidu.com"

/// 用户需要登录通知
let WBUserShouldLoginNotification = "WBUserShouldLoginNotification"

///用户登录成功通知
let WBUserLoginSuccessedNotification = "WBUserLoginSuccessedNotification"

/// 照片浏览通知定义
///
/// @param selectedIndex    选中照片索引
/// @param urls             浏览照片 URL 字符串数组
/// @param parentImageViews 父视图的图像视图数组，用户展现和解除转场动画参照
/// 微博 cell 浏览照片通知
let WBStatusCellBrowserPhotoNotification = "WBStatusCellBrowserPhotoNotification"
// 选中索引key
let WBStatusCellBrowserPhotoSelectedIndexKey="WBStatusCellBrowserPhotoSelectedIndexKey"

// 浏览照片 URL 字符串key
let WBStatusCellBrowserPhotoURLsKey="WBStatusCellBrowserPhotoURLsKey"

// 父视图的图像视图数组 key
let WBStatusCellBrowserPhotoImageViewsKey="WBStatusCellBrowserPhotoImageViewsKey"

// MARK: -微博配图视图常量
// 配图视图外侧的间距
let WBStatusPictureViewOutterMargin:CGFloat = 12
// 配图视图内部图像视图的间距
let WBStatusPictureViewInnerMargin:CGFloat = 3

// 屏幕的宽度
let WBStatusPictureViewWidth=UIScreen.cz_screenWidth() - 2*WBStatusPictureViewOutterMargin

// 每个Item 默认的宽度
let WBStatusPictureItemWidth=(WBStatusPictureViewWidth-2*WBStatusPictureViewInnerMargin)/3

