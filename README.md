# Handle [![Build Status](https://secure.travis-ci.org/mbklein/handle.png)](http://travis-ci.org/mbklein/handle)

Classes and methods for dealing with [Handle System](http://handle.net/) servers and handles. 

## Platform Notes

`Handle::Connection` and `Handle::Persistence` have two implementations each – one for JRuby,
and one for everything else. Under JRuby, it calls Java HSAdapter methods directly. Under MRI 
or other non-JVM rubies, it shells out to command line tools (particularly `hdl-qresolver` 
and `hdl-genericbatch`) behind the scenes to do its work.

## Installation

Add this line to your application's Gemfile:

    gem 'handle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install handle

## Usage

```ruby
require 'handle'

# Set up an authenticated connection
conn = Handle::Connection.new('0.NA/admin.handle', 300, 
  '/path/to/private/key/file', 'privkey-passphrase')

# Create an empty record
record = conn.create_record('handle.prefix/new.handle')

# Two ways to add fields
record.add(:URL, 'http://example.edu/').index = 2
record.add(:Email, 'someone@example.edu').index = 6
record << Handle::Field::HSAdmin.new('0.NA/admin.handle')

# Manipulate permissions
record.last.perms.public_read = false

record.save

record = conn.resolve_handle('handle.prefix/new.handle')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
