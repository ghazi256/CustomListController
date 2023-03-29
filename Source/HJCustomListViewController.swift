//
//  HJCustomListViewController.swift
//  Fox
//
//  Created by Hasnain Jafri on 19/10/2020.
//  Copyright © 2020 MTBC. All rights reserved.
//

import UIKit
import StoreKit

//MARK: - Data Models

enum DisplayType: Equatable {
    case fullScreen(ListBackgroundType)
    case popover
}

enum ListBackgroundType {
    case lightbox
    case blur
    case dropShadow
}

struct HJListConfiguration {
    var displayType: DisplayType
    var topViewConfiguration: TopViewConfiguration?
    var cellConfiguration: CellConfiguration
    var bottomButtonConfiguration: BottomButtonConfiguration?
    var popoverConfiguration: PopoverConfiguration?
    var containerConfiguration: ContainerConfiguration = ContainerConfiguration()
    
    //Show selection images or not. Will auto change to true in case of multiple selection or selected values in initialization.
    var shouldShowSelection = true
    
    //Allow to select multiple values in the list. The default value is true
    var isMultiSelectionAllowed = false
    
    //Used when isMultiSelectionAllowed is false for sending empty or selected item in case of selecting an already selected item.
    var isAllowedToRemoveSelectedItemInSingleSelection = true
    
    //Flash scroll indicator. Default value is true
    var shouldFlashScrollIndicators = true
    
    //If list have multiple sections, this will be used to draw background color or section headers.
    var sectionHeaderBackgroundColor = UIColor.lightOrange
}

struct ContainerConfiguration {
    var horizontalPadding: CGFloat = 20
    var verticalPadding: CGFloat = 40
    var cornerRadius: CGFloat = 10
}

struct TopViewConfiguration {
    var title: String
    var displayLeftBarButtonItem: Bool
    var displayRightBarButtonItem: Bool
    var leftBarButtonTitle: String?
    var rightBarButtonTitle: String?
    var backgroundColor: UIColor = UIColor.regularOrange
}

struct CellConfiguration {
    var cellType: UITableViewCell.CellStyle
    var titleFont = UIFont(name: "Helvetica", size: 15.0)
    var subtitleFont = UIFont(name: "Helvetica-Light", size: 13.0)
    var accessoryImage: UIImage?
    var acessoryUserInterationEnabled = true
    var selectionConfiguration: CellSelectionConfiguration = CellSelectionConfiguration()
    var seperatorColor: UIColor?
}

struct CellSelectionConfiguration {
    var selectionStyle: UITableViewCell.SelectionStyle = .none
    var checked: UIImage?
    var unchecked: UIImage?
    var tint: UIColor = UIColor.regularOrange
}

struct PopoverConfiguration {
    var presentingRect: CGRect
    var direction: UIPopoverArrowDirection = .up
    var contentSize: CGSize = CGSize(width: 250, height: 350)
    var shouldDimBackground = false
    var displayBorder = true
}

struct BottomButtonConfiguration {
    var title: String
    var image: UIImage?
    var titleColor: UIColor = .white
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    var backgroundColor: UIColor = UIColor(red: 193.0/255.0, green: 27.0/255.0, blue: 102.0/255.0, alpha: 1.0)
    var width: CGFloat = 150
    var height: CGFloat = 40
}

protocol ListRowProtocol: Equatable {
    associatedtype ListElement: Equatable = Encodable
    associatedtype ID
    var id: ID? { get set}
    var title: String { get set}
    var subtitle: String? { get set}
}

struct HJRowData<Element: Equatable & Encodable>: ListRowProtocol{
    
    typealias ListElement = Element
    
    var id: String?
    var title: String
    var subtitle: String?
    var dataObject: ListElement?
    
    static func == (lhs: HJRowData, rhs: HJRowData) -> Bool {
        
        if let lhsID = lhs.id, let rhsID = rhs.id {
            if lhsID.isEmpty == false && rhsID.isEmpty == false{
                return lhsID == rhsID
            }
        }else if let lhsDataObject = lhs.dataObject, let rhsDataObject = rhs.dataObject {
            return lhsDataObject == rhsDataObject
        }else{
            return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
        }
        
        return false
    }
}

struct HJIdentifier {
    var uniqueID: Double?
    var stringIdentifier: String?
    var controlObject: Any?
}

//MARK: - protocol

protocol HJCustomListDelegate: AnyObject {
    
    /// - Return true if we want to dsimiss Custome List on selection
    @discardableResult func customList(_ customList: HJCustomListViewController, selectedValues selectedRows: Array<HJRowData>) -> Bool?
    
    func customList(_ customList: HJCustomListViewController, leftButtonTapped selectedRows: Array<HJRowData>)
    func customList(_ customList: HJCustomListViewController, rightButtonTapped selectedRows: Array<HJRowData>)
    func customList(_ customList: HJCustomListViewController, bottomButtonTapped selectedRows: Array<HJRowData>)
    func customList(_ customList: HJCustomListViewController, accessoryButtonTapped accessoryButton: UIButton, rowData: HJRowData)
    func customList(_ customList: HJCustomListViewController, colorForTitle rowData: HJRowData) -> UIColor?
    func customList(_ customList: HJCustomListViewController, colorForSubtitle rowData: HJRowData) -> UIColor?
    func customList(_ customList: HJCustomListViewController, colorFroRow rowData: HJRowData) -> UIColor?
    /// - Called when shouldShowSelection is turned false
    func customList(_ customList: HJCustomListViewController, imageFromRow rowData: HJRowData) -> UIImage?
    /// - Called when list view controller is being dismissed
    func customList(_ customList: HJCustomListViewController, listViewDismissed selectedRows: Array<HJRowData>)
}

//Provide Default Implementations for optional protocols
extension HJCustomListDelegate {
    func customList(_ customList: HJCustomListViewController, leftButtonTapped selectedRows: Array<HJRowData>) {}
    func customList(_ customList: HJCustomListViewController, rightButtonTapped selectedRows: Array<HJRowData>) {}
    func customList(_ customList: HJCustomListViewController, bottomButtonTapped selectedRows: Array<HJRowData>) {}
    func customList(_ customList: HJCustomListViewController, accessoryButtonTapped accessoryButton: UIButton, rowData: HJRowData) {}
    func customList(_ customList: HJCustomListViewController, colorForTitle rowData: HJRowData) -> UIColor? {
        return nil
    }
    func customList(_ customList: HJCustomListViewController, colorForSubtitle rowData: HJRowData) -> UIColor? {
        return nil
    }
    func customList(_ customList: HJCustomListViewController, colorFroRow rowData: HJRowData) -> UIColor? {
        return nil
    }
    func customList(_ customList: HJCustomListViewController, imageFromRow rowData: HJRowData)  -> UIImage? {
        return nil
    }
    func customList(_ customList: HJCustomListViewController, listViewDismissed selectedRows: Array<HJRowData>) {}
}

class HJCustomListViewController: UIViewController {

    //IBOutelt
    
    @IBOutlet fileprivate weak var lightBoxView: UIView!
    @IBOutlet fileprivate weak var containerView: UIView!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    @IBOutlet fileprivate weak var topView: UIView!
    @IBOutlet fileprivate weak var leftButton: UIButton!
    @IBOutlet fileprivate weak var rightButton: UIButton!
    @IBOutlet fileprivate weak var bottomButton: UIButton!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    //Constraints
    
    @IBOutlet fileprivate weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var containerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var containerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var bottomButtonBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomButtonHeightConstraint: NSLayoutConstraint!
    
    //Properties
    
    private var listDataArr: Array<HJRowData>
    
    private var selectedDataArr: Array<HJRowData> = []
    
    private var listDataDict: Dictionary<String,Array<HJRowData>>
    
    private var listConfiguration: HJListConfiguration
    
    private var isSectionBasedDistributed: Bool
    
    weak var delegate: HJCustomListDelegate?
    
    //Constant Variables
    
    private let cellIdentifier = "ListCell"
    private let checkedIconImage = UIImage(named: "checked-icon")
    private let uncheckedIconImage = UIImage(named: "unchecked-icon")
    
    private let defaultLeftButtonTitle = "Dismiss"
    private let defaultRightButtonTitle = "Done"
    
    //Object to identify diff
    var uniqueID: HJIdentifier?
    
    //MARK: - Initialization
    
    init(listConfiguration: HJListConfiguration, listArray: Array<HJRowData>, selectedArray: Array<HJRowData>? = nil, uniqueID: HJIdentifier?) {
        
        self.listConfiguration = listConfiguration
        self.listDataArr = listArray
        
        if let selectedArray = selectedArray {
            self.selectedDataArr = selectedArray
            self.listConfiguration.shouldShowSelection = true
        }
        
        self.listDataDict = [:]
        self.uniqueID = uniqueID
        
        isSectionBasedDistributed = false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(listConfiguration: HJListConfiguration, listDictionary: Dictionary<String,Array<HJRowData>>, selectedArray: Array<HJRowData>? = nil, uniqueID: HJIdentifier?) {

        /*if listConfiguration.isMultipleSelectionAllowed && listConfiguration.topViewConfiguration == nil{
            self.listConfiguration.topViewConfiguration = TopViewConfiguration(displayLeftBarButtonItem: false, displayRightBarButtonItem: true, leftBarButtonTitle: "", rightBarButtonTitle: defaultRightButtonTitle, title: "")
        }*/
        
        self.listConfiguration = listConfiguration
        self.listDataArr = []
        self.listDataDict = listDictionary
        
        if let selectedArray = selectedArray {
            self.selectedDataArr = selectedArray
            self.listConfiguration.shouldShowSelection = true
        }
        
        self.uniqueID = uniqueID
        
        isSectionBasedDistributed = true
        
        super.init(nibName: "HJCustomListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Loading
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if listConfiguration.displayType == .popover {
            
            let displayBorder = self.listConfiguration.popoverConfiguration?.displayBorder ?? true
            
            containerLeadingConstraint.constant = displayBorder ? 1 : 0
            containerTrailingConstraint.constant = displayBorder ? 1 : 0
            containerTopConstraint.constant = displayBorder ? 1 : 0
            containerBottomConstraint.constant = displayBorder ? 1 : 0
            
            if displayBorder {
                self.containerView.layer.cornerRadius = 15.0
            }
        }
        
        if let bottomBtnConfig = listConfiguration.bottomButtonConfiguration {
            bottomButtonHeightConstraint.constant = bottomBtnConfig.height
            bottomButtonWidthConstraint.constant = bottomBtnConfig.width
        }else{
            tableViewBottomSpaceConstraint.constant = 0
            bottomButtonHeightConstraint.constant = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setup()
    }
    
    override func viewDidAppear (_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if listConfiguration.shouldFlashScrollIndicators {
            tableView.flashScrollIndicators()
        }
    }
    
    //MARK: Setup
    
    private func setup() {
        
        configure()
        setUpTopBar()
        setUpBottomButton()
        setupContainer()
        setupBackground()
    }
    
    private func configure() {
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setUpTopBar(){
        guard let configuration = listConfiguration.topViewConfiguration else {
            topViewHeightConstraint.constant = 0
            return
        }
        
        if configuration.displayLeftBarButtonItem{
            leftButton.setTitle(configuration.leftBarButtonTitle ?? defaultLeftButtonTitle, for: .normal)
        }else{
            leftButton.isHidden = true
        }
        
        if configuration.displayRightBarButtonItem{
            rightButton.setTitle(configuration.rightBarButtonTitle ?? defaultRightButtonTitle, for: .normal)
        }else{
            rightButton.isHidden = true
        }
        
        titleLabel.text = configuration.title
        
        topView.backgroundColor = configuration.backgroundColor
    }
    
    private func setUpBottomButton() {
        guard let configuration = listConfiguration.bottomButtonConfiguration else {
            return
        }
        
        bottomButton.titleLabel?.textAlignment = .center
        bottomButton.titleLabel?.lineBreakMode = .byWordWrapping
        
        bottomButton.setTitle(configuration.title, for: .normal)
        bottomButton.setTitleColor(configuration.titleColor, for: .normal)
        bottomButton.titleLabel?.font = configuration.titleFont
        bottomButton.backgroundColor = configuration.backgroundColor
        
        if let buttonImage = configuration.image{
            bottomButton.setImage(buttonImage, for: .normal)
        }
    }
    
    private func setupBackground() {
        
        let displayType = listConfiguration.displayType
        
        if displayType == .fullScreen(.blur){
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.insertSubview(blurEffectView, at: 1)
            
            lightBoxView.alpha = 1.0
            lightBoxView.backgroundColor = .clear
        }
        else if displayType == .fullScreen(.dropShadow){
            lightBoxView.alpha = 1.0
            lightBoxView.backgroundColor = .clear
            
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
            containerView.layer.shadowRadius = 5.0
            containerView.layer.shadowOpacity = 0.5
        }
        else if displayType == .popover {
            lightBoxView.alpha = 0.0
            lightBoxView.backgroundColor = .clear
        }
    }
    
    private func setupContainer() {
        containerView.subviews.first!.layer.cornerRadius = listConfiguration.containerConfiguration.cornerRadius
        
        containerLeadingConstraint.constant = listConfiguration.containerConfiguration.horizontalPadding
        containerTrailingConstraint.constant = listConfiguration.containerConfiguration.horizontalPadding
        containerTopConstraint.constant = listConfiguration.containerConfiguration.verticalPadding
        containerBottomConstraint.constant = listConfiguration.containerConfiguration.verticalPadding
    }
    
    //MARK: - Presenting Controller
    
    /// Show List Controller
    /// - Parameters:
    ///   - delegate: For call backs based on actions.
    ///   - caller: The view controller implementing the ListViewController. Default is nil which will get the calling view controller automatically.
    func show(delegate: HJCustomListDelegate?, caller: UIViewController? = nil) {
        
        var callingController: UIViewController? = nil
        
        if let callingClass = caller {
            callingController = callingClass
        }else if let callingClass = HJCustomListViewController.getTopViewController(){
            callingController = callingClass
        }
    
        guard let callingController = callingController else {
            fatalError()
        }
        
        self.delegate = delegate
        
        if listConfiguration.displayType != .popover{
            
            self.view.alpha = 0.0
            self.view.frame = callingController.view.bounds
            
            callingController.addChild(self)
            callingController.view.addSubview(self.view)
            self.didMove(toParent: callingController)
            
            UIView.animate(withDuration: 0.35) {
                self.view.alpha = 1.0
            }
        }else{
            HJCustomListViewController.presentPopover(baseViewController: callingController, presentedViewController: self)
       }
    }
    
    /// Dismiss List Controller
    func dismissController(completion: (() -> Void)?) {
        
        if self.listConfiguration.displayType == .popover {
            self.delegate?.customList(self, listViewDismissed: selectedDataArr)
            self.dismiss(animated: true) {
                if let completionBlock = completion{
                    completionBlock()
                }
            }
        }else{
            self.delegate?.customList(self, listViewDismissed: selectedDataArr)
            UIView.animate(withDuration: 0.35, animations: {
                self.view.alpha = 0.0
            }) { (finished) in
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                
                if let completionBlock = completion{
                    completionBlock()
                }
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        delegate?.customList(self, leftButtonTapped: selectedDataArr)
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        delegate?.customList(self, rightButtonTapped: selectedDataArr)
    }
    
    @IBAction func bottomButtonTapped(_ sender: UIButton) {
        delegate?.customList(self, bottomButtonTapped: selectedDataArr)
    }
    
    //MARK: - Miscellaneous
    
    @objc private func accessoryButtonTapped(_ sender: UIButton) {
        
        let indexPath = self.getIndexPathFromSubView(subView: sender, tableView: tableView)
        
        let rowData = listDataArr[indexPath.row]
        
        delegate?.customList(self, accessoryButtonTapped: sender, rowData: rowData)
    }
    
    private func checkAndRemoveDuplicate(_ rowData: HJRowData) -> Bool{
        if selectedDataArr.contains(where: { $0 == rowData}){
            if let itemToRemoveIndex = selectedDataArr.firstIndex(of: rowData) {
                selectedDataArr.remove(at: itemToRemoveIndex)
                return true
            }
        }
        
        return false
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension HJCustomListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSectionBasedDistributed == false{
            return 1
        }else{
            let keys = Array(listDataDict.keys)
            return keys.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSectionBasedDistributed == false{
            return listDataArr.count
        }else{
            let keys = Array(listDataDict.keys)
            let sortedKeys = keys.sorted(by: <)
            let sectionKey = sortedKeys[section]
            
            return listDataDict[sectionKey]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSectionBasedDistributed == false {
            return 0
        }
        
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSectionBasedDistributed == false {
            return nil
        }
        
        let keys = Array(listDataDict.keys)
        let sortedKeys = keys.sorted(by: <)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 34))
        
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.bounds.size.width - 16, height: 34))
        label.text = sortedKeys[section]
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.white
        
        view.addSubview(label)

        view.backgroundColor = listConfiguration.sectionHeaderBackgroundColor
        
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cellConfiguration = listConfiguration.cellConfiguration
        
        if cellConfiguration.seperatorColor != nil{
            
            if tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
                tableView.separatorInset = UIEdgeInsets.zero
            }
            if tableView.responds(to: #selector(setter: UIView.layoutMargins)) {
                tableView.layoutMargins = UIEdgeInsets.zero
            }
            if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
                cell.layoutMargins = UIEdgeInsets.zero
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellConfiguration = listConfiguration.cellConfiguration
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: cellConfiguration.cellType, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = cellConfiguration.selectionConfiguration.selectionStyle
            cell?.textLabel?.font = cellConfiguration.titleFont
            cell?.detailTextLabel?.font = cellConfiguration.subtitleFont
            
            if let seperatorColor = cellConfiguration.seperatorColor{
                tableView.separatorColor = seperatorColor
            }
            
            cell!.textLabel?.numberOfLines = 0
            cell!.detailTextLabel?.numberOfLines = 0
            
            if let img = cellConfiguration.accessoryImage {
                let accessoryBtn = UIButton(type: .custom)
                accessoryBtn.setImage(img, for: .normal)
                accessoryBtn.addTarget(self, action: #selector(accessoryButtonTapped(_:)), for: .touchUpInside)
                cell?.accessoryView = accessoryBtn
                accessoryBtn.sizeToFit()
                accessoryBtn.isUserInteractionEnabled = cellConfiguration.acessoryUserInterationEnabled
            }
            
            if let unCheckedImage = cellConfiguration.selectionConfiguration.unchecked {
                cell?.imageView?.image = unCheckedImage
                cell?.imageView?.tintColor = cellConfiguration.selectionConfiguration.tint
            }else{
                cell?.imageView?.image = UIImage(named: "unchecked-icon")
            }
        }
        
        var currRow: HJRowData? = nil
        
        if isSectionBasedDistributed == false{
            currRow = listDataArr[indexPath.row]
        }else{
            let keys = Array(listDataDict.keys)
            let sortedKeys = keys.sorted(by: <)
            let sectionKey = sortedKeys[indexPath.section]
            if let dataArr = listDataDict[sectionKey]{
                currRow = dataArr[indexPath.row]
            }
        }
        
        guard let cell = cell else {
            return UITableViewCell()
        }
        
        guard let rowData = currRow else {
            return cell
        }
        
        configureCell(cell,rowData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var currRow: HJRowData? = nil
        
        if isSectionBasedDistributed == false{
            currRow = listDataArr[indexPath.row]
        }else{
            let keys = Array(listDataDict.keys)
            let sortedKeys = keys.sorted(by: <)
            let sectionKey = sortedKeys[indexPath.section]
            if let dataArr = listDataDict[sectionKey]{
                currRow = dataArr[indexPath.row]
            }
        }
        
        guard let rowData = currRow else {
            return
        }

        if listConfiguration.isMultiSelectionAllowed{
            if checkAndRemoveDuplicate(rowData) == false {
                selectedDataArr.append(rowData)
            }
        }else{
            if checkAndRemoveDuplicate(rowData) {
                if listConfiguration.isAllowedToRemoveSelectedItemInSingleSelection == false{
                    selectedDataArr = [rowData]
                }
            }else{
                selectedDataArr = [rowData]
            }
        }
        
        let shouldDismiss = delegate?.customList(self, selectedValues: selectedDataArr) ?? false
        if shouldDismiss {
            dismissController(completion: nil)
        }else{
            listConfiguration.shouldShowSelection = true
            tableView.reloadData()
        }
    }
}

//MARK: - TableView Helper

extension HJCustomListViewController {
    
    private func configureCell(_ cell: UITableViewCell, _ rowData: HJRowData) {
        
        let cellConfiguration = listConfiguration.cellConfiguration
        
        cell.textLabel?.text = rowData.title
        cell.detailTextLabel?.text = rowData.subtitle
        
        if listConfiguration.shouldShowSelection {
            if selectedDataArr.contains(where: { $0 == rowData }){
                
                if let checkedImage = cellConfiguration.selectionConfiguration.checked {
                    cell.imageView?.image = checkedImage
                    cell.imageView?.tintColor = cellConfiguration.selectionConfiguration.tint
                }else {
                    cell.imageView?.image = checkedIconImage
                }
            }else{
                if listConfiguration.isMultiSelectionAllowed {
                    if let unCheckedImage = cellConfiguration.selectionConfiguration.unchecked {
                        cell.imageView?.image = unCheckedImage
                        cell.imageView?.tintColor = cellConfiguration.selectionConfiguration.tint
                    }else {
                        cell.imageView?.image = uncheckedIconImage
                    }
                }
                else{
                    cell.imageView?.image = nil
                }
            }
        }else{
            cell.imageView?.image = delegate?.customList(self, imageFromRow: rowData)
        }
        
        // Background Color For Row
        if let color = delegate?.customList(self, colorFroRow: rowData) {
            cell.contentView.backgroundColor = color
        }else{
            cell.contentView.backgroundColor = .white
        }
        
        // TextColor for Title
        if let color = delegate?.customList(self, colorForTitle: rowData) {
            cell.textLabel?.textColor = color
        }else{
            cell.textLabel?.textColor = .black
        }
        
        // TextColor for Subtitle
        if let color = delegate?.customList(self, colorForSubtitle: rowData) {
            cell.detailTextLabel?.textColor = color
        }else{
            cell.detailTextLabel?.textColor = .black
        }
    }
}

//MARK: UIAdaptivePresentationControllerDelegate & UIPopoverPresentationControllerDelegate

extension HJCustomListViewController: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        
        let shouldDim = self.listConfiguration.popoverConfiguration?.shouldDimBackground ?? false
        if shouldDim {
            guard let callingController = HJCustomListViewController.getTopViewController() else { return true }
            callingController.view.alpha = 1
        }
        
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.dismissController(completion: nil)
    }
}

//MARK: ListView Presentation

extension HJCustomListViewController{
    
    fileprivate class func presentPopover(baseViewController: UIViewController, presentedViewController: HJCustomListViewController){
        
        let defaultTopViewHeight: CGFloat = 44
        let defaultBottomViewHeight: CGFloat = 40
        let defaultPopoverSize = CGSize(width: 250, height: 350)
        
        let shouldDim = presentedViewController.listConfiguration.popoverConfiguration?.shouldDimBackground ?? false
        if shouldDim {
            baseViewController.view.alpha = 0.9
        }
        
        var contentSize = presentedViewController.listConfiguration.popoverConfiguration?.contentSize ?? defaultPopoverSize
        let direction = presentedViewController.listConfiguration.popoverConfiguration?.direction ?? .up
        let presentingRect = presentedViewController.listConfiguration.popoverConfiguration?.presentingRect ?? .zero
        let displayBorder = presentedViewController.listConfiguration.popoverConfiguration?.displayBorder ?? true
        
        if presentedViewController.listConfiguration.topViewConfiguration != nil {
            contentSize.height = contentSize.height + defaultTopViewHeight
        }
        if presentedViewController.listConfiguration.bottomButtonConfiguration != nil {
            contentSize.height = contentSize.height + (presentedViewController.listConfiguration.bottomButtonConfiguration?.height ?? defaultBottomViewHeight)
        }
        
        presentedViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        presentedViewController.preferredContentSize = contentSize
        presentedViewController.view.layer.borderColor = UIColor.lightOrange.cgColor
        presentedViewController.view.layer.borderWidth = displayBorder ? 1 : 0
        presentedViewController.view.layer.cornerRadius = displayBorder ? 10 : 0
        presentedViewController.view.layer.masksToBounds = false
        
        let popController:UIPopoverPresentationController = presentedViewController.popoverPresentationController!
        
        popController.permittedArrowDirections = direction
        popController.sourceView = baseViewController.view
        popController.sourceRect = presentingRect
        popController.delegate = presentedViewController
        popController.backgroundColor = displayBorder ? .lightOrange : .white

        baseViewController.present(presentedViewController, animated: true) {
            if displayBorder {
                presentedViewController.view.superview?.layer.cornerRadius = 15.0
            }
        }
    }
}

//MARK: - Data Creation

extension HJCustomListViewController{
    
    class func parseDataFromArrayOfDictionary(baseArray: Array<Dictionary<String,Any>>, idTypeKey: String? = nil, titleTypeKeys: [String], titleSeperator: String = ", ", defaultTitleForEmptyData: String = "", subtitleTypeKeys: [String]? = nil, subtitleSeperator: String = ", ", defaultSubtitleForEmptyData: String = "", needDataDictionary: Bool = false) -> Array<HJRowData> {
        
        //Nested Function Start
        func parseID(_ dictionary: Dictionary<String,Any>) -> String {
            guard let identificationkey = idTypeKey else { return ""}
            if let identificationValue = dictionary[identificationkey] {
                return String(describing: identificationValue)
            }
            return ""
        }
        //Nested Function End
        
        var dataArr: Array<HJRowData> = []
        
        for dictionary in baseArray {
            
            let dataID = parseID(dictionary)
            let titleTxt = getDataFromMultipleKeys(dictionary: dictionary, stringArr: titleTypeKeys, seperatorString: titleSeperator)
            let subtitleTxt = getDataFromMultipleKeys(dictionary: dictionary, stringArr: subtitleTypeKeys, seperatorString: subtitleSeperator)
            
            let rowData = HJRowData(id: dataID, title: titleTxt, subtitle: subtitleTxt, dataObject: needDataDictionary ? dictionary : nil)
            
            dataArr.append(rowData)
        }
        
        return dataArr
    }
    
    class func parseDataFromArrayOfDictionary(baseArray: Array<Dictionary<String,Any>>, idTypeKey: String? = nil, titleTypeKeys: [String], titleSeperator: String = ", ", subtitleTypeKeys: [String]? = nil, subtitleSeperator: String = ", ", sectionKey: String, needDataDictionary: Bool = false) -> Dictionary<String,Array<HJRowData>> {
        
        var dataDict: Dictionary<String,Array<HJRowData>> = [:]
        
        for dictionary in baseArray {
            
            let sectionName = dictionary[sectionKey] as? String ?? ""
            let dataID = idTypeKey != nil ? dictionary[idTypeKey!] as? String ?? "" : ""
            let titleTxt = getDataFromMultipleKeys(dictionary: dictionary, stringArr: titleTypeKeys, seperatorString: titleSeperator)
            let subtitleTxt = getDataFromMultipleKeys(dictionary: dictionary, stringArr: subtitleTypeKeys, seperatorString: subtitleSeperator)
            
            let rowData = HJRowData(id: dataID, title: titleTxt, subtitle: subtitleTxt, dataObject: needDataDictionary ? dictionary : nil)
            
            if var arr = dataDict[sectionName]{
                arr.append(rowData)
                dataDict[sectionName] = arr
            }else{
                dataDict[sectionName] = [rowData]
            }
        }
        
        return dataDict
    }
    
    /// Convert Array of String to Array of HJRowData
    ///
    ///     - Parameters:
    ///                 - baseArray: The array which needs to be converted to HJRowData array.
    class func parseDataFromStringArray(baseArray: Array<String>) -> Array<HJRowData> {
        
        var dataArr: Array<HJRowData> = []
        
        for string in baseArray {
            let titleTxt = string
            let rowData = HJRowData(title: titleTxt)
            dataArr.append(rowData)
        }
        
        return dataArr
    }
}

//MARK: - Helper

extension HJCustomListViewController {

    private class func getDataFromMultipleKeys(dictionary: Dictionary<String,Any>, stringArr: [String]?, seperatorString: String, defaultForEmptyData: String = "") -> String {
        
        guard let arrayOfStrings = stringArr else { return "" }
        
        if arrayOfStrings.isEmpty{
            return ""
        }
        
        var finalString = defaultForEmptyData
        
        for string in arrayOfStrings {
            
            if let data = dictionary[string] as? String{
                if data.isEmpty == false {
                    finalString = finalString.isEmpty ? data : "\(finalString)\(seperatorString)\(data)"
                }
            }
        }
        
        return finalString
    }
    
    private class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
    private func getIndexPathFromSubView(subView: Any, tableView: UITableView) -> IndexPath {
        
        if let control = subView as? UIView
        {
            let controlPosition:CGPoint = control.convert(CGPoint.zero, to:tableView)
            if let indexPath = tableView.indexPathForRow(at: controlPosition)
            {
                return indexPath
            }
        }
        
        return IndexPath(row: 0, section: 0)
    }
}

//MARK: - Color

extension UIColor{
    static let regularOrange: UIColor = UIColor(red: 242.0/255.0, green: 102.0/255.0, blue: 40.0/255.0, alpha: 1.0)
    static let lightOrange: UIColor = UIColor(red: 245.0/255.0, green: 148.0/255.0, blue: 104.0/255.0, alpha: 1.0)
    static let darkOrange: UIColor = UIColor(red: 207.0/255.0, green: 77.0/255.0, blue: 19.0/255.0, alpha: 1.0)
}

///USAGE

/*func showList(dataArr: Array<Dictionary<String,Any>>) {
 
 let topViewConfiguration = TopViewConfiguration(displayLeftBarButtonItem: true, displayRightBarButtonItem: false, leftBarButtonTitle: defaultLeftButtonTitle, rightBarButtonTitle: defaultRightButtonTitle, title: "Active Cases")
 
 let bottomButtonConfiguration = BottomButtonConfiguration(title: "Dismiss")
 
 let cellConfiguration = CellConfiguration(cellType: .subtitle, selectionStyle: .none, accessoryImage: UIImage(named: "add-icon-3")!, acessoryUserInterationEnabled: false)
 
 let containerConfiguration = ContainerConfiguration(horizontalPadding: 50, verticalPadding: 120, cornerRadius: 10)
 
 let listConfiguration = HJListConfiguration(displayType: .fullScreen(.blur), topViewConfiguration: topViewConfiguration, isMultipleSelectionAllowed: false, cellConfiguration: cellConfiguration, containerConfiguration: containerConfiguration)
 
 let listDataArr = HJCustomListViewController.parseDataFromArrayOfDictionary(baseArray: dataArr, idTypeKey: "Case_id", titleTypeKey: ["PatientLastName","PatientFirstName"], subtitleTypeKey: ["Discipline","Case_no"], needDataDict: true)
 
 let customListController = HJCustomListViewController(listConfiguration: listConfiguration, listDataArr: listDataArr, uniqueID: nil)
 
 let rect = quickNewAppointmentBtn.superview!.convert(quickNewAppointmentBtn.frame, to: self.view)
 customListController.show(delegate: self, presentingRect: rect)
 }*/
