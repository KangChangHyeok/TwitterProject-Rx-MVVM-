//
//  RxCollectionViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import Differentiator

open class RxCollectionViewSectionedReloadDataSource<Section: SectionModelType>
    : CollectionViewSectionedDataSource<Section>
    , RxCollectionViewDataSourceType {
    
    public typealias Element = [Section]

    open func collectionView(_ feedTableView: UICollectionView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, element in
            #if DEBUG
                dataSource._dataSourceBound = true
            #endif
            dataSource.setSections(element)
            feedTableView.reloadData()
            feedTableView.collectionViewLayout.invalidateLayout()
        }.on(observedEvent)
    }
}
#endif
