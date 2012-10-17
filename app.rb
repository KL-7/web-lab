require 'sinatra'
require 'json'
require 'net/http'


def api_get(api_url)
  JSON.parse(Net::HTTP.get(URI.parse(api_url)))
end

def json
  content_type :json
  yield.to_json
end


set :public_folder, File.dirname(__FILE__) + '/public'


get('/js/*.js') { coffee(params[:splat].first.to_sym) }

get('/') { send_file File.join(settings.public_folder, 'index.html') }


CURRENCY_API_KEY = '902f65f28d5f4348a6974942a4775eb8'
CURRENCY_API_URL = "http://openexchangerates.org/api/historical/%s.json?app_id=#{CURRENCY_API_KEY}"

get('/currency/:currency/:date.json') do
  json { { :date => params[:date], :value => api_get(CURRENCY_API_URL % params[:date])['rates'][params[:currency]] } }
end


WEATHER_API_KEY = 'e06c59f816e8caae'
WEATHER_API_URL = "http://api.wunderground.com/api/#{WEATHER_API_KEY}/history_%s/q/%s.json"

get('/weather/:city/:date.json') do
  url = WEATHER_API_URL % [params[:date], params[:city].gsub(/_/, '/')]
  p url
  json { { :date => params[:date], :value => api_get(url)['history']['dailysummary'].first['meantempm'].to_i } }
end