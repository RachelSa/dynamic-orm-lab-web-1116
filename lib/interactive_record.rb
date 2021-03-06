require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord

 def self.table_name
   self.to_s.downcase.pluralize
 end

 def self.column_names
   DB[:conn].results_as_hash = true
   sql = "pragma table_info('#{table_name}')" #array of rows, where each row is a hash
   table_data = DB[:conn].execute(sql)

   table_data.collect {|row| row["name"]}.compact
 end

def initialize(options={})
 options.each do |key, value|
   self.send("#{key}=", value)
 end
end

 def save
   sql = <<-SQL
   INSERT INTO #{table_name_for_insert}
   (#{col_names_for_insert}) VALUES
   (#{values_for_insert})
   SQL

   DB[:conn].execute(sql)
   @id = DB[:conn].execute("SELECT last_insert_rowid()
     FROM '#{table_name_for_insert}'")[0][0]
 end

 def table_name_for_insert
     self.class.table_name
 end

 def col_names_for_insert
   self.class.column_names.reject {|el|el == "id"}.join(", ")
 end

 def values_for_insert
   values = []
   self.class.column_names.each do |column|
    values << "'#{send(column)}'" unless send(column).nil?
   end
   values.join(", ")
   #binding.pry
 end

 def self.find_by_name(name)
   sql = "SELECT * FROM #{table_name} WHERE name = ?"

   DB[:conn].execute(sql, name)
 end

 def self.find_by(hash)
   sql = "SELECT * FROM #{table_name} WHERE #{hash.keys[0].to_s} = '#{hash.values[0]}'"
   DB[:conn].execute(sql)
 end


end