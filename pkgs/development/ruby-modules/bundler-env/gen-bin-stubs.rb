require 'rbconfig'
require 'rubygems'
require 'rubygems/specification'
require 'fileutils'

# args/settings
out = ENV["out"]
ruby = ARGV[0]
gemfile = ARGV[1]
bundle_path = ARGV[2]
bundler_gem_path = ARGV[3]
paths = ARGV[4].split

# generate binstubs
FileUtils.mkdir_p("#{out}/bin")
paths.each do |path|
  next unless File.directory?("#{path}/nix-support/gem-meta")

  name = File.read("#{path}/nix-support/gem-meta/name")
  executables = File.read("#{path}/nix-support/gem-meta/executables").split
  executables.each do |exe|
    File.open("#{out}/bin/#{exe}", "w") do |f|
      f.write(<<-EOF)
#!#{ruby}
#
# This file was generated by Nix.
#
# The application '#{exe}' is installed as part of a gem, and
# this file is here to facilitate running it.
#

ENV["BUNDLE_GEMFILE"] = "#{gemfile}"
ENV["BUNDLE_PATH"] = "#{bundle_path}"
ENV['BUNDLE_FROZEN'] = '1'

Gem.use_paths("#{bundler_gem_path}", ENV["GEM_PATH"])

require 'bundler/setup'

load Gem.bin_path(#{name.inspect}, #{exe.inspect})
EOF
      FileUtils.chmod("+x", "#{out}/bin/#{exe}")
    end
  end
end
