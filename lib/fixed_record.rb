
require 'yaml'

class FixedRecord
  VERSION = "0.2.0"

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
        all.length
      end

      def self.[]( k )
        if all.is_a?(Hash)
          all[k]
        else
          nil
        end
      end

      def self.has_key?( k )
        if all.is_a?(Hash)
          all.has_key?( k )
        else
          false
        end
      end 

      def self.load!
        if @@items.nil?
          y = YAML.load_file( filename )
          validate_yaml( y )
          valid_keys = nil
          if y.is_a?(Array)
            valid_keys = y.first.keys
            @@items = y.map.with_index do |values,i|
              validate_item( valid_keys, values, i )
              r = new
              r.instance_variable_set( :@values, values )
              r
            end
          elsif y.is_a?(Hash)
            @@items = Hash.new
            add_key = true
            y.each do |k,values|
              if valid_keys.nil?
                valid_keys = values.keys
                add_key = !values.has_key?('key')
              end
              validate_item( valid_keys, values, k )
              values['key'] = k if add_key
              r = new
              r.instance_variable_set( :@values, values )
              @@items[k] = r   
            end
            valid_keys << 'key' if add_key
          end
          create_methods( valid_keys )
        end
      end
    }
  end

  # Create access methods for each of valid_keys
  def self.create_methods( valid_keys )
    valid_keys.each do |k|
      define_method( k.to_sym) { @values[k] }
    end
  end

  # Validate the top level of the data structure returned 
  def self.validate_yaml( y )
    if y.is_a?(Array)
      if y.length <= 0
        throw ArgumentError.new "#{filename} contain a zero length array"
      end
      if y.any?{ |i| !i.is_a?(Hash)}
        throw ArgumentError.new "#{filename} does not contain an array of items (hashes)"
      end
    elsif y.is_a?(Hash)
      if y.count <= 0
         throw ArgumentError.new "#{filename} contain an empty hash"
      end
      if y.any?{ |k,v| !v.is_a?(Hash) }
        throw ArgumentError.new "#{filename} does not contain an array of items (hashes)"
      end
    else
      throw ArgumentError.new "#{filename} does not contain a hash of items or an array of items"
    end

  end

  # Validate a values of name -> value
  def self.validate_item( valid_keys, values, index )
    raise ArgumentError, "#{filename} item #{index} should be name value pairs" unless values.is_a?(Hash)
    raise ArgumentError, "#{filename} item #{index} has wrong number of values" if valid_keys.length != values.length
    valid_keys.each do |name|
      unless values.has_key? name
        raise ArgumentError, "#{filename} item #{index}  is missing value for '#{name}'" 
      end
    end
  end



end
