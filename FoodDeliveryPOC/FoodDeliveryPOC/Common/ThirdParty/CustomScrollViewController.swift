//
//  CustomScrollViewController.swift
//  DinDinnAssignment
//
//  Created by Mangrulkar on 16/10/20.
//  Copyright © 2020 Ashwinkumar Mangrulkar. All rights reserved.
//

import EasyPeasy
import UIKit


@objc public protocol ViewControllerViewSource {
    @objc optional func viewForMixToObserveContentOffsetChange() -> UIView
    @objc optional func headerViewForMixObserveContentOffsetChange() -> UIView?
    @objc optional func cartAction(_ sender: Any)
}

public class CustomScrollViewController<T: CustomSegmentProtocol>: UIViewController where T: UIView {
    open var segmentView: T!
    
    var segmentedScrollView = CustomSengmentScrollView<T>(frame: CGRect.zero)
    var delegate: ViewControllerViewSource?
    var batchLabel: UILabel!
    
    open var scrollView: UIScrollView {
        get{
            return segmentedScrollView
        }
    }
    
    open var headerViewController: UIViewController?
    open var segmentControllers = [UIViewController]()
    
    open var headerViewOffsetHeight: CGFloat = 0.0 {
        didSet {
            segmentedScrollView.headerViewOffsetHeight = headerViewOffsetHeight
        }
    }
    
    open var segmentViewHeight: CGFloat = 40.0 {
        didSet {
            segmentedScrollView.segmentViewHeight = segmentViewHeight
        }
    }
    
    open var showsVerticalScrollIndicator = true {
        didSet {
            segmentedScrollView.mxShowsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
    }
    
    open var showsHorizontalScrollIndicator = true {
        didSet {
            segmentedScrollView.mxShowsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
    }
    
    open var shouldScrollToBottomAtFirstTime: Bool = true {
        didSet {
            segmentedScrollView.shouldScrollToBottomAtFirstTime = shouldScrollToBottomAtFirstTime
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public convenience init(headerViewController: UIViewController?,
                            segmentControllers: [UIViewController],
                            segmentView: T?) {
        self.init(nibName: nil, bundle: nil)
        self.headerViewController = headerViewController
        self.segmentControllers = segmentControllers
        self.segmentView = segmentView
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldScrollToBottomAtFirstTime {
            scrollToBottom()
        }
    }
    
    public override func loadView() {
        super.loadView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setupSegmentScrollView()
        loadControllers()
        configureCartButton()
        configureBatchLabel()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topSpacing = SegmentUtility.getTopSpacing(self)
        segmentedScrollView.topSpacing = topSpacing
        segmentedScrollView.bottomSpacing = SegmentUtility.getBottomSpacing(self)
        segmentedScrollView.easy.layout(Top(topSpacing).to(view))
        segmentedScrollView.updateSubview(view.bounds)
    }
    
    func setupSegmentScrollView() {
        let topSpacing = SegmentUtility.getTopSpacing(self)
        segmentedScrollView.topSpacing = topSpacing
        
        let bottomSpacing = SegmentUtility.getBottomSpacing(self)
        segmentedScrollView.bottomSpacing = bottomSpacing
        view.addSubview(segmentedScrollView)
        
        segmentedScrollView.easy.layout(Left(0),
                                        Right(0),
                                        Top(topSpacing).to(view),
                                        Bottom(bottomSpacing))
        
        segmentedScrollView.setContainerView()
    }
    
    func addHeaderViewController(_ headerViewController: UIViewController) {
        addChild(headerViewController)
        segmentedScrollView.addHeaderView(view: headerViewController.view)
        if let delegate = headerViewController as? ViewControllerViewSource, let v = delegate.headerViewForMixObserveContentOffsetChange?() {
            segmentedScrollView.setListenHeaderView(view: v)
            
        } else {
            headerViewController.view.layoutIfNeeded()
            segmentedScrollView.headerViewHeight = headerViewController.view.frame.height
            segmentedScrollView.updateHeaderHeight()
        }
        
        headerViewController.didMove(toParent: self)
    }
    
    func addContentControllers(_ contentControllers: [UIViewController]) {
        for controller in contentControllers {
            addChild(controller)
            segmentedScrollView.addContentView(controller.view, frame: view.bounds)
            controller.didMove(toParent: self)
            if let delegate = controller as? ViewControllerViewSource {
                let v = delegate.viewForMixToObserveContentOffsetChange!()
                segmentedScrollView.contentViews.append(v)
            } else {
                segmentedScrollView.contentViews.append(controller.view)
            }
        }
        segmentedScrollView.listenContentOffset()
        segmentedScrollView.addSegmentView(segmentView, frame: view.bounds)
    }
    
    func loadControllers() {
        if headerViewController == nil {
            headerViewController = UIViewController()
        }
        
        addHeaderViewController(headerViewController!)
        addContentControllers(segmentControllers)
    }
    
    
    private func configureCartButton() {
        let button = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "cart"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.frame = CGRect(x: UIScreen.main.bounds.size.width - 100, y: UIScreen.main.bounds.size.height - 150, width: 80, height: 80)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.cornerRadius = 40
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowRadius = 5.0
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 1.0
        button.addTarget(self, action: #selector(cartButtonClicked(_:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    private func configureBatchLabel() {
        batchLabel = UILabel()
        batchLabel.frame = CGRect(x: UIScreen.main.bounds.size.width - 40, y: UIScreen.main.bounds.size.height - 150, width: 30, height: 30)
        batchLabel.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        batchLabel.clipsToBounds = true
        batchLabel.layer.cornerRadius = 15
        batchLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        batchLabel.text = "0"
        batchLabel.textAlignment = .center
        self.view.addSubview(batchLabel)
    }
    
    @objc func cartButtonClicked(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.cartAction?(sender)
        }
    }
}

extension CustomScrollViewController {
    public func scrollToBottom() {
        segmentedScrollView.scrollToBottom(animated: false)
    }
}
