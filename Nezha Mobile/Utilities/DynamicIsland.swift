//
//  DynamicIsland.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/1/24.
//

import UIKit

extension DynamicIsland {
    public struct ProgressIndicator {
        private let progressIndicatorImpl: DynamicIslandProgressIndicatorImplementation
        
        init () {
            progressIndicatorImpl = .init()
            progressIndicatorImpl.add(toContext: window)
        }
        
        /// The window that this progress indicator is attached to.
        /// By default, it's added to the key window (or the first window
        /// of the first scene), but you can change that by assigning a
        /// different window to this property.
        public var window: UIWindow = Self.getMainWindow() {
            didSet {
                progressIndicatorImpl.changeContext(to: window)
            }
        }
        
        /// The current progress of the progress indicator, between 0 and 100.
        /// - Note: This requires `isProgressIndeterminate` to be set to `false`
        public var progress: Double {
            get { progressIndicatorImpl.progress }
            set { progressIndicatorImpl.progress = newValue }
        }
        
        /// The color of the progress indicator. The default value is `UIColor.red`.
        public var progressColor: UIColor {
            get { progressIndicatorImpl.progressColor }
            set { progressIndicatorImpl.progressColor = newValue }
        }
        
        /// Whether the progress indicator should show indeterminate progress (this is useful when you don't know
        /// how long something is going to take). The default value is `true`.
        public var isProgressIndeterminate: Bool {
            get { progressIndicatorImpl.isProgressIndeterminate }
            set { progressIndicatorImpl.isProgressIndeterminate = newValue }
        }
        
        /// Shows an indeterminate progress animation indicator on the dynamic island.
        /// - Note: This requires `isProgressIndeterminate` to be set to `true`.
        public func showIndeterminateProgressAnimation() {
            progressIndicatorImpl.showIndeterminateProgressAnimation()
        }
        
        /// Hides the progress indicator on the dynamic island.
        public func hideProgressIndicator() {
            progressIndicatorImpl.hideProgressIndicator()
        }
        
        private static func getMainWindow() -> UIWindow {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return (windowScene?.windows.first)!
        }
    }
}

/// A type that information about the Dynamic Island as well as functionality around it such as a progress indicator.
/// - Note: The information provided (such as size) is for a static island, not one that is expanded (while a live activity is running for example).
public enum DynamicIsland {
    
    /// An object hat provides a progress indicator that shows progress around the dynamic island cutout.
    public static var progressIndicator: ProgressIndicator = {
        precondition(DynamicIsland.isAvailable,
                     "Cannot show dynamic island progress indicator on a device that does not support it!")
        return .init()
    }()
    
    /// The size of the Dynamic Island cutout.
    public static let size: CGSize = {
        return .init(width: 126.0, height: 37.33)
    }()
    
    /// The starting position of the Dynamic Island cutout.
    public static let origin: CGPoint = {
        return .init(x: UIScreen.main.bounds.midX - size.width / 2, y: 11)
    }()
    
    /// A rect that has the size and position of the Dynamic Island cutout.
    public static let rect: CGRect = {
        return .init(origin: origin, size: size)
    }()
    
    /// The corner radius of the Dynamic Island cutout.
    public static let cornerRadius: Double = {
        return size.width / 2
    }()
    
    /// Returns whether this device supports the Dynamic Island.
    /// This returns `true` for iPhone 14 Pro and iPhone Pro Max, otherwise returns `false`.
    public static let isAvailable: Bool = {
        if #unavailable(iOS 16) {
            return false
        }
        
#if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
#else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
#endif
        
        return identifier == "iPhone15,2" || identifier == "iPhone15,3" || identifier == "iPhone15,4" || identifier == "iPhone15,5" || identifier == "iPhone16,1" || identifier == "iPhone16,2"
    }()
}

final class DynamicIslandProgressIndicatorImplementation: UIView {
    private let tailLayer: CAShapeLayer = CAShapeLayer()
    private let partialTailLayer: CAShapeLayer = CAShapeLayer()
    private var currentContext: UIWindow!
    
    private enum State {
        case ready
        case animating
    }
    
    private var state: State = .ready
    
    private var isProgressIndicatorHidden: Bool {
        return tailLayer.isHidden && partialTailLayer.isHidden
    }
    
    @Clamped(between: 0...100) var progress: Double {
        didSet {
            requiresIndeterminateProgress(equalTo: false)
            if isProgressIndicatorHidden {
                requiresState(equalTo: .ready)
                showProgressIndicator()
                state = .animating
            }
            tailLayer.strokeEnd = progress / 100
        }
    }
    
    var progressColor: UIColor = .red {
        didSet {
            tailLayer.strokeColor = progressColor.cgColor
            partialTailLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var isProgressIndeterminate = true {
        didSet {
            resetProgressIndicator()
        }
    }
    
    func add(toContext context: UIWindow) {
        requiresState(equalTo: .ready)
        currentContext = context
        createAndAddDynamicIslandBorderLayers()
        currentContext.addSubview(self)
        currentContext.bringSubviewToFront(self)
    }
    
    func changeContext(to newContext: UIWindow) {
        requiresState(equalTo: .ready)
        removeIndicator()
        add(toContext: newContext)
    }
    
    
    func showIndeterminateProgressAnimation() {
        requiresIndeterminateProgress(equalTo: true)
        requiresState(equalTo: .ready)
        
        resetProgressIndicator()
        showProgressIndicator()
        tailLayer.add(mainTailAnimation(), forKey: nil)
        partialTailLayer.add(partialTailAnimation(), forKey: nil)
        state = .animating
    }
    
    func hideProgressIndicator() {
        tailLayer.isHidden = true
        partialTailLayer.isHidden = true
        resetProgressIndicator()
        state = .ready
    }
    
    fileprivate func showProgressIndicator() {
        tailLayer.isHidden = false
        partialTailLayer.isHidden = false
    }
    
    fileprivate func resetProgressIndicator() {
        tailLayer.removeAllAnimations()
        partialTailLayer.removeAllAnimations()
        tailLayer.strokeStart = 0
        tailLayer.strokeEnd = 1
        partialTailLayer.strokeStart = 0
        partialTailLayer.strokeEnd = 0
    }
    
    private func removeIndicator() {
        resetProgressIndicator()
        removeFromSuperview()
        tailLayer.removeFromSuperlayer()
        partialTailLayer.removeFromSuperlayer()
        currentContext = nil
    }
    
    private func requiresIndeterminateProgress(equalTo value: Bool) {
        precondition(isProgressIndeterminate == value, "isProgressIndeterminate must be set to '\(value)'!")
    }
    
    private func requiresState(equalTo value: State) {
        let message: String
        switch (value, state) {
        case (.ready, .animating):
            message = "Cannot show animation because progress indicator is already animating!"
            // Handle other cases here if we require them.
        default:
            message = ""
        }
        precondition(state == value, message)
    }
    
    private func createAndAddDynamicIslandBorderLayers() {
        let dynamicIslandPath = UIBezierPath(roundedRect: DynamicIsland.rect,
                                             byRoundingCorners: [.allCorners],
                                             cornerRadii: CGSize(width: DynamicIsland.cornerRadius,
                                                                 height: DynamicIsland.cornerRadius))
        
        tailLayer.path = dynamicIslandPath.cgPath
        partialTailLayer.path = dynamicIslandPath.cgPath
        
        if #available(iOS 16.0, *) {
            tailLayer.cornerCurve = .continuous
        }
        tailLayer.lineCap = .round
        tailLayer.fillRule = .evenOdd
        tailLayer.strokeColor = progressColor.cgColor
        tailLayer.strokeStart = 0
        tailLayer.strokeEnd = 1
        tailLayer.lineWidth = 5
        
        if #available(iOS 16.0, *) {
            partialTailLayer.cornerCurve = .continuous
        }
        partialTailLayer.lineCap = .round
        partialTailLayer.fillRule = .evenOdd
        partialTailLayer.strokeColor = progressColor.cgColor
        partialTailLayer.strokeStart = 0
        partialTailLayer.strokeEnd = 0
        partialTailLayer.lineWidth = 5
        partialTailLayer.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(tailLayer)
        layer.addSublayer(partialTailLayer)
    }
    
    private func mainTailAnimation() -> CAAnimationGroup {
        let animationStart = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        animationStart.values = [0, 0, 0.75]
        animationStart.keyTimes = [0, 0.25, 1]
        animationStart.duration = 2
        
        let animationEnd = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animationEnd.values = [0, 0.25, 1]
        animationEnd.keyTimes = [0, 0.25, 1]
        animationEnd.duration = 2
        
        let group = CAAnimationGroup()
        group.duration = 2
        group.repeatCount = .infinity
        group.animations = [animationStart, animationEnd]
        return group
    }
    
    private func partialTailAnimation() -> CAAnimationGroup {
        let animationStart = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        animationStart.fromValue = 0.75
        animationStart.toValue = 1
        animationStart.duration = 0.5
        
        let animationEnd = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animationEnd.fromValue = 1
        animationEnd.toValue = 1
        animationEnd.duration = 0.5
        
        let group = CAAnimationGroup()
        group.duration = 2
        group.repeatCount = .infinity
        group.animations = [animationStart, animationEnd]
        return group
    }
}

/// A property wrapper that clamps a value between a specified range.
@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>
    
    init(between range: ClosedRange<Value>) {
        self.value = range.lowerBound
        self.range = range
    }
    
    var wrappedValue: Value {
        get { value }
        set { value = min(max(range.lowerBound, newValue), range.upperBound) }
    }
}
