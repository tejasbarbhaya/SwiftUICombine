//
//  SecondView.swift
//  SampleSwiftUI
//
//  Created by Tejash Barbhaya on 11/04/24.
//

import SwiftUI

struct SecondView: View {
    @Binding var category: Category
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    List {
                        ForEach(category.subCategory ?? []) { subcategory in
                            Text("\(subcategory.subCategory!)")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView(category: .constant(Category(categoryID: "", name: "", image: "", subCategory: nil)))
    }
}
