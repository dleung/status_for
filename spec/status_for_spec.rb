require 'spec_helper'

describe Message do
  let (:message) {Message.new}
  let (:user) {User.new}
  let (:email) {Email.new}
  
  it "I should be able to mark a message as deleted for a user" do
    user.save
    message.save
    message.mark_as_deleted_for!(user.id)
    Message.deleted_for(user).include?(message).should be_true
    Message.not_deleted_for(user).include?(message).should be_false
    message.check_deleted_for?(user.id).should be_true
  end

  it "I should be able to mark a message as not for a user" do
    user.save
    message.save
    message.mark_as_deleted_for!(user.id)
    message.mark_as_not_deleted_for!(user.id)
    Message.not_deleted_for(user).include?(message).should be_true
    Message.deleted_for(user).include?(message).should be_false
    message.check_deleted_for?(user.id).should be_false
  end

  it "Getting a query for an improperly initialized class should return an error" do
    user.save
    message.save
    expect {Message.not_deleted_for(email).include?(message)}.should raise_error
    expect {Message.deleted_for(email).include?(message)}.should raise_error
  end  

  it "Checking a status without providing an id should raise an error" do
    user.save
    message.save
    expect {message.check_deleted_for?(user)}.should raise_error
  end

  it "Undefined Methods, or methods without proper database columns, should returnan error" do
    user.save
    message.save
    expect {Message.foobar_for(user).include?(message)}.should raise_error
  end

  it "Checking respond_to?(status_for) should return true for defined columns" do
    user.save
    message.save
    Message.respond_to?("deleted_for").should be_true
  end

  it "Checking respond_to?(not_status_for) should return true for defined columns" do
    user.save
    message.save
    Message.respond_to?("not_deleted_for").should be_true
  end


  it "Marking an unspecified status should return an error" do
    user.save
    message.save
    expect {message.mark_as_foobar_for!(user)}.should raise_error
    expect {message.mark_as_not_foobar_for!(user)}.should raise_error
  end

  it "Checking an unspecified status should return an error" do
    user.save
    message.save
    expect {message.check_foobar_for?(user)}.should raise_error
  end

  it "Checking respond_to?(mark_as_deleted_for!) should return true for defined columns" do
    user.save
    message.save
    message.respond_to?("mark_as_deleted_for!").should be_true
  end

  it "Checking respond_to?(mark_as_not_status_for!) should return true for defined columns" do
    user.save
    message.save
    message.respond_to?("mark_as_not_deleted_for!").should be_true
  end

  it "Checking respond_to?(check_status_for?) should return true for defined columns" do
    user.save
    message.save
    message.respond_to?("check_deleted_for?").should be_true
  end

  it "I should be able to mark an email as read for a user" do
    user.save
    email.save
    email.mark_as_read_for!(user.id)
    Email.read_for(user).include?(email).should be_true
    Email.not_read_for(user).include?(email).should be_false
    email.check_read_for?(user.id).should be_true
  end

  it "I should be able to mark an email as not for a user" do
    user.save
    email.save
    email.mark_as_read_for!(user.id)
    email.mark_as_not_read_for!(user.id)
    Email.not_read_for(user).include?(email).should be_true
    Email.read_for(user).include?(email).should be_false
    email.check_read_for?(user.id).should be_false
  end
end
