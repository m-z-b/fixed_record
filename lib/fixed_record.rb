
require 'yaml'
require 'psych'
require 'set'

# Provides error-checked simplified access to a YAML data file
class FixedRecord
  VERSION = "0.6.1"

  # Lazy load data from given filename 
  # creating accessors for top level attributes
  def self.data( filename, required: [], optional: [], singleton: false ) 
    required = required.map( &:to_s )
    optional = optional.map( &:to_s )
    throw ArgumentError, "Required and Optional names overlap" unless (required & optional).empty?

    # Although not necessary, the class_eval makes it easier to see 
    # we are defining variables and methods in the context of the child class which
    # called us
    class_eval do
      # Use @x names for class variables to simplify / restrict access
      @filename = filename
      @valid_keys = Set.new( required )
      @valid_keys.merge( optional )
      @required_keys = Set.new( required )
      @singleton = singleton

      # Load the data and create the methods...
      def self.load!
        return unless @items.nil?
        begin
          y = YAML.load_file( @filename )
        rescue Errno::ENOENT
          raise 
        rescue Psych::SyntaxError => error
          fname = File.basename(@filename)
          msg = error.message
          if msg.include? @filename
            msg.sub!( @filename, fname )
            msg = "#{error.class.name} #{msg}"
          else
            msg = "#{error.class.name} #{fname} #{error.message}"
          end
          raise ArgumentError, msg
        end

        validate_structure( y, @singleton, @filename )

        if @valid_keys.empty? 
          # Grab keys from file
          if @singleton
            @valid_keys = y.keys
          elsif y.is_a?(Array)
            @valid_keys = y.first.keys
            @required_keys = @valid_keys       
          elsif y.is_a?(Hash)
            @valid_keys = y[y.keys.first].keys
            @required_keys = @valid_keys
          end
        end

        if @singleton
          @items = y
        elsif y.is_a?(Array)
          @items = y.map.with_index do |values,i|
            validate_item( @valid_keys, @required_keys, values, i )
            r = new
            r.instance_variable_set( :@values, values )
            r
          end
        elsif y.is_a?(Hash)
          @items = Hash.new
          add_key = !@valid_keys.member?('key')
          y.each do |k,values|
            validate_item( @valid_keys, @required_keys, values, k )
            values['key'] = k if add_key
            r = new
            r.instance_variable_set( :@values, values )
            @items[k] = r   
          end
          define_method( :key ) { @values['key'] }  if add_key
        end
        create_methods( @valid_keys  )
      end

      # filename data was loaded from
      def self.filename
        @filename
      end

      # valid keys (as strings)
      def self.valid_names
        load!
        @valid_keys
      end
    end # class_eval

    if singleton 
      class_eval do # class methods for singleton object
        def self.[](k)
          load!
          k = k.to_s
          raise ArgumentError, "#{k} is not a valid key" unless @valid_keys.member?(k)
          @items[k]
        end
      end # class_eval
    else
      # Add methods for Coillection based objects
      class << self
        include Enumerable
      end
      class_eval do
        def self.all
          load!
          @items
        end

        def self.each( &block )
          all.each(&block)
        end

        def self.size
          all.size
        end

        def self.[]( k )
          if all.is_a?(Hash)
            all[k.to_s]
          else
            nil # Arguably we could index the array, but if we did your code would smell...
          end
        end

        def self.has_item_key?( k )
          if all.is_a?(Hash)
            all.has_key?( k )
          else
            false
          end
        end 
      end #class_eval
    
      # Only way I can find to alias class methods...
      class << self
        alias length size
        alias count size
      end

    end

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
    # Test if a value is defined (could be nil) for a name
    define_method( :present? ) { |name| @values.key?(name.to_s)}
  end



  # Validate the top level of the data structure returned 
  # Validate the top level of the data structure returned 
  def self.validate_structure( y, singleton, filename )
    if singleton
      if !y.is_a?(Hash)
        raise ArgumentError, "#{filename} does not contain a hash of values or an array of items"
      end
    else
      if y.is_a?(Array)
        if y.length <= 0
          raise ArgumentError, "#{filename} contain a zero length array"
        end
        if y.any?{ |i| !i.is_a?(Hash)}
          raise ArgumentError, "#{filename} does not contain an array of items (hashes)"
        end
      elsif y.is_a?(Hash)
        if y.count <= 0
           raise ArgumentError, "#{filename} contain an empty hash"
        end
        if y.any?{ |k,v| !v.is_a?(Hash) }
          raise ArgumentError, "#{filename} does not contain an array of items (hashes)"
        end
      else
        raise ArgumentError, "#{filename} does not contain a hash of items or an array of items"
      end
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
