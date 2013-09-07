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
      temp_path = File.join(UPLOADED_FILES_PATH, filename)
      doc = Document.create_from_file(temp_path, project: @project)
      doc.process!
    end

    @project.to_json
  end

  get '/:id' do |id|
    @project = Project[id]
    @documents = @project.documents
    erb :'projects/view'
  end

  get '/:id/tokens.csv' do |id|
    content_type :csv

    @project = Project[id]

    csv_path = File.join(APP_ROOT, 'tmp', "#{@project.id}__tokens.csv")
    File.open(csv_path, 'wb') do |fd|
      @project.documents.each do |doc|
        File.open(doc.path, 'rb') do |doc_fd|
          IO.copy_stream(doc_fd, fd)
        end
      end
    end

    send_file csv_path, filename: "#{@project.name}__tokens.csv", type: 'text/csv'
  end

  get '/:id/wordcloud' do |id|
    @project = Project[id]
    erb :'projects/wordcloud'
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

  get '/:id/download' do |id|
    @document = Document[id]
    send_file @document.path, filename: @document.filename
  end

  get '/:id/wordcloud' do |id|
    @document = Document[id]
    erb :'documents/wordcloud'
  end

  get '/:id/tokens.csv' do |id|
    content_type :csv

    @document = Document[id]
    csv_path = File.join(@document.project.path, 'tokens', "#{@document.id}.csv")
    if File.exists?(csv_path)
      send_file csv_path, filename: "#{@document.filename}__tokens.csv", type: 'text/csv'
    else
      status 404
      halt 'CSV not found'
    end
  end

  get '/:id/entities.csv' do |id|
    content_type :csv

    @document = Document[id]
    csv_path = File.join(@document.project.path, 'entities', "#{@document.id}.csv")
    if File.exists?(csv_path)
      send_file csv_path, filename: "#{@document.filename}__entities.csv", type: 'text/csv'
    else
      status 404
      halt 'CSV not found'
    end
  end
end

helpers do
  def timeago_tag(time)
    "<abbr class=\"timeago\" title=\"#{time.utc.iso8601}\">#{time}</abbr>"
  end
end
