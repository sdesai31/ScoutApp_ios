//
//  ProtoConnectSettings.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 4/2/23.
//

import SwiftUI
import Neumorphic

struct ProtoConnectSettings: View {
    @State var showLogOutConfirm: Bool = false
    @Binding var logOutProtoConnect: Bool
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text((ProtoFirebase.currentProtoUser?.firstName ?? "ERROR") + " " + (ProtoFirebase.currentProtoUser?.lastName ?? "ERROR"))
                        .font(.title2)
                        .bold()
                    Spacer()
                    Image("google")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                }
                .padding([.top, .horizontal])
                .padding(.bottom, 0.5)
                HStack {
                    Text(ProtoFirebase.currentProtoUser?.email ?? "ERROR")
                        .font(.title3)
                        .foregroundColor(Color.blue)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(Color.Neumorphic.main)
            .cornerRadius(20)
            .padding()
            .softOuterShadow()
            Text("Settings")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            List {
                
                NavigationLink(destination: {
                        TeamsView()
                }, label: {
                    HStack {
                        Image(systemName: "person.3")
                            .bold()
                        Text("Team")
                            .bold()
                    }
                })
                Section {
                    Button {
                        showLogOutConfirm = true
                    } label: {
                     
                            Text("Sign Out")
                                .bold()
                                .foregroundColor(.red)
                        
                    }
                } header: {
                   Text("Actions")
                }

                


            }
            .navigationTitle("Profile")
            
            .alert(isPresented: $showLogOutConfirm, content: {
                Alert(title: Text("Are you sure?"), message: Text("By clicking yes, you will be logged out of ProtoConnect"), primaryButton: Alert.Button.destructive(Text("Log Out"), action: {
                    ProtoFirebase.signOutUser()
                    protoMainVC?.showProtoAuthController()
                    logOutProtoConnect = false

                }), secondaryButton: Alert.Button.cancel())
            })
                HStack {
                    Text("FRC 2854")
                        .bold()
                        .foregroundColor(Color.Neumorphic.secondary)
                    Divider()
                        .frame(height: 20)
                    Text("The Prototypes")
                        .bold()
                        .foregroundColor(Color.Neumorphic.secondary)
             
           
                }
                .padding(.top, 10)
                
            
        }
    }
}

struct ProtoConnectSettings_Previews: PreviewProvider {
    static var previews: some View {
        Text("ProtoConnectSettings")
//        ProtoConnectSettings()
    }
}
