import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/screens/add_work.dart';
import 'package:hirfy/screens/fav_screen.dart';
import 'package:hirfy/screens/home_screen.dart';
import 'package:hirfy/screens/profile_screen.dart';


class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}
int index=0;
class _NavBarScreenState extends State<NavBarScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String,IconData>navItem={
  'Home':Icons.home,
  'Add':Icons.add,
  'Fav':Icons.favorite,
  'Profile':Icons.person
};
List<Widget>screens=[
  HomeScreen(),
  AddWork(),
  FavScreen(),
  ProfileScreen()
];
    return Scaffold(
      body: IndexedStack(
        children:screens ,
        index: index,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: .fixed,
        unselectedItemColor: ConstantColors.ternary,
        selectedItemColor: ConstantColors.secondary,
        unselectedIconTheme: IconThemeData(color:ConstantColors.ternary),
        currentIndex: index,
        backgroundColor: ConstantColors.primary,
        items:navItem.entries.map((item)=>BottomNavigationBarItem(
          icon: Icon(item.value,),
          label: item.key,

        )).toList(),
        onTap: (value) => setState(() {
          index=value;
        }),
        
         ),
    );
  }
}