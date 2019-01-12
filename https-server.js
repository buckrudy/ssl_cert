var https = require("https")
var fs = require("fs")

var options = {
	key: fs.readFileSync("demoCA/www.leegoogol.com.key.pem"),
	cert: fs.readFileSync("demoCA/www.leegoogol.com.cert.pem"),
}

https.createServer(options, function(req, res) {
	res.writeHead(200);
	res.end("hello world");
}).listen(8000, function() {
	console.log("Open URL: www.leegoogol.com:8000")
})
