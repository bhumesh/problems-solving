//
//  CuisineViewController.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 22/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import UIKit

protocol CuisineProtocol: class {
    func didAddToCart(cuisine: Cuisine, type: String)
    func getCusinesForType(_ type: String) -> [Cuisine]
}
class CuisineViewController: BaseViewController {
    weak var delegate: CuisineProtocol?
    var type: String = ""
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    var cuisines: [Cuisine] {
        return delegate?.getCusinesForType(type) ?? []
    }
}

extension CuisineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cuisines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CuisineCell.reusableID) as? CuisineCell else {
            return UITableViewCell()
        }
        
        let data = cuisines[indexPath.row]
        cell.configureCuisine(cuisine: data)
        cell.delegate = self
        cell.addButton.tag = indexPath.row
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CuisineViewController: CuisineCellDelegate {
    func didSelecteCuisionAtIndex(_ index: Int) {
        let cuisine = cuisines[index]
        cuisine.quantity? += 1
        delegate?.didAddToCart(cuisine: cuisine, type: self.type)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension CuisineViewController:ViewControllerViewSource {
    func viewForMixToObserveContentOffsetChange() -> UIView {
        return self.tableView
    }
}
