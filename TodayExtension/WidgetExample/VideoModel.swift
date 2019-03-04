//
//  VideoModel.swift
//  WidgetExample
//
//  Created by Liu Chuan on 2018/5/2.
//  Copyright © 2018年 LC. All rights reserved.
//

import Foundation

struct VideoModel: Decodable {
    let content: Content
}

struct Content: Decodable {
    let list: [List]
}

struct List: Decodable {
    let title: String
    let img_url: String
    let type_id: String
}
