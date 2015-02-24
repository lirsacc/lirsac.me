var express = require('express'),
    logger = require('morgan');

var app = express();

app.use(logger('dev'));
app.use(express.static(__dirname + '/_site'));
app.listen(3000);
