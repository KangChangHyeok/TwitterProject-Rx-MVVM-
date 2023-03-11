//
//  RxCollectionViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift

/// For more information take a look at `DelegateProxyType`.
open class RxCollectionViewDelegateProxy
    : RxScrollViewDelegateProxy {

    /// Typed parent object.
    public weak private(set) var feedTableView: UICollectionView?

    /// Initializes `RxCollectionViewDelegateProxy`
    ///
    /// - parameter collectionView: Parent object for delegate proxy.
    public init(feedTableView: UICollectionView) {
        self.feedTableView = feedTableView
        super.init(scrollView: feedTableView)
    }
}

extension RxCollectionViewDelegateProxy: UICollectionViewDelegateFlowLayout {}

#endif
