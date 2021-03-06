import 'package:cafeexpress/app.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoder/geocoder.dart';
import '../global.dart' as globals;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
// import 'package:amplify_core/amplify_core.dart';
import "package:amplify_flutter/amplify.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_theme.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MerchantProfilePage extends StatefulWidget {
  @override
  _MerchantProfilePageState createState() => _MerchantProfilePageState();
}

Map shopData;
var _userId;
var _category;
var _vacancyType = "";
var images;

class _MerchantProfilePageState extends State<MerchantProfilePage> {
  @override
  void initState() {
    super.initState();
    _getShopData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController storeUrlController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  Future<void> _getShopData() async {
    setState(() => _userId = globals.userId);
    var response = await http.get(
        'https://pq3mbzzsbg.execute-api.ap-northeast-1.amazonaws.com/CaffeExpressRESTAPI/store/$_userId');
    if (response.statusCode == 200) {
      final jsonResponse = await json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        shopData = jsonResponse['body'];
      });
      await _showPic();
      _mapMountedStoreData();
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _uploadPhoto() async {
    try {
      File file = await FilePicker.getFile(type: FileType.image);
      String fileName = new DateTime.now().millisecondsSinceEpoch.toString();
      fileName = "image/store/${globals.userId}/" + fileName;
      S3UploadFileOptions options =
          S3UploadFileOptions(accessLevel: StorageAccessLevel.guest);
      UploadFileResult result = await Amplify.Storage.uploadFile(
          key: fileName, local: file, options: options);
      setState(() {
        shopData["imageUrl"].add(result.key);
      });
      await _updatePhoto();
      print("Photo Upload Completed!");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _showPic() async {
    final getUrlOptions = GetUrlOptions(
      accessLevel: StorageAccessLevel.guest,
    );
    var listOfUrl = [];
    print("shopData Image URL: ${shopData["imageUrl"]}");
    if (shopData["imageUrl"] != null && shopData["imageUrl"].length > 0) {
      for (var key in shopData["imageUrl"]) {
        var result =
            await Amplify.Storage.getUrl(key: key, options: getUrlOptions);
        var url = result.url;
        listOfUrl.add(url);
      }
    }
    print("done getting getting image Url");
    setState(() {
      images = listOfUrl;
    });
    print("done listing image url");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("プロフィール編集",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
          centerTitle: true,
          backgroundColor: CafeExpressTheme.buildLightTheme().backgroundColor,
          elevation: 3.0,
        ),
        body: shopData == null && images == null && _category == null
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: new ListView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              images != null && images.length != 0
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0, bottom: 10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          images[0],
                                          width: 83,
                                          height: 83,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                                child: SizedBox(
                                              width: 83,
                                              height: 83,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            ));
                                          },
                                        ),
                                      ))
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0, bottom: 10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Container(
                                            width: 83,
                                            height: 83,
                                            color: Colors.grey[300],
                                            child: IconButton(
                                              iconSize: 35,
                                              color: Colors.grey,
                                              icon: FaIcon(
                                                  FontAwesomeIcons.camera),
                                              onPressed: () {
                                                _uploadPhoto();
                                              },
                                            )),
                                      ),
                                    ),
                              images != null && images.length >= 2
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0, bottom: 10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          images[1],
                                          width: 83,
                                          height: 83,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                                child: SizedBox(
                                              width: 83,
                                              height: 83,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            ));
                                          },
                                        ),
                                      ))
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0, bottom: 10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Container(
                                            width: 83,
                                            height: 83,
                                            color: Colors.grey[300],
                                            child: IconButton(
                                              iconSize: 35,
                                              color: Colors.grey,
                                              icon: FaIcon(
                                                  FontAwesomeIcons.camera),
                                              onPressed: () {
                                                _uploadPhoto();
                                              },
                                            )),
                                      ),
                                    ),
                              images != null && images.length >= 3
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0, bottom: 10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          images[2],
                                          width: 83,
                                          height: 83,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                                child: SizedBox(
                                              width: 83,
                                              height: 83,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            ));
                                          },
                                        ),
                                      ))
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0, bottom: 10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Container(
                                            width: 83,
                                            height: 83,
                                            color: Colors.grey[300],
                                            child: IconButton(
                                              iconSize: 35,
                                              color: Colors.grey,
                                              icon: FaIcon(
                                                  FontAwesomeIcons.camera),
                                              onPressed: () {
                                                _uploadPhoto();
                                              },
                                            )),
                                      ),
                                    ),
                              images != null && images.length >= 4
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0, bottom: 10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          images[3],
                                          width: 83,
                                          height: 83,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                                child: SizedBox(
                                              width: 83,
                                              height: 83,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            ));
                                          },
                                        ),
                                      ))
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0, bottom: 10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Container(
                                            width: 83,
                                            height: 83,
                                            color: Colors.grey[300],
                                            child: IconButton(
                                              iconSize: 35,
                                              color: Colors.grey,
                                              icon: FaIcon(
                                                  FontAwesomeIcons.camera),
                                              onPressed: () {
                                                _uploadPhoto();
                                              },
                                            )),
                                      ),
                                    ),
                            ],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Container(
                                width: 26,
                                child: FaIcon(
                                  FontAwesomeIcons.user,
                                  color: Colors.grey,
                                ),
                              ),
                              hintText: 'お店の名前を入力ください',
                              labelText: '店名',
                            ),
                            controller: nameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '情報を入力してください';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Container(
                                width: 26,
                                child: FaIcon(
                                  FontAwesomeIcons.addressCard,
                                  color: Colors.grey,
                                ),
                              ),
                              hintText: 'お店の詳細を入力下さい',
                              labelText: '詳細',
                            ),
                            maxLines: 2,
                            controller: descriptionController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '情報を入力してください';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: FaIcon(
                                    FontAwesomeIcons.usps,
                                    color: Colors.grey,
                                  ),
                                  width: 40),
                              Expanded(
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: zipCodeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: '郵便番号',
                                  ),
                                ),
                              ),
                              OutlineButton(
                                child: Text('検索'),
                                onPressed: () async {
                                  var result = await http.get(
                                      'https://zipcloud.ibsnet.co.jp/api/search?zipcode=${zipCodeController.text}');
                                  Map<String, dynamic> map =
                                      json.decode(result.body)['results'][0];
                                  addressController.text =
                                      '${map['address1']}${map['address2']}${map['address3']}';
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Container(
                                width: 26,
                                child: FaIcon(
                                  FontAwesomeIcons.locationArrow,
                                  color: Colors.grey,
                                ),
                              ),
                              hintText: '住所を入力してください',
                              labelText: '住所',
                            ),
                            controller: addressController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '情報を入力してください';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Container(
                                width: 26,
                                child: FaIcon(
                                  FontAwesomeIcons.phoneAlt,
                                  color: Colors.grey,
                                ),
                              ),
                              hintText: '電話番号を入力してください',
                              labelText: '電話番号',
                            ),
                            controller: telController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '情報を入力してください';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Container(
                                width: 26,
                                child: FaIcon(
                                  FontAwesomeIcons.at,
                                  color: Colors.grey,
                                ),
                              ),
                              hintText: 'お店のEメールを入力ください',
                              labelText: 'Eメール',
                            ),
                            controller: emailController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '情報を入力してください';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Container(
                                width: 26,
                                child: FaIcon(
                                  FontAwesomeIcons.cloud,
                                  color: Colors.grey,
                                ),
                              ),
                              hintText: 'お店のURLを記載してください',
                              labelText: 'URL',
                            ),
                            controller: storeUrlController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '情報を入力してください';
                              }
                              return null;
                            },
                          ),
                          Row(children: [
                            Container(
                                padding: EdgeInsets.only(right: 15),
                                child: Container(
                                  width: 26,
                                  child: FaIcon(
                                    FontAwesomeIcons.utensils,
                                    color: Colors.grey,
                                  ),
                                ),
                                width: 40),
                            Flexible(
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(),
                                  labelText: 'カテゴリー',
                                  hintText: 'お店の種類を選択ください',
                                ),
                                items: ["お店のカテゴリーを選択ください", "カフェ", "バー", "レストラン"]
                                    .map((String category) {
                                  return new DropdownMenuItem(
                                      value: category,
                                      child: Row(
                                        children: <Widget>[
                                          Text(category),
                                        ],
                                      ));
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() => _category = newValue);
                                },
                                value: _category,
                                validator: (value) {
                                  if (value == "お店のカテゴリーを選択ください") {
                                    return 'カテゴリーを選択ください';
                                  }
                                  return null;
                                },
                              ),
                            )
                          ]),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                            child: Row(children: [
                              Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Container(
                                    width: 26,
                                    child: FaIcon(
                                      FontAwesomeIcons.cog,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  width: 40),
                              Text(
                                "テーブル設定",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ]),
                          ),
                          Row(children: [
                            Expanded(
                                child: ListTile(
                              title: const Text(
                                '固定',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              leading: Radio(
                                value: "strict",
                                groupValue: _vacancyType,
                                onChanged: (value) {
                                  setState(() {
                                    _vacancyType = value;
                                  });
                                },
                              ),
                            )),
                            Expanded(
                              child: ListTile(
                                title: const Text(
                                  '範囲',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                leading: Radio(
                                  value: "flex",
                                  groupValue: _vacancyType,
                                  onChanged: (value) {
                                    setState(() {
                                      _vacancyType = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ]),
                          Center(
                              child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: CafeExpressTheme.buildLightTheme()
                                        .primaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(24.0)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.6),
                                        blurRadius: 8,
                                        offset: const Offset(4, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(24.0)),
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        if (_formKey.currentState.validate()) {
                                          assignVariable();
                                          _updateStoreProfile();
                                        }
                                      },
                                      child: Center(
                                        child: Text(
                                          '保存',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ]))));
  }

  Future<void> _getAddress(String address) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(address);
    var first = addresses.first;
    var strCoordinates = first.coordinates
        .toString()
        .substring(1, first.coordinates.toString().length - 1);
    List coordinates = strCoordinates.split(",");
    shopData['lat'] = double.parse(coordinates[0]);
    shopData['lng'] = double.parse(coordinates[1]);
  }

  void _changePage(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
    print("Going to $route was triggered");
  }

  Future<void> _updateStoreProfile() async {
    print("inside update store");
    await _getAddress(shopData["address"]);
    var response = await http.patch(
      "https://pq3mbzzsbg.execute-api.ap-northeast-1.amazonaws.com/CaffeExpressRESTAPI/store/$_userId",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(shopData),
    );
    if (response.statusCode == 200) {
      if (globals.firstSignIn) {
        print("insidefirstsignin");
        globals.firstSignIn = false;
        _changePage(context, NavigateMerchantRoute);
      } else {
        AwesomeDialog(
          context: context,
          customHeader: null,
          dialogType: DialogType.NO_HEADER,
          animType: AnimType.BOTTOMSLIDE,
          body: Center(
            child: Text('プロフィール情報がアップデートされました'),
          ),
          // btnOkOnPress: () {},
          useRootNavigator: false,
          // btnOkColor: Colors.tealAccent[400],
          // btnCancelOnPress: () {},
          // btnOkText: '',
          // btnCancelText: '',
          // btnCancelColor: Colors.blueGrey[400],
          dismissOnTouchOutside: true,
          headerAnimationLoop: false,
          showCloseIcon: false,
          buttonsBorderRadius: BorderRadius.all(Radius.circular(100)),
        )..show();
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _updatePhoto() async {
    await _getAddress(shopData["address"]);
    assignVariable();
    var response = await http.patch(
      "https://pq3mbzzsbg.execute-api.ap-northeast-1.amazonaws.com/CaffeExpressRESTAPI/store/$_userId",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(shopData),
    );
    if (response.statusCode == 200) {
      print('Succesfully Updated Photo');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void assignVariable() {
    shopData["name"] = nameController.text;
    shopData["description"] = descriptionController.text;
    shopData["address"] = addressController.text;
    shopData["zipCode"] = zipCodeController.text;
    shopData["tel"] = telController.text;
    shopData["contactEmail"] = emailController.text;
    shopData["storeURL"] = storeUrlController.text;
    shopData["category"] = _category;
    shopData["vacancyType"] = _vacancyType;
    shopData["updatedAt"] = DateTime.now().toString();
  }

  void _mapMountedStoreData() {
    nameController.text = shopData['name'];
    descriptionController.text = shopData['description'];
    addressController.text = shopData['address'];
    zipCodeController.text = shopData['zipCode'];
    telController.text = shopData['tel'];
    emailController.text = shopData['contactEmail'];
    storeUrlController.text = shopData['storeURL'];
    _category = shopData['category'];
    _vacancyType = shopData['vacancyType'];
    shopData.remove("id");
  }
}
