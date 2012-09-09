require 'active_support/all'
class Message
  cattr_accessor :object_status
end

Message.object_status = 'bob'
a = Message.new
puts a.class.object_status
