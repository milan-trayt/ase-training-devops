function handler(event) {
  var request = event.request;

  if (!request.uri.includes(".")) {
    var route = request.uri.split("/");
    if (route.length > 1 && route[1] != "") {
      request.uri = `/${route.slice(1).join("/")}/index.html`;
      request.querystring = {};
    }
  }

  return request;
}
