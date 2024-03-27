//
//  ProtoTeamJoinCodeOnboard.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/31/23.
//

import SwiftUI
import SimpleToast

struct ProtoTeamJoinCodeOnboard: View {
    
    @State var teamNum: String = ""
    @State var presentTeamToast: Bool = false
    @State var presentTeamError: Bool = false
    @Binding var presentOnboard: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Image("joinProtoTeamUpload")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400)
                    .padding(.top, 30)
                Text("Join a Team")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.black)
                    .padding(.bottom, 1)

                Text("By joining a team, you'll get access to features like shared scouting, field renting, etc.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .bold()
                    .foregroundColor(Color.gray)
                
                
                TextField("Code", text: $teamNum)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(1)
                    .padding(.horizontal, 10)
                    .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 2).foregroundColor(Color.clear))
                    .padding(.top, 60)
                    .padding(.horizontal)
                    .keyboardType(UIKeyboardType.asciiCapableNumberPad)
                
                
                Button {
                    
                    if (teamNum.isEmpty) {
                        presentTeamError = true
                        return
                    }
                    ProtoFirebase.getProtoTeam(teamCode: (teamNum)) { didProtoTeam in
                        if didProtoTeam {
                            presentTeamToast = true
                        }
                        else {
                            presentTeamError = true
                        }
                    }
                    
                } label: {
                    Text("Link Team")
                        .font(.headline)
                        .frame(width: 140, height: 20)
                }
                .softButtonStyle(RoundedRectangle(cornerRadius: 20), padding: 10, mainColor: Color.blue, textColor: Color.white)
                .padding(.top, 30)
                
                Spacer()
                
                
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentOnboard = false
                        protoMainVC?.showProtoHomeController()
                        
                    } label: {
                        Text("Skip")
                            .bold()
                            .font(.subheadline)
                            .frame(width: 50, height: 20)
                    }
                    .softButtonStyle(RoundedRectangle(cornerRadius: 20), padding: 10, mainColor: Color.gray, textColor: Color.white, darkShadowColor: Color.clear, lightShadowColor: Color.clear)

                }
            }
            

        }
        .simpleToast(isPresented: $presentTeamToast, options: SimpleToastOptions(alignment: .top, hideAfter: 2, animation: .easeInOut, modifierType: .slide), onDismiss: {
            
            presentOnboard = false

            protoMainVC?.showProtoHomeController()

        }) {
            Text("Team Code Accepted")
                .font(.headline)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(30)
        }
        .simpleToast(isPresented: $presentTeamError, options: SimpleToastOptions(alignment: .top, hideAfter: 2, animation: .easeInOut, modifierType: .slide), onDismiss: {
            presentOnboard = false

            protoMainVC?.showProtoHomeController()
        }) {
            
            if teamNum.isEmpty {
                Text("No Team Code Entered")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(30)
            }
            else {
                Text("Team Not Found")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(30)
            }
        }
        

    }
}

struct ProtoTeamJoinCodeOnboard_Previews: PreviewProvider {
    static var previews: some View {
        Text("Proto Team Enter")
//        ProtoTeamJoinCodeOnboard(, presentOnboard: Binding<Bool>)
    }
}
