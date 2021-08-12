import 'package:flutter/material.dart';

import 'divider.dart';


class MainDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      child: ListView(
        children: [
          Container(
            height: 165,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Image.asset("images/user_icon.png",
                      height: 65, width: 65),
                  SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Profile Name",
                          style: TextStyle(
                              fontSize: 16, fontFamily: "Brand-Bold")),
                      SizedBox(height: 6),
                      Text("Visit Profile"),
                    ],
                  )
                ],
              ),
            ),
          ),
          DividerWidget(),
          SizedBox(height: 12),
          ListTile(
              leading: Icon(Icons.history),
              title: Text("History", style: TextStyle(fontSize: 15))),
          ListTile(
              leading: Icon(Icons.person),
              title: Text("Visit Profile", style: TextStyle(fontSize: 15))),
          ListTile(
              leading: Icon(Icons.info),
              title: Text("About", style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
