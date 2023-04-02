//
//  LoginOnboardView.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/25/23.
//

import SwiftUI
import Neumorphic
import SimpleToast

struct LoginOnboardView: View {
    
    
    @State var teamNum: String = ""
    @State var presentTeamToast: Bool = false
    @State var presentTeamError: Bool = false
    @Binding var presentOnboard: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Image("protoTeamUpload")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400)
                    .padding(.top, 30)
                Text("Creating a Team")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.black)
                    .padding(.bottom, 1)

                Text("By creating a team, you'll get access to features like shared scouting, field renting, etc.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .bold()
                    .foregroundColor(Color.gray)
                
                
                TextField("FRC Team Number", text: $teamNum)
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
                    ProtoLookup.teamLookup(teamNumber: teamNum) { doesTeamExist in
                        if (!doesTeamExist.isEmpty) {
                             let teamNumInt = String(teamNum)
                            ProtoFirebase.addTeamNum(teamNum: teamNumInt, teamDetails: doesTeamExist, completion: { teamUploadSuccess in
                                if (teamUploadSuccess) {
                                    presentTeamToast = true

                                }
                                else {
                                    presentTeamError = true

                                }
                            })
                            
                            
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
            Text("Welcome to Team \(teamNum)")
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
                Text("No Team Number Entered")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(30)
            }
            else {
                Text("Team \(teamNum) Not Found")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(30)
            }
        }
        

    }
}

struct LoginOnboardView_Previews: PreviewProvider {
    static var previews: some View {
        Text("login onboard")
//        LoginOnboardView()
    }
}
