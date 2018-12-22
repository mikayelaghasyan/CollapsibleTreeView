//
//  CollapsibleTreeView.swift
//  CollapsibleTreeView
//
//  Created by Mikayel Aghasyan on 12/21/18.
//

import UIKit

public class CollapsibleTreeView: UITableView {
	weak open var treeDataSource: CollapsibleTreeViewDataSource?
	weak open var treeDelegate: CollapsibleTreeViewDelegate?

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	public override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
		setup()
	}

	private func setup() {
		self.dataSource = self
		self.delegate = self
	}

	public func dequeueReusableTreeCell(withIdentifier identifier: String, for indexPath: IndexPath) -> CollapsibleTreeViewCell {
		let index = self.index(for: indexPath)!
		return self.dequeueReusableCell(withIdentifier: identifier, for: IndexPath(row: index, section: 0)) as! CollapsibleTreeViewCell
	}

	private func numberOfExpandedRowsInSubtree(at indexPath: IndexPath) -> Int {
		var numberOfRows = self.treeDataSource?.treeView(self, numberOfSubnodesOf: indexPath) ?? 0
		for i in 0..<numberOfRows {
			let childIndexPath = indexPath.appending(i)
			if self.treeDataSource?.treeView(self, isNodeExpandedAt: childIndexPath) ?? false {
				numberOfRows += numberOfExpandedRowsInSubtree(at: childIndexPath)
			}
		}
		return numberOfRows
	}

	private func treeIndexPath(for index: IndexPath.Element) -> IndexPath? {
		return subIndexPath(for: index, in: IndexPath())
	}

	private func subIndexPath(for index: IndexPath.Element, in indexPath: IndexPath) -> IndexPath? {
		var offset = 0
		let numberOfNodes = self.treeDataSource?.treeView(self, numberOfSubnodesOf: indexPath) ?? 0
		for i in 0..<numberOfNodes {
			let childIndexPath = indexPath.appending(i)
			if index == offset {
				return childIndexPath
			} else {
				offset += 1
				var numberOfRows = 0
				if self.treeDataSource?.treeView(self, isNodeExpandedAt: childIndexPath) ?? false {
					numberOfRows = numberOfExpandedRowsInSubtree(at: childIndexPath)
				}
				if index < offset + numberOfRows {
					return subIndexPath(for:(index - offset), in:childIndexPath)
				} else {
					offset += numberOfRows
				}
			}
		}
		return nil
	}

	private func index(for treeIndexPath: IndexPath, in indexPath: IndexPath = IndexPath()) -> IndexPath.Element? {
		guard let idx = treeIndexPath.first else { return nil }
		var index: IndexPath.Element = 0
		for i in 0..<idx {
			index += 1
			let nextIndexPath = indexPath.appending(i)
			if self.treeDataSource?.treeView(self, isNodeExpandedAt: nextIndexPath) ?? false {
				index += numberOfExpandedRowsInSubtree(at: nextIndexPath)
			}
		}
		index += self.index(for: treeIndexPath.dropFirst(), in: indexPath.appending(idx)) ?? 0
		return index
	}
}

extension CollapsibleTreeView: UITableViewDataSource, UITableViewDelegate {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return numberOfExpandedRowsInSubtree(at: IndexPath())
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let treeIndexPath = self.treeIndexPath(for: indexPath.item)!
		let cell = self.treeDataSource!.treeView(self, cellForNodeAt: treeIndexPath)
		cell.indentationLevel = treeIndexPath.count - 1
		return cell
	}
}

public protocol CollapsibleTreeViewDataSource: class {
	func treeView(_ treeView: CollapsibleTreeView, numberOfSubnodesOf indexPath: IndexPath) -> Int
	func treeView(_ treeView: CollapsibleTreeView, isNodeExpandedAt indexPath: IndexPath) -> Bool
	func treeView(_ treeView: CollapsibleTreeView, cellForNodeAt indexPath: IndexPath) -> CollapsibleTreeViewCell
}

public protocol CollapsibleTreeViewDelegate: class {
}
