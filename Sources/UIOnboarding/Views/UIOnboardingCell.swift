//
//  UIOnboardingCell.swift
//  UIOnboarding
//
//  Created by Lukman Aščić on 14.02.22.
//

import UIKit

final class UIOnboardingCell: UITableViewCell {
    static let reuseIdentifier = "onboardingFeatureCell"

    private var featureGlyphWidth: NSLayoutConstraint!
    private lazy var featureGlyph: UIImageView = {
        let featureGlyph: UIImageView = .init()
        featureGlyph.tintColor = .label
        featureGlyph.contentMode = .scaleAspectFit
        
        featureGlyphWidth = featureGlyph.heightAnchor.constraint(equalToConstant: traitCollection.horizontalSizeClass == .regular ? 60 : 44)
        featureGlyphWidth.isActive = true
        featureGlyph.widthAnchor.constraint(equalTo: featureGlyph.heightAnchor).isActive = true
        
        featureGlyph.translatesAutoresizingMaskIntoConstraints = false
        return featureGlyph
    }()
    
    private let titleLabel: UIIntrinsicLabel = {
        let label: UIIntrinsicLabel = .init()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        if #available(iOS 15.0, *) {
            label.maximumContentSizeCategory = .accessibilityLarge
        }
        label.adjustsFontForContentSizeCategory = true

        return label
    }()
    private var stackLeading: NSLayoutConstraint!
    private var stackBottom: NSLayoutConstraint!
    
    private let descriptionLabel: UIIntrinsicLabel = {
        let label: UIIntrinsicLabel = .init()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        if #available(iOS 15.0, *) {
            label.maximumContentSizeCategory = .accessibilityLarge
        }
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private var labelStack: UIStackView!
    var configuration: UIOnboardingFeatureStyle = .init()
                
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        #if swift(>=5.9)
            if #available(iOS 17.0, *) {
                registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: Self, _) in
                    self.handleHorizontalSizeClassChange()
                }
            }
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(feature: UIOnboardingFeature) {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        selectionStyle = .none
        
        isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        
        descriptionLabel.isAccessibilityElement = true
        
        configureFonts()
        
        labelStack = .init(frame: .zero)
        labelStack.axis = .vertical
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(descriptionLabel)
        labelStack.setCustomSpacing(configuration.spacing, after: titleLabel)
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(featureGlyph)
        contentView.addSubview(labelStack)
        
        featureGlyph.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        labelStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        
        stackLeading = labelStack.leadingAnchor.constraint(equalTo: featureGlyph.trailingAnchor, constant: traitCollection.horizontalSizeClass == .regular ? 32 : 18)
        stackLeading.isActive = true
        labelStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        stackBottom = labelStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: traitCollection.horizontalSizeClass == .regular ? -48 : -12)
        stackBottom.isActive = true

        featureGlyph.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 4).isActive = true
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        
        set(feature)
    }
    
    private var premiumBadge: UIView?

    private func set(_ feature: UIOnboardingFeature) {
        premiumBadge?.removeFromSuperview()
        premiumBadge = nil

        featureGlyph.image = feature.icon
        featureGlyph.tintColor = feature.iconTint

        titleLabel.text = feature.title
        titleLabel.accessibilityLabel = feature.title

        descriptionLabel.text = feature.description
        descriptionLabel.accessibilityLabel = feature.description

        if feature.isPremium {
            addPremiumBadge(tintColor: feature.iconTint, title: feature.premiumBadgeTitle)
        }
    }

    private func addPremiumBadge(tintColor: UIColor, title: String) {

        let label = UILabel()
        label.text = title.uppercased()
        label.font = .systemFont(ofSize: 8, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center

        let badge = UIView()
        badge.backgroundColor = tintColor
        badge.layer.cornerRadius = 5
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: badge.topAnchor, constant: 1),
            label.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -1),
            label.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -4),
        ])

        contentView.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.trailingAnchor.constraint(equalTo: featureGlyph.trailingAnchor, constant: 4),
            badge.bottomAnchor.constraint(equalTo: featureGlyph.bottomAnchor, constant: 2),
        ])

        premiumBadge = badge
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #unavailable(iOS 17.0), traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            // iOS 17+ uses the trait registration API instead. (`registerForTraitChanges(_:handler:)`)
            handleHorizontalSizeClassChange()
        }
    }
    
    private func handleHorizontalSizeClassChange() {
        // Check if the view is visible and the properties are initialized.
        guard window != nil else { return }
        
        configureFonts()
        
        stackBottom.constant = traitCollection.horizontalSizeClass == .regular ? -48 : -12
        featureGlyphWidth.constant = traitCollection.horizontalSizeClass == .regular ? 60 : 44
        stackLeading.constant = traitCollection.horizontalSizeClass == .regular ? 32 : 18
        contentView.layoutIfNeeded()
    }
}

private extension UIOnboardingCell {
    func configureFonts() {
        if let customTitleFont = UIFont(name: configuration.titleFontName, size: traitCollection.horizontalSizeClass == .regular ? configuration.titleFontSize * 1.176 : configuration.titleFontSize) {
            titleLabel.font = UIFontMetrics.default.scaledFont(for: customTitleFont)
        } else {
            titleLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: traitCollection.horizontalSizeClass == .regular ? configuration.titleFontSize * 1.176 : configuration.titleFontSize, weight: .semibold))
        }

        if let customDescriptionFont = UIFont(name: configuration.descriptionFontName, size: traitCollection.horizontalSizeClass == .regular ? configuration.descriptionFontSize * 1.176 : configuration.descriptionFontSize) {
            descriptionLabel.font = UIFontMetrics.default.scaledFont(for: customDescriptionFont)
        } else {
            descriptionLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: traitCollection.horizontalSizeClass == .regular ? configuration.descriptionFontSize * 1.176 : configuration.descriptionFontSize, weight: .light))
        }
    }
}
