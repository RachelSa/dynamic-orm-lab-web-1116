require_relative "../config/environment.rb"
require 'active_support/inflector'

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
    self.col_names.map do |column|
     "'#{self.send(column)}'"  unless self.send(column).nil?
    end.join(", ")
  end

  
end