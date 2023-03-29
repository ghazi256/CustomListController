//
//  ViewController.swift
//  HJCustomListController
//
//  Created by Hasnain Jafri on 10/27/21.
//

import UIKit

struct Test: RowTypeConstraints {
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
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func buttonTapped(_ sender: UIButton?) {
        let testObj1 = Test(abc: "Test 1", def: 1)
        let testObj2 = Test(abc: "Test 2", def: 2)
        HJRowData(id: "", title: "", subtitle: "", rowObject: Test(abc: "", def: ""), dataDictionary: nil)
        let abc = HJRowData(id: "10", title: "My title 1", subtitle: nil, rowObject: testObj1)
        let def = HJRowData(id: "20", title: "My title 2", subtitle: nil, rowObject: testObj2)
        
        let listCon = HJCustomListViewController(listConfiguration: ListConfiguration(displayType: .fullScreen(.dropShadow), cellConfiguration: CellConfiguration(cellType: .default,selectionConfiguration: CellSelectionConfiguration(selectionStyle: .default, checked: nil, unchecked: nil, tint: .gray))), listArray: [abc,def], selectedArray: nil, uniqueID: nil)
        listCon.show(delegate: self, caller: self)
    }
    
}

extension ViewController: HJCustomListDelegate{
    
    func customList<RowData: ListRowProtocol>(_ customList: HJCustomListViewController<RowData>, selectedValues selectedRows: Array<RowData>) -> Bool? {
        
        let rowData = selectedRows.first!.rowObject as! Test
        
        print("\(rowData.abc)")
        
        return false
    }
}

/*struct Manager: SomeProtocol {
    
}

struct Operation: SomeProtocol {
    
}

struct InformationTechnology: SomeProtocol {
    
}

Class Employee {
    
}

//Delegate
func employee<EmpType: SomeProtocol>(_ employeeClass: Employee, selected: EmpType) {
    if EmpType is Manager {
        //Do Something
    }
}*/
