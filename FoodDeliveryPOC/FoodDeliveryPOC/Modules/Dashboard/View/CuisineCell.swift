//
//  CuisineCell.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 24/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import UIKit
protocol CuisineCellDelegate: class {
    func didSelecteCuisionAtIndex(_ index: Int)
}
class CuisineCell: UITableViewCell {
    static let reusableID: String = "CuisineCellID"
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var descContainerView: UIView!
    @IBOutlet weak var foodTitleLabel: UILabel!
    @IBOutlet weak var foodDescLabel: UILabel!
    @IBOutlet weak var priceInfoLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    weak var delegate: CuisineCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.roundTopCornersRadius(radius: 16)
        self.foodImageView.clipsToBounds = true
    }
    @IBAction func addCuisine(_ sender: Any) {
        
        self.addButton.backgroundColor = UIColor(displayP3Red: 60/255, green: 183/255, blue: 66/255, alpha: 1.0)
        self.addButton.setTitle("added+1", for: .normal)
        delegate?.didSelecteCuisionAtIndex(addButton.tag)
    }
    
    func configureCuisine(cuisine: Cuisine) {
        self.foodTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.foodTitleLabel.numberOfLines = 0
        self.foodDescLabel.font = UIFont.systemFont(ofSize: 14)
        self.foodDescLabel.textColor = .lightGray
        self.foodDescLabel.numberOfLines = 0

        self.priceInfoLabel.numberOfLines = 0
        self.priceInfoLabel.font = UIFont.systemFont(ofSize: 14)
        self.priceInfoLabel.textColor = .lightGray
        foodImageView.contentMode = .scaleAspectFill
        foodImageView.image = UIImage(named: cuisine.imageUrl ?? "")

        self.addButton.setTitle(String(format: "%.2f usd", (cuisine.price ?? 0)), for: .normal)
        self.foodTitleLabel.text = cuisine.name
        self.foodDescLabel.text = cuisine.description
        self.priceInfoLabel.text = cuisine.extraDetail
        self.addButton.backgroundColor = UIColor(displayP3Red: 59/255, green: 60/255, blue: 59/255, alpha: 1.0)
        self.addButton.layer.cornerRadius = 20
        self.addButton.setTitleColor(UIColor.white, for: .normal)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let bounds = foodImageView.bounds
        let size = CGSize(width: radius, height: radius)
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: size)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath

        foodImageView.layer.mask = maskLayer

        let frameLayer = CAShapeLayer()
        frameLayer.frame = bounds
        frameLayer.path = maskPath.cgPath
        frameLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        frameLayer.fillColor = nil

        foodImageView.layer.addSublayer(frameLayer)
    }

    func roundTopCornersRadius(radius: CGFloat) {
        self.roundCorners(corners: [UIRectCorner.topLeft, UIRectCorner.topRight], radius:radius)
    }
}
