//
//  SegmentControl.swift
//  DinDinnAssignment
//
//  Created by Mangrulkar on 16/10/20.
//  Copyright © 2020 Ashwinkumar Mangrulkar. All rights reserved.
//

import Foundation
import UIKit

public let SLSegmentedControlNoSegment = -1

public typealias IndexChangeBlock = (Int) -> Void
public typealias TitleFormatterBlock = ((_ segmentedControl: SegmentControl, _ title: String, _ index: Int, _ selected: Bool) -> NSAttributedString)

public class SegmentControl: UIControl {
    private var _didIndexChange: (Int) -> Void = { _ in }
    
    public var sectionTitles: [String]! {
        didSet {
            self.updateSegmentsRects()
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    
    public var indexChangeBlock: IndexChangeBlock?
    
    public var titleFormatter: TitleFormatterBlock?
    
    public var titleTextAttributes: [NSAttributedString.Key: Any]?
    
    public var selectedTitleTextAttributes: [NSAttributedString.Key: Any]?
    
    public var fixLast: Bool = false
    
    open dynamic override var backgroundColor: UIColor! {
        set {
            SegmentControl.appearance().backgroundColor = newValue
        }
        get {
            return SegmentControl.appearance().backgroundColor
        }
    }
    
    public var selectionIndicatorColor: UIColor = .black {
        didSet {
            self.selectionIndicator.backgroundColor = self.selectionIndicatorColor
            self.selectionIndicatorBoxColor = self.selectionIndicatorColor
        }
    }
    
    public lazy var selectionIndicator: UIView = {
        let selectionIndicator = UIView()
        selectionIndicator.backgroundColor = self.selectionIndicatorColor
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        return selectionIndicator
    }()
    
    public var selectionIndicatorBoxColor: UIColor = .black
    
    public var borderWidthSG: CGFloat = 1.0
    
    public var selectedSegmentIndex: Int = 0
    
    public var selectionIndicatorHeight: CGFloat = 5.0
    
    public var edgeInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    internal var selectionIndicatorStripLayer = CALayer()
    internal var selectionIndicatorBoxLayer = CALayer() {
        didSet {
            self.selectionIndicatorBoxLayer.opacity = 0.3
            self.selectionIndicatorBoxLayer.borderWidth = self.borderWidthSG
        }
    }
    internal var selectionIndicatorArrowLayer = CALayer()
    internal var segmentWidth: CGFloat = 0.0
    
    internal var scrollView: CustomScrollView! = {
        let scroll = CustomScrollView()
        scroll.scrollsToTop = false
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    public var titles: [String] = []
    
    // MARK: - Init Methods
    public convenience init(sectionTitles titles: [String]) {
        self.init()
        self.setup()
        self.sectionTitles = titles
    }
    
    open override func awakeFromNib() {
        self.setup()
    }
    
    private func setup() {
        self.addSubview(self.scrollView)
        self.backgroundColor = UIColor.lightGray
        self.isOpaque = false
        self.contentMode = .redraw
    }
    
    // MARK: - View LifeCycle
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            // Control is being removed
            return
        }
        self.updateSegmentsRects()
    }
    
    // MARK: - Drawing
    
    private func measureTitleAtIndex(index: Int) -> CGSize {
        if index >= self.sectionTitles.count {
            return CGSize.zero
        }
        let title = self.sectionTitles[index]
        
        let selected = (index == self.selectedSegmentIndex)
        var size = CGSize.zero
        if self.titleFormatter == nil {
            size = (title as NSString).size(withAttributes: selected ?
                self.finalSelectedTitleAttributes() : self.finalTitleAttributes())
        } else {
            size = self.titleFormatter!(self, title, index, selected).size()
        }
        return size
    }
    
    private func attributedTitleAtIndex(index: Int) -> NSAttributedString {
        let title = self.sectionTitles[index]
        let selected = (index == self.selectedSegmentIndex)
        var str = NSAttributedString()
        if self.titleFormatter == nil {
            let attr = selected ? self.finalSelectedTitleAttributes() : self.finalTitleAttributes()
            str = NSAttributedString(string: title, attributes: attr)
        } else {
            str = self.titleFormatter!(self, title, index, selected)
        }
        return str
    }
    
    open override func draw(_ rect: CGRect) {
        self.backgroundColor.setFill()
        UIRectFill(self.bounds)
        
        self.selectionIndicatorArrowLayer.backgroundColor = self.selectionIndicatorColor.cgColor
        self.selectionIndicatorStripLayer.backgroundColor = self.selectionIndicatorColor.cgColor
        self.selectionIndicatorBoxLayer.backgroundColor = self.selectionIndicatorBoxColor.cgColor
        self.selectionIndicatorBoxLayer.borderColor = self.selectionIndicatorBoxColor.cgColor
        
        self.scrollView.layer.sublayers = nil
        
        let oldrect = rect
        
        self.editWithText(oldrect: oldrect)
        
        if self.sectionTitles == nil {
            return
        }
        
    }
    
    func editWithText(oldrect: CGRect) {
        if self.sectionTitles == nil {
            return
        }
        for (index, _) in self.sectionTitles.enumerated() {
            let size = self.measureTitleAtIndex(index: index)
            let strWidth = size.width
            let strHeight = size.height
            var fullRect = CGRect.zero
            
            // Text inside the CATextLayer will appear blurry unless the rect values are rounded
            let isLocationUp: CGFloat = 0.0
            let isBoxStyle: CGFloat = 0.0
            
            let a: CGFloat = (self.frame.height - (isBoxStyle * self.selectionIndicatorHeight)) / 2
            let b: CGFloat = (strHeight / 2) + (self.selectionIndicatorHeight * isLocationUp)
            let yPosition: CGFloat = CGFloat(roundf(Float(a - b)))
            
            var newRect = CGRect.zero
            let xPosition: CGFloat = CGFloat((self.segmentWidth * CGFloat(index)) + (self.segmentWidth - strWidth) / 2)
            newRect = CGRect(x: xPosition,
                             y: yPosition,
                             width: strWidth,
                             height: strHeight)
            fullRect = CGRect(x: self.segmentWidth * CGFloat(index), y: 0.0, width: self.segmentWidth, height: oldrect.size.height)
            
            if self.fixLast && index == self.sectionTitles.count - 1 {
                newRect = CGRect(x: self.frame.width - ceil(newRect.size.width), y: ceil(newRect.origin.y), width: ceil(newRect.size.width), height: ceil(newRect.size.height))
                
            } else {
                // Fix rect position/size to avoid blurry labels
                newRect = CGRect(x: ceil(newRect.origin.x), y: ceil(newRect.origin.y), width: ceil(newRect.size.width), height: ceil(newRect.size.height))
            }
            
            let titleLayer = CATextLayer()
            titleLayer.frame = newRect
            titleLayer.alignmentMode = CATextLayerAlignmentMode.center
            if (UIDevice.current.systemVersion as NSString).floatValue < 10.0 {
                titleLayer.truncationMode = CATextLayerTruncationMode.end
            }
            titleLayer.string = self.attributedTitleAtIndex(index: index)
            titleLayer.contentsScale = UIScreen.main.scale
            self.scrollView.layer.addSublayer(titleLayer)
            
            self.addBgAndBorderLayer(with: fullRect)
        }
    }
    
    private func addBgAndBorderLayer(with rect: CGRect) {
        // Background layer
        let bgLayer = CALayer()
        bgLayer.frame = rect
        self.layer.insertSublayer(bgLayer, at: 0)
    }
    
    private func setArrowFrame() {
        self.selectionIndicatorArrowLayer.frame = self.frameForSelectionIndicator()
        self.selectionIndicatorArrowLayer.mask = nil
        
        let arrowPath = UIBezierPath()
        var p1 = CGPoint.zero
        var p2 = CGPoint.zero
        var p3 = CGPoint.zero
        
        p1 = CGPoint(x: self.selectionIndicatorArrowLayer.bounds.size.width / 2, y: 0)
        p2 = CGPoint(x: 0, y: self.selectionIndicatorArrowLayer.bounds.size.height)
        p3 = CGPoint(x: self.selectionIndicatorArrowLayer.bounds.size.width, y: self.selectionIndicatorArrowLayer.bounds.size.height)
        
        arrowPath.move(to: p1)
        arrowPath.addLine(to: p2)
        arrowPath.addLine(to: p3)
        arrowPath.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.selectionIndicatorArrowLayer.bounds
        maskLayer.path = arrowPath.cgPath
        self.selectionIndicatorArrowLayer.mask = maskLayer
    }
    
    public var indicatorWidthPercent: Double = 1.0 {
        didSet {
            if !(indicatorWidthPercent <= 1.0 && indicatorWidthPercent >= 0.0) {
                indicatorWidthPercent = max(0.0, min(indicatorWidthPercent, 1.0))
            }
        }
    }
    
    private func frameForSelectionIndicator() -> CGRect {
        var indicatorYOffset: CGFloat = 0
        indicatorYOffset = self.bounds.size.height - self.selectionIndicatorHeight + self.edgeInset.bottom
        
        var sectionWidth: CGFloat = 0.0
        sectionWidth = self.measureTitleAtIndex(index: self.selectedSegmentIndex).width
        
        var indicatorFrame = CGRect.zero
        
        let widthToStartOfSelIndex: CGFloat = CGFloat(self.selectedSegmentIndex) * self.segmentWidth
        let widthToEndOfSelIndex: CGFloat = widthToStartOfSelIndex + self.segmentWidth
        
        var xPos = (widthToStartOfSelIndex - (sectionWidth / 2)) + ((widthToEndOfSelIndex - widthToStartOfSelIndex) / 2)
        xPos += self.edgeInset.left
        indicatorFrame = CGRect(x: xPos, y: indicatorYOffset, width: (sectionWidth - self.edgeInset.right), height: self.selectionIndicatorHeight)
        
        let currentIndicatorWidth = indicatorFrame.size.width
        let widthToMinus = CGFloat(1 - self.indicatorWidthPercent) * currentIndicatorWidth
        indicatorFrame.size.width = currentIndicatorWidth - widthToMinus
        indicatorFrame.origin.x += widthToMinus / 2
        
        return indicatorFrame
    }
    
    private func frameForFillerSelectionIndicator() -> CGRect {
        return CGRect(x: self.segmentWidth * CGFloat(self.selectedSegmentIndex), y: 0, width: self.segmentWidth, height: self.frame.height)
    }
    
    private func updateSegmentsRects() {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.layoutIfNeeded()
        self.scrollView.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        
        let count = self.sectionCount()
        if count > 0 {
            self.segmentWidth = self.frame.size.width / CGFloat(count)
        }
        
        for (index, _) in self.sectionTitles.enumerated() {
            let stringWidth = self.measureTitleAtIndex(index: index).width +
                self.edgeInset.left + self.edgeInset.right
            self.segmentWidth = max(stringWidth, self.segmentWidth)
        }
        
        self.scrollView.isScrollEnabled = true
        self.scrollView.contentSize = CGSize(width: self.totalSegmentedControlWidth(), height: self.frame.height)
    }
    
    private func sectionCount() -> Int {
        return self.sectionTitles.count
    }
    
    var enlargeEdgeInset = UIEdgeInsets()
    
    // MARK: - Touch Methods
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let touchesLocation = touch?.location(in: self) else {
            assert(false, "Touch Location not found")
            return
        }
        let enlargeRect = CGRect(x: self.bounds.origin.x - self.enlargeEdgeInset.left,
                                 y: self.bounds.origin.y - self.enlargeEdgeInset.top,
                                 width: self.bounds.size.width + self.enlargeEdgeInset.left + self.enlargeEdgeInset.right,
                                 height: self.bounds.size.height + self.enlargeEdgeInset.top + self.enlargeEdgeInset.bottom)
        
        if enlargeRect.contains(touchesLocation) {
            var segment = 0
            segment = Int((touchesLocation.x + self.scrollView.contentOffset.x) / self.segmentWidth)
            
            var sectionsCount = 0
            
            sectionsCount = self.sectionTitles.count
            
            if segment != self.selectedSegmentIndex && segment < sectionsCount {
                self.setSelected(forIndex: segment, animated: true, shouldNotify: true)
            }
        }
    }
    
    // MARK: - Scrolling
    private func totalSegmentedControlWidth() -> CGFloat {
        return CGFloat(self.sectionTitles.count) * self.segmentWidth
    }
    
    func scrollToSelectedSegmentIndex(animated: Bool) {
        var rectForSelectedIndex = CGRect.zero
        var selectedSegmentOffset: CGFloat = 0
        rectForSelectedIndex = CGRect(x: (self.segmentWidth * CGFloat(self.selectedSegmentIndex)),
                                      y: 0,
                                      width: self.segmentWidth,
                                      height: self.frame.height)
        selectedSegmentOffset = (self.frame.width / 2) - (self.segmentWidth / 2)
        rectForSelectedIndex.origin.x -= selectedSegmentOffset
        rectForSelectedIndex.size.width += selectedSegmentOffset * 2
        self.scrollView.scrollRectToVisible(rectForSelectedIndex, animated: animated)
    }
    
    // MARK: - Index Change
    public func setSelected(forIndex index: Int, animated: Bool) {
        self.setSelected(forIndex: index, animated: animated, shouldNotify: false)
    }
    
    public func setSelected(forIndex index: Int, animated: Bool, shouldNotify: Bool) {
        self.selectedSegmentIndex = index
        self.setNeedsDisplay()
        
        if index == SLSegmentedControlNoSegment {
            self.selectionIndicatorBoxLayer.removeFromSuperlayer()
            self.selectionIndicatorArrowLayer.removeFromSuperlayer()
            self.selectionIndicatorStripLayer.removeFromSuperlayer()
        } else {
            self.scrollToSelectedSegmentIndex(animated: animated)
            
            if animated {
                if self.selectionIndicatorStripLayer.superlayer == nil {
                    self.scrollView.layer.addSublayer(self.selectionIndicatorStripLayer)
                    self.setSelected(forIndex: index, animated: false, shouldNotify: true)
                    return
                }
                if shouldNotify {
                    self.notifyForSegmentChange(toIndex: index)
                }
                
                // Restore CALayer animations
                self.selectionIndicatorArrowLayer.actions = nil
                self.selectionIndicatorStripLayer.actions = nil
                self.selectionIndicatorBoxLayer.actions = nil
                
                // Animate to new position
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.15)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear))
                self.setArrowFrame()
                self.selectionIndicatorBoxLayer.frame = self.frameForFillerSelectionIndicator()
                self.selectionIndicatorStripLayer.frame = self.frameForSelectionIndicator()
                CATransaction.commit()
                
            } else {
                // Disable CALayer animations
                self.selectionIndicatorArrowLayer.actions = nil
                self.setArrowFrame()
                self.selectionIndicatorStripLayer.actions = nil
                self.selectionIndicatorStripLayer.frame = self.frameForSelectionIndicator()
                self.selectionIndicatorBoxLayer.actions = nil
                self.selectionIndicatorBoxLayer.frame = self.frameForFillerSelectionIndicator()
                if shouldNotify {
                    self.notifyForSegmentChange(toIndex: index)
                }
            }
        }
    }
    
    private func notifyForSegmentChange(toIndex index: Int) {
        if self.superview != nil {
            self.sendActions(for: .valueChanged)
        }
        self._didIndexChange(index)
    }
    
    // MARK: - Styling Support
    private func finalTitleAttributes() -> [NSAttributedString.Key: Any] {
        var defaults: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                       NSAttributedString.Key.foregroundColor: UIColor.black]
        if self.titleTextAttributes != nil {
            defaults.merge(dict: self.titleTextAttributes!)
        }
        
        return defaults
    }
    
    private func finalSelectedTitleAttributes() -> [NSAttributedString.Key: Any] {
        var defaults: [NSAttributedString.Key: Any] = self.finalTitleAttributes()
        if self.selectedTitleTextAttributes != nil {
            defaults.merge(dict: self.selectedTitleTextAttributes!)
        }
        return defaults
    }
}

extension SegmentControl: CustomSegmentProtocol {
    // segment change to tell vc
    public var change: ((Int) -> Void) {
        get {
            return self._didIndexChange
        }
        set {
            self._didIndexChange = newValue
        }
    }
    
    // vc change callback method
    public func setSelected(index: Int, animator: Bool) {
        self.setSelected(forIndex: index, animated: animator, shouldNotify: true)
    }
}

class CustomScrollView: UIScrollView {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isDragging {
            self.next?.touchesBegan(touches, with: event)
        } else {
            super.touchesBegan(touches, with: event)
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isDragging {
            self.next?.touchesMoved(touches, with: event)
        } else {
            super.touchesMoved(touches, with: event)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isDragging {
            self.next?.touchesEnded(touches, with: event)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
    
}

extension CGRect {
    mutating func changeXTo(_ value: CGFloat) {
        self.origin.x = value
    }
    
}

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]) {
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}
