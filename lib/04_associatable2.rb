require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method "#{name}" do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      source_table = source_options.model_class.table_name
      through_table = through_options.model_class.table_name
      source_f_key = source_options.foreign_key.to_s
      through_p_key = through_options.primary_key.to_s
      through_f_key = through_options.foreign_key.to_s
      select_str = "#{source_table}.*"
      from_str = "#{through_table}"
      join_str = "#{source_table} ON #{through_table}.#{source_f_key} = #{source_table}.#{through_p_key}"
      where_str = "#{through_table}.#{through_p_key} = ?"
      result = DBConnection.execute(<<-SQL, self.send(through_f_key.to_sym))
      SELECT
        #{select_str}
      FROM
        #{from_str}
      JOIN
        #{join_str}
      WHERE
        #{where_str}
      SQL

      source_options.model_class.parse_all(result).first


    end
  end
end

