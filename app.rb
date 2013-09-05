require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/content_for'

configure do
  set :server, :puma
end

get '/' do
  erb :index
end

get '/about' do
  erb :about
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
    content_type :json

    @project = Project.create(params[:project])

    filenames = params[:filenames].split(',')
    filenames.each do |filename|
      path = File.join(UPLOADED_FILES_PATH, filename)
      doc = @project.add_document(filename: filename, size: File.size?(path))
      doc.process!
    end

    @project.to_json
  end

  get '/:id' do |id|
    @project = Project[id]
    @documents = @project.documents
    erb :'projects/view'
  end
end

namespace '/documents' do
  get '/' do
    @documents = Document.reverse_order(:created_at).all
    erb :'documents/index'
  end

  post '/upload' do
    content_type :json

    file = params[:files].first

    filename = file[:filename]
    size = File.size?(file[:tempfile])

    # Copy file to UPLOADED_FILES_PATH
    FileUtils.mkdir_p(UPLOADED_FILES_PATH)
    File.open(File.join(UPLOADED_FILES_PATH, filename), 'wb') do |fd|
      IO.copy_stream(file[:tempfile], fd)
    end

    require 'json'
    { files: [{ name: filename, size: size }] }.to_json
  end

  # NOTE this is only defined because of a bug in $.fileupload
  get '/upload' do
    halt
  end

  get '/:id' do |id|
    @document = Document[id]
    erb :'documents/view'
  end
end

helpers do
  def timeago_tag(time)
    "<abbr class=\"timeago\" title=\"#{time.utc.iso8601}\">#{time}</abbr>"
  end
end
