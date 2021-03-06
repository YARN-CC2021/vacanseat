import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import '../global.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import '../app_theme.dart';

class BookingListPage extends StatefulWidget {
  @override
  _BookingListPageState createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  @override
  Widget build(BuildContext context) {
    return BookingPage();
  }
}

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  var bookingData;
  final channel = IOWebSocketChannel.connect(
      "wss://gu2u8vdip2.execute-api.ap-northeast-1.amazonaws.com/CafeExpressWS?id=${globals.userId}");

  var bookingId;

  @override
  void initState() {
    super.initState();
    _getBookingData();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new Container(),
        title: Text("予約管理",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
        centerTitle: true,
        backgroundColor: CafeExpressTheme.buildLightTheme().backgroundColor,
        elevation: 3.0,
      ),
      body: bookingData == null
          ? Center(child: CircularProgressIndicator())
          : bookingData.length == 0
              ? Center(
                  child: Text("予約情報がありません", style: TextStyle(fontSize: 20)))
              : StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        json.decode(snapshot.data)["bookingId"] != bookingId) {
                      if (json.decode(snapshot.data)["status"] ==
                          "checked_in") {
                        _statusUpdateFromCustomer(json.decode(snapshot.data));
                      } else {
                        _insertBooking(json.decode(snapshot.data));
                        bookingId = json.decode(snapshot.data)["bookingId"];
                      }
                    }
                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: buildListView());
                  }),
    );
  }

  Future<void> _getBookingData() async {
    var response = await http.get(
        'https://pq3mbzzsbg.execute-api.ap-northeast-1.amazonaws.com/CaffeExpressRESTAPI/booking?storeId=${globals.userId}');
    if (response.statusCode == 200) {
      final jsonResponse = await json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        bookingData = jsonResponse['body'];
      });
      await _sortBookingData(bookingData);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _sortBookingData(bookingData) async {
    setState(() {
      bookingData
        ..sort((v1, v2) =>
            DateTime.parse(v2["bookedAt"]).millisecondsSinceEpoch -
            DateTime.parse(v1["bookedAt"]).millisecondsSinceEpoch);
    });
  }

  void _statusUpdateFromCustomer(snapShot) {
    for (var aBooking in bookingData) {
      if (aBooking["bookingId"] == snapShot["bookingId"]) {
        setState(() {
          aBooking["status"] = snapShot["status"];
          aBooking["updatedAt"] = snapShot["updatedAt"];
        });
        break;
      }
    }
  }

  void _statusUpdate(int index, String status) {
    setState(() {
      bookingData[index]["status"] = status;
    });

    channel.sink.add(json.encode({
      "action": "onBookingStatusChange",
      "bookingId": bookingData[index]["bookingId"],
      "status": status,
      "updatedAt": "${DateTime.now()}",
      "customerId": bookingData[index]["customerInfo"]["customerId"]
    }));
  }

  void _insertBooking(data) {
    bookingData.insert(0, data);
  }

  ListView buildListView() {
    String prevDay;
    String today = DateFormat("EEE, MMM d, y").format(DateTime.now());
    String yesterday = DateFormat("EEE, MMM d, y")
        .format(DateTime.now().add(Duration(days: -1)));

    return ListView.builder(
      cacheExtent: 250.0 * 1000.0,
      itemCount: bookingData.length,
      itemBuilder: (context, index) {
        var booking = bookingData[index];
        var bookedAt =
            DateTime.parse(booking["bookedAt"]).millisecondsSinceEpoch;
        var expiredAt =
            DateTime.parse(booking["expiredAt"]).millisecondsSinceEpoch;

        DateTime date = DateTime.fromMillisecondsSinceEpoch(bookedAt);
        DateTime date2 = DateTime.fromMillisecondsSinceEpoch(expiredAt);
        String dateString = DateFormat("EEE, MMM d, y").format(date);
        if (today == dateString) {
          dateString = "Today";
        } else if (yesterday == dateString) {
          dateString = "Yesteday";
        }
        bool showHeader = prevDay != dateString;
        prevDay = dateString;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            showHeader
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      dateString,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  )
                : Offstage(),
            buildItem(index, context, date, date2, booking),
          ],
        );
      },
    );
  }

  Widget buildItem(int index, BuildContext context, DateTime date,
      DateTime date2, Map booking) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(width: 20),
          buildLine(index, context),
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.only(right: 26),
                  child: Text(
                    "予約時間",
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .copyWith(fontSize: 10),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    DateFormat("hh:mm a").format(date),
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 26),
                  child: Text(
                    "到着締切",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 10, color: Colors.red),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(),
                  child: Text(
                    DateFormat("hh:mm a").format(date2),
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                )
              ])),
          Expanded(
            flex: 1,
            child: buildItemInfo(booking, index, context),
          ),
        ],
      ),
    );
  }

  _changeCardColor(Map booking) {
    if (booking["status"] == "paid" &&
        DateTime.now().isAfter(DateTime.parse(booking["expiredAt"]))) {
      return LinearGradient(
          colors: [Colors.yellow.withOpacity(0.8), Colors.yellow]);
    } else if (booking["status"] == "paid") {
      return LinearGradient(colors: [Colors.white, Colors.white]);
    } else if (booking["status"] == "checked_in") {
      return LinearGradient(colors: [
        Theme.of(context).primaryColor.withOpacity(0.5),
        Theme.of(context).primaryColor,
      ]);
    } else if (booking["status"] == "cancelled") {
      return LinearGradient(colors: [
        Colors.blueGrey[100].withOpacity(0.8),
        Colors.blueGrey[100]
      ]);
    }
  }

  Card buildItemInfo(Map booking, int index, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(
          gradient: _changeCardColor(booking),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              offset: const Offset(4, 4),
              blurRadius: 30,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 8),
                        child: SizedBox(
                          width: 100,
                          height: 20,
                          child: Text(
                            booking["bookName"],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Container(
                          width: 100,
                          child: Text(
                            "種類：${booking["tableType"]["label"]}\n人数：${booking["partySize"]}人",
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ]))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(children: [
                MaterialButton(
                  minWidth: 110,
                  child: Text('チェックイン',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                  color: Theme.of(context).primaryColor,
                  shape: const StadiumBorder(
                    side: BorderSide(color: Colors.white),
                  ),
                  onPressed: booking["status"] == "checked_in" ||
                          booking["status"] == "cancelled"
                      ? null
                      : () {
                          _statusUpdate(index, "checked_in");
                        },
                ),
                MaterialButton(
                  minWidth: 110,
                  child: Text('キャンセル',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                  color: Theme.of(context).selectedRowColor,
                  shape: const StadiumBorder(
                    side: BorderSide(color: Colors.white),
                  ),
                  onPressed: DateTime.now()
                              .isAfter(DateTime.parse(booking["expiredAt"])) &&
                          booking["status"] == "paid"
                      ? () {
                          _statusUpdate(index, "cancelled");
                        }
                      : null,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Container buildLine(int index, BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              width: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, shape: BoxShape.circle),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
