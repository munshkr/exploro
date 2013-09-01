require File.expand_path('../config/boot', __FILE__)
require 'app'

map '/' do
  run Sinatra::Application
end

map '/files' do
  run Rack::Directory.new(FILES_PATH)
end
