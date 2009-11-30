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


require 'whois/answer/part'
require 'whois/answer'


module Whois
  class Server
    module Adapters

      #
      # = Abstract Base Server Adapter
      #
      # @abstract Override this class to implement a custom server adapter.
      #
      class Base

        # Default Whois request port.
        DEFAULT_WHOIS_PORT = 43

        attr_reader :type
        attr_reader :allocation
        attr_reader :host
        attr_reader :options
        attr_reader :buffer

        def initialize(type, allocation, host, options = {})
          @type       = type
          @allocation = allocation
          @host       = host
          @options    = options || {}
        end

        # Performs a Whois query for <tt>qstring</tt> 
        # using current server adapter and returns a <tt>Whois::Answer</tt>
        # instance with the result of the request.
        #
        #   server.query("google.com")
        #   # => Whois::Answer
        #
        # @param  [String] qstring the query string
        # @return [Whois::Answer] the answer returned by the WHOIS server(s) 
        #
        def query(qstring)
          with_buffer do |buffer|
            request(qstring)
            Answer.new(self, buffer)
          end
        end

        # Handles the WHOIS request.
        #
        # @abstract This method should implement the logic that sends
        #   the socket request with the WHOIS query and appends
        #   all the responses to the answer stack.
        # @param  [String] qstring the query string
        #
        def request(qstring)
          raise NotImplementedError
        end


        protected

          def with_buffer(&block)
            @buffer = []
            result = yield(@buffer)
            # @buffer = []
            # result
          end
          
          # Store an answer part in <tt>@buffer</tt>.
          def append_to_buffer(response, host)
            @buffer << ::Whois::Answer::Part.new(response, host)
          end

          def query_the_socket(qstring, host, port = nil)
            ask_the_socket(qstring, host, port || options[:port] || DEFAULT_WHOIS_PORT)
          end

        private

          def ask_the_socket(qstring, host, port)
            client = TCPSocket.open(host, port)
            client.write("#{qstring}\r\n")  # I could use put(foo) and forget the \n
            client.read                     # but write/read is more symmetric than puts/read
          ensure                            # and I really want to use read instead of gets.
            client.close if client          # If != client something went wrong.
          end
        
      end
      
    end
  end
end