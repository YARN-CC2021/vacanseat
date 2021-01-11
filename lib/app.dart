import 'package:flutter/material.dart';
import 'screens/map_page.dart';
import 'screens/merchant_page.dart';
import 'wrapper.dart';
import 'package:provider/provider.dart';
import 'models/user_status.dart';
import './screens/detail_page.dart';
import 'screens/user_category_page.dart';
import 'screens/validation.dart';

const WrapperRoute = "/";
const MapSearchRoute = "/map_search";
const DetailRoute = "/detail";
const MerchantRoute = "/merchant_settings";
const UserCategoryRoute = "/user_category";
const ValidationRoute = "validation";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: _routes(),
      home: ChangeNotifierProvider<Status>(
        create: (context) => Status(),
        child: Wrapper(),
      ),
    );
  }

  RouteFactory _routes() {
    return (settings) {
      print(settings.arguments);
      final Map<String, dynamic> arguments = settings.arguments;
      Widget screen;
      switch (settings.name) {
        case WrapperRoute:
          screen = Wrapper();
          break;
        case MapSearchRoute:
          screen = MapPage();
          break;
        case DetailRoute:
          screen = DetailPage(arguments['id']);
          break;
        case MerchantRoute:
          screen = MerchantPage();
          break;
        case UserCategoryRoute:
          screen = UserCategoryPage();
          break;
        case ValidationRoute:
          screen = Validation(arguments['email'], arguments['passcode']);
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
