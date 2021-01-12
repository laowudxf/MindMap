//
//  MindMapView.swift
//  Example
//
//  Created by 钟志远 on 2021/1/11.
//

import Foundation
import UIKit
import SnapKit

class CustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
        addTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
    }
    
    func addTarget() {
        
    }
    
    func bind() {
        
    }
}



class MindMapNodeView: CustomView {
    static var nodeGap: CGFloat = 30
    static var nodeLineGap: CGFloat = 60
    var mindMapNode: MindMapNode
    var line: MindMapLineView?
    var parentNodeView: MindMapNodeView?
    let nameLabel: UILabel = {
        let x = UILabel()
        x.textColor = .white
        return x
    }()
    
    init(node: MindMapNode) {
        self.mindMapNode = node
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        backgroundColor = .black
           _ = [nameLabel]
            .map{addSubview($0)}
        
        nameLabel.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalTo(UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5))
        }
        
        nameLabel.text = mindMapNode.name
    }
}

class MindMapViewController: UIViewController {
    
    var mindMapData: MindMapNode?
    
    override func viewDidLoad() {
        if let node = mindMapData {
            drawMindMap(node: node)
        }
        
    }
    
    func drawMindMap(parentNode: MindMapNodeView? = nil, node: MindMapNode) {
        let nodeView = MindMapNodeView(node: node)
        if let parentNode = parentNode {
            nodeView.parentNodeView = parentNode
            
            view.addSubview(nodeView)
            
            let positionIndex = CGFloat(node.getPostionIndex())
            
            nodeView.snp.makeConstraints { (ConstraintMaker) in
                if node.position == .right {
                    ConstraintMaker.left.equalTo(parentNode.snp.right).offset(MindMapNodeView.nodeGap)
                    ConstraintMaker.centerY.equalTo(parentNode)
                } else if node.position == .rightTop {
                    ConstraintMaker.left.equalTo(parentNode.snp.right).offset(MindMapNodeView.nodeGap)
                    ConstraintMaker.centerY.equalTo(parentNode).offset(-MindMapNodeView.nodeLineGap * positionIndex)
                } else if node.position == .rightBottom {
                    ConstraintMaker.left.equalTo(parentNode.snp.right).offset(MindMapNodeView.nodeGap)
                    ConstraintMaker.centerY.equalTo(parentNode).offset(MindMapNodeView.nodeLineGap * positionIndex)
                }
            }
            let lView = MindMapLineView()
            nodeView.line = lView
            view.addSubview(lView)
            lView.setLayout(parent: parentNode, child: nodeView, position: node.position)
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panCallback(pan:)))
            nodeView.addGestureRecognizer(pan)
        } else {
            view.addSubview(nodeView)
            nodeView.snp.makeConstraints { (ConstraintMaker) in
                ConstraintMaker.center.equalToSuperview()
            }
        }
        
        for child in node.children {
            drawMindMap(parentNode: nodeView, node: child)
        }
        
    }
    
    var tmpOffsetCenter: CGPoint?
    var tmpPostion: MindMapPosition?
    var tmpChildFrame: CGRect?
    @objc func panCallback(pan: UIPanGestureRecognizer) {
        guard let v = pan.view as? MindMapNodeView, let parentNodeView = v.parentNodeView else {
            return
        }
        let offset = pan.translation(in: nil)
        let offsetCenter = v.frame.offsetCenter(rect: parentNodeView.frame)
        
        
        switch pan.state {
            case .began:
                tmpOffsetCenter = offsetCenter
                tmpPostion = v.mindMapNode.position
                tmpChildFrame = v.frame
            case .cancelled, .ended:
                tmpPostion = nil
                tmpOffsetCenter = nil
                tmpChildFrame = nil
            default:
                break
        }
        

        
        if let value = tmpOffsetCenter, let tmpChildFrame = tmpChildFrame, let tmpPostion = tmpPostion {
            
            var tmpFrame = tmpChildFrame
            tmpFrame.origin.x += offset.x
            tmpFrame.origin.y += offset.y

        let position = MindMapPosition.generate(parentRect: parentNodeView.frame, childRect: tmpFrame)
            
            if position != tmpPostion {
                v.line?.setLayout(parent: parentNodeView, child: v, position: position)
                self.tmpPostion = position
            }
            
            v.snp.remakeConstraints { (ConstraintMaker) in
                ConstraintMaker.centerX.equalTo(parentNodeView).offset(offset.x + value.x).priority(ConstraintPriority.init(750))
                ConstraintMaker.centerY.equalTo(parentNodeView).offset(offset.y + value.y).priority(ConstraintPriority.init(750))
            }
        }
        
    }
}

extension CGRect {
    
    
    func collision(rect: CGRect) -> (Bool, Bool) {
       var x = true
       var y = true
        
        if minX > rect.maxX || maxX < rect.minX {
            x = false
        }
        
        if minY > rect.maxY || maxY < rect.minY {
            y = false
        }
        
        return (x, y)
        
    }
    
    func offsetCenter(rect: CGRect) -> CGPoint {
        .init(x: centerX - rect.centerX, y: centerY - rect.centerY)
    }
    
    var centerY: CGFloat {
       return maxY - (height / 2)
    }
    
    var centerX: CGFloat {
       return maxX - (width / 2)
    }
}


//func - (left: CGRect, right: CGRect) -> CGRect{
//    return
//}
