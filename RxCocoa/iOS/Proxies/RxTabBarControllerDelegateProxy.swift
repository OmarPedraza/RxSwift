//
//  RxTabBarControllerDelegateProxy.swift
//  RxCocoa
//
//  Created by Yusuke Kita on 2016/12/07.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift

public typealias ShouldSelectViewController = (shouldSelect: Bool, viewController: UIViewController)

extension UITabBarController: HasDelegate {
    public typealias Delegate = UITabBarControllerDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxTabBarControllerDelegateProxy
    : DelegateProxy<UITabBarController, UITabBarControllerDelegate>
    , DelegateProxyType 
    , UITabBarControllerDelegate {

    /// Typed parent object.
    public weak private(set) var tabBar: UITabBarController?

    /// Publish subject for subscribing to `delegate` message `tabBarController:shouldSelect:`.
    public let shouldSelectSubject = PublishSubject<ShouldSelectViewController>()

    /// - parameter tabBar: Parent object for delegate proxy.
    public init(tabBar: ParentObject) {
        self.tabBar = tabBar
        super.init(parentObject: tabBar, delegateProxy: RxTabBarControllerDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxTabBarControllerDelegateProxy(tabBar: $0) }
    }

    // MARK: delegate methods

    /// For more information take a look at `DelegateProxyType`.
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let result = _forwardToDelegate?.tabBarController(tabBarController, shouldSelect: viewController) {
            let next = ShouldSelectViewController(result, viewController)
            shouldSelectSubject.on(.next(next))

            return result
        } else {
            let next = ShouldSelectViewController(false, viewController)
            shouldSelectSubject.on(.next(next))

            return false
        }
    }
}

#endif
