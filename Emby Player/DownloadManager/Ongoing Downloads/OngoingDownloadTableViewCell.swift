//
//  OngoingDownloadTableViewCell.swift
//  Emby Player
//
//  Created by Mats Mollestad on 28/09/2018.
//  Copyright © 2018 Mats Mollestad. All rights reserved.
//

import UIKit


/// A table view cell that presents a ongoing download
class OngoingDownloadTableViewCell: UITableViewCell {
    
    var item: PlayableIteming? { didSet { updateContent() } }
    var progress: DownloadProgressable? { didSet { updateContent() } }
    
    lazy var titleLabel: UILabel = self.createLabel(fontSize: 20, fontWeight: .bold, alpha: 1)
    lazy var totalSizeLabel: UILabel = self.createLabel(fontSize: 16, fontWeight: .medium, alpha: 0.8)
    lazy var progressView: UIProgressView = self.createProgressView()
    lazy var progressLabel: UILabel = self.createLabel(fontSize: 16, fontWeight: .medium, alpha: 0.8)
    
    lazy var horizontalStackView: UIStackView = self.createContentView(subviews: [self.progressView, self.progressLabel], axis: .horizontal, alignment: .center)
    lazy var verticalStackView: UIStackView = self.createContentView(subviews: [self.titleLabel, self.totalSizeLabel, self.horizontalStackView], axis: .vertical, alignment: .fill)
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .black
        addSubview(verticalStackView)
        verticalStackView.fillSuperView()
        selectionStyle = .none
    }
    
    
    private func updateContent() {
        if let item = item {
            titleLabel.text = item.name
        }
        if let progress = progress {
            progressView.progress = Float(progress.progress)
            totalSizeLabel.text = "\(string(fromBytes: progress.writtenBytes)) of \(string(fromBytes: progress.expectedContentLength))"
            
            if !progress.progress.isNaN {
                progressLabel.text = "\(Double(Int(progress.progress*1000))/10)%"
            } else {
                progressLabel.text = "Not started"
            }
        }
    }
    
    private func string(fromBytes bytes: Int) -> String {
        return ByteCountFormatter().string(fromByteCount: Int64(truncating: NSNumber(value: bytes)))
    }
    
    
    // MARK: - View Setup
    
    private func createContentView(subviews: [UIView], axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment) -> UIStackView {
        let view = UIStackView(arrangedSubviews: subviews)
        view.axis = axis
        view.spacing = 10
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.isLayoutMarginsRelativeArrangement = true
        view.alignment = alignment
        return view
    }
    
    private func createProgressView() -> UIProgressView {
        let view = UIProgressView()
        view.tintColor = .green
        return view
    }
    
    private func createLabel(fontSize: CGFloat, fontWeight: UIFont.Weight, alpha: CGFloat) -> UILabel {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        view.textColor = .white
        view.alpha = alpha
        return view
    }
    
    private func createTitleLabel() -> UILabel {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.textColor = .white
        view.numberOfLines = 2
        return view
    }
    
    private func createProgressLabel() -> UILabel {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .white
        view.alpha = 0.8
        return view
    }
}


extension OngoingDownloadTableViewCell: DownloadManagerObserverable {
    
    func downloadDidUpdate(_ progress: DownloadRequest) {
        DispatchQueue.main.async { [weak self] in
            self?.progress = progress
        }
    }
    
    func downloadWasCompleted(for downloadPath: String, response: FetcherResponse<String>) {
        DispatchQueue.main.async { [weak self] in
            switch response {
            case .success(_):
                self?.totalSizeLabel.text = "The download has been completed!"
                self?.progressView.progress = 1
                self?.progressLabel.text = "100%"
                
            case .failed(let error):
                self?.totalSizeLabel.text = "An error cooured: \(error.localizedDescription)"
                self?.progressView.progress = 0
                self?.progressLabel.text = "NaN"
            }
        }
    }
}
