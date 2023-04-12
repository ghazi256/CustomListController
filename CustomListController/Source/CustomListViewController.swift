//
//  CustomListViewController.swift
//  Fox
//
//  Created by Hasnain Jafri on 19/10/2020.
//  Copyright (c) 2020 Hasnain Jafri. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import StoreKit

//MARK: - Data Models

public
enum DisplayType: Equatable {
    case fullScreen(ListBackgroundType)
    case popover
}

public
enum ListBackgroundType {
    case lightbox
    case blur
    case dropShadow
}

public
struct ListConfiguration {
    var displayType: DisplayType
    var topViewConfiguration: TopViewConfiguration?
    var cellConfiguration: CellConfiguration
    var bottomButtonConfiguration: BottomButtonConfiguration?
    var searchBarConfiguration: SearchbarConfiguration?
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

public
struct ContainerConfiguration {
    var constantSize: CGSize? = nil
    var horizontalPadding: CGFloat = 20
    var verticalPadding: CGFloat = 40
    var cornerRadius: CGFloat = 10
    var autoAdjustHeight = false
}

public
struct TopViewConfiguration {
    var title: String
    var displayLeftBarButtonItem: Bool
    var displayRightBarButtonItem: Bool
    var leftBarButtonTitle: String?
    var rightBarButtonTitle: String?
    var backgroundColor: UIColor = UIColor.regularOrange
}

public
struct CellConfiguration {
    var cellType: UITableViewCell.CellStyle
    var titleAttributes: LabelAttributes = LabelAttributes(font: UIFont(name: "Helvetica", size: 15.0)!)
    var subtitleAttributes: LabelAttributes = LabelAttributes(font: UIFont(name: "Helvetica-Light", size: 13.0)!)
    var accessoryImage: UIImage?
    var acessoryUserInterationEnabled = true
    var selectionConfiguration: CellSelectionConfiguration = CellSelectionConfiguration()
    var seperatorColor: UIColor?
}

public
struct CellSelectionConfiguration {
    var selectionStyle: UITableViewCell.SelectionStyle = .none
    var checked: UIImage?
    var unchecked: UIImage?
    var tint: UIColor = UIColor.regularOrange
}

public
struct PopoverConfiguration {
    var presentingRect: CGRect
    var direction: UIPopoverArrowDirection = .up
    var contentSize: CGSize = CGSize(width: 250, height: 350)
    var shouldDimBackground = false
    var displayBorder = true
}

public
struct BottomButtonConfiguration {
    var title: String
    var image: UIImage?
    var titleColor: UIColor = .white
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    var backgroundColor: UIColor = UIColor(red: 193.0/255.0, green: 27.0/255.0, blue: 102.0/255.0, alpha: 1.0)
    var width: CGFloat = 150
    var height: CGFloat = 40
}

public
struct SearchbarConfiguration {
    var placeholder: String = ""
    var allowedCharacters: String = "0123456789abcdefghijklmnopqrstuvwxyzQWERTYUIOPLKJHGFDSAZXCVBNM,-.'\n "
    var allowedLength: Int = 50
    var keyboardType: UIKeyboardType = .asciiCapable
    var tintColor: UIColor = UIColor.lightOrange
    var textOffset = UIOffset(horizontal: 8.0, vertical: 8.0)
}

public typealias RowTypeConstraints = Equatable
public struct EmptyElement: RowTypeConstraints { }

public
protocol ListRowProtocol: Equatable {
    associatedtype ListElement: RowTypeConstraints
    var title: String { get set}
    var subtitle: String? { get set}
    var rowObject: ListElement? { get set }
}

public
extension ListRowProtocol {
    var subtitle: String? {
        get {
            return nil
        }
        set { }
    }
    
    var rowObject: EmptyElement? {
        get { return nil }
        set { }
    }
}

public
struct HJRowData<Element: RowTypeConstraints>: ListRowProtocol {
    
    public typealias ListElement = Element
    
    public var id: String?
    public var title: String
    public var subtitle: String?
    public var rowObject: ListElement?
    
    init(id: String?, title: String, subtitle: String? = nil, rowObject: ListElement? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.rowObject = rowObject
    }
    
    public static func == (lhs: HJRowData, rhs: HJRowData) -> Bool {
        
        if let lhsID = lhs.id, let rhsID = rhs.id {
            if lhsID.isEmpty == false && rhsID.isEmpty == false{
                return lhsID == rhsID
            }
        } else if let lhsRowObject = lhs.rowObject, let rhsRowObject = rhs.rowObject {
            return lhsRowObject == rhsRowObject
        } else if let lhsSubtitle = lhs.subtitle, let rhsSubtitle = rhs.subtitle {
            return lhs.title == rhs.title && lhsSubtitle == rhsSubtitle
        } else {
            return lhs.title == rhs.title
        }
        
        return false
    }
}

public
struct CustomListIdentifier {
    public var uniqueID: Double?
    public var stringIdentifier: String?
    public var controlObject: Any?
}

public
struct LabelAttributes {
    public var font: UIFont
    public var alignment: NSTextAlignment
    public var textToHighlight: [String]?
    public var highlightColor: UIColor?
    public var hightlightFont: UIFont?
    
    public init(font: UIFont = UIFont.systemFont(ofSize: 15.0),
         alignment: NSTextAlignment = .left,
         textToHighlight: [String]? = nil,
         highlightColor: UIColor = .black,
         hightlightFont: UIFont? = nil) {
        self.font = font
        self.alignment = alignment
        self.textToHighlight = textToHighlight
        self.highlightColor = highlightColor
        self.hightlightFont = hightlightFont == nil && textToHighlight != nil ? font : hightlightFont
    }
}

//MARK: - protocol

public
protocol CustomListDelegate: AnyObject {
    
    /// - Return true if we want to dsimiss Custome List on selection
    @discardableResult func customList(_ customList: CustomListViewController, selectedValues selectedRows: Array<any ListRowProtocol>) -> Bool?
    
    func customList(_ customList: CustomListViewController, leftButtonTapped selectedRows: Array<any ListRowProtocol>)
    func customList(_ customList: CustomListViewController, rightButtonTapped selectedRows: Array<any ListRowProtocol>)
    func customList(_ customList: CustomListViewController, bottomButtonTapped selectedRows: Array<any ListRowProtocol>)
    func customList(_ customList: CustomListViewController, accessoryButtonTapped accessoryButton: UIButton, rowData: any ListRowProtocol)
    func customList(_ customList: CustomListViewController, colorForTitle rowData: any ListRowProtocol) -> UIColor?
    func customList(_ customList: CustomListViewController, colorForSubtitle rowData: any ListRowProtocol) -> UIColor?
    func customList(_ customList: CustomListViewController, colorFroRow rowData: any ListRowProtocol) -> UIColor?
    /// - Called when shouldShowSelection is turned false
    func customList(_ customList: CustomListViewController, imageFromRow rowData: any ListRowProtocol) -> UIImage?
    /// - Called when list view controller is being dismissed
    func customList(_ customList: CustomListViewController, listViewDismissed selectedRows: Array<any ListRowProtocol>)
}

//Provide Default Implementations for optional protocols
public
extension CustomListDelegate {
    func customList(_ customList: CustomListViewController, leftButtonTapped selectedRows: Array<any ListRowProtocol>) {}
    func customList(_ customList: CustomListViewController, rightButtonTapped selectedRows: Array<any ListRowProtocol>) {}
    func customList(_ customList: CustomListViewController, bottomButtonTapped selectedRows: Array<any ListRowProtocol>) {}
    func customList(_ customList: CustomListViewController, accessoryButtonTapped accessoryButton: UIButton, rowData: any ListRowProtocol) {}
    func customList(_ customList: CustomListViewController, colorForTitle rowData: any ListRowProtocol) -> UIColor? { return nil }
    func customList(_ customList: CustomListViewController, colorForSubtitle rowData: any ListRowProtocol) -> UIColor? { return nil }
    func customList(_ customList: CustomListViewController, colorFroRow rowData: any ListRowProtocol) -> UIColor? { return nil }
    func customList(_ customList: CustomListViewController, imageFromRow rowData: any ListRowProtocol) -> UIImage? { return nil }
    func customList(_ customList: CustomListViewController, listViewDismissed selectedRows: Array<any ListRowProtocol>) {}
}

public
class CustomListViewController: UIViewController {

    //MARK: - IBOutelt
    
    @IBOutlet fileprivate weak var lightBoxView: UIView!
    @IBOutlet fileprivate weak var containerView: UIView!
    
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    @IBOutlet fileprivate weak var topView: UIView!
    @IBOutlet fileprivate weak var leftButton: UIButton!
    @IBOutlet fileprivate weak var rightButton: UIButton!
    @IBOutlet fileprivate weak var bottomButton: UIButton!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    //MARK: - Constraints
    
    @IBOutlet fileprivate weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var containerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var containerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var bottomButtonBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomButtonHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    
    public typealias RowData = (any ListRowProtocol)
    
    private var listDataArr: Array<RowData>
    private var filteredeListDataArr: Array<RowData>
    private var selectedDataArr: Array<RowData> = []
    private var listDataDict: Dictionary<String,Array<RowData>>
    private var listConfiguration: ListConfiguration
    private var isSectionBasedDistributed: Bool
    weak var delegate: CustomListDelegate?
    
    private var hasLayoutFinished = false
    
    //Constant Variables
    
    private let cellIdentifier = "ListCell"
    private let checkedIconImage = UIImage(named: "checked-icon")
    private let uncheckedIconImage = UIImage(named: "unchecked-icon")
    
    private let defaultLeftButtonTitle = "Dismiss"
    private let defaultRightButtonTitle = "Done"
    
    //Object to identify diff
    public var uniqueID: CustomListIdentifier?
    
    //MARK: - Initialization
    
    public
    init(listConfiguration: ListConfiguration, listArray: Array<RowData>, selectedArray: Array<RowData>? = nil, uniqueID: CustomListIdentifier?) {
        
        self.listConfiguration = listConfiguration
        self.listDataArr = listArray
        self.filteredeListDataArr = listArray
        
        if let selectedArray = selectedArray {
            self.selectedDataArr = selectedArray
            self.listConfiguration.shouldShowSelection = true
        }
        
        self.listDataDict = [:]
        self.uniqueID = uniqueID
        
        isSectionBasedDistributed = false
        
        super.init(nibName: "CustomListViewController", bundle: nil)
    }
    
    public
    init(listConfiguration: ListConfiguration, listDictionary: Dictionary<String,Array<RowData>>, selectedArray: Array<RowData>? = nil, uniqueID: CustomListIdentifier?) {

        /*if listConfiguration.isMultipleSelectionAllowed && listConfiguration.topViewConfiguration == nil{
            self.listConfiguration.topViewConfiguration = TopViewConfiguration(displayLeftBarButtonItem: false, displayRightBarButtonItem: true, leftBarButtonTitle: "", rightBarButtonTitle: defaultRightButtonTitle, title: "")
        }*/
        
        self.listConfiguration = listConfiguration
        self.listDataArr = []
        self.filteredeListDataArr = []
        self.listDataDict = listDictionary
        
        if let selectedArray = selectedArray {
            self.selectedDataArr = selectedArray
            self.listConfiguration.shouldShowSelection = true
        }
        
        self.uniqueID = uniqueID
        
        isSectionBasedDistributed = true
        
        super.init(nibName: "CustomListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Loading
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if hasLayoutFinished == false {
            hasLayoutFinished = true
            setup()
        }
        
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    public override func viewDidAppear (_ animated: Bool) {
        super.viewDidAppear(animated)

        if listConfiguration.shouldFlashScrollIndicators {
            tableView.flashScrollIndicators()
        }
    }
    
    //MARK: Setup
    
    private func setup() {
        
        configure()
        setUpTopBar()
        setUpSearchBar()
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
    
    private func setUpSearchBar() {
        if let configuration = self.listConfiguration.searchBarConfiguration {
            searchBar.delegate = self
            searchBarHeightConstraint.constant = 44
            searchBar.placeholder = configuration.placeholder
            searchBar.tintColor = configuration.tintColor
            searchBar.keyboardType = configuration.keyboardType
            searchBar.searchTextPositionAdjustment = configuration.textOffset
        } else {
            searchBarHeightConstraint.constant = 0
        }
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
        
        if let size = listConfiguration.containerConfiguration.constantSize {
                        
            containerLeadingConstraint.isActive = false
            containerTrailingConstraint.isActive = false
            containerTopConstraint.isActive = false
            containerBottomConstraint.isActive = false
            
            let widthConstraint = NSLayoutConstraint(item: containerView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: size.width)
            let heightConstraint = NSLayoutConstraint(item: containerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: size.height)
            containerView.addConstraint(widthConstraint)
            containerView.addConstraint(heightConstraint)
            
            containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            
            self.view.layoutIfNeeded()
        } else if listConfiguration.containerConfiguration.autoAdjustHeight {
                let height = self.getContentHeight()
                self.containerTopConstraint.isActive = false
                self.containerBottomConstraint.isActive = false
                let heightConstraint = NSLayoutConstraint(item: self.containerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: height)
                self.containerView.addConstraint(heightConstraint)
                self.containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        } else{
            containerLeadingConstraint.constant = listConfiguration.containerConfiguration.horizontalPadding
            containerTrailingConstraint.constant = listConfiguration.containerConfiguration.horizontalPadding
            containerTopConstraint.constant = listConfiguration.containerConfiguration.verticalPadding
            containerBottomConstraint.constant = listConfiguration.containerConfiguration.verticalPadding
        }
    }
    
    //MARK: - Presenting Controller
    
    /// Show List Controller
    /// - Parameters:
    ///   - delegate: For call backs based on actions.
    ///   - caller: The view controller implementing the ListViewController. Default is nil which will get the calling view controller automatically.
    public
    func show(delegate: CustomListDelegate?, caller: UIViewController? = nil) {
        
        var callingController: UIViewController? = nil
        
        if let callingClass = caller {
            callingController = callingClass
        }else if let callingClass = CustomListViewController.getTopViewController(){
            callingController = callingClass
        }
    
        guard let callingController = callingController else {
            fatalError()
        }
        
        self.delegate = delegate
        
        if listConfiguration.displayType != .popover{
            
            callingController.addChild(self)
            callingController.view.addSubview(self.view)
            self.didMove(toParent: callingController)
            
            self.view.alpha = 0.0
            self.view.frame = callingController.view.bounds
            
            UIView.animate(withDuration: 0.35) {
                self.view.alpha = 1.0
            }
        }else{
            CustomListViewController.presentPopover(baseViewController: callingController, presentedViewController: self)
       }
    }
    
    /// Dismiss List Controller
    public
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
        
        let rowData = filteredeListDataArr[indexPath.row]
        
        delegate?.customList(self, accessoryButtonTapped: sender, rowData: rowData)
    }
    
    //MARK: - Data Creation
    
    public
    class
    func parseDataFromArrayOfDictionary<Element: RowTypeConstraints>(baseArray: Array<Dictionary<String,Any>>, idTypeKey: String? = nil, titleTypeKeys: [String], titleSeperator: String = ", ", defaultTitleForEmptyData: String = "", subtitleTypeKeys: [String]? = nil, subtitleSeperator: String = ", ", defaultSubtitleForEmptyData: String = "") -> Array<HJRowData<Element>> {
        
        //Nested Function Start
        func parseID(_ dictionary: Dictionary<String,Any>) -> String {
            guard let identificationkey = idTypeKey else { return ""}
            if let identificationValue = dictionary[identificationkey] {
                return String(describing: identificationValue)
            }
            return ""
        }
        //Nested Function End
        
        var dataArr: Array<HJRowData<Element>> = []
        
        for dictionary in baseArray {
            
            let dataID = parseID(dictionary)
            let titleTxt = getDataFromMultipleKeys(dictionary: dictionary, stringArr: titleTypeKeys, seperatorString: titleSeperator)
            let subtitleTxt = getDataFromMultipleKeys(dictionary: dictionary, stringArr: subtitleTypeKeys, seperatorString: subtitleSeperator)
            
            let rowData = HJRowData<Element>(id: dataID, title: titleTxt, subtitle: subtitleTxt, rowObject: nil)
            
            dataArr.append(rowData)
        }
        
        return dataArr
    }
    
    public
    class
    func parseDataFromArrayOfDictionary<Element: RowTypeConstraints>(baseArray: Array<Dictionary<String,Any>>, idTypeKey: String? = nil, titleTypeKeys: [String], titleSeperator: String = ", ", subtitleTypeKeys: [String]? = nil, subtitleSeperator: String = ", ", sectionKey: String) -> Dictionary<String,Array<HJRowData<Element>>> {
        
        var dataDict: Dictionary<String,Array<HJRowData<Element>>> = [:]
        
        for dictionary in baseArray {
            
            let sectionName = dictionary[sectionKey] as? String ?? ""
            let dataID = idTypeKey != nil ? dictionary[idTypeKey!] as? String ?? "" : ""
            let titleTxt = getDataFromMultipleKeys(dictionary: dictionary, stringArr: titleTypeKeys, seperatorString: titleSeperator)
            let subtitleTxt = getDataFromMultipleKeys(dictionary: dictionary, stringArr: subtitleTypeKeys, seperatorString: subtitleSeperator)
            
            let rowData = HJRowData<Element>(id: dataID, title: titleTxt, subtitle: subtitleTxt, rowObject: nil)
            
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
    public
    class
    func parseDataFromStringArray<Element: RowTypeConstraints>(baseArray: Array<String>) -> Array<HJRowData<Element>> {
        
        var dataArr: Array<HJRowData<Element>> = []
        
        for string in baseArray {
            let titleTxt = string
            let rowData = HJRowData<Element>(id: nil, title: titleTxt)
            dataArr.append(rowData)
        }
        
        return dataArr
    }
    
    private
    func checkAndRemoveDuplicate(_ selectedRowData: RowData) -> Bool {
        if let index = getIndexInSelectedData(for: selectedRowData) {
            selectedDataArr.remove(at: index)
            return true
        }
        
        return false
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension CustomListViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if isSectionBasedDistributed == false{
            return 1
        }else{
            let keys = Array(listDataDict.keys)
            return keys.count
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSectionBasedDistributed == false{
            return filteredeListDataArr.count
        }else{
            let keys = Array(listDataDict.keys)
            let sortedKeys = keys.sorted(by: <)
            let sectionKey = sortedKeys[section]
            
            return listDataDict[sectionKey]?.count ?? 0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSectionBasedDistributed == false {
            return 0
        }
        
        return 34
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
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
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellConfiguration = listConfiguration.cellConfiguration
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: cellConfiguration.cellType, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = cellConfiguration.selectionConfiguration.selectionStyle
            cell?.textLabel?.font = cellConfiguration.titleAttributes.font
            cell?.detailTextLabel?.font = cellConfiguration.subtitleAttributes.font
            
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
        
        var currRow: RowData? = nil
        
        if isSectionBasedDistributed == false{
            currRow = filteredeListDataArr[indexPath.row]
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var currRow: RowData? = nil
        
        if isSectionBasedDistributed == false{
            currRow = filteredeListDataArr[indexPath.row]
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

extension CustomListViewController {
    
    private func configureCell(_ cell: UITableViewCell, _ rowData: RowData) {
        
        let cellConfiguration = listConfiguration.cellConfiguration
        
        if let highlightArray = cellConfiguration.titleAttributes.textToHighlight {
            
            var textColor: UIColor = .black
            if let color = delegate?.customList(self, colorForTitle: rowData) {
                textColor = color
            }
            
            cell.textLabel?.attributedText = applyAttributesTo(string: rowData.title,
                                                               font: cellConfiguration.titleAttributes.font,
                                                               textColor: textColor,
                                                               alignment: cellConfiguration.titleAttributes.alignment,
                                                               textToHighlight: highlightArray,
                                                               highlightColor: cellConfiguration.titleAttributes.highlightColor ?? .black,
                                                               hightlightFont: cellConfiguration.titleAttributes.hightlightFont)
        } else {
            cell.textLabel?.text = rowData.title
        }
        
        if let highlightArray = cellConfiguration.subtitleAttributes.textToHighlight, rowData.subtitle != nil  {
            
            var textColor: UIColor = .black
            if let color = delegate?.customList(self, colorForSubtitle: rowData) {
                textColor = color
            }
            
            cell.detailTextLabel?.attributedText = applyAttributesTo(string: rowData.subtitle!,
                                                               font: cellConfiguration.subtitleAttributes.font,
                                                               textColor: textColor,
                                                               alignment: cellConfiguration.subtitleAttributes.alignment,
                                                               textToHighlight: highlightArray,
                                                               highlightColor: cellConfiguration.subtitleAttributes.highlightColor ?? .black,
                                                               hightlightFont: cellConfiguration.subtitleAttributes.hightlightFont)
        } else {
            cell.detailTextLabel?.text = rowData.subtitle
        }
        
        if listConfiguration.shouldShowSelection {
            if let _ = getIndexInSelectedData(for: rowData) {
                
                if let checkedImage = cellConfiguration.selectionConfiguration.checked {
                    cell.imageView?.image = checkedImage
                    cell.imageView?.tintColor = cellConfiguration.selectionConfiguration.tint
                }else {
                    let image = delegate?.customList(self, imageFromRow: rowData)
                    cell.imageView?.image = image != nil ? image : checkedIconImage
                }
            }else{
                if listConfiguration.isMultiSelectionAllowed {
                    if let unCheckedImage = cellConfiguration.selectionConfiguration.unchecked {
                        cell.imageView?.image = unCheckedImage
                        cell.imageView?.tintColor = cellConfiguration.selectionConfiguration.tint
                    }else {
                        let image = delegate?.customList(self, imageFromRow: rowData)
                        cell.imageView?.image = image != nil ? image : uncheckedIconImage
                    }
                }
                else{
                    cell.imageView?.image = delegate?.customList(self, imageFromRow: rowData)
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

//MARK: - UISearchBarDelegate

extension CustomListViewController: UISearchBarDelegate{
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard let configuration = listConfiguration.searchBarConfiguration else { return true }
        
        let allowed_length = configuration.allowedLength
        let allowed_characters = configuration.allowedCharacters
        
        if (searchBar.text?.count)! >= allowed_length && range.length == 0{
            return false
        }
        
        let invalidCharSet: CharacterSet = CharacterSet(charactersIn: allowed_characters).inverted
        let filtered = text.components(separatedBy: invalidCharSet).joined(separator: "")
        
        return text == filtered
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchString = searchText.trimWhiteSpace().lowercased()
        
        filteredeListDataArr = listDataArr
        
        if searchString.count > 0{
            filteredeListDataArr = listDataArr.filter( { $0.title.lowercased().contains(searchString) } )
        }
        
        tableView.reloadData()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
}

//MARK: - UIAdaptivePresentationControllerDelegate & UIPopoverPresentationControllerDelegate

extension CustomListViewController: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        let shouldDim = self.listConfiguration.popoverConfiguration?.shouldDimBackground ?? false
        if shouldDim {
            guard let callingController = CustomListViewController.getTopViewController() else { return true }
            callingController.view.alpha = 1
        }
        
        return true
    }
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.dismissController(completion: nil)
    }
}

//MARK: ListView Presentation
extension CustomListViewController{
    
    fileprivate
    class
    func presentPopover(baseViewController: UIViewController, presentedViewController: CustomListViewController){
        
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

//MARK: - Helper
 
extension CustomListViewController {

    private
    class
    func getDataFromMultipleKeys(dictionary: Dictionary<String,Any>, stringArr: [String]?, seperatorString: String, defaultForEmptyData: String = "") -> String {
        
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
    
    private
    class
    func getTopViewController(base: UIViewController? = .none) -> UIViewController? {

        var baseController = base
        
        if base == .none {
            baseController = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }?
                .rootViewController
        }
        
        if let nav = baseController as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = baseController as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = baseController?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return baseController
    }
    
    private
    func getIndexPathFromSubView(subView: Any, tableView: UITableView) -> IndexPath {
        
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
    
    private
    func getIndexInSelectedData(for selectedRowData: RowData) -> Int? {
        for (index, row) in selectedDataArr.enumerated() {
            
            if row.title == selectedRowData.title {
                if let currentSubtitle = row.subtitle,
                   let rowSubtitle = selectedRowData.subtitle,
                   currentSubtitle != rowSubtitle {
                    return nil
                }
                
                if let currentRowObj = row.rowObject,
                   let selectedRowObj = selectedRowData.rowObject,
                   AnyEquatable(currentRowObj) != AnyEquatable(selectedRowObj) {
                    return nil
                }
                
                return index
            }
        }
        
        return nil
    }
    
    private
    func applyAttributesTo(string mainText: String,
                           font: UIFont,
                           textColor: UIColor,
                           alignment: NSTextAlignment,
                           textToHighlight: Array<String>,
                           highlightColor: UIColor,
                           hightlightFont: UIFont? = nil) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedText = NSMutableAttributedString(string: mainText, attributes: attributes)
        
        for highlight in textToHighlight {
            
            if mainText.contains(highlight){
                
                let convertedString = mainText as NSString
                let range = convertedString.range(of: highlight)
                attributedText.addAttribute(.foregroundColor, value: highlightColor,range: range)
                if let hightlightFont = hightlightFont {
                    attributedText.addAttribute(.font, value: hightlightFont, range: range)
                }
                
            }
        }
        
        return attributedText
    }
    
    private
    func getContentHeight() -> CGFloat {
        let bottomButtonVerticalPadding: CGFloat = 16
        let spaceExceptTable: CGFloat = self.topView.frame.height + (self.bottomButton.frame.height + bottomButtonVerticalPadding)
        var availableHeight = self.view.frame.height - (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)
        availableHeight = availableHeight - (listConfiguration.containerConfiguration.verticalPadding * 2)
        tableView.reloadData()
        tableView.layoutIfNeeded()
        let requiredContainerSize = tableView.contentSize.height + spaceExceptTable
        return requiredContainerSize <= availableHeight ? requiredContainerSize : availableHeight
    }
}

//MARK: - Helper Extensions

//MARK: - Color
public
extension UIColor{
    static let regularOrange: UIColor = UIColor(red: 242.0/255.0, green: 102.0/255.0, blue: 40.0/255.0, alpha: 1.0)
    static let lightOrange: UIColor = UIColor(red: 245.0/255.0, green: 148.0/255.0, blue: 104.0/255.0, alpha: 1.0)
    static let darkOrange: UIColor = UIColor(red: 207.0/255.0, green: 77.0/255.0, blue: 19.0/255.0, alpha: 1.0)
}

//MARK: - String
public
extension String {
    func trimWhiteSpace() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

//MARK: - AnyEquatable
private
struct AnyEquatable {
    private let value: Any
    private let equals: (Any) -> Bool

    public init<T: Equatable>(_ value: T) {
        self.value = value
        self.equals = { ($0 as? T == value) }
    }
}

extension AnyEquatable: Equatable {
    static public func ==(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        return lhs.equals(rhs.value)
    }
}
