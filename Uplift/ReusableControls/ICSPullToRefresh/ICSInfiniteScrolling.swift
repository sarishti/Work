//
//  ICSInfiniteScrolling.swift
//  ICSPullToRefresh
//
//  Created by LEI on 3/17/15.
//  Copyright (c) 2015 TouchingAPP. All rights reserved.
//

import UIKit

private var infiniteScrollingViewKey: Void?
private let observeKeyContentOffset = "contentOffset"
private let observeKeyContentSize = "contentSize"
private let observeKeyContentInset = "contentInset"

private let ICSInfiniteScrollingViewHeight: CGFloat = 40

public extension UIScrollView {

	public var infiniteScrollingView: InfiniteScrollingView? {
		get {
			return objc_getAssociatedObject(self, &infiniteScrollingViewKey) as? InfiniteScrollingView
		}
		set(newValue) {
			self.willChangeValueForKey("ICSInfiniteScrollingView")
			objc_setAssociatedObject(self, &infiniteScrollingViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
			self.didChangeValueForKey("ICSInfiniteScrollingView")
		}
	}

	public var showsInfiniteScrolling: Bool {
		return infiniteScrollingView != nil ? infiniteScrollingView!.hidden : false
	}

	public var hasMoreData: Bool {
		get {
			return infiniteScrollingView!.hasMoreData
		}
		set(newValue) {
			infiniteScrollingView!.hasMoreData = newValue
		}
	}

	public var font: UIFont {
		get {
			return infiniteScrollingView!.font
		}
		set(newValue) {
			infiniteScrollingView!.labelNoMoreRecord.font = newValue
		}
	}

	public var fontColor: UIColor {
		get {
			return infiniteScrollingView!.fontColor
		}
		set(newValue) {
			infiniteScrollingView!.labelNoMoreRecord.textColor = fontColor
		}
	}

	public func addInfiniteScrollingWithHandler(actionHandler: ActionHandler) {
		if infiniteScrollingView == nil {
			infiniteScrollingView = InfiniteScrollingView(frame: CGRect(x: CGFloat(0), y: contentSize.height, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight))
			infiniteScrollingView?.backgroundColor = UIColor.clearColor()
			addSubview(infiniteScrollingView!)
			infiniteScrollingView?.scrollViewOriginContentBottomInset = contentInset.bottom
		}
		infiniteScrollingView?.actionHandler = actionHandler
		setShowsInfiniteScrolling(true)
	}

	public func addInfiniteScrollingWithHandler(font: UIFont, fontColor: UIColor, actionHandler: ActionHandler) {
		if infiniteScrollingView == nil {
			infiniteScrollingView = InfiniteScrollingView(frame: CGRect(x: CGFloat(0), y: contentSize.height, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight))
			addSubview(infiniteScrollingView!)
			infiniteScrollingView?.scrollViewOriginContentBottomInset = contentInset.bottom

			infiniteScrollingView?.font = font
			infiniteScrollingView?.fontColor = fontColor

			infiniteScrollingView?.labelNoMoreRecord.font = font
			infiniteScrollingView?.labelNoMoreRecord.textColor = fontColor

		}
		infiniteScrollingView?.actionHandler = actionHandler
		setShowsInfiniteScrolling(true)
	}

	public func triggerInfiniteScrolling() {
		infiniteScrollingView?.state = .Triggered
		infiniteScrollingView?.startAnimating()
	}

	public func setShowsInfiniteScrolling(showsInfiniteScrolling: Bool) {
		if infiniteScrollingView == nil {
			return
		}
		infiniteScrollingView!.hidden = !showsInfiniteScrolling
		if showsInfiniteScrolling {
			addInfiniteScrollingViewObservers()
		} else {
			removeInfiniteScrollingViewObservers()
			infiniteScrollingView!.setNeedsLayout()
			infiniteScrollingView!.frame = CGRect(x: CGFloat(0), y: contentSize.height, width: infiniteScrollingView!.bounds.width, height: ICSInfiniteScrollingViewHeight)
		}
	}

	func addInfiniteScrollingViewObservers() {
		if infiniteScrollingView != nil && !infiniteScrollingView!.isObserving {
			addObserver(infiniteScrollingView!, forKeyPath: observeKeyContentOffset, options: .New, context: nil)
			addObserver(infiniteScrollingView!, forKeyPath: observeKeyContentSize, options: .New, context: nil)
			infiniteScrollingView!.isObserving = true
		}
	}

	func removeInfiniteScrollingViewObservers() {
		if infiniteScrollingView != nil && infiniteScrollingView!.isObserving {
			removeObserver(infiniteScrollingView!, forKeyPath: observeKeyContentOffset)
			removeObserver(infiniteScrollingView!, forKeyPath: observeKeyContentSize)
			infiniteScrollingView!.isObserving = false
		}
	}

}

public class InfiniteScrollingView: UIView {
	public var actionHandler: ActionHandler?
	public var isObserving: Bool = false

	public var scrollView: UIScrollView? {
		return self.superview as? UIScrollView
	}

	public var scrollViewOriginContentBottomInset: CGFloat = 0

	public enum State {
		case Stopped
		case Triggered
		case Loading
		case All
	}

	/// If true then No more records will not display and if false then show no more records label
	public var hasMoreData: Bool = true {
		didSet {
			if hasMoreData {

				labelNoMoreRecord.hidden = true
			}
		}
	}

	public var font: UIFont = UIFont.systemFontOfSize(12.0)
	public var fontColor: UIColor = UIColor.blackColor()

	public var state: State = .Stopped {
		willSet {
			if state != newValue {
				self.setNeedsLayout()
				switch newValue {
				case .Stopped:
					resetScrollViewContentInset()
				case .Loading:
					setScrollViewContentInsetForInfiniteScrolling()
					if state == .Triggered {
						actionHandler?()
					}
				default:
					break
				}
			}
		}
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)
		initViews()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initViews()
	}

	public func startAnimating() {
		state = .Loading
	}

	public func stopAnimating() {
		state = .Stopped
	}

	public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == observeKeyContentOffset {
			srollViewDidScroll(change?[NSKeyValueChangeNewKey]?.CGPointValue)
		} else if keyPath == observeKeyContentSize {
			setNeedsLayout()
			if let _ = change?[NSKeyValueChangeNewKey]?.CGPointValue {
				self.frame = CGRect(x: CGFloat(0), y: scrollView!.contentSize.height, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight)
			}
		}
	}

	private func srollViewDidScroll(contentOffset: CGPoint?) {
		if scrollView == nil || contentOffset == nil {
			return
		}
		if state != .Loading {
			let scrollViewContentHeight = scrollView!.contentSize.height
			var scrollOffsetThreshold = scrollViewContentHeight - scrollView!.bounds.height + 40
			if scrollViewContentHeight < self.scrollView!.bounds.height {
				scrollOffsetThreshold = 40 - self.scrollView!.contentInset.top
			}
			if !scrollView!.dragging && state == .Triggered {
				state = .Loading
			} else if contentOffset!.y > scrollOffsetThreshold && state == .Stopped && scrollView!.dragging {
				state = .Triggered
			} else if contentOffset!.y < scrollOffsetThreshold && state != .Stopped {
				state == .Stopped
			}
		}
	}

	private func setScrollViewContentInset(contentInset: UIEdgeInsets) {
		UIView.animateWithDuration(0.3, delay: 0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: { () -> Void in
            print("self.scrollView:\(self.scrollView) \(contentInset)")
			self.scrollView?.contentInset = contentInset
			}, completion: nil)
	}

	private func resetScrollViewContentInset() {
		if scrollView == nil {
			return
		}
		var currentInset = scrollView!.contentInset
		currentInset.bottom = scrollViewOriginContentBottomInset
		setScrollViewContentInset(currentInset)
	}

	private func setScrollViewContentInsetForInfiniteScrolling() {
		if scrollView == nil {
			return
		}
		var currentInset = scrollView!.contentInset
		currentInset.bottom = scrollViewOriginContentBottomInset + ICSInfiniteScrollingViewHeight
		setScrollViewContentInset(currentInset)
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		let screenSize: CGRect = UIScreen.mainScreen().bounds
		let screenWidth = screenSize.width
		activityIndicator.center = CGPoint.init(x: (screenWidth as CGFloat - activityIndicator.frame.size.width + 15) / 2, y: 20)

		var frame = labelNoMoreRecord.frame
		frame.size.width = screenWidth
		labelNoMoreRecord.frame = frame

		switch state {
		case .Stopped:
			if !hasMoreData {
				labelNoMoreRecord.hidden = false
			}
			activityIndicator.stopAnimating()
		case .Loading:
			if !hasMoreData {
				labelNoMoreRecord.hidden = false
			} else {
				activityIndicator.startAnimating()
			}
		default:
			break
		}
	}

	public override func willMoveToSuperview(newSuperview: UIView?) {
		if superview != nil && newSuperview == nil {
			if scrollView?.showsInfiniteScrolling != nil && scrollView!.showsInfiniteScrolling {
				scrollView?.removeInfiniteScrollingViewObservers()
			}
		}
	}

	// MARK: Basic Views

	func initViews() {
		addSubview(defaultView)
		defaultView.addSubview(activityIndicator)
		defaultView.addSubview(labelNoMoreRecord)
	}

	lazy var defaultView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.clearColor()
		view.frame = self.bounds
		return view
	}()

	lazy var activityIndicator: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
		activityIndicator.hidesWhenStopped = true
		return activityIndicator
	}()

	/// To show no more records in infinite scroll

	lazy var labelNoMoreRecord: UILabel = {

		let labelNoMoreRecord = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight))
		labelNoMoreRecord.hidden = true
		labelNoMoreRecord.text = "No More Records"
		labelNoMoreRecord.font = UIFont.systemFontOfSize(12.0)
		labelNoMoreRecord.textAlignment = .Center
		labelNoMoreRecord.backgroundColor = UIColor.clearColor()

		return labelNoMoreRecord
	}()

}
