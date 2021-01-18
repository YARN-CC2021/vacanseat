import 'package:cafeexpress/screens/auth.dart';
import 'package:flutter/material.dart';
import 'screens/map_page.dart';
import 'screens/merchant_strict.dart';
import 'screens/merchant_flex.dart';
import 'screens/merchant_page.dart';
import 'wrapper.dart';
import 'screens/auth.dart';
import 'screens/detail_page.dart';
import 'screens/user_category_page.dart';
import 'screens/validation.dart';
import 'screens/merchant_profile_page.dart';
import 'screens/timer_page.dart';
import 'screens/merchant_calendar_page.dart';
import 'screens/qr_page.dart';
import 'screens/booking_list_page.dart';
import 'screens/booking_history_page.dart';
import 'screens/merchant_profile_setting_page.dart';
import 'screens/stripe.dart';
import 'services/stored_cards.dart';

const WrapperRoute = "/";
const AuthRoute = "/auth";
const MapSearchRoute = "/map_search";
const DetailRoute = "/detail";
const MerchantRoute = "/merchant_settings";
const MerchantFlexRoute = "/merchant_settings_flex";
const MerchantStrictRoute = "/merchant_settings_strict";
const UserCategoryRoute = "/user_category";
const ValidationRoute = "validation";
const MerchantProfileRoute = "/merchant_profile";
const MerchantCalendarRoute = "/merchant_calendar";
const TimerRoute = "/timer";
const QrRoute = "/qr";
const BookingListRoute = "/booking_list";
const BookingHistoryRoute = "/booking_history_route";
const MerchantProfileSettingRoute = "/merchant_profile_setting";
const StripeRoute = "/stripe";
const StoredCardsRoute = "/stored_cards";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.greenAccent,
          accentColor: Colors.teal[600],
          fontFamily: 'Faster One',
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          )),
      onGenerateRoute: _routes(),
      // home: Wrapper(),
      home: Wrapper(),
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
        case AuthRoute:
          screen = Auth();
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
        case MerchantFlexRoute:
          screen = MerchantFlex();
          break;
        case MerchantStrictRoute:
          screen = MerchantStrict();
          break;
        case UserCategoryRoute:
          screen = UserCategoryPage();
          break;
        case ValidationRoute:
          screen = Validation(arguments['email'], arguments['passcode']);
          break;
        case MerchantProfileRoute:
          screen = MerchantProfilePage();
          break;
        case MerchantProfileSettingRoute:
          screen = MerchantProfileSettingPage();
          break;
        case MerchantCalendarRoute:
          screen = MerchantCalendarPage();
          break;
        case TimerRoute:
          screen = TimerPage();
          break;
        case QrRoute:
          screen = QrPage();
          break;
        case BookingListRoute:
          screen = BookingListPage();
          break;
        case StripeRoute:
          screen = StripePage(arguments['id'], arguments['price']);
          break;
        case StoredCardsRoute:
          screen = ExistingCardsPage();
          break;
        case BookingHistoryRoute:
          screen = BookingHistoryPage();
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
