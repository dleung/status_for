require 'spec_helper'

describe Message do
  let (:message) {Message.new}
  let (:user) {User.new}
  
  it "I should be able to mark a message as deleted for a user" do
    user.save
    message.save
    message.mark_as_deleted_for!(user.id)
    Message.deleted_for(user).include?(message).should be_true
    Message.not_deleted_for(user).include?(message).should be_false
    message.deleted_for?(user).should be_true
  end

  it "I should be able to mark a message as not for a user" do
    user.save
    message.save
    message.mark_as_deleted_for!(user.id)
    message.mark_as_not_deleted_for!(user.id)
    Message.not_deleted_for(user).include?(message).should be_true
    Message.deleted_for(user).include?(message).should be_false
    message.deleted_for?(user).should be_false
  end

end
