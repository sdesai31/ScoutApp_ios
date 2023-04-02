//
//  LoginView.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/24/23.
//

import SwiftUI
import Neumorphic
import GoogleSignIn
import SimpleToast
import IrregularGradient

struct LoginView: View {
    

    @State var refreshID = UUID().uuidString
    
    var body: some View {
        VStack {
            
            VStack {
            
                Image("protoconnect_icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .padding(.bottom, -20)
                Image("protoconnect_text")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 220)
                    .padding(.top, -70)
            }
            .padding(.top)
            
            Spacer()
            
            
            Button {
                guard let tempVC = protoMainVC else { return }
                GIDSignIn.sharedInstance.signIn(withPresenting: tempVC) { didGIDSignIn, didGIDError in
                    if (didGIDSignIn != nil && didGIDError == nil) {
                        
                        guard let gidSignIn = didGIDSignIn?.user.profile else { return }
                        
                        let gidSignInEmail = gidSignIn.email
                        let gidSignInName = gidSignIn.name.components(separatedBy: " ")

                        ProtoFirebase.checkProtoUserExists(email: gidSignInEmail) { gidSignInUser in
                            if (!gidSignInUser) {
                                
                                let gidSignFirst = gidSignInName.first ?? ""
                                let gidSignLast = gidSignInName.last ?? ""
                                
                                ProtoFirebase.createProtoUser(firstName: gidSignFirst, lastName: gidSignLast, email: gidSignInEmail, teamNum: "-1", teamID: "-1", teamCode: "-1") { didCompleteAccount in
                                    if (didCompleteAccount) {
                                        refreshID = UUID().uuidString
                                        protoMainVC?.showProtoHomeController()
                                    }
                                }
                            }
                            else {
                                refreshID = UUID().uuidString
                                protoMainVC?.showProtoHomeController()
                            }
                            
                        }
                    }
                }
            } label: {
                HStack {
                    Image("google")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 25)
                        

                    Text("Sign in with Google")
                        .foregroundColor(.black)
                        .bold()
                }
                .padding(.horizontal)
            }
            
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 30).stroke(Color.black, lineWidth: 2).foregroundColor(.clear))
            Spacer()

        }
        .padding()
        .id(refreshID)
       
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
