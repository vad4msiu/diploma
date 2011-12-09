# encoding: UTF-8
require "rubygems"
require "nokogiri"
require 'net/http'
require 'net/https'
require "iconv"
require "cgi"

http = Net::HTTP.new('www.recipdonor.com')
cookie = '.ASPXAUTH=4C8F89B6B944C3065D496AF279E8AB986E794703AEE35A391D348C1EEC3D12E42068779435DE672DB7797CE0DA4255D8012BCE77FF9DDDB6199C731B5351B07C71692C63979FA306E7D2A50D11A33D5C5F2B9F404147C0023823CDF5AD309BD3BF5107F32EAA7A42E1CF7A17EFBC9F50; ASP.NET_SessionId=qdcgyp3iejkjw0a2modyn5b1;'
text = 'Образование в Европе в 500-1789гг прошло длительный путь развития от всеобщего невежества до всеобщего обязательного начального образования. Около 500г пал древний Рим, завоеванный германским имением вандалов. Исчезла культура, а вместе с ней и классическое образование. Сохранилось только христианское образование священников в монастырских и церковных школах. В них господствовало догматическое обучение, основанное на вере и заучивание наизусть молитв и других священных текстов.'
data = "first=#{CGI::escape(Iconv.iconv('windows-1251','utf-8', text).join)}&dictId=#{CGI::escape(',6,7,8,')}"
headers = {
  'Cookie' => cookie,
  'Host' => 'www.recipdonor.com',
  'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:6.0.2) Gecko/20100101 Firefox/6.0.2',
  'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  'Accept-Language' => 'ru-ru,ru;q=0.8,en-us;q=0.5,en;q=0.3',
  'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
  'Connection' => 'keep-alive',
  'Referer' => 'http://www.recipdonor.com/synonymizer'
}

resp, data = http.post('/synonymizer/rewrite', data, headers)
doc = Nokogiri::HTML(data, nil, 'windows-1251')
tmp = doc.css('.rewrite').first
tmp = tmp.to_html.sub('<td class="rewrite">', '').sub('</td>', '').gsub('<span>', '').gsub('</span>', '')
tmp = Iconv.iconv('utf-8', 'windows-1251', tmp).join
data = "text=#{CGI::escape(tmp)}&typograf=0&alphabetic=1&misprint=1&shuffleSentences=1&shuffleParargaphs=1&reduction=0"

headers['Accept'] =	'application/json, text/javascript, */*; q=0.01'
headers.merge! 'Content-Type' =>	'application/x-www-form-urlencoded; charset=UTF-8'
headers.merge! 'X-Requested-With' =>	'XMLHttpRequest'
headers['Referer'] =	'http://www.recipdonor.com/synonymizer/rewrite'
headers.merge! 'Pragma' => 'no-cache'
headers.merge! 'Cache-Control' => 'no-cache'

resp, data = http.post('/synonymizer/TypografRu', data, headers)
text_result = Iconv.iconv('utf-8', 'windows-1251', data).join
puts text
puts "-"*20
puts text_result
