APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(APP_ROOT)

require 'bundler/setup'

require 'term/ansicolor'
class String
  include Term::ANSIColor
end

FILES_PATH = File.join(APP_ROOT, 'db', 'files')
FileUtils.mkdir_p(FILES_PATH)

require 'config/database'
require 'config/queue'

puts "=> Bootstrapped".bold
