var { Readability } = require('@mozilla/readability');
require("fastestsmallesttextencoderdecoder");
var { JSDOM } = require('jsdom');


var doc = new JSDOM("<html></html>", {});

global.window = doc.window
global.setTimeout = global.window.setTimeout

global.parseArticle = function(body) {
    var doc = new JSDOM(body);

    const options = {
        debug: false,
        disableJSONLD: false,
    }
    let reader = new Readability(doc.window.document, options);
    let article = reader.parse();
    console.log(article)
    return article
}