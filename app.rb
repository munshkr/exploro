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
    @projects = Project.reverse_order(:updated_at).all
    erb :'projects/index'
  end

  get '/new' do
    @project = Project.new
    erb :'projects/new'
  end

  post '/new' do
    @project = Project.create(params[:project])
    redirect '/projects/'
  end
end

namespace '/documents' do
  get '/' do
    @documents = Document.reverse_order(:created_at).all
    erb :'documents/index'
  end

  get '/new' do
  end

  post '/new' do
    content_type :json

    file = params[:files].first
    @document = Document.create({
      filename: file[:filename],
      size: File.size?(file[:tempfile]),
    })

    File.open(File.join(FILES_PATH, @document.filename), 'wb') do |fd|
      IO.copy_stream(file[:tempfile], fd)
    end

    @document.process!

    { files: [jqupload_response(@document)] }.to_json
  end

  helpers do
    def jqupload_response(document)
      { name: document.filename,
        size: document.size,
        url:  "/files/#{document.filename}" }
    end
  end
end
