'use strict';
var fs = require('fs');
if (!fs.existsSync('.env')) {
  console.log("creating .env");
  fs.createReadStream('.sample-env').pipe(fs.createWriteStream('.env'));
}
