
require 'yaml'

class FixedRecord
  VERSION = "0.1.2"

  # Lazy load data from given filename 
  # creating accessors for top level attributes
  def self.data( filename ) 
    class_eval %Q{
      class << self
        include Enumerable
      end

      @@items = nil

      def self.filename
        %Q{#{filename}}
      end

      def self.all 
        load!
        @@items
      end

      def self.each( &block )
        all.each(&block)
      end

      def self.count
        all.count
      end

      def self.load!
        if @@items.nil?
          y = YAML.load_file( filename )
          validate_yaml( y )
          valid_keys = y.first.keys
          valid_keys.each do |k|
            define_method( k.to_sym) { @values[k] }
          end

          @@items = y.map.with_index do |values,i|
            validate_item( valid_keys, values, i )
            r = new
            r.instance_variable_set( :@values, values )
            r
          end
        end
      end
    }
  end

  # Validate the top level of the data structure returned 
  def self.validate_yaml( y )
    unless y.is_a?(Array) && y.length > 0
      throw ArgumentError.new "#{filename} does not contain an array of items"
    end
  end

  # Validate a hash of name -> value
  def self.validate_item( keys, hash, index )
    raise ArgumentError, "#{filename} item #{index+1} should be name value pairs" unless hash.is_a?(Hash)
    raise ArgumentError, "#{filename} item #{index+1} has wrong number of values" if keys.count != hash.count
    keys.each do |name|
      unless hash.has_key? name
        raise ArgumentError, "#{filename} item #{index+1}  is missing value for '#{name}'" 
      end
    end
  end



end
