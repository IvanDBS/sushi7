require 'sqlite3'
require 'pg'
require 'active_record'
require 'dotenv/load'

# SQLite connection
sqlite_db = SQLite3::Database.new('db/sushi_bot.sqlite3')
sqlite_db.results_as_hash = true

# PostgreSQL connection
ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: ENV.fetch('POSTGRES_HOST', 'localhost'),
  database: ENV.fetch('POSTGRES_DATABASE', 'sushi7_development'),
  username: ENV.fetch('POSTGRES_USER', 'postgres'),
  password: ENV.fetch('POSTGRES_PASSWORD', '')
)

# Reset PostgreSQL sequences
def reset_sequence(table_name)
  ActiveRecord::Base.connection.execute("SELECT setval(pg_get_serial_sequence('#{table_name}', 'id'), COALESCE((SELECT MAX(id) FROM #{table_name}), 0) + 1, false)")
end

# Migrate data for a table
def migrate_table(sqlite_db, table_name)
  puts "Migrating #{table_name}..."
  rows = sqlite_db.execute("SELECT * FROM #{table_name}")
  
  rows.each do |row|
    next if row.nil? || (row.is_a?(Hash) && row.key?('name') && row['name'] == 'sqlite_sequence')
    
    # Convert row to hash if it's not already
    row = row.transform_keys(&:to_s) if row.is_a?(Hash)
    
    # Remove nil values and sqlite-specific fields
    row.reject! { |k, v| v.nil? || k == 'sql' }
    
    # Create insert query
    columns = row.keys.join(', ')
    values = row.values.map { |v| ActiveRecord::Base.connection.quote(v) }.join(', ')
    
    begin
      ActiveRecord::Base.connection.execute(
        "INSERT INTO #{table_name} (#{columns}) VALUES (#{values})"
      )
    rescue => e
      puts "Error inserting into #{table_name}: #{e.message}"
    end
  end
  
  reset_sequence(table_name)
end

# Clear existing data
tables = ['order_items', 'orders', 'users', 'products', 'categories']
tables.each do |table|
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE")
end

# Migrate data in correct order
migrate_table(sqlite_db, 'categories')
migrate_table(sqlite_db, 'products')
migrate_table(sqlite_db, 'users')
migrate_table(sqlite_db, 'orders')
migrate_table(sqlite_db, 'order_items')

puts "Migration completed!" 