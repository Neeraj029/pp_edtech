import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:pp_edtech/Screens/watch_video.dart';
import "package:youtube_player_flutter/youtube_player_flutter.dart";
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSearched = false;
  String searchQuery = "India";
  Color darkGreyColor = new Color(0xFF212128);
  Color lightBlueColor = new Color(0xFF8787A0);
  Color redColor = new Color(0xFFDC4F64);

  List<String> channelItemsName = [];
  String dropdownValue = "";

  // List of items in our dropdown menu
  Map channelItems = {};

  makeItems() async {
    // make shared prefernces instance
    // SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // get the list of items from shared preferences
    List<String>? items = prefs.getStringList('channels');
    // print(items);
    for (var element in items!) {
      var channelName = await fetchChannelName(element);
      var map = {channelName["title"]: element};
      // if (!channelItems.contains(map)) {
      channelItems[channelName["title"]] = element;
      channelItemsName.add(channelName["title"]);
      // }
    }
    setState(() {
      dropdownValue = channelItemsName[0];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    makeItems();
  }

  TextEditingController taskName = new TextEditingController();

  returnSnacks(
      BuildContext context, String message, Color color, IconData icon) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(
      backgroundColor: color,
      content: Row(
        children: [
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
          ),
          SizedBox(
            width: 10,
          ),
          Icon(
            icon,
            color: Colors.black,
          ),
        ],
      ),
    ));
  }

  addChannel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints.expand(
              height: 220,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(13)),
                color: Colors.black),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Add new channel",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                    )),
                Container(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: taskName,
                    decoration: InputDecoration(
                      hintStyle: GoogleFonts.inter(
                        color: Colors.white,
                      ),
                      hintText: "Id of the youtube channel",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.red,
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text(
                        "Add",
                        style: GoogleFonts.inter(
                          color: Colors.blue,
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () async {
                        // do some shit idk
                        var channelInfo;
                        try {
                          channelInfo = await fetchChannelName(taskName.text);
                        } catch (e) {
                          Navigator.pop(context);

                          returnSnacks(context, "Invalid channel id",
                              Colors.red, Icons.error);
                          return;
                        }

                        print(channelInfo);
                        String channelName = channelInfo["title"];

                        if (channelItems[channelName] == taskName.text) {
                          returnSnacks(context, "This channel is already added",
                              Color.fromARGB(255, 222, 31, 47), Icons.error);
                          Navigator.pop(context);
                        } else {
                          final prefs = await SharedPreferences.getInstance();

                          final key = 'channels';
                          List<String>? channelsList =
                              prefs.getStringList(key) ?? <String>[];
                          channelsList?.add("${taskName.text}");

                          prefs.setStringList(key, channelsList!);
                          print("name " + taskName.text);
                          setState(() {
                            channelItems[channelName] = taskName.text;
                            channelItemsName.add(channelName);
                            dropdownValue = channelName;
                          });
                          returnSnacks(context, "${channelName} added",
                              Color.fromARGB(255, 31, 240, 115), Icons.check);

                          Navigator.pop(context);
                          // print(prefs.getStringList("channels"));
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  deleteWarning(channelItemsNameSingle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints.expand(
              height: 300,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(13)),
                color: Colors.black),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // danger image
                Image.network(
                    "https://cdn-icons-png.flaticon.com/512/1008/1008928.png",
                    height: 100,
                    width: 100),
                Text("Do you want to delete this channel?",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        "Nope",
                        style: GoogleFonts.inter(
                          color: Colors.blue,
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      color: Colors.red,
                      child: Text(
                        "Yes",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final key = 'channels';
                        List<String>? items = prefs.getStringList('channels');
                        // print(channelItems);
                        items?.remove(channelItems[channelItemsNameSingle]);
                        prefs.setStringList(key, items!);
                        print(prefs.getStringList('channels'));

                        setState(() {
                          channelItemsName.remove(channelItemsNameSingle);
                          channelItems.remove(channelItemsNameSingle);
                          dropdownValue = channelItemsName[0];
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map> fetchAlbum(String q, String cid) async {
    String query = q.replaceAll(" ", "%20");
    String channelId = cid;
    // print(channelId);
    final response = await http.get(Uri.parse(
        'https://lionfish-app-cokfc.ondigitalocean.app/search/channelid=${channelId}&q=${query}'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<Map> fetchChannelName(String q) async {
    String channelId = q;
    final response = await http.get(Uri.parse(
        'https://lionfish-app-cokfc.ondigitalocean.app/channel/${channelId}'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    // makeItems();
    final scaffold = ScaffoldMessenger.of(context);

    // print(channelItemsName);
    return Scaffold(
      backgroundColor: Colors.black38,
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 10.0, left: 12.0, right: 12.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 3, color: Colors.blue), //<-- SEE HERE
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  hintStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w400, color: Colors.white),
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                onSubmitted: (value) {
                  print(value);
                  setState(() {
                    searchQuery = value;
                    isSearched = true;
                  });
                },
              ),
            ),
          ),
          // check if channelItemsName is empty
          // if it is empty then show a loading screen
          // else show the list of channels
          channelItemsName.isEmpty
              ? Text("")
              : DropdownButton(
                  // Initial Value
                  value: dropdownValue!,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  dropdownColor: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  // Down Arrow Icon
                  icon: const Icon(Icons.keyboard_arrow_down),

                  // Array list of items
                  items: channelItemsName.map((String channelItemsNameSingle) {
                    return DropdownMenuItem(
                      value: channelItemsNameSingle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(channelItemsNameSingle),
                          // bin icon button
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              deleteWarning(channelItemsNameSingle);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                ),
          channelItemsName.isEmpty
              ? Text("loading")
              : Expanded(
                  child: Center(
                    child: FutureBuilder<Map>(
                      future:
                          fetchAlbum(searchQuery, channelItems[dropdownValue]!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!['result'].length,
                            itemBuilder: (context, index) {
                              // print(snapshot.data!['result'][index]['thumbnails']
                              // ['normal'][3]['url']);
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => video_screen(
                                              videoId: snapshot.data!['result']
                                                  [index]['id'])));
                                },
                                child: Column(
                                  children: [
                                    snapshot.data!["result"][index]
                                                    ["thumbnails"]["normal"] !=
                                                null &&
                                            snapshot.data!["result"][index]
                                                        ["thumbnails"]["normal"]
                                                    [3]["url"] !=
                                                null &&
                                            snapshot.data!['result'][index]
                                                    ["type"] ==
                                                "video"
                                        ? Image.network(snapshot.data!["result"]
                                                [index]["thumbnails"]["normal"]
                                            [3]["url"])
                                        : Text(""),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10,
                                          left: 35,
                                          right: 35,
                                          bottom: 20),
                                      child: snapshot.data!['result'][index]
                                                  ["type"] ==
                                              "video"
                                          ? Text(
                                              snapshot.data!['result'][index]
                                                  ['title'],
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            )
                                          : Text(""),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        // By default, show a loading spinner.
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          addChannel();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
