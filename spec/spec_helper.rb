require 'active_support'
require 'active_record'
require 'acts_as_status_for'

configs = YAML.load_file(File.dirname(__FILE__) + '/database.yml')
ActiveRecord::Base.configurations = configs

db_name = ENV['DB'] || 'pg'
ActiveRecord::Base.establish_connection(db_name)
ActiveRecord::Migration.verbose = false
load(File.dirname(__FILE__) + "/schema.rb")

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
end

module App
  class User < ActiveRecord::Base
  end
  class Message < ActiveRecord::Base
    acts_as_status_for User
  end
  class Email < ActiveRecord::Base
    acts_as_status_for User
  end
end
include App