//
//  ContentView.swift
//  Books
//
//  Created by Rodolfo Salazar on 10/14/20.
//

import SwiftUI
import KingfisherSwiftUI


//Structs for JSON feed
struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results: [Result]
}

struct Genres: Decodable, Hashable, Equatable {
    let name: String
}

struct Result: Decodable, Hashable, Equatable {
    let name, artworkUrl100, releaseDate, url: String
    let genres : [Genres]
}

//Model to fetch movies from Apple RSS
class GridViewModel: ObservableObject {
    
    @Published var results = [Result]()
    
    init() {
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/movies/top-movies/all/25/explicit.json") else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data else { return }
            do {
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                print(rss)
                self.results = rss.feed.results.shuffled()
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
        
    }
}

//Model to fetch top ten movies from Apple RSS
class TopTenViewModel: ObservableObject {
    
    @Published var topTenResults = [Result]()
    
    init() {
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/movies/top-movies/all/10/explicit.json") else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data else { return }
            do {
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                print(rss)
                self.topTenResults = rss.feed.results
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
        
    }
}

struct ContentView: View {
    
    @ObservedObject var vm = GridViewModel()
    @ObservedObject var topTenViewModel = TopTenViewModel()

    @State var text = ""
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack{
                    HStack(){
                        Text("Nested Movies")
                            .font(.custom("AppleSDGothicNeo-Bold", size: 36, relativeTo: .largeTitle))
                        
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .cornerRadius(10)
                    }.padding(.leading, -100)
                    
                   //Places Search Bar
                    SearchBar(text: $text)
                        
                }
                
                VStack{
                    Text("Popular")
                        .bold()
                        .font(.custom("AppleSDGothicNeo-Bold", size: 32, relativeTo: .title))
                        .padding(.leading, -190)
                        .padding(.top, 5)
                }
                Spacer()
                    .frame(height: 5)
                
                //Create horizontal grid and display top ten movies
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [
                        GridItem(.flexible(minimum: 100, maximum: 300))], content: {
                            ForEach(topTenViewModel.topTenResults.filter({"\($0)".contains(text) || text.isEmpty}), id: \.self){ card in
                                HStack{
                                    ZStack{
                                        VStack (spacing: 4) {
                                            
                                            //Adds image using KingFisher and make image link to movie info
                                            Link(destination: URL(string: card.url)!){
                                                KFImage(URL(string: card.artworkUrl100))
                                                    .resizable()
                                                    .scaledToFit()
                                                    .cornerRadius(22)
                                            }
                                                
                                            
                                            Text(card.name)
                                                .font(.system(size: 14, weight: .semibold))
                                                .padding(.top, 4)

                                            Text(card.genres[0].name)
                                                .font(.system(size: 12, weight: .regular))

                                        }
                                        .frame(width: 200, height: 270)
                                        .shadow(radius: 20)
                                        
                                    }
                                }
                                .frame(width: 200, height: 300)
                                .background(LinearGradient(gradient: .init(colors: [.yellow, .orange]), startPoint: .top, endPoint: .bottom))
                                .cornerRadius(22)
                                .shadow(radius: 5)
                                .padding(.vertical, 5)
                            }
                    })
                }

                //Create vertical grid and display all movies
                VStack {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 100, maximum: 200), spacing: 16, alignment: .top),
                        GridItem(.flexible(minimum: 100, maximum: 200), spacing: 16, alignment: .top),
                        GridItem(.flexible(minimum: 100, maximum: 200), spacing: 16),
                    ], alignment: .leading, spacing: 16, content: {
                        ForEach(vm.results.filter({"\($0)".contains(text) || text.isEmpty}), id: \.self) { app in
                            
                            VStack(alignment: .leading, spacing: 4) {
                                
                                //Adds image using KingFisher and make image link to movie info
                                Link(destination: URL(string: app.url)!){
                                    KFImage(URL(string: app.artworkUrl100))
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(22)
                                }
                                
                                Text(app.name)
                                    .font(.system(size: 10, weight: .semibold))
                                    .padding(.top, 4)
                                
                                Text(app.genres[0].name)
                                    .font(.system(size: 9, weight: .regular))
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                        
                        }
                        
                    })
                }.padding(.horizontal, 12)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView()
        ContentView()
                    .environment(\.colorScheme, .dark)
    }
}
