//
//  UIWindow+VisibleViewController.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//
import Foundation

public extension UIWindow {
	
	public var visibleViewController: UIViewController? {
		return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
	}
	
	/// Adapted from https://stackoverflow.com/questions/11637709/get-the-current-displaying-uiviewcontroller-on-the-screen-in-appdelegate-m
	public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
		if let nc = vc as? UINavigationController {
			return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
		} else if let tc = vc as? UITabBarController {
			return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
		} else {
			if let pvc = vc?.presentedViewController {
				return UIWindow.getVisibleViewControllerFrom(pvc)
			} else {
				return vc
			}
		}
	}
}
