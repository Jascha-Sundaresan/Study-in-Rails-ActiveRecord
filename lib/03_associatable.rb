require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    self.class_name = options[:class_name] || name.to_s.camelcase
    self.primary_key = options[:primary_key] || :id

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    f_key_sym = "#{self_class_name.to_s.singularize.underscore}_id".to_sym
    self.foreign_key = options[:foreign_key] || f_key_sym
    self.class_name = options[:class_name] || name.to_s.singularize.camelcase
    self.primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)


    assoc_options[name] = options

    define_method "#{name}" do
      f_key = options.send(:foreign_key)
      model_class = options.model_class
      p_key = options.send(:primary_key)
      val = self.send(f_key)
      model_class.where(p_key => val).first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method "#{name}" do
      f_key = options.send(:foreign_key)
      model_class = options.model_class
      p_key = options.send(:primary_key)
      val = self.send(p_key)
      model_class.where(f_key => val)
    end

  end

  def assoc_options
    @ass_opts ||= {}
  end
end

class SQLObject
  extend Associatable
end
