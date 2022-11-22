//
//  HorizontalPickerViewController.swift
//  HorizontalPickerDemo
//
//  Created by Diego Bustamante on 11/19/22.
//

import UIKit

// MARK: - UIKit PickerViewController
class HorizontalPickerViewController: UIViewController {
    
    var cellWidth: CGFloat = 0
    var data: [String] = []
    var selectedCellIndexPath: IndexPath?
    
    // MARK: - SubViews
    /// CollectionView
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HorizontalPickerViewCell.self, forCellWithReuseIdentifier: HorizontalPickerViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionViewUI()
        setUpData()
    }
    
    /// Sets up test data
    private func setUpData() {
        for i in 0..<10 {
            data.append("\(i)")
        }
    }
}
// MARK: - UI Functinos
extension HorizontalPickerViewController {
    /// Adds the `UICollectionView`to the view
    fileprivate func setUpCollectionViewUI() {
        cellWidth = view.frame.width/4
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            collectionView.heightAnchor.constraint(equalToConstant: cellWidth),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - UICollectionView Functions
extension HorizontalPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HorizontalPickerViewCell.identifier,
            for: indexPath
        ) as! HorizontalPickerViewCell
        cell.backgroundColor = indexPath.item % 2 == 0 ? .blue : .red
        cell.configure(with: data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(
            width: cellWidth,
            height: cellWidth-1
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        select(row: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = view.frame.width/2 - (cellWidth/2)
        return UIEdgeInsets(
            top: 0,
            left: inset,
            bottom: 0,
            right: inset
        )
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // if decelerate doesnt occur, scrollToCell
        if !decelerate {
            scrollToCell()
        } // else wait until decleration ends to scrollToCell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // scroll to cell
         scrollToCell()
    }
}

// MARK: - HorizontalPicker Functions
extension HorizontalPickerViewController {
    /// Scrolls to selected cell
    /// - Parameters:
    ///   - row: Item index
    ///   - section: Row index
    ///   - animated: Animated boolean
    public func select(
        row: Int,
        in section: Int = 0,
        animated: Bool = true
    ) {
        // Ensures selected row isnt more then data count
        guard row < data.count else { return }
        
        // removes any selected items
        cleanupSelection()
        
        // set new selected item
        let indexPath = IndexPath(row: row, section: section)
        selectedCellIndexPath = indexPath
        
        // Update selected cell
        let cell = collectionView.cellForItem(at: indexPath) as? HorizontalPickerViewCell
        cell?.configure(
            with: data[indexPath.row],
            isSelected: true
        )
        
        collectionView.selectItem(
            at: indexPath,
            animated: animated,
            scrollPosition: .centeredHorizontally)
    }
    
    
    /// Cleans up prior highlighted selection
    private func cleanupSelection() {
        guard let indexPath = selectedCellIndexPath else { return }
        let cell = collectionView.cellForItem(at: indexPath) as? HorizontalPickerViewCell
        cell?.configure(with: data[indexPath.row])
        selectedCellIndexPath = nil
    }
    
    /// Scrolls to visible cell based on `scrollViewDidEndDragging` or `scrollViewDidEndDecelerating` delegate functions
    private func scrollToCell() {
        var indexPath = IndexPath()
        var visibleCells = collectionView.visibleCells
        
        /// Gets visible cells
        visibleCells = visibleCells.filter({ cell -> Bool in
            let cellRect = collectionView.convert(
                cell.frame,
                to: collectionView.superview
            )
            /// Calculate if at least 50% of the cell is in the boundaries we created
            let viewMidX = view.frame.midX
            let cellMidX = cellRect.midX
            let topBoundary = viewMidX + cellRect.width/2
            let bottomBoundary = viewMidX - cellRect.width/2
            
            /// A print state representating what the return is calculating
            print("topboundary: \(topBoundary) > cellMidX: \(cellMidX) > Bottom Boundary: \(bottomBoundary)")
            return topBoundary > cellMidX  && cellMidX > bottomBoundary
        })
        
        /// Appends visible cell index to `cellIndexPath`
        visibleCells.forEach({
            if let selectedIndexPath = collectionView.indexPath(for: $0) {
                indexPath = selectedIndexPath
            }
        })
        
        let row = indexPath.row
        // Disables animation on the first and last cell
        if row == 0 || row == data.count - 1 {
            self.select(row: row, animated: false)
            return
        }
        self.select(row: row)
    }
}

