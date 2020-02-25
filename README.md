# FixedRecord

FixedRecord provides ActiveRecord-like read-only access to a set of records
described in a YAML file.

Why is this useful? Occasionally you have tabular data which hardly ever
changes and can easily be edited by hand. Although this data could be placed in a database, it may not be worth the overhead involved (loading a database, maintaining database code, etc.). 

It may be quicker and simpler to implement this as an array or hash of objects in a YAML file, and use this gem to provide access to the data. 

See the Usage section below.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fixed_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fixed_record

## Usage

### Array of Records

Create a YAML file defining an array of records like this:

```yaml
-
    name: Risky Thinking
    url: https://www.riskythinking.com/
-
    name: Krebs on Security
    url: https://krebsonsecurity.com/

```

Then to load these, create a class

```ruby
require 'fixed_record'

class MyFavoriteWebsite < FixedRecord
    data "#{Rails.root}/data/my_favorite_websites.yml", required: [:name, :url]

  # Return hostname of url for company
  def hostname
    URI.parse(url).host
  end

end
```
The collection can then be enumerated as required:

```ruby
MyFavoriteWebsite.each do |w| 
    puts w.name
    puts w.hostname
end
```
Or can be accessed as an array:

```ruby
MyFavoriteWebsite.all.is_a?(Array)  # true
```
A count of the number of records is available:

```ruby
puts MyFavoriteWebsite.count
```

The declared class will also include all the methods from the `Enumerable` module.

### Hash of Records

Create a YAML file `my_web_pages.yml` defining a hash of records like this:

```yaml
StaticPage#first:
  title: First Page
  description: Welcome to the First Page

StaticPage#last:
  title: Last Page
  short_title: LastP 
  description: Welcome to the Last Page

```

Then to load these, create a class

```ruby
require 'fixed_record'

class MyWebPages < FixedRecord
    data "#{Rails.root}/data/my_web_pages.yml", required: [:title,:description], optional: [:short_title]

end
```

The collection can be accessed by index:

```ruby
MyWebPages['StaticPage#first'].title # First Page
MyWebPages['StaticPage#last'].description # Welcome to he Last page
MyWebPages['StaticPage#first'].key # StaticPage#fifst
```

The collection can then be enumerated as required:

```ruby
MyWebPages.each do |k,v| 
    puts k
    puts v.title
end
```
Or can be accessed as an hash:

```ruby
MyWebPages.all.is_a?(Hash)  # true
```
A count of the number of records is available:

```ruby
puts MyWebPages.count
```

The declared class will also include all the methods from the `Enumerable` module.



## Error Checking

Some basic sanity checks are performed on the YAML file to catch common errors:

* It must define a non-empty array or hash of records
* If the optional `required:` or `optional:` arguments are given, then each record _must_ have all the required fields and _may_ also have any of the optional fields. 
* If niether the `required:` or `optional:` arguments are given, then each record _must_ have the same set of fields.

An `ArgumentError` exception will be thrown if any validation errors are detected. A system-dependent error (probably `Errno::ENOENT`) will be thrown if the file cannot be read. 

Additional validations can be performed by defining a `validate` method. e.g.

```ruby
require 'fixed_record'
require 'uri'

class MyFavoriteWebsite < FixedRecord
    data "#{Rails.root}/data/my_favorite_websites.yml", required: [:name, :url]

  # Check that the url can be parsed
  def validate( values, index )
    begin
      URI.parse(url)
    rescue URI::InvalidURIError -> e
      raise e.class, "#{filename} index #{index} has invalid url: #{e.message}"
    end
  end

end
```






## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `fixed_record.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/m-z-b/fixed_record.
