import UIKit

final class WeightMonitorViewController: UIViewController {
    private var chartLightImages: [UIImage] = [
        UIImage(named: "1")!,
        UIImage(named: "2")!,
        UIImage(named: "3")!,
        UIImage(named: "4")!
    ]
    private var chartDarkImages: [UIImage] = [
        UIImage(named: "5")!,
        UIImage(named: "6")!,
        UIImage(named: "7")!,
        UIImage(named: "8")!
    ]
    private var currentIndex = 0
    private let itemsPerRow = 1
    private var currentPage = 0
    
    private var historyRecords: [WeightRecord] = []
    private var currentWeight: String?
    private let weightRecordStore = WeightRecordStore()
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private let metricSystemStorage = MetricSystemStorage()
    private var editingRecordIndexPath: IndexPath?
    
    private lazy var plusButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(
                systemName: "plus",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 16,
                    weight: .bold
                )
            )!,
            target: self, action: #selector(didTapPlusButton))
        button.backgroundColor = .purpleColor
        button.tintColor = .white
        
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor(red: 0.267, green: 0.267, blue: 0.63, alpha: 0.3).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 1
        
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .backgroundColor
        
        return scroll
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Монитор веса"
        label.font = UIFont.appFont(.semibold, withSize: 20)
        label.textColor = .blackDayColor
        
        return label
    }()
    
    private lazy var widgetView = WidgetView()
    
    private lazy var historyTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let header = UIView(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 24))
        
        let headerLabel = UILabel()
        headerLabel.text = "История"
        headerLabel.font = UIFont.appFont(.semibold, withSize: 20)
        headerLabel.textColor = .blackDayColor
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            headerLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor),
        ])
        
        tableView.tableHeaderView = header
        
        return tableView
    }()
    
    private lazy var noticeView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor(red: 0.165, green: 0.165, blue: 0.388, alpha: 0.1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 20
        view.layer.shadowOpacity = 1
        view.layer.cornerRadius = 12
        view.backgroundColor = .blackDayColor
        view.isHidden = true
        
        return view
    }()
    
    private lazy var noticeViewLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавлено новое измерение"
        label.font = UIFont.appFont(.medium, withSize: 15)
        label.textColor = .modalVCBgColor
        
        return label
    }()
    
    private lazy var titleСollectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Измерения за месяц"
        label.font = UIFont.appFont(.semibold, withSize: 20)
        label.textColor = .blackDayColor
        
        return label
    }()
    
    private lazy var chartСollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(ChartCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .backgroundColor
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        return collectionView
    }()
    
    private lazy var titleSmallСollectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appFont(.medium, withSize: 15)
        label.textColor = .secondaryTextColor
        label.text = "Март"
        
        return label
    }()
    
    private lazy var leftButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(
                systemName: "chevron.left",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 11.44,
                    weight: .medium
                )
            )!,
            target: self, action: #selector(didTapLeftButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .secondaryTextColor
        button.tintColor = .white
        
        button.layer.cornerRadius = 6
        
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(
                systemName: "chevron.right",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 11.44,
                    weight: .medium
                )
            )!,
            target: self, action: #selector(didTapRightButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .secondaryTextColor
        button.tintColor = .white
        
        button.layer.cornerRadius = 6
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColor
        
        widgetView.delegateTransition = self
        weightRecordStore.delegate = self
        
        historyRecords = weightRecordStore.weightRecords
        if historyRecords.count > 0 {
            currentWeight = String(historyRecords[0].weight)
        }
        setDataToWidget(with: historyRecords)
        widgetView.updateWidgetView(with: metricSystemStorage.metricSystem)
        
        addSubviews()
        addConstraints()
    }
    
    @objc
    private func didTapPlusButton() {
        let addWeightVC = AddWeightViewController()
        addWeightVC.currentWeight = currentWeight
        addWeightVC.delegateTransition = self
        
        present(addWeightVC, animated: true)
    }
    
    private func showNoticeView() {
        noticeView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.hideNoticeView()
        }
    }
    
    private func hideNoticeView() {
        UIView.animate(withDuration: 0.5) {
            self.noticeView.alpha = 0.0
        } completion: { (_) in
            self.noticeView.isHidden = true
            self.noticeView.alpha = 1.0
        }
    }
    
    private func updateTableViewHeight() {
        tableViewHeightConstraint?.constant = historyTableView.contentSize.height
    }
    
    func updateHistoryTableView(for cell: HistoryTableViewCell, at indexPath: IndexPath) {
        let weight = historyRecords[indexPath.row].weight
        let difference = calculateDifference(for: indexPath.row)
        
        switch metricSystemStorage.metricSystem {
        case .metricUnit:
            cell.weightLabel.text = String(format: "%.1f", weight) + " " + metricSystemStorage.metricSystem.rawValue
            if let difference = difference {
                if difference > 0 {
                    cell.diffLabel.text = "+" + String(format: "%.1f", difference) + " " + metricSystemStorage.metricSystem.rawValue
                } else {
                    cell.diffLabel.text = String(format: "%.1f", difference) + " " + metricSystemStorage.metricSystem.rawValue
                }
            }
        case .imperialUnit:
            cell.weightLabel.text = String(format: "%.1f", weight * 2.20462) + " " + metricSystemStorage.metricSystem.rawValue
            if let difference = difference {
                if difference > 0 {
                    cell.diffLabel.text = "+" + String(format: "%.1f", difference * 2.20462) + " " + metricSystemStorage.metricSystem.rawValue
                } else {
                    cell.diffLabel.text = String(format: "%.1f", difference * 2.20462) + " " + metricSystemStorage.metricSystem.rawValue
                }
            }
        }
    }
    
    private func calculateDifference(for row: Int) -> Double? {
        var currentCellWeight: Double?
        var previousCellWeight: Double?
        
        if row < historyRecords.count - 1 {
            currentCellWeight = historyRecords[IndexPath(row: row, section: 1).row].weight
            previousCellWeight = historyRecords[IndexPath(row: row, section: 1).row + 1].weight
        }
        guard
            let currentCellWeight = currentCellWeight,
            let previousCellWeight = previousCellWeight
        else { return nil }
        
        return currentCellWeight - previousCellWeight
    }
    
    private func setDataToWidget(with history: [WeightRecord]) {
        guard history.count > 0 else { return }
        let lastWeight = history[0].weight
        widgetView.currentWeight = lastWeight
        
        guard history.count > 1 else { return }
        let preLastWeight = history[1].weight
        let differenceWeight = lastWeight - preLastWeight
        widgetView.diffWeight = differenceWeight
    }
    
    @objc func didTapRightButton() {
        let nextPage = currentPage + 1
        let maxPage = chartСollectionView.numberOfItems(inSection: 0) - 1
        
        if nextPage <= maxPage {
            let indexPath = IndexPath(item: nextPage, section: 0)
            chartСollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentPage = nextPage
        }
    }
    
    @objc func didTapLeftButton() {
        let prevPage = currentPage - 1
        
        if prevPage >= 0 {
            let indexPath = IndexPath(item: prevPage, section: 0)
            chartСollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentPage = prevPage
        }
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        
        view.addSubview(plusButton)
        view.bringSubviewToFront(plusButton)
        
        view.addSubview(noticeView)
        view.bringSubviewToFront(noticeView)
        noticeView.addSubview(noticeViewLabel)
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(widgetView)
        scrollView.addSubview(historyTableView)
        
        scrollView.addSubview(titleСollectionLabel)
        scrollView.addSubview(chartСollectionView)
        scrollView.addSubview(titleSmallСollectionLabel)
        scrollView.addSubview(leftButton)
        scrollView.addSubview(rightButton)
    }
    
    private func addConstraints() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        noticeViewLabel.translatesAutoresizingMaskIntoConstraints = false
        titleСollectionLabel.translatesAutoresizingMaskIntoConstraints = false
        chartСollectionView.translatesAutoresizingMaskIntoConstraints = false
        titleSmallСollectionLabel.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewHeightConstraint = historyTableView.heightAnchor.constraint(equalToConstant: historyTableView.contentSize.height)
        tableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            plusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            plusButton.widthAnchor.constraint(equalToConstant: 48),
            plusButton.heightAnchor.constraint(equalToConstant: 48),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            
            widgetView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            widgetView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            widgetView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            widgetView.heightAnchor.constraint(equalToConstant: 129),
            widgetView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            
            titleСollectionLabel.leadingAnchor.constraint(equalTo: widgetView.leadingAnchor),
            titleСollectionLabel.bottomAnchor.constraint(equalTo: widgetView.bottomAnchor, constant: 40),
            
            titleSmallСollectionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            titleSmallСollectionLabel.bottomAnchor.constraint(equalTo: titleСollectionLabel.bottomAnchor, constant: 33),
            
            rightButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            rightButton.centerYAnchor.constraint(equalTo: titleSmallСollectionLabel.centerYAnchor),
            rightButton.heightAnchor.constraint(equalToConstant: 24),
            rightButton.widthAnchor.constraint(equalToConstant: 24),
            
            leftButton.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -16),
            leftButton.centerYAnchor.constraint(equalTo: titleSmallСollectionLabel.centerYAnchor),
            leftButton.heightAnchor.constraint(equalToConstant: 24),
            leftButton.widthAnchor.constraint(equalToConstant: 24),
            
            chartСollectionView.topAnchor.constraint(equalTo: titleSmallСollectionLabel.bottomAnchor, constant: 26),
            chartСollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            chartСollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            chartСollectionView.heightAnchor.constraint(equalToConstant: view.frame.height / 812 * 297),
            
            historyTableView.topAnchor.constraint(equalTo: chartСollectionView.bottomAnchor, constant: 16),
            historyTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            historyTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            historyTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -48),
            
            noticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            noticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            noticeView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -58),
            noticeView.heightAnchor.constraint(equalToConstant: view.frame.height * 52 / 812),
            noticeViewLabel.leadingAnchor.constraint(equalTo: noticeView.leadingAnchor, constant: 16),
            noticeViewLabel.centerYAnchor.constraint(equalTo: noticeView.centerYAnchor),
        ])
    }
}

extension WeightMonitorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editingRecordIndexPath = indexPath
        
        let editingRecord = historyRecords[indexPath.row]
        let addWeightVC = AddWeightViewController()
        addWeightVC.currentWeight = String(editingRecord.weight)
        addWeightVC.currentDate = DateHelper().dateFormatterFull.string(from: editingRecord.date)
        addWeightVC.isEditVC = true
        addWeightVC.delegateTransition = self
        
        present(addWeightVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {  (contextualAction, view, boolValue) in
            
            do {
                try self.weightRecordStore.deleteExistingWeightRecord(at: indexPath)
            } catch {
                print("Не удалось удалить запись: \(error.localizedDescription)")
            }
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActions
    }
}

extension WeightMonitorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return historyRecords.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.reuseIdentifier, for: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
        
        let accessoryChevron = UIImageView(
            image: UIImage(
                systemName: "chevron.forward",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 11.44,
                    weight: .semibold
                )
            )
        )
        accessoryChevron.tintColor = .blackDayColor
        
        cell.accessoryView = accessoryChevron
        cell.backgroundColor = .backgroundColor
        
        switch indexPath.section {
        case 0:
            cell.weightLabel.text = "Вес"
            cell.diffLabel.text = "Изменения"
            cell.dateLabel.text = "Дата"
            
            cell.weightLabel.font = UIFont.appFont(.medium, withSize: 13)
            cell.diffLabel.font = UIFont.appFont(.medium, withSize: 13)
            cell.dateLabel.font = UIFont.appFont(.medium, withSize: 13)
            cell.weightLabel.textColor = .secondaryTextColor.withAlphaComponent(0.4)
            cell.diffLabel.textColor = .secondaryTextColor.withAlphaComponent(0.4)
            cell.dateLabel.textColor = .secondaryTextColor.withAlphaComponent(0.4)
            
            accessoryChevron.tintColor = .clear
            
        case 1:
            cell.diffLabel.text = ""
            updateHistoryTableView(for: cell, at: indexPath)
            
            if Calendar.current.component(.year, from: historyRecords[indexPath.row].date) == Calendar.current.component(.year, from: Date()) {
                let dateString = DateHelper().dateFormatter.string(from: historyRecords[indexPath.row].date).prefix(6)
                let dateText = dateString.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
                cell.dateLabel.text = dateText
            } else {
                cell.dateLabel.text = DateHelper().dateFormatterWithYear.string(from: historyRecords[indexPath.row].date)
            }
            
            cell.weightLabel.font = UIFont.appFont(.medium, withSize: 17)
            cell.diffLabel.font = UIFont.appFont(.medium, withSize: 17)
            cell.dateLabel.font = UIFont.appFont(.regular, withSize: 17)
            cell.weightLabel.textColor = .blackDayColor
            cell.diffLabel.textColor = .secondaryTextColor.withAlphaComponent(0.6)
            cell.dateLabel.textColor = .secondaryTextColor.withAlphaComponent(0.4)
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footer = UIView()
            footer.backgroundColor = .backgroundColor
            
            let separatorView = UIView()
            separatorView.backgroundColor = .graySeparatorColor
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            footer.addSubview(separatorView)
            
            NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16),
                separatorView.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
                separatorView.topAnchor.constraint(equalTo: footer.topAnchor, constant: -4),
                separatorView.heightAnchor.constraint(equalToConstant: 1)
            ])
            return footer
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5.0
        } else {
            return 0.0
        }
    }
}

extension WeightMonitorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ChartCollectionViewCell
        
        if UIScreen.main.traitCollection.activeAppearance != .unspecified {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                cell.backgroundView = UIImageView(image: chartDarkImages[indexPath.item])
            } else {
                cell.backgroundView = UIImageView(image: chartLightImages[indexPath.item])
            }
        }
        
        
        return cell
    }
}

extension WeightMonitorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension WeightMonitorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}


extension WeightMonitorViewController: WeightRecordStoreDelegate {
    func store(_ store: WeightRecordStore, didUpdate update: WeightRecordStoreUpdate) {
        historyRecords = weightRecordStore.weightRecords
        historyTableView.performBatchUpdates {
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(row: $0, section: 1) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(row: $0, section: 1) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(row: $0, section: 1) }
            historyTableView.insertRows(at: insertedIndexPaths, with: .fade)
            historyTableView.deleteRows(at: deletedIndexPaths, with: .fade)
            historyTableView.deleteRows(at: updatedIndexPaths, with: .fade)
            historyTableView.insertRows(at: updatedIndexPaths, with: .fade)
            for move in update.movedIndexes {
                historyTableView.moveRow(
                    at: IndexPath(item: move.oldIndex, section: 1),
                    to: IndexPath(item: move.newIndex, section: 1)
                )
            }
        }
    }
}

extension WeightMonitorViewController: ScreenTransitionProtocol {
    func onTransition<T>(value: T, key: String) {
        switch key {
            
        case "newRecord":
            guard let newRecord = value as? WeightRecord else { return }
            
            do {
                try weightRecordStore.addNewWeightRecord(newRecord)
                updateTableViewHeight()
                historyRecords = weightRecordStore.weightRecords
                historyTableView.reloadData()
                currentWeight = String(historyRecords[0].weight)
                setDataToWidget(with: historyRecords)
                widgetView.updateWidgetView(with: metricSystemStorage.metricSystem)
                showNoticeView()
            } catch {
                print("Не удалось добавить новую запись: \(error.localizedDescription)")
            }
            
        case "editRecord":
            guard let newRecord = value as? WeightRecord,
                  let editingRecordIndexPath = editingRecordIndexPath
            else { return }
            
            do {
                try weightRecordStore.updateExistingWeightRecord(at: editingRecordIndexPath, with: newRecord)
                historyRecords = weightRecordStore.weightRecords
                historyTableView.reloadData()
                currentWeight = String(historyRecords[0].weight)
                setDataToWidget(with: historyRecords)
                widgetView.updateWidgetView(with: metricSystemStorage.metricSystem)
            } catch {
                print("Не удалось изменить запись: \(error.localizedDescription)")
            }
            
        case "metricSystemShouldChange":
            guard let updatedSystem = value as? MetricSystem else { return }
            metricSystemStorage.store(metricSystem: updatedSystem)
            widgetView.updateWidgetView(with: metricSystemStorage.metricSystem)
            historyTableView.reloadData()
        default:
            break
        }
    }
}
