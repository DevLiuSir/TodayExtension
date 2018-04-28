//
//  TodayViewController.swift
//  WidgetExample
//
//  Created by Liu Chuan on 2018/5/2.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit
import NotificationCenter


/// 单元格重用标识符
private let identifier = "CELL"
/// 今日扩展默认高度
private let todayExtensionNormalHeight: CGFloat = 110



class TodayViewController: UIViewController, NCWidgetProviding {
    
    /// 表格
    @IBOutlet weak var table: UITableView!
    /// 模型
    private lazy var vedioModels = [VedioModel]()
    
    /// More button
    private lazy var moreBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        btn.setTitle("Look at more", for:.normal)
        btn.addTarget(self, action: #selector(moreBtnClickted), for: .touchUpInside)
        btn.backgroundColor = UIColor(red:245/255.0, green:74/255.0, blue:48/255.0, alpha: 1)
        return btn
    }()
    
    // MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadVediosData {
            self.table.reloadData()
        }
       
        configTableView()
        setTodayExtensionMode()
    }
    
    /// 配置TableView
    private func configTableView() {
        table.tableFooterView = moreBtn
        table.dataSource = self
        table.delegate = self
        table.register(UINib(nibName: "VedioCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
    
    /// 更多按钮点击事件
    @objc private func moreBtnClickted(){
        print("look more button")
    }
    
    /// 设置今日扩展模式
    private func setTodayExtensionMode() {
        // 设置今日扩展模式为可张开收缩模式(IOS10以后支持,进入扩展右上角显示"展开"和"折叠")
        /* expanded: 展开, compact: 折叠 */
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            print("iOS8, iOS9需要自己添加折叠按钮..")
        }
    }
    
    
    /*** 这些方法适用的iOS10及以上操作系统 ***/
/*
     特性参数:星号(*),表示包含了所有平台,目前有以下几个平台:
     - iOS
     - iOSApplicationExtension
     - OSX
     - OSXApplicationExtension
     - watchOS
     - watchOSApplicationExtension
     - tvOS
     - tvOSApplicationExtension
*/
    @available(iOSApplicationExtension 10.0, *)
    
    /// 监听Widget的 展开\折叠状态视图大小的改变
    ///
    /// - Parameters:
    ///   - activeDisplayMode: 展开和折叠状态
    ///   - maxSize: 界面能够显示的 最小 和 最大尺寸(最小状态下是110)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {  //折叠
            print("折叠状态")
            preferredContentSize = CGSize(width: maxSize.width, height: maxSize.height)
        }else {
            print("展开状态")
            preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(5 * todayExtensionNormalHeight + 60))
        }
    }
    
    
/**
     completionHandler(NCUpdateResult.newData) 这个方法是系统回调。那么这个参数就需要注意一下，NCUpdateResult 枚举，三种状态。
     NCUpdateResultNewData: 新内容需要您重绘视图
     NCUpdateResultNoData:  小部件不需要更新
     NCUpdateResultFailed:  在更新过程中发生错误
 **/
    
    /// 刷新Today Widgets
    ///
    /// - Parameter completionHandler: 回调
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
       
        // #available 用在条件语句代码块中,判断不同的平台下,做不同的逻辑处理
        if #available(iOSApplicationExtension 11.0, *) {
            if extensionContext?.widgetActiveDisplayMode == .compact{
                completionHandler(NCUpdateResult.newData)
            }else{
                completionHandler(NCUpdateResult.noData)
            }
        }else {
            completionHandler(NCUpdateResult.newData)
        }
    }
    
    
    
}


// MARK: - 解析JSON数据
extension TodayViewController {
    
    /// 加载电影数据
    ///
    /// - Parameter completed: 回调
    func loadVediosData(completed: @escaping () -> ()) {
        
        let url = URL(string: "http://yingshi.m.jinerkan.com/v3/api/banners")
  
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            guard error == nil else { return }
            
            do {
                print("开始解析...")
                let downloadedChannels = try JSONDecoder().decode(VedioModel.self, from: data!)
                self.vedioModels = [downloadedChannels]
                // 简写
                //self.vedioModels = try [JSONDecoder().decode(MusicModel.self, from: data!)]
                DispatchQueue.main.async {
                    completed()
                }
            }catch {
                print("JSON解析出错....\(error)")
            }
        }.resume()
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vedioModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vedioModels[section].content.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 创建cell
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! VedioCell
        
        /// 图片网址
        let url = vedioModels[indexPath.section].content.list[indexPath.row].img_url
        /// 电影名称
        let title = vedioModels[indexPath.section].content.list[indexPath.row].title
        /// 类型ID
        let id = vedioModels[indexPath.section].content.list[indexPath.row].type_id
        /// 图片URL
        let imageURL = URL(string: url)
        
        let da = try? Data(contentsOf: imageURL!)
        
        // 根据URL获取图片
        let imag = UIImage(data: da!)
        
        // 设置cell
        cell.vedioImage.image = imag
        cell.vedioTitle.text = title
        cell.typeID.text = "ID = \(id)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("点击 cell")
    }
}

