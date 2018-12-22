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

	private var expandedNodes: Set<IndexPath> = Set()

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
			if self.isNodeExpanded(at: childIndexPath) {
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
				if self.isNodeExpanded(at: childIndexPath) {
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
			if self.isNodeExpanded(at: nextIndexPath) {
				index += numberOfExpandedRowsInSubtree(at: nextIndexPath)
			}
		}
		if let idx = self.index(for: treeIndexPath.dropFirst(), in: indexPath.appending(idx)) {
			index += idx + 1
		}
		return index
	}

	public func isNodeExpanded(at indexPath: IndexPath) -> Bool {
		return self.expandedNodes.contains(indexPath)
	}

	public func expandNode(at indexPath: IndexPath) {
		guard let isLeaf = self.treeDataSource?.treeView(self, isLeafAt: indexPath) else { return }
		guard !isLeaf else { return }
		self.expandedNodes.insert(indexPath)

		let start = self.index(for: indexPath)! + 1
		let count = self.numberOfExpandedRowsInSubtree(at: indexPath)
		let indexPaths = Array(0..<count).map { (idx) -> IndexPath in
			IndexPath(row: start + idx, section: 0)
		}

		self.beginUpdates()
		self.insertRows(at: indexPaths, with: .automatic)
		self.endUpdates()
	}

	public func collapseNode(at indexPath: IndexPath) {
		self.expandedNodes.remove(indexPath)

		let start = self.index(for: indexPath)! + 1
		let count = self.numberOfExpandedRowsInSubtree(at: indexPath)
		let indexPaths = Array(0..<count).map { (idx) -> IndexPath in
			IndexPath(row: start + idx, section: 0)
		}

		self.beginUpdates()
		self.deleteRows(at: indexPaths, with: .automatic)
		self.endUpdates()
	}

	public func treeCell(at indexPath: IndexPath) -> CollapsibleTreeViewCell? {
		let index = self.index(for: indexPath)!
		return self.cellForRow(at: IndexPath(row: index, section: 0)) as? CollapsibleTreeViewCell
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

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let treeIndexPath = self.treeIndexPath(for: indexPath.item)!
		guard let isLeaf = self.treeDataSource?.treeView(self, isLeafAt: treeIndexPath) else { return }
		if isLeaf  {
			self.treeDelegate?.treeView(self, didSelectLeafAt: treeIndexPath)
		} else {
			if self.isNodeExpanded(at: treeIndexPath) {
				self.collapseNode(at: treeIndexPath)
				self.treeDelegate?.treeView(self, didCollapseNodeAt: treeIndexPath)
			} else {
				self.expandNode(at: treeIndexPath)
				self.treeDelegate?.treeView(self, didExpandNodeAt: treeIndexPath)
			}
		}
	}
}

public protocol CollapsibleTreeViewDataSource: class {
	func treeView(_ treeView: CollapsibleTreeView, numberOfSubnodesOf indexPath: IndexPath) -> Int
	func treeView(_ treeView: CollapsibleTreeView, cellForNodeAt indexPath: IndexPath) -> CollapsibleTreeViewCell
	func treeView(_ treeView: CollapsibleTreeView, isLeafAt indexPath: IndexPath) -> Bool
}

public protocol CollapsibleTreeViewDelegate: class {
	func treeView(_ treeView: CollapsibleTreeView, didExpandNodeAt indexPath: IndexPath)
	func treeView(_ treeView: CollapsibleTreeView, didCollapseNodeAt indexPath: IndexPath)
	func treeView(_ treeView: CollapsibleTreeView, didSelectLeafAt indexPath: IndexPath)
}
