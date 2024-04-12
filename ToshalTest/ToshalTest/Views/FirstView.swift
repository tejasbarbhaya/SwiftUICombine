//
//  ContentView.swift
//  SampleSwiftUI
//
//  Created by Tejash Barbhaya on 11/04/24.
//

import SwiftUI



struct FirstView: View {
    
    @StateObject var viewModel = FirstViewModel()
    @State private var isShowDetailView = false
    @State private var showSecondScreen = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("OUR POPULER PRODUCTS")
                            .font(Font.headline.weight(.bold))
                            .frame(minHeight: 50.0)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    
                    HStack {
                        ScrollView {
                            LazyVGrid(columns: columns,spacing: 5.0) {
                                ForEach(viewModel.productCategories?.data?.categories ?? []) { value in
                                    ProductView(categoryModel: value)
                                        .onTapGesture {
                                            viewModel.currentCategory = value
                                            self.showSecondScreen = true
                                        }
                                }
                            }
                        }
                        .navigationDestination(isPresented: .constant(showSecondScreen), destination: {
                           SecondView(category: $viewModel.currentCategory)
                        })
                    }
                    
                    /*HStack {
                        List {
                            ForEach(viewModel.arrayValues) { postObject in
                                
                                //RowView(currentPost: postObject, viewModel: viewModel)
                                Text("\(postObject.id ?? 0)")
                                    .onTapGesture {
                                        viewModel.currentPost = postObject
                                        self.showSecondScreen = true
                                    }
                                
                            }
                        }
                        .navigationDestination(isPresented: .constant(showSecondScreen), destination: {
                            SecondView(currentPost: .constant(viewModel.currentPost))
                        })
                        .listStyle(.insetGrouped)
                    }*/
                
                }
            }
            .overlay(content: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        ProgressView().hidden()
                    }
                }
            })
            .onAppear() {
                viewModel.createNewToken()
                self.showSecondScreen = false
            }
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}


struct ProductView: View {
    let firstViewModel =  FirstViewModel()
    let categoryModel: Category
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: firstViewModel.refreshImageUrl(categoryModel.image!))) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: 300, maxHeight: 200)
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 200)
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
            .padding(2)
            Text(categoryModel.name!)
        }
        .frame(maxWidth: 300, maxHeight: 200)
        .background(Rectangle().fill(Color.white).shadow(radius: 8))
    }
}
