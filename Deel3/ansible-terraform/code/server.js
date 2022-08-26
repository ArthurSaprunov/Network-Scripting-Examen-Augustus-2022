var http = require('http');
var os = require("os");
var hostname = os.hostname();

var fs = require('fs');

const PORT = 8080;

fs.readFile('./index.html', 'utf8', function (err, html) {

    if (err) throw err;

    http.createServer(function (request, response) {
        response.writeHeader(200, {"Content-Type": "text/html"});
        response.write(html.replace(/\$HOSTNAME\$/g, hostname).replace('$VERSION$', process.version));
        response.end();
    }).listen(PORT);
});
