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
  get '/new' do
  end

  post '/new' do
    content_type :json

    documents = []
    params[:files].each do |file_data|
      @document = Document.create({
        filename: file_data[:filename],
        size: File.size?(file_data[:tempfile]),
      })
      documents << @document

      File.open(File.join(FILES_PATH, @document.filename), 'wb') do |fd|
        IO.copy_stream(file_data[:tempfile], fd)
      end

      @document.process!
    end

    { files: documents.map { |doc| jqupload_response(doc) } }.to_json
  end

  helpers do
    def jqupload_response(document)
      { name: document.filename,
        size: document.size,
        url:  "/files/#{document.filename}" }
    end
  end
end
