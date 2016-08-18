import "dart:async";
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
  httpServer.listen((request) {
    print("### REQUEST ###");
    print("URI: ${request.uri}");
    print("Method: ${request.method}");
    print("Body: ${request.method}");
    print("###############");
    request.response.write("SUCCESS");
    request.response.close();
  });
}
