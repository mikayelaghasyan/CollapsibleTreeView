//
//  ViewController.swift
//  CollapsibleTreeView
//
//  Created by Mikayel Aghasyan on 12/20/2018.
//  Copyright (c) 2018 Mikayel Aghasyan. All rights reserved.
//

import UIKit
import CollapsibleTreeView

class ViewController: UIViewController {
	@IBOutlet weak var treeView: CollapsibleTreeView!

	var categories: [Category]?

    override func viewDidLoad() {
        super.viewDidLoad()
		treeView.treeDataSource = self
		treeView.treeDelegate = self
		loadData()
    }

	private func loadData() {
		guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else { return }
		guard let data = try? Data(contentsOf: url) else { return }
		do {
			self.categories = try JSONDecoder().decode([Category].self, from: data)
		} catch {
			print("Error info: \(error)")
		}
	}
}

extension Category: TreeIndexable {
	var children: [TreeIndexable]? {
		return self.subcategories
	}
}

extension ViewController: CollapsibleTreeViewDataSource, CollapsibleTreeViewDelegate {
	func treeView(_ treeView: CollapsibleTreeView, numberOfSubnodesOf indexPath: IndexPath) -> Int {
		return self.categories?.node(at: indexPath)?.children?.count ?? 0
	}

	func treeView(_ treeView: CollapsibleTreeView, isNodeExpandedAt indexPath: IndexPath) -> Bool {
		return true
	}

	func treeView(_ treeView: CollapsibleTreeView, cellForNodeAt indexPath: IndexPath) -> CollapsibleTreeViewCell {
		let category = self.categories?.node(at: indexPath) as? Category
		let cell = treeView.dequeueReusableTreeCell(withIdentifier: "Node", for: indexPath)
		cell.textLabel?.text = category?.name
		return cell
	}
}
