APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(APP_ROOT)

require 'bundler/setup'

require 'term/ansicolor'
class String
  include Term::ANSIColor
end

UPLOADED_FILES_PATH = File.join(APP_ROOT, 'tmp', 'files')
FILES_PATH = File.join(APP_ROOT, 'db', 'files')

require 'lib/logger'
require 'config/database'
require 'config/queue'
