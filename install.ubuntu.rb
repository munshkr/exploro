#!/usr/bin/env ruby

DEPENDENCIES = %w{
  poppler-utils
  poppler-data
  ghostscript
  libreoffice

  libxslt-dev
  libxml2-dev

  sqlite3
  libsqlite3-dev

  libboost-dev
  libboost-regex-dev
  libicu-dev
  libboost-filesystem-dev
  libboost-program-options-dev
}

def log(text)
  puts "\e[1m\e[32m=> \e[34m#{text}\e[0m"
end

def run(commands)
  commands = Array(commands)
  system(commands.join(" && "))
end

def install_freeling
  tmpdir = '/tmp/exploro'
  run [
    "mkdir -p #{tmpdir}",
    "cd #{tmpdir}",
    "wget --continue http://devel.cpl.upc.edu/freeling/downloads/21 --output-document freeling-3.0.tar.gz",
    "rm -rf freeling-3.0",
    "tar xzvf freeling-3.0.tar.gz",
    "cd freeling-3.0",
    "./configure",
    "make",
    "sudo make install",
  ]
end

log "Install gem dependencies"
system "sudo apt-get install #{DEPENDENCIES.join(' ')}"

log "Install Ruby gems"
system "bundle install"

log "Download and install FreeLing"
install_freeling

log "Installation finished! Run ./exploro"
