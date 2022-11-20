//
//  PickerViewCell.swift
//  HorizontalPickerDemo
//
//  Created by Diego Bustamante on 11/19/22.
//

import UIKit

/// Picker item cell
final class HorizontalPickerViewCell: UICollectionViewCell {
    /// Cell identifier
    static let identifier = String(describing: HorizontalPickerViewCell.self)
    
    /// Title label
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 21, weight: .heavy)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
    }

    public func configure(with title: String, isSelected: Bool = false) {
        titleLabel.text = title
        backgroundColor = isSelected ? .green : .darkGray
    }
}
