var statik = require('node-static'),
    http = require('http');

var fileServer = new(statik.Server)('./public');

http.createServer(function (req, res) {
    req.addListener('end', function () {
        fileServer.serve(req, res);
    }).resume();
}).listen(8888);
