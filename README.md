[![Build Status](https://secure.travis-ci.org/dleung/status_for.png)](http://travis-ci.org/dleung/status_for)
 
# Status For

This module allows you to define a particular status, such as 'deleted', 'unread', 'viewed', etc, to an object, like a message, for a subject like a user.  For example, you can set message.mark_as_read_for(current_user), which marks the message as read, and you can call Message.read_for(current_user) which queries the database to find the messages that has been marked as 'read' for this user.  The query is not instantiated, so you can chain additional methods like .search and .paginate.

### Prerequisites
This module uses postgresql as the database.  It also needs the intarray extension to run.  You'll need to include postgresql in your Gemfile like gem 'pg'.

##Usage
This is an example where you want messages statuses "read" and "deleted" for a user.
#### Step 1: Include the gem
``` ruby
# In Gemfile
gem 'status_for'
###

#### Step 2: Models
``` ruby
# In your object, 'acts_as_status_for' and include a class you want the subject to be.  
# model/messages.rb
initialize_status_for User
```

#### Step 3:  Migration Definition
``` ruby
# For each of the status you want, include a status_for integer column.
# db/migrate/add_status_to_message.rb

create_table :messages, :force => true
add_column :messages, :deleted_for, "integer[]"
add_column :messages, :read_for, "integer[]"

# You also need to create the intarray extension if you haven't before.
execute "CREATE EXTENSION IF NOT EXISTS intarray"
```

#### Step 4:  Use it!
``` ruby
# These methods are available for the Message class:
current_user = User.first

Message.deleted_for(current_user)   # Returns an array of messages where mark_as_deleted has been executed for current_user
Message.not_deleted_for(current_user)   # Returns an array of messages where mark_as_deleted has NOT been executed for current_user

Message.read_for(current_user)
Message.unread_for(current_user)


# These methods are available for the @message instance variable.
message = Message.first

message.mark_as_deleted_for!(current_user.id)  #Takes an id or array of id, and marks it as deleted for each user.  Returns message
message.mark_as_not_deleted_for!(current_user.id)  # Unmarks the message as deleted for the id or array of id.  Returns message
message.check_deleted_for?(current_user.id)  # Checks to see if deleted has been marked for the id.  Returns true or false.

message.mark_as_read_for!([1, 2, 4])  # You can also pass in an array of ids.  Currently, you'll need to ensure these are IDs of the users you want.
message.mark_as_not_read_for!([1, 3])
message.check_read_for?(1)

```

### How does it work?
Instead of creating a separate join table associating the subject (ex. user) with the object (ex. message), this module simply requires you to add a new column in the object with the format 'status_for'.  This column will contain an array of subject ids that the status has been set for.  The heart of the query looks something like "Message.where("idx(messages.deleted_for, 2)::boolean" which returns an array of messages where deleted_for column contains the subject id.  



