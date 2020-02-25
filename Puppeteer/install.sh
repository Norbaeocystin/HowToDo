#!/bin/bash
yes | apt update
yes | apt install nodejs
yes | apt install npm
yes | apt install screen
npm install express --save

npm install puppeteer
npm install puppeteer-extra
npm install puppeteer-extra-plugin-stealth
cat <<EOT >> index.js
const express = require('express')
const app = express()
const puppeteer = require('puppeteer-extra')
// Enable stealth plugin with all evasions
puppeteer.use(require('puppeteer-extra-plugin-stealth')())

async function get_html(url){
  // Launch the browser in headless mode and set up a page.
  const browser = await puppeteer.launch({
    args: [
'--no-sandbox',
'--disable-setuid-sandbox',
'--disable-infobars',
'--window-position=0,0',
'--ignore-certifcate-errors',
'--ignore-certifcate-errors-spki-list',
'--user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3312.0 Safari/537.36"'
],
    headless: true
  })
  const page = await browser.newPage()
 
  // Navigate to the page that will perform the tests.
  await page.goto(url)
 await page.waitFor(1 * 5000);
  // Save a screenshot of the results.
  let html = await page.content();
  await browser.close();
    return await html;
}

app.get("/belgium", (req, res, next) => {
    var query = req.query
    var re = / /g;
    var url = query.url.replace(re,'+');
    var html = get_html(url);
    html.then(function(values) {
      res.send(values);
    }).catch(function(e) {
        console.log(e)
  res.send(e); // "oh, no!"
});
    });

app.listen(3001)
EOT
nohup node index.js &
