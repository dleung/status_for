ActiveRecord::Schema.define(:version => 0) do
  create_table :messages, :force => true do |t|
  end
  add_column :messages, :deleted_for, "integer[]", default: "{}"

  create_table :emails, :force => true do |t|
  end
  add_column :emails, :read_for, "integer[]", default: "{}"
  execute "CREATE EXTENSION IF NOT EXISTS intarray"
  create_table :users, :force => true do |t|
  end
end