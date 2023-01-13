// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'mqttclient.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Client UI',
      home: MQTTClientUI(),
    );
  }
}

class MQTTClientUI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MQTTClientTabs();
  }
}

class MQTTClientTabs extends State<MQTTClientUI> with TickerProviderStateMixin {
  static MQTTClient? client;

  static String url = 'test.mosquitto.org';
  static String port = '1883';
  static String username = '';
  static String password = '';

  static String topic = 'led/state';
  static String message = '';

  static String subscribeTopic = '';

  static TextEditingController publishedMessages = TextEditingController();
  static TextEditingController receievedMessages = TextEditingController();

  static void _handleConnect() {
    client = MQTTClient(url, 'NodeMCU8266', port);
    client!.connect().then((value) => {print('Connected to $url')});
  }

  static void _handleDisconnect() {
    client!.disconnect();
  }

  static void _publish() {
    client!.publish(topic, message);
    publishedMessages.text = '$topic|$message';
  }

  static void _subscribe() {
    client!.subscribe(subscribeTopic);
    String t = client!.subscribedTopic;
    String m = client!.recvdMsg;
    receievedMessages.text = '$t|$m';
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.animateTo(2);
  }

  static const List<Tab> _tabs = [
    Tab(icon: Icon(Icons.hub), child: Text('Connect')),
    Tab(icon: Icon(Icons.publish), text: 'Publish'),
    Tab(icon: Icon(Icons.subscriptions), text: 'Subscribe'),
  ];

  static Widget createConnectWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), labelText: 'Url'),
            onChanged: (newValue) => url = newValue,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), labelText: 'Port'),
            onChanged: (newValue) => port = newValue,
          ),
          const SizedBox(height: 10),
          TextFormField(
            onChanged: (newValue) => username = newValue,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Username',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            onChanged: (newValue) => password = newValue,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              ElevatedButton(
                onPressed: _handleConnect,
                child: Text('Connect'),
              ),
              SizedBox(width: 60),
              ElevatedButton(
                onPressed: _handleDisconnect,
                child: Text('Disconnect'),
              ),
            ],
          )
        ],
      ),
    );
  }

  static Widget createPublishWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), labelText: 'Topic'),
            onChanged: (newValue) => topic = newValue,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), labelText: 'Message'),
            onChanged: (newValue) => message = newValue,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              ElevatedButton(
                onPressed: _publish,
                child: Text('Publish'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text('Publsihed Messages (Topic | Message )'),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: publishedMessages,
            keyboardType: TextInputType.multiline,
            maxLines: 10,
            decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Colors.blue))),
          )
        ],
      ),
    );
  }

  static Widget createSubscribeWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), labelText: 'Topic'),
            onChanged: (newValue) => subscribeTopic = newValue,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              ElevatedButton(
                onPressed: _subscribe,
                child: Text('Subscribe'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text('Received Messages (Topic | Message )'),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: receievedMessages,
            keyboardType: TextInputType.multiline,
            maxLines: 10,
            decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Colors.blue))),
          )
        ],
      ),
    );
  }

  final List<Widget> _views = [
    createConnectWidget(),
    createPublishWidget(),
    createSubscribeWidget()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                labelColor: Colors.white,
                //unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontStyle: FontStyle.italic),
                overlayColor:
                    MaterialStateColor.resolveWith((Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.blue;
                  }
                  if (states.contains(MaterialState.focused)) {
                    return Colors.blueGrey;
                  } else if (states.contains(MaterialState.hovered)) {
                    return Colors.blueGrey;
                  }

                  return Colors.transparent;
                }),
                indicatorWeight: 10,
                indicatorColor: Colors.blueGrey,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(5),
                indicator: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                ),
                isScrollable: true,
                // physics: BouncingScrollPhysics()
                enableFeedback: true,
                // Uncomment the line below and remove DefaultTabController if you want to use a custom TabController
                // controller: _tabController,
                tabs: _tabs,
              ),
              title: const Text('MQTT Client'),
              backgroundColor: Color.fromARGB(255, 7, 8, 27),
            ),
            body: Center(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * .6,
                  height: MediaQuery.of(context).size.height * .8,
                  child: TabBarView(children: _views)),
            )),
      ),
    );
  }
}
