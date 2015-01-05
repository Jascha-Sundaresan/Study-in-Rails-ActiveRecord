require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns
      @columns
    else
      @columns = DBConnection.execute2(<<-SQL).first
      SELECT *
      FROM #{table_name}
      LIMIT 0
      SQL
      @columns.map! { |column| column.to_sym }
    end
  end

  def self.finalize!
    columns.each do |column|
      define_method "#{column}" do
        attributes[column]
      end
      define_method "#{column}=" do |obj|
        attributes[column] = obj
      end
    end
  end

  def self.table_name=(table_name)
    instance_variable_set("@#{self}", table_name)
  end

  def self.table_name
    instance_variable_get("@#{self}") || self.to_s.tableize
  end

  def self.all
    name = self.table_name
    hashes = DBConnection.execute(<<-SQL)
    SELECT #{name}.*
    FROM #{name}
    SQL
    parse_all(hashes)
  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    name = self.table_name
    hash = DBConnection.execute(<<-SQL, id)
    SELECT #{name}.*
    FROM #{name}
    WHERE #{name}.id = ?
    LIMIT 1
    SQL
    parse_all(hash).first
  end

  def initialize(params = {})
    params.each do |attr_name, attr_value|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless 
                                       self.class.columns.include?(attr_name)
      setter = "#{attr_name}=".to_sym
      self.send(setter, attr_value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      self.send(col)
    end
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = Array.new(self.class.columns.length, "?").join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO 
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    SQL

    self.id = DBConnection.instance.last_insert_row_id
  end

  def update
    set_string = self.class.columns.map { |c| "#{c} = ?" }.join(", ")
    p attribute_values
    DBConnection.execute(<<-SQL, *attribute_values, attribute_values[0])
    UPDATE
      #{self.class.table_name}
    SET
      #{set_string}
    WHERE
      id = ?
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
