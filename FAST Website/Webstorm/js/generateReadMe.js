var marked = require('marked');
var fs = require('fs');

var readMe = fs.readFileSync('/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/README.md', 'utf-8');
var markdownReadMe = marked(readMe);

fs.writeFileSync('README.html', markdownReadMe);
