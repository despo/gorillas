var haml = require('hamljs'),
    fs = require('fs'),
    cs = require('coffeescript'),
    sass = require('node-sass');

fs.writeFileSync("public/index.html", haml.render(fs.readFileSync("index.haml"),{}));
fs.writeFileSync("public/gorillas.js", cs.compile(fs.readFileSync("gorillas.coffee").toString(), {'filename':'gorillas.coffee'}));
sass.render({
    file: "style.scss",
    outFile: "public/style.css"
}, function(error, result) {
    if(!error){
        fs.writeFileSync("public/style.css", result.css);
    }else{
        console.log(error);
    }
});
