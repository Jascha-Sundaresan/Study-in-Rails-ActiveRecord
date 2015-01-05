require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
  	where_arr = []
  	values = []
  	params.each do |key, value|
  		where_arr << "#{key} = ?"
  		values << value
  	end
  	where_str = where_arr.join(" AND ")
  results = DBConnection.execute(<<-SQL, *values)
  SELECT
    *
  FROM
    #{self.table_name}
  WHERE
    #{where_str}
  SQL

  parse_all(results)

  end
end

class SQLObject
  extend Searchable
end
