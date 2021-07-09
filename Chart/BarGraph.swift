//
//  BarGraph.swift
//  Chart
//
//  Created by 한우람 on 2021/07/08.
//

import UIKit

class BarGraph: UIView {
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomGraphView: UIView!
    
    /**
     * https://sujinnaljin.medium.com/swift-%EC%BB%A4%EC%8A%A4%ED%85%80-%EB%B7%B0-xib-%EC%97%B0%EA%B2%B0%ED%95%98%EA%B8%B0-files-owner-vs-custom-class-89984ef73a59
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    func initUI() {
        if let view = Bundle.main.loadNibNamed("BarGraph", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            addSubview(view)
        }
    }
}
