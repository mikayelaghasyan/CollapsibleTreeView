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

		treeView.collapseRowAnimation = .fade
		treeView.expandRowAnimation = .fade

		loadData()
		if let categories = self.categories {
			for i in 0..<categories.count {
				self.treeView.expandNode(at: IndexPath(index: i))
			}
		}
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

extension Category {
	var isLeaf: Bool {
		return self.children?.count == 0
	}
}

extension ViewController: CollapsibleTreeViewDataSource, CollapsibleTreeViewDelegate {
	func treeView(_ treeView: CollapsibleTreeView, numberOfSubnodesOf indexPath: IndexPath) -> Int {
		return self.categories?.node(at: indexPath)?.children?.count ?? 0
	}

	func treeView(_ treeView: CollapsibleTreeView, cellForNodeAt indexPath: IndexPath) -> CollapsibleTreeViewCell {
		let category = self.categories?.node(at: indexPath) as? Category
		let cell: CollapsibleTreeViewCell
		if category?.isLeaf ?? false {
			cell = treeView.dequeueReusableTreeCell(withIdentifier: "Leaf", for: indexPath)
		} else {
			cell = treeView.dequeueReusableTreeCell(withIdentifier: "Node", for: indexPath)
			if treeView.isNodeExpanded(at: indexPath) {
				(cell as? NodeCell)?.showExpanded(animated: false)
			} else {
				(cell as? NodeCell)?.showCollapsed(animated: false)
			}
		}
		cell.textLabel?.text = category?.name
		return cell
	}

	func treeView(_ treeView: CollapsibleTreeView, isLeafAt indexPath: IndexPath) -> Bool {
		let category = self.categories?.node(at: indexPath) as? Category
		return category?.isLeaf ?? false
	}

	func treeView(_ treeView: CollapsibleTreeView, didExpandNodeAt indexPath: IndexPath) {
		if let cell = treeView.treeCell(at: indexPath) as? NodeCell {
			cell.showExpanded(animated: true)
		}
	}

	func treeView(_ treeView: CollapsibleTreeView, didCollapseNodeAt indexPath: IndexPath) {
		if let cell = treeView.treeCell(at: indexPath) as? NodeCell {
			cell.showCollapsed(animated: true)
		}
	}

	func treeView(_ treeView: CollapsibleTreeView, didSelectLeafAt indexPath: IndexPath) {
		if let category = self.categories?.node(at: indexPath) as? Category {
			print("Category Selected: \(category.name)")
		}
	}

	func treeView(_ treeView: CollapsibleTreeView, didDeselectLeafAt indexPath: IndexPath) {
		if let category = self.categories?.node(at: indexPath) as? Category {
			print("Category Deselected: \(category.name)")
		}
	}
}

class NodeCell: CollapsibleTreeViewCell {
	@IBOutlet weak var arrowImageView: UIImageView!

	func showExpanded(animated: Bool) {
		let transform: () -> () = {
			self.arrowImageView.transform = CGAffineTransform(rotationAngle: (.pi / 2.0))
		}
		if animated {
			UIView.animate(withDuration: 0.25) {
				transform()
			}
		} else {
			transform()
		}
	}

	func showCollapsed(animated: Bool) {
		let transform: () -> () = {
			self.arrowImageView.transform = .identity
		}
		if animated {
			UIView.animate(withDuration: 0.25) {
				transform()
			}
		} else {
			transform()
		}
	}
}
