#
# = Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
#
# Category::    Net
# Package::     Whois
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


require 'ostruct'


#
# = SuperStruct
#
# SuperStruct is an enhanced version of the Ruby Standar library <tt>Struct</tt>.
#
# Compared with the original version, it provides the following additional features:
# * ability to initialize an instance from Hash
# * ability to pass a block on creation  
#
class SuperStruct < Struct

  # Overwrites the standard Struct initializer
  # to add the ability to create an instance from a Hash of parameters.
  #
  # If block is given, yields self.
  #
  #   attributes = { :foo => 1, :bar => "baz" }
  #   Struct.new(attributes)
  #   # => #<Struct foo=1, bar="baz">
  #
  # @overload initialize(value, value, ...)
  #   Initializes a new instance setting each Struct key to the value
  #   passed in the same order in the argument list.
  #   @param [Object] value describe value param
  # @overload initialize(attributes)
  #   Initializes a new instance from the key-value Hash.
  #   @param [Hash<Symbol => Object>] attributes
  # @return [SuperStruct]
  # @yield  [self] a block to perform any extra initialization on the object
  # @yieldparam [Client] self the newly initialized client object
  #
  def initialize(*args, &block)
    if args.first.is_a? Hash
      initialize_with_hash(args.first)
    else
      super
    end
    yield(self) if block_given?
  end

  private

    def initialize_with_hash(attributes = {})
      attributes.each do |key, value|
        self[key] = value
      end
    end
  
end