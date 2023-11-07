import UIKit

class ReusableHorizontalScrollView: UIViewController {
    var selectedTags: Set<String> = []
    var buttonAction: ((UIButton) -> Void)?

    func createHorizontalScrollViewWithButtons(tagNames: [String], scrollView: UIScrollView) {
        var xOffset: CGFloat = 10.0

        for tagName in tagNames {
            let button = UIButton(type: .system)
            let buttonWidth = tagName.width(withConstrainedHeight: 40, font: UIFont.systemFont(ofSize: 17.0))
            button.frame = CGRect(x: xOffset, y: 0, width: buttonWidth + 20.0, height: 40)

            setDefaultHorizontalButtons(button: button, tagName: tagName)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            xOffset += buttonWidth + 30.0
        }

        scrollView.contentSize = CGSize(width: xOffset, height: scrollView.frame.height)
    }

    func setColoredHorizontalButtons(button: UIButton, tag: Tag) {
        button.layer.backgroundColor = tag.color?.cgColor
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
    }

    func setDefaultHorizontalButtons(button: UIButton, tagName: String) {
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.setTitleColor(.gray, for: .normal)
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 20.0
        button.backgroundColor = UIColor.clear
        button.setTitle(tagName, for: .normal)
    }

    @objc func buttonTapped(_ sender: UIButton) {
        guard let tagName = sender.titleLabel?.text else { return }

        if selectedTags.contains(tagName) {
            selectedTags.remove(tagName)
        } else {
            selectedTags.insert(tagName)
        }

        buttonAction?(sender)
    }

    func updateButtonAppearance(_ button: UIButton) {
        guard let tagName = button.titleLabel?.text else { return }
    }
}
