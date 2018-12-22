//
//  Category.swift
//  CollapsibleTreeView_Example
//
//  Created by Mikayel Aghasyan on 12/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

struct Category: Codable {
	var id: String
	var name: String
	var subcategories: [Category]?
}
