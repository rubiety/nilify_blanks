def postgresql?
  ENV["DB"] == "postgresql"
end

if postgresql?
  connection = PG.connect(dbname: "postgres")
  connection.exec("DROP DATABASE nilify_blanks_plugin_test")
  connection.exec("CREATE DATABASE nilify_blanks_plugin_test")
  connection.finish
end

ActiveRecord::Schema.define(:version => 0) do
  if postgresql?
    enable_extension 'citext'
  end

  create_table :posts, :force => true do |t|
    t.string :first_name
    t.string :last_name, :null => false
    t.string :title
    t.text :summary
    t.text :body
    t.column :slug, :citext
    t.integer :views
    t.integer :category_id
    t.string :blog_id
  end
end
