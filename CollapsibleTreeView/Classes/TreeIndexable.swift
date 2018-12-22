//
//  TreeIndexable.swift
//  CollapsibleTreeView
//
//  Created by Mikayel Aghasyan on 12/23/18.
//

public protocol TreeIndexable {
	var children: [TreeIndexable]? { get }
	func node(at indexPath: IndexPath) -> TreeIndexable?
}

extension TreeIndexable {
	public func node(at indexPath: IndexPath) -> TreeIndexable? {
		guard let idx = indexPath.first else { return self }
		return self.children?[idx].node(at: indexPath.dropFirst())
	}
}

extension Array: TreeIndexable where Element: TreeIndexable {
	public var children: [TreeIndexable]? {
		return self
	}
}
