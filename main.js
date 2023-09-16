var express = require('express');
var app = express();
app.get('/', function(req, res){
var result = eval(req.query.parameter)
res.send("Result = " + result);
});
app.listen(5000);
