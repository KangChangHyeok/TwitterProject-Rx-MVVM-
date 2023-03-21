//
//  RxCollectionViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift

// objc monkey business
class _RxCollectionViewReactiveArrayDataSource
    : NSObject
    , UICollectionViewDataSource {
    
    @objc(numberOfSectionsInCollectionView:)
    func numberOfSections(in: UICollectionView) -> Int {
        1
    }

    func _collectionView(_ feedTableView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ feedTableView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _collectionView(feedTableView, numberOfItemsInSection: section)
    }

    fileprivate func _collectionView(_ feedTableView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        rxAbstractMethod()
    }

    func collectionView(_ feedTableView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        _collectionView(feedTableView, cellForItemAt: indexPath)
    }
}

class RxCollectionViewReactiveArrayDataSourceSequenceWrapper<Sequence: Swift.Sequence>
    : RxCollectionViewReactiveArrayDataSource<Sequence.Element>
    , RxCollectionViewDataSourceType {
    typealias Element = Sequence

    override init(cellFactory: @escaping CellFactory) {
        super.init(cellFactory: cellFactory)
    }
    
    func collectionView(_ feedTableView: UICollectionView, observedEvent: Event<Sequence>) {
        Binder(self) { collectionViewDataSource, sectionModels in
            let sections = Array(sectionModels)
            collectionViewDataSource.collectionView(feedTableView, observedElements: sections)
        }.on(observedEvent)
    }
}


// Please take a look at `DelegateProxyType.swift`
class RxCollectionViewReactiveArrayDataSource<Element>
    : _RxCollectionViewReactiveArrayDataSource
    , SectionedViewDataSourceType {
    
    typealias CellFactory = (UICollectionView, Int, Element) -> UICollectionViewCell
    
    var itemModels: [Element]?
    
    func modelAtIndex(_ index: Int) -> Element? {
        itemModels?[index]
    }

    func model(at indexPath: IndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        guard let item = itemModels?[indexPath.item] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }
    
    var cellFactory: CellFactory
    
    init(cellFactory: @escaping CellFactory) {
        self.cellFactory = cellFactory
    }
    
    // data source
    
    override func _collectionView(_ feedTableView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemModels?.count ?? 0
    }
    
    override func _collectionView(_ feedTableView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cellFactory(feedTableView, indexPath.item, itemModels![indexPath.item])
    }
    
    // reactive
    
    func collectionView(_ feedTableView: UICollectionView, observedElements: [Element]) {
        self.itemModels = observedElements
        
        feedTableView.reloadData()

        // workaround for http://stackoverflow.com/questions/39867325/ios-10-bug-uicollectionview-received-layout-attributes-for-a-cell-with-an-index
        feedTableView.collectionViewLayout.invalidateLayout()
    }
}

#endif
