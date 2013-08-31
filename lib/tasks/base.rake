task :environment do
  require File.expand_path("../../../config/boot.rb", __FILE__)
end

desc "Fire up console"
task :console => :environment do
  Bundler.require(:default, :development)

  Pry.config.prompt = [
    proc { "exploro> " },
    proc { "       | " }
  ]

  binding.pry(:quiet => true)
end
