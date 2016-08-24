import "dart:async";
import "dart:convert" show UTF8;
import "dart:io";

import "package:dslink/dslink.dart";

LinkProvider link;
HttpServer httpServer;

main(List<String> args) async {
  link = new LinkProvider(args, "Obvius-");

  link.init();

  var port = link.addNode("/port", {
    r"$name": "Port",
    r"$type": "number",
    r"?value": 8020
  });

  try {
    bind(port.value);
  } catch (e) {
    print("Can't bind to ${port.value}");
    print(e);
  }

  link.onValueChange("/port").listen((event) async {
    httpServer.close();
    bind(event.value);
    link.save();
  });

  link.connect();
}

Future bind(int port) async {
  httpServer = await new HttpServer.listenOn(await ServerSocket.bind(InternetAddress.ANY_IP_V4, port));
  httpServer.listen((request) async {
    var body = await request.toList();
    List<String> bodyStr;
    try {
      bodyStr = body.map((data) => UTF8.decode(data)).toList();
    } catch (e) {
      bodyStr = new List<String>()..add("Body not UTF8");
    }
    print("### REQUEST ###");
    print("URI: ${request.uri}");
    print("Method: ${request.method}");
    print("Headers:");
    request.headers.forEach((name, vals) {
      print("\t$name: $vals");
    });
    print("Body: $bodyStr");
    print("###############");
    request.response.write("SUCCESS");
    request.response.close();
  });
}
