import 'package:flutter/material.dart';
import 'package:gk_chemist/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import './screens/screens.dart';
import './providers/providers.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth,Campaigns>(
          create: (BuildContext context) { 
            return Campaigns(); 
          }, 
          update: (BuildContext context, Auth value, Campaigns previous) {
            return Campaigns(shopUserID: value.shopUserID);
          }
          
        ),
        ChangeNotifierProxyProvider<Auth,Invoice>(
          create: (BuildContext context){
            return Invoice();
          }, 
          update: (BuildContext context, Auth value, Invoice previous) {  
            return Invoice(shopUserData: value.userData);
          },
          
        ),
        
      ],
      
      
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          title: 'GK Chemist',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth?
          HomePage():
          FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx,authResultSS)=>
            authResultSS.connectionState==ConnectionState.waiting? 
            SplashScreen():
            AuthScreen(),
          ),
          routes: {
            RegisterScreen.routeName:(ctx)=>RegisterScreen(),
            HomePage.routeName:(ctx)=>HomePage(),
            AddCampaignPage.routeName:(ctx)=>AddCampaignPage(),
            ProfilePage.routeName:(ctx)=>ProfilePage(),
            ApproveInvoicePage.routeName:(ctx)=>ApproveInvoicePage(),
            EditProfilePage.routeName:(ctx)=>EditProfilePage(),
            ChangePasswordPage.routeName:(ctx)=>ChangePasswordPage(),

          }
            
         
        ),
      ),
    );
  }
}

