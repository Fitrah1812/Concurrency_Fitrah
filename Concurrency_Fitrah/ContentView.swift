//
//  ContentView.swift
//  Concurrency_Fitrah
//
//  Created by Fitrah Arie Ramadhan on 07/08/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var waifu: [WaifuUser] = []
    
    @State private var searchText: String = ""
    
    private var filteredWaifu: [WaifuUser]{
        if searchText.isEmpty {
            return waifu
        }else {
            return waifu.filter { index in
                index.name.lowercased().contains(searchText.lowercased()) ||
                index.anime.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredWaifu, id: \.name) { waifuData in
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: waifuData.image.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                        HStack {
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .scaledToFit()
                                    .clipShape(Circle())
                                
                            } else if phase.error != nil {
                                Color.red
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                AsyncImage(url: URL(string: "https://res.cloudinary.com/moyadev/image/upload/v1691380966/Moyadev/default_afp8ju.png"))
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .clipShape(Circle())
                            }
                            VStack(alignment: .leading, spacing: 10){
                                Text(waifuData.name)
                                    .fontWeight(.bold)
                                    .font(.title3)
                                
                                Text(waifuData.anime)
                                    .font(.subheadline)

                            }
                        }
                    }
                    .padding(6)
                    .background(.white)
                    .frame(height: .infinity)
                    .opacity(0.8)
                }
//                .listRowSeparator(.hidden)
            }
            .searchable(text: $searchText)
            .listStyle(.plain)
            .navigationTitle("Waifu")
            .task {
                do{
                    waifu = try await getWaifu()
                } catch WUError.invalidURL {
                    print("Invalid URL")
                } catch WUError.invalidResponse {
                    print("Invalid Response")
                } catch WUError.invalidData {
                    print("invalid Data")
                } catch {
                    print("Unexpected Error")
                }
            }
        }
    }
    
    func getWaifu() async throws -> [WaifuUser] {
        let endpoint = "https://waifu-generator.vercel.app/api/v1"
        
        guard let url = URL(string: endpoint) else{
            throw WUError.invalidURL
        }
        
        let (data, response) = try await
            URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw WUError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([WaifuUser].self, from: data)
        } catch {
            throw WUError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

