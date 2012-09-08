ActiveRecord::Schema.define(:version => 0) do
  create_table :messages, :force => true do |t|
    t.string :read_for
  end
  add_column :messages, :deleted_for, "integer[]"
  execute "CREATE EXTENSION IF NOT EXISTS intarray"
  create_table :users, :force => true do |t|
  end
end