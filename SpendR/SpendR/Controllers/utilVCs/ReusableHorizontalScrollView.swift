//
//  ReusableHorizontalScrollView.swift
//  SpendR
//
//  Created by José Luis Corral López on 20/9/23.
//

import UIKit

class ReusableHorizontalScrollView: UIViewController {
    var selectedTags: Set<String> = []
    var classTags: [Tag] = []
    var buttonAction: ((UIButton) -> Void)?

    // MARK: - Public Functions

    func createHorizontalScrollViewWithButtons(tags: [Tag], scrollView: UIScrollView) {
        var xOffset: CGFloat = 10.0
        classTags = tags

        for tag in tags {
            if let tagName = tag.properties?.name {
                let button = createButton(tagName: tagName)
                configureButton(button, tag: tag, xOffset: &xOffset)
                scrollView.addSubview(button)
            }
        }

        scrollView.contentSize = CGSize(width: xOffset, height: scrollView.frame.height)
    }

    func removeButtonsFromScrollView(_ scrollView: UIScrollView) {
        for subview in scrollView.subviews {
            if let button = subview as? UIButton {
                button.removeFromSuperview()
            }
        }
        selectedTags.removeAll()
    }

    // MARK: - Scroll setup functions

    private func createButton(tagName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }

    private func configureButton(_ button: UIButton, tag: Tag, xOffset: inout CGFloat) {
        let buttonWidth = tag.properties?.name?.width(withConstrainedHeight: 40, font: UIFont.systemFont(ofSize: 17.0)) ?? 0.0
        button.frame = CGRect(x: xOffset, y: 0, width: buttonWidth + 20.0, height: 40)
        setDefaultHorizontalButtons(button: button, tagName: tag.properties?.name ?? "")
        xOffset += buttonWidth + 30.0
    }

    private func setColoredHorizontalButtons(button: UIButton, tag: Tag) {
        button.layer.backgroundColor = tag.color?.cgColor
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
    }

    private func setDefaultHorizontalButtons(button: UIButton, tagName: String) {
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.setTitleColor(.gray, for: .normal)
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 20.0
        button.backgroundColor = UIColor.clear
        button.setTitle(tagName, for: .normal)
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let tagName = sender.titleLabel?.text else { return }

        if selectedTags.contains(tagName) {
            setDefaultHorizontalButtons(button: sender, tagName: tagName)
            selectedTags.remove(tagName)
        } else {
            selectedTags.insert(tagName)
            if let tag = classTags.first(where: { $0.properties?.name == tagName }) {
                setColoredHorizontalButtons(button: sender, tag: tag)
            }
        }

        buttonAction?(sender)
    }
}
