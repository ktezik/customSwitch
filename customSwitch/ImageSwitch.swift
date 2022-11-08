//
//  ImageSwitch.swift
//  customSwitch
//
//  Created by Иван Гришин on 08.11.2022.
//

import UIKit

enum ShapeType {
    case square
    case rounded
}

typealias SwitchValueChange = (_ value: Bool) -> Void
class BaseControl: UIControl {
    
    // MARK: - Property
    
    var valueChange: SwitchValueChange?
    
    var isOn: Bool = false
}

final class ImageSwitch: BaseControl {
    
    // MARK: - Properties
    
    //// corner radius of thumbnail in case of square
    //// It has no effect if shape is rounded
    
    var thumbCornerRadius: CGFloat = 0 {
        didSet {
            layoutThumbLayer(for: layer.bounds)
        }
    }
    
    //// if stretch is enable .. on touch down thumbnail increase its width....
    var isStretchEnable: Bool = true
    
    /// `shape` of your switch ... it can either be rounded or square .. you can set it accordingly
    
    var shape: ShapeType = .rounded {
        didSet {
            layoutSublayers(of: layer)
        }
    }
    
    /// Width of the border... it can have any `float` value
    var borderWidth: CGFloat = 0 {
        didSet {
            trackLayer.borderWidth = borderWidth
            layoutSublayers(of: layer)
        }
    }
    
    var borderColor: UIColor? {
        didSet { setBorderColor() }
    }
    
    var onBorderColor: UIColor = .white {
        didSet { setBorderColor() }
    }
    
    var offBorderColor: UIColor = .white {
        didSet { setBorderColor() }
    }
    
    var textColor: UIColor? {
        didSet {
            (offContentLayer as? CATextLayer)?.foregroundColor = textColor?.cgColor
            (onContentLayer as? CATextLayer)?.foregroundColor = textColor?.cgColor
        }
    }
    
    var onTextColor: UIColor = .white {
        didSet {
            (onContentLayer as? CATextLayer)?.foregroundColor = onTextColor.cgColor
        }
    }
    
    var offTextColor: UIColor = .white {
        didSet {
            (offContentLayer as? CATextLayer)?.foregroundColor = offTextColor.cgColor
        }
    }
    
    var trackTopBottomPadding: CGFloat = 0 {
        didSet {
            layoutSublayers(of: layer)
        }
    }
    
    var contentLeadingTrailingPadding: CGFloat = 0 {
        didSet {
            layoutSublayers(of: layer)
        }
    }
    
    //// Distance of `thumb` from track layer
    var thumbRadiusPadding: CGFloat = 3.5 {
        didSet {
            layoutThumbLayer(for: layer.bounds)
        }
    }
    
    var onTintColor: UIColor = .green {
        didSet {
            trackLayer.backgroundColor = getBackgroundColor()
            setNeedsLayout()
        }
    }
    
    var onTintColors: [CGColor] = [] {
        didSet {
            gradientLayer.colors = [onTintColors[0], onTintColors[1]]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.75)
            gradientLayer.locations = [0.0, 1.0]
            trackLayer.insertSublayer(gradientLayer, at: 1)
            
            setNeedsLayout()
        }
    }
    
    var offTintColor: UIColor = .white {
        didSet {
            gradientLayer.removeFromSuperlayer()
            trackLayer.backgroundColor = getBackgroundColor()
            setNeedsLayout()
        }
    }
    
    var thumbTintColor: UIColor? {
        didSet { setThumbColor() }
    }
    
    var onThumbTintColor: UIColor = .white {
        didSet { setThumbColor() }
    }
    
    var offThumbTintColor: UIColor = .white {
        didSet { setThumbColor() }
    }
    
    var onText: String? {
        didSet {
            addOnTextLayerIfNeeded()
            (onContentLayer as? CATextLayer)?.string = onText
        }
    }
    
    var offText: String? {
        didSet {
            addOffTextLayerIfNeeded()
            (offContentLayer as? CATextLayer)?.string = offText
        }
    }
    
    var onThumbImage: UIImage? {
        didSet {
            thumbLayer.contents = onThumbImage?.cgImage
        }
    }
    
    var offThumbImage: UIImage? {
        didSet {
            thumbLayer.contents = offThumbImage?.cgImage
        }
    }
    
    var thumbImage: UIImage? {
        didSet {
            thumbLayer.contents = thumbImage?.cgImage
        }
    }
    
    var onImage: UIImage? {
        didSet {
            addOnImageLayerIfNeeded()
            onContentLayer?.contents = onImage?.cgImage
        }
    }
    
    var offImage: UIImage? {
        didSet {
            addOffImageLayerIfNeeded()
            offContentLayer?.contents = offImage?.cgImage
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 64, height: 40)
    }
    
    // MARK: - Layers
    
    //// `trackLayer`:-  is main track layer
    //// `innerLayer`:- over track layer
    //// `thumLayer` :- it is used for thumb
    
    private lazy var trackLayer = CALayer()
    private lazy var innerLayer = CALayer()
    private lazy var thumbLayer: CALayer = {
        let layer = CALayer()
        layer.shadowColor = UIColor(named: "imageSwitch")?.cgColor
        layer.shadowRadius = 6
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.contentsGravity = .resizeAspect
        return layer
    }()
    
    private lazy var contentsLayer = CALayer()
    
    private let gradientLayer = CAGradientLayer()
    
    private var onContentLayer: CALayer? {
        willSet {
            onContentLayer?.removeFromSuperlayer()
        }
        didSet {
            layoutOnContentLayer(for: layer.bounds)
        }
    }
    
    private var offContentLayer: CALayer? {
        willSet {
            offContentLayer?.removeFromSuperlayer()
        }
        didSet {
            layoutOffContentLayer(for: layer.bounds)
        }
    }
    
    private var isTouchDown: Bool = false
    
    // MARK: - initializers
    
    convenience init() {
        self.init(frame: .zero)
        frame.size = intrinsicContentSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        controlDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        controlDidLoad()
    }
    
    // MARK: - Life Cycle
    
    private func controlDidLoad() {
        backgroundColor = .clear
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(innerLayer)
        layer.addSublayer(contentsLayer)
        layer.addSublayer(thumbLayer)
        
        if getBackgroundColors().isEmpty {
            gradientLayer.removeFromSuperlayer()
            trackLayer.backgroundColor = getBackgroundColor()
        } else {
            trackLayer.insertSublayer(gradientLayer, at: 0)
        }
        setBorderColor()
        trackLayer.borderWidth = borderWidth
        
        innerLayer.backgroundColor = UIColor.white.cgColor
        
        contentsLayer.masksToBounds = true
        
        setThumbColor()
        addTouchHandlers()
        layoutSublayers(of: layer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = trackLayer.bounds
        gradientLayer.cornerRadius = trackLayer.cornerRadius
    }
    
    // MARK: - Public methods
    
    func setOn(_ on: Bool, animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        isOn = on
        layoutSublayers(of: layer)
        sendActions(for: .valueChanged)
        valueChange?(isOn)
        CATransaction.commit()
    }
    
    // MARK: - layoutSubviews
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        layoutTrackLayer(for: layer.bounds)
        layoutThumbLayer(for: layer.bounds)
        contentsLayer.frame = layer.bounds
        layoutOffContentLayer(for: layer.bounds)
        layoutOnContentLayer(for: layer.bounds)
    }
    
    override func didMoveToSuperview() {
        layoutSublayers(of: layer)
    }
    
    private func layoutTrackLayer(for bounds: CGRect) {
        trackLayer.frame = bounds.insetBy(dx: trackTopBottomPadding, dy: trackTopBottomPadding)
        shape == .rounded ? (trackLayer.cornerRadius = trackLayer.bounds.height / 2)
        : (trackLayer.cornerRadius = bounds.height * 0.12)
    }
    
    private func layoutInnerLayer(for bounds: CGRect) {
        let inset = borderWidth + trackTopBottomPadding
        let isInnerHidden = isOn || (isTouchDown && isStretchEnable)
        
        innerLayer.frame = isInnerHidden
        ? CGRect(origin: trackLayer.position, size: .zero)
        : bounds.insetBy(dx: inset, dy: inset)
        
        shape == .rounded ? (innerLayer.cornerRadius = isInnerHidden ? 0 : bounds.height / 2 - inset)
        : (innerLayer.cornerRadius = isInnerHidden ? 5 : 5)
    }
    
    private func layoutThumbLayer(for bounds: CGRect) {
        let size = getThumbSize()
        let origin = getThumbOrigin(for: size.width)
        thumbLayer.frame = CGRect(origin: origin, size: size)
        
        if let thumb = thumbImage {
            onThumbImage = thumb
            offThumbImage = thumb
        }
        
        thumbLayer.contents = isOn ? onThumbImage?.cgImage : offThumbImage?.cgImage
        
        shape == .rounded ? (thumbLayer.cornerRadius = size.height / 2) : (thumbLayer.cornerRadius = thumbCornerRadius)
    }
    
    private func layoutOffContentLayer(for bounds: CGRect) {
        let size = getContentLayerSize(for: offContentLayer)
        let y = bounds.midY - size.height / 2
        let leading = (bounds.maxX - (contentLeadingTrailingPadding + borderWidth + getThumbSize().width)) / 2
        - size.width / 2
        let x = !isOn ? bounds.width - size.width - leading : bounds.width
        let origin = CGPoint(x: x, y: y)
        offContentLayer?.frame = CGRect(origin: origin, size: size)
        bounds.height < 50 ? ((offContentLayer as? CATextLayer)?.fontSize = 12)
        : ((offContentLayer as? CATextLayer)?.fontSize = bounds.height * 0.2)
    }
    
    private func layoutOnContentLayer(for bounds: CGRect) {
        let size = getContentLayerSize(for: onContentLayer)
        let y = bounds.midY - size.height / 2
        let leading = (bounds.maxX - (contentLeadingTrailingPadding + borderWidth + getThumbSize().width)) / 2
        - size.width / 2
        let x = isOn ? leading : -bounds.width / 2
        let origin = CGPoint(x: x, y: y)
        onContentLayer?.frame = CGRect(origin: origin, size: size)
        onContentLayer?.contentsCenter = CGRect(origin: origin, size: size)
        bounds.height < 50 ? ((onContentLayer as? CATextLayer)?.fontSize = 12)
        : ((onContentLayer as? CATextLayer)?.fontSize = bounds.height * 0.2)
    }
    
    private func stateDidChange() {
        if getBackgroundColors().isEmpty {
            gradientLayer.removeFromSuperlayer()
            trackLayer.backgroundColor = getBackgroundColor()
        } else {
            trackLayer.insertSublayer(gradientLayer, at: 0)
        }
        trackLayer.borderWidth = borderWidth
        thumbLayer.contents = isOn ? onThumbImage?.cgImage : offThumbImage?.cgImage
        setThumbColor()
        sendActions(for: .valueChanged)
        valueChange?(isOn)
    }
    
    // MARK: - Touches
    
    private func addTouchHandlers() {
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside])
        addTarget(self, action: #selector(touchEnded), for: [.touchDragExit, .touchCancel])
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftRight(_:)))
        leftSwipeGesture.direction = [.left]
        addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftRight(_:)))
        rightSwipeGesture.direction = [.right]
        addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc
    private func swipeLeftRight(_ gesture: UISwipeGestureRecognizer) {
        let canLeftSwipe = isOn && gesture.direction == .left
        let canRightSwipe = !isOn && gesture.direction == .right
        guard canLeftSwipe || canRightSwipe else { return }
        touchUp()
    }
    
    @objc
    private func touchDown() {
        print("touch down")
        isTouchDown = true
        layoutSublayers(of: layer)
    }
    
    @objc
    private func touchUp() {
        isOn.toggle()
        stateDidChange()
        touchEnded()
    }
    
    @objc
    private func touchEnded() {
        isTouchDown = false
        layoutSublayers(of: layer)
    }
    
    // MARK: - Layout Helper
    
    private func setBorderColor() {
        if let borderClor = borderColor {
            trackLayer.borderColor = borderClor.cgColor
        } else {
            trackLayer.borderColor = (isOn ? onBorderColor : offBorderColor).cgColor
        }
    }
    
    private func setThumbColor() {
        if let thumbColor = thumbTintColor {
            thumbLayer.backgroundColor = thumbColor.cgColor
        } else {
            thumbLayer.backgroundColor = (isOn ? onThumbTintColor : offThumbTintColor).cgColor
        }
    }
    
    final func getBackgroundColor() -> CGColor {
        return (isOn ? onTintColor : offTintColor).cgColor
    }
    
    final func getBackgroundColors() -> [CGColor] {
        return (isOn ? onTintColors : [])
    }
    
    private func getThumbSize() -> CGSize {
        let height = bounds.height - 2 * (borderWidth + thumbRadiusPadding)
        let width = (isTouchDown && isStretchEnable) ? height * 1.2 : height
        return CGSize(width: width, height: height)
    }
    
    final func getThumbOrigin(for width: CGFloat) -> CGPoint {
        let inset = borderWidth + thumbRadiusPadding
        let x = isOn ? bounds.width - width - inset : inset
        return CGPoint(x: x, y: inset)
    }
    
    final func getContentLayerSize(for layer: CALayer?) -> CGSize {
        let inset = 2 * (borderWidth + trackTopBottomPadding)
        let diameter = bounds.height - inset - getThumbSize().height / 2
        if let textLayer = layer as? CATextLayer {
            return textLayer.preferredFrameSize()
        }
        return CGSize(width: diameter, height: diameter)
    }
    
    // MARK: - Content Layers
    
    private func addOffTextLayerIfNeeded() {
        guard offText != nil else {
            offContentLayer = nil
            return
        }
        let textLayer = CATextLayer()
        textLayer.alignmentMode = .center
        textLayer.fontSize = bounds.height * 0.2
        textLayer.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        
        textLayer.foregroundColor = (textColor == nil) ? offTextColor.cgColor : textColor?.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        contentsLayer.addSublayer(textLayer)
        offContentLayer = textLayer
    }
    
    private func addOnTextLayerIfNeeded() {
        guard onText != nil else {
            onContentLayer = nil
            return
        }
        let textLayer = CATextLayer()
        textLayer.alignmentMode = .center
        textLayer.fontSize = bounds.height * 0.2
        textLayer.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        textLayer.foregroundColor = (textColor == nil) ? onTextColor.cgColor : textColor?.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        contentsLayer.addSublayer(textLayer)
        onContentLayer = textLayer
    }
    
    private func addOnImageLayerIfNeeded() {
        guard onImage != nil else {
            onContentLayer = nil
            return
        }
        let imageLayer = CALayer()
        imageLayer.contentsGravity = .center
        imageLayer.contentsScale = UIScreen.main.scale
        contentsLayer.addSublayer(imageLayer)
        onContentLayer = imageLayer
    }
    
    private func addOffImageLayerIfNeeded() {
        guard offImage != nil else {
            offContentLayer = nil
            return
        }
        let imageLayer = CALayer()
        imageLayer.contentsGravity = .resizeAspect
        imageLayer.contentsScale = UIScreen.main.scale
        contentsLayer.addSublayer(imageLayer)
        offContentLayer = imageLayer
    }
}
