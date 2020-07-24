import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:prospek/db/DatabaseHelper.dart';
import 'package:prospek/model/ResponseResult.dart';
import 'package:prospek/utils/Constants.dart';
import '../main.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AddData extends StatefulWidget {
  @override
  _AddDataState createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();
  ProgressDialog pr;
  TextEditingController namacontroller = new TextEditingController();
  TextEditingController tanggalcontroller = new TextEditingController();
  TextEditingController nohpcontroller = new TextEditingController();
  TextEditingController rencanacontroller = new TextEditingController();
  TextEditingController tipecontroller = new TextEditingController();
  TextEditingController alamatcontroller = new TextEditingController();
  TextEditingController keterangancontroller = new TextEditingController();
  TextEditingController statuscontroller = new TextEditingController();

  bool loading = false;
  bool _validate = false;
  bool isUseReminder = false;

  ResponseResult res;
  int selectedDay = new DateTime.now().weekday + 1;
  TextEditingController notifdate = new TextEditingController();

  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //GlobalDateTimeUtility
  var datetimeForNow = DateTime.now();
  var dateForNotif;
  var completeTimetoDB = "";

  //checkbox utils
  int ntb = 0;
  int ttb = 0;
  int atb = 0;
  int mtb = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => new MyApp(
                    isRefresh: false,
                  ))),
      child: new Scaffold(
        key: _scaffoldState,
        appBar: new AppBar(
          title: Text('Tambah Prospek Baru'),
          backgroundColor: Colors.green,
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Padding(padding: new EdgeInsets.only(top: 15.0)),
                      new TextField(
                          controller: namacontroller,
                          decoration: new InputDecoration(
                            hintText: "John Doe",
                            labelText: "Nama Prospek",
                          )),
                      new Padding(padding: new EdgeInsets.all(5.0)),
                      TextFormField(
                        maxLength: 23,
                        readOnly: true,
                        controller: tanggalcontroller,
                        decoration: InputDecoration(
                            labelText: "Time",
                            suffixIcon: InkWell(
                              onTap: () {
                                DatePicker.showDateTimePicker(context,
                                    currentTime: datetimeForNow,
                                    onConfirm: (date) {
                                  setState(() {
                                    tanggalcontroller.text =
                                        DateFormat('yyyy-MM-dd HH:mm')
                                            .format(date);

                                    dateForNotif = date.toUtc();
//
                                  });
                                });
                              },
                              child: Icon(Icons.date_range),
                            )),
                      ),
                      new Padding(padding: new EdgeInsets.all(5.0)),
                      new TextField(
                          controller: nohpcontroller,
                          keyboardType: TextInputType.phone,
                          decoration: new InputDecoration(
                            hintText: "081234567890",
                            labelText: "Nomor Hp",
                          )),
                      new Padding(padding: new EdgeInsets.all(5.0)),
                      new TextField(
                          controller: rencanacontroller,
                          decoration: new InputDecoration(
                            hintText: "Bulan ini",
                            labelText: "Rencana Pembelian",
                          )),
                      new Padding(padding: new EdgeInsets.all(5.0)),
                      new TextField(
                          controller: tipecontroller,
                          decoration: new InputDecoration(
                            hintText: "Fortuner",
                            labelText: "Type Kendaraan",
                          )),
                      new Padding(padding: new EdgeInsets.all(5.0)),
                      new TextField(
                          maxLines: 3,
                          minLines: 2,
                          controller: alamatcontroller,
                          decoration: new InputDecoration(
                            hintText: "Jl. Raya Blok i1 Tangerang",
                            labelText: "Alamat Prospek",
                          )),
                      new Padding(padding: new EdgeInsets.all(5.0)),
                      new TextField(
                          maxLines: 3,
                          minLines: 2,
                          controller: keterangancontroller,
                          decoration: new InputDecoration(
                            hintText: "Keterangan",
                            labelText: "Keterangan Prospek",
                          )),
                      new Padding(padding: new EdgeInsets.all(5.0)),
                      Text(
                        "Status Proyek",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      CheckboxGroup(
                        labels: <String>[
                          "Need to buy",
                          "Time to buy",
                          "Authority to buy",
                          "Money to buy",
                        ],
                        onChange: (bool isChecked, String label, int index) {
                          switch (index) {
                            case 0:
                              setState(() {
                                isChecked ? ntb = 1 : ntb = 0;
                              });
                              break;
                            case 1:
                              setState(() {
                                isChecked ? ttb = 1 : ttb = 0;
                              });
                              break;
                            case 2:
                              setState(() {
                                isChecked ? atb = 1 : atb = 0;
                              });
                              break;
                            case 3:
                              setState(() {
                                isChecked ? mtb = 1 : mtb = 0;
                              });
                              break;
                            default:
                          }
                          print(ntb);
                        },
                        onSelected: (List<String> checked) {
                          switch (checked.length) {
                            case 1:
                              statuscontroller.text = "Low Prospect";
                              break;
                            case 2:
                              statuscontroller.text = "Medium Prospect";
                              break;
                            case 3:
                              statuscontroller.text = "Medium Prospect";
                              break;
                            case 4:
                              statuscontroller.text = "Hot Prospect";
                              break;
                            default:
                              statuscontroller.text = "";
                              break;
                          }
                        },
                      ),
                      new TextField(
                          readOnly: true,
                          enabled: false,
                          controller: statuscontroller,
                          decoration: new InputDecoration(
                              hintText: "Pilih salah satu dari diatas")),
                      Row(
                        children: [
                          Checkbox(
                            value: isUseReminder,
                            onChanged: (value) {
                              setState(() {
                                isUseReminder = value;
                              });
                            },
                          ),
                          Text("Aktifkan Reminder")
                        ],
                      ),
                      isUseReminder
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    "Reminder",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 120,
                                      child: new DropdownButton(
                                          value: selectedDay,
                                          items: [
                                            DropdownMenuItem(
                                                child: Text("Minggu"),
                                                value: 1),
                                            DropdownMenuItem(
                                              child: Text("Senin"),
                                              value: 2,
                                            ),
                                            DropdownMenuItem(
                                                child: Text("Selasa"),
                                                value: 3),
                                            DropdownMenuItem(
                                                child: Text("Rabu"), value: 4),
                                            DropdownMenuItem(
                                                child: Text("Kamis"), value: 5),
                                            DropdownMenuItem(
                                                child: Text("Jumat"), value: 6),
                                            DropdownMenuItem(
                                                child: Text("Sabtu"), value: 7)
                                          ],
                                          onChanged: changedDropDownItem),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: notifdate,
                                        decoration: InputDecoration(
                                            errorText: _validate
                                                ? 'Harus diisi!'
                                                : null,
                                            hintText: "Waktu",
                                            hintMaxLines: 1,
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                DatePicker.showTimePicker(
                                                    context,
                                                    currentTime: datetimeForNow,
                                                    onConfirm: (date) {
                                                  setState(() {
                                                    notifdate.text =
                                                        DateFormat('HH:mm')
                                                            .format(date);

                                                    completeTimetoDB = DateFormat(
                                                            'yyyy-MM-dd kk:mm:ss.SS')
                                                        .format(date);
                                                    setState(() {
                                                      dateForNotif = date;
                                                    });
                                                  });
                                                });
                                              },
                                              child: Icon(Icons.date_range),
                                            )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                      new Padding(padding: const EdgeInsets.all(5.0)),
                      new RaisedButton(
                          child: new Text(
                            "BUAT PROSPEK BARU",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.green,
                          onPressed: () {
                            if(isUseReminder){
                              if (notifdate.text.isEmpty) {
                                setState(() {
                                  _validate = true;
                                });
                                return;
                              } else {
                                setState(() {
                                  _validate = false;
                                });
                              }
                            }
                            addData(context);
                          })
                    ],
                  ),
                ),
              ]),
      ),
    );
  }

  Future weeklyNotification(int id, String s, String namaProspect,
      String statusProspek, String payload) async {
    var datetime = DateFormat("HH:mm").parse(s);
    print("DATETIME" + datetime.toString());
    Time t = new Time(datetime.hour, datetime.minute, datetime.second);
    print("DATETIME" + t.toString());

    print(t);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel-id', 'channel-name', 'channel-description',
        importance: Importance.Max,
        priority: Priority.High,
        autoCancel: false,
        playSound: true);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        id,
        'Follow Up',
        'Nama Prospect : $namaProspect | Status : $statusProspek ',
        Day(selectedDay),
        t,
        platformChannelSpecifics,
        payload: id.toString());
  }

  void changedDropDownItem(int selectedDay) {
    setState(() {
      this.selectedDay = selectedDay;
    });
  }

  void addData(BuildContext context) async {
    setState(() {
      loading = true;
    });
    var r = await http.post(Constants.ADD_PROSPECT, body: {
      "namaProspek": namacontroller.text,
      "tglProspek": tanggalcontroller.text,
      "nohpProspek": nohpcontroller.text,
      "rencanaProspek": rencanacontroller.text,
      "kendaraanProspek": tipecontroller.text,
      "alamatProspek": alamatcontroller.text,
      "ketProspek": keterangancontroller.text,
      "ntbProspek": ntb.toString(),
      'ttbProspek': ttb.toString(),
      'atbProspek': atb.toString(),
      'mtbProspek': mtb.toString(),
    });
    print(r.body);
    var data = jsonDecode(r.body);
    if (r.statusCode == 200) {
      setState(() {
        res = ResponseResult.fromJson(data);
      });
    }
    print("PRINTING DATA");
    if (res.error == "false") {
      if(isUseReminder){
        addReminder();
      }
      _scaffoldState.currentState.showSnackBar(new SnackBar(
        content: Text("Berhasil Ditambah"),
        duration: Duration(seconds: 2),
      ));
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (c) => MyApp(
                      isRefresh: true,
                    )));
      });
    } else {
      setState(() {
        loading = false;
      });
      _scaffoldState.currentState
          .showSnackBar(new SnackBar(content: Text("Gagal Menambah")));
    }
  }

  void addReminder()async{
    var row = {
      DatabaseHelper.columnIdNotif: res.id.toString(),
      DatabaseHelper.columnTitle: namacontroller.text,
      DatabaseHelper.columnData: statuscontroller.text,
      DatabaseHelper.columnDay: selectedDay,
      DatabaseHelper.columnTime: notifdate.text
    };
    await DatabaseHelper.instance.insert(row);
    await weeklyNotification(int.parse(res.id.toString()), notifdate.text,
    namacontroller.text, statuscontroller.text, res.id.toString());
  }
}
