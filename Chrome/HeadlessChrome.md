
##### How to install headless chrome and setting up Selenium webdriver
```
sudo apt-get update
sudo apt-get install -y libglib2.0-0 libnss3 libgconf-2-4 libfontconfig1
sudo apt-get install chromium-browser
sudo apt-get install unzip
wget https://chromedriver.storage.googleapis.com/2.36/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv -f ~/chromedriver /usr/local/bin/chromedriver
sudo chown root:root /usr/local/bin/chromedriver
sudo chmod 0755 /usr/local/bin/chromedriver
```

Setting up webdriver in Python
```
from selenium import webdriver
chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument("--headless")
chrome_options.add_argument('--no-sandbox')
driver = webdriver.Chrome('chromedriver', chrome_options=chrome_options)
```
