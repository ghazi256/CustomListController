//
//  ViewController.swift
//  HJCustomListController
//
//  Created by Hasnain Jafri on 10/27/21.
//

import UIKit

struct MyTest: RowTypeConstraints {
    var id: String? = nil
    var abc: String
    var def: Int
}

struct MyObject: RowTypeConstraints {
    var id: Double
    var name: String
    var age: Int
}

struct RowObject: ListRowProtocol {
    var title: String
    var dataObject: Any?
    
    static func == (lhs: RowObject, rhs: RowObject) -> Bool {
        if lhs.title == rhs.title {
            return true
        }
        
        return false
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func buttonTapped(_ sender: UIButton?) {
        let testObj1 = MyTest(abc: "Test 1", def: 1)
        let testObj2 = MyTest(abc: "Test 2", def: 2)
        let dataTest = RowObject(title: "Test", dataObject: [["Test1": "Test", "Test2": 123]])
        let abc = HJRowData(id: "10", title: "My title 1", subtitle: nil, rowObject: testObj1)
        let def = HJRowData(id: "20", title: "My title 2", subtitle: nil, rowObject: testObj2)
        
        let listCon = HJCustomListViewController(listConfiguration:
                                                    ListConfiguration(displayType: .fullScreen(.dropShadow),
                                                                                      cellConfiguration: CellConfiguration(cellType: .default,selectionConfiguration: CellSelectionConfiguration(selectionStyle: .default, checked: nil, unchecked: nil, tint: .gray))),
                                                 listArray: [abc,def,dataTest],
                                                 selectedArray: nil,
                                                 uniqueID: nil)
        listCon.show(delegate: self, caller: self)
    }
    
}

extension ViewController: HJCustomListDelegate{
    
    func customList(_ customList: HJCustomListViewController, selectedValues selectedRows: Array<any ListRowProtocol>) -> Bool? {
        if let rowData = selectedRows.first as? RowObject {
            print("\(rowData.title)")
        }
        
        return false
    }
}
