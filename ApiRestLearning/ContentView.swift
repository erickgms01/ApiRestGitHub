//
//  ContentView.swift
//  ApiRestLearning
//
//  Created by Erick on 19/10/23.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    var body: some View {
        ZStack{
            
            VStack(spacing: 20) {
                
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit )
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                }
                .frame(width: 120, height: 120)
                
                Text(user?.login ?? "login placeholder")
                    .bold()
                    .font(.title)
                
                HStack {
                    let follow = String(user?.followers ?? 0)
                    let following = String(user?.following ?? 0)
                    VStack {
                        Text("followers")
                        Text(follow)
                    }
                    
                    VStack{
                        Text("following")
                       
                        Text(following)
                    }
                }
                
                Text(user?.bio ?? "bio placeholder")
                    .font(.system(size: 20, weight: .bold))
                
                
                Spacer()
            }
            .padding(50)
            .task {
                do {
                    user = try await getUser()
                }catch GHError.invalidData{
                    print("invalid data")
                }catch GHError.invalidURL{
                    print("invalid url")
                }catch GHError.invalidResponse{
                    print("invalid response")
                }catch GHError.invalidFollowers{
                    print("invalid followers")
                }catch GHError.invalidFollowing{
                    print("invalid following")
                }catch {
                    print("unexpected error")
                }
            }
        }
    }
}
    func getUser() async throws -> GitHubUser{
        
        //Pega o URL
        let endpoint = "https://api.github.com/users/erickgms01"
        
        //transforma em um url conhecido
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        //faz a chamada de dados
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
    let followers: Int?
    let following: Int?
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidFollowers
    case invalidFollowing
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
