require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/content_for'

configure do
  set :server, :puma
end

get '/' do
  erb :index
end

namespace '/projects' do
  get '/' do
    @projects = []
    erb :'projects/index'
  end

  get '/new' do
    @project = nil
    erb :'projects/new'
  end

  post '/new' do
    @document = OpenStruct.new(id: rand(1000))

    require 'qu'
    require 'lib/jobs/extraction_job'

    job = Qu.enqueue ExtractionJob, @document.id

    redirect '/projects/'
  end
end
