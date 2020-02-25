
require 'yaml'
require 'set'

class FixedRecord
  VERSION = "0.3.0"

  # Lazy load data from given filename 
  # creating accessors for top level attributes
  def self.data( filename, required: [], optional: [] ) 
    required = required.map( &:to_s )
    optional = optional.map( &:to_s )
    throw ArgumentError, "Required and Optional names overlap" unless (required & optional).empty?

    valid_keys = Set.new( required )
    valid_keys.merge( optional )
    required_keys = Set.new( required )

    self.class_variable_set( :@@filename, filename )
    self.class_variable_set( :@@required_keys, required_keys )
    self.class_variable_set( :@@valid_keys, valid_keys )
    self.class_variable_set( :@@items, nil )

    class_eval %Q{
      class << self
        include Enumerable
      end

      def self.filename
        @@filename
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
          validate_structure( y )
          if y.is_a?(Array)
            if @@valid_keys.empty?
              @@valid_keys = y.first.keys
              @@required_keys = @@valid_keys
            end
            @@items = y.map.with_index do |values,i|
              validate_item( @@valid_keys, @@required_keys, values, i )
              r = new
              r.instance_variable_set( :@values, values )
              r
            end
          elsif y.is_a?(Hash)
            @@items = Hash.new
            add_key = !@@valid_keys.member?('key')
            y.each do |k,values|
              if @@valid_keys.empty?
                @@required_keys.merge( values.keys )
                @@valid_keys.merge( values.keys )
                add_key = !@@valid_keys.member?('key')
              end
              validate_item( @@valid_keys, @@required_keys, values, k )
              values['key'] = k if add_key
              r = new
              r.instance_variable_set( :@values, values )
              @@items[k] = r   
            end
            define_method( :key ) { @values['key'] }  if add_key
          end
          create_methods( @@valid_keys  )
        end
      end
    }
  end


  # Override this to perform additional entries. It gets passed the hash containing the
  # values for each record. index is either a record index (0 based) or a key associated
  # with the record
  def self.validate( values, index )
  end

private

  # Create access methods for each of valid_keys
  def self.create_methods( valid_keys )
    valid_keys.each do |key|
      define_method( key.to_sym) { @values[key] }
    end
  end

  # Validate the top level of the data structure returned 
  def self.validate_structure( y )
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
  def self.validate_item( valid_keys, required_keys, values, index )
    raise ArgumentError, "#{filename} item #{index} should be name value pairs" unless values.is_a?(Hash)
    required_keys.each do |name|
        raise ArgumentError, "#{filename} item #{index}  is missing value for '#{name}'" unless values.has_key?(name)
    end
    values.keys.each do |v|
      raise ArgumentError, "#{filename} item #{index} has unexpected value for '#{name}'" unless valid_keys.include?(v) 
    end
    # User can implement this to add extra validation
    validate( values, index )
  end



end
