require 'active_record'

ActiveRecord::Base.establish_connection({
  :database => ":memory:",
  :adapter  => 'sqlite3',
  :timeout  => 500
})

ActiveRecord::Schema.define do
end

ActiveRecord::Migrator.migrate('db/migrate')
