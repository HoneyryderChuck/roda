# frozen-string-literal: true

class Roda
  module RodaPlugins

    module Rack

      module ClassMethods
      
        private

        # Build the rack app to use
        def build_rack_app
          if block = @route_block
            builder = ::Rack::Builder.new
            @middleware.each{|a, b| builder.use(*a, &b)}
            builder.run lambda{|env| new(env).call(&block)}
            @app = builder.to_app
          end
        end
      end

      module InstanceMethods
        def initialize(env)
          klass = self.class
          rack_request = ::Rack::Request.new(env)
          super(rack_request)
        end


        # The environment hash for the current request. Example:
        #
        #   env['REQUEST_METHOD'] # => 'GET'
        def env
          @_request.env
        end

      end

      module RequestMethods
       extend Forwardable
       SCRIPT_NAME = "SCRIPT_NAME".freeze
       PATH_INFO = "PATH_INFO".freeze
       SESSION_KEY = 'rack.session'.freeze
       HTTP_IF_NONE_MATCH = 'HTTP_IF_NONE_MATCH'.freeze
       HTTP_IF_MATCH = 'HTTP_IF_MATCH'.freeze
       HTTP_IF_MODIFIED_SINCE = 'HTTP_IF_MODIFIED_SINCE'.freeze
       HTTP_IF_UNMODIFIED_SINCE = 'HTTP_IF_UNMODIFIED_SINCE'.freeze

       def_delegators :@_request, :path, :get?, :post?, :delete?, :head?,
                      :options?, :link?, :patch?, :put?, :trace?, :unlink?, :path,
                      :path_info, :path_info=, :script_name, :script_name=,
                      :host_with_port, :content_type, :user_agent, :host,
                      :get_header, :ssl?, :scheme, :port, :logger, :referrer, :body,
                      :accept_encoding

        # This an an optimized version of Rack::Request#path.
        #
        #   r.env['SCRIPT_NAME'] = '/foo'
        #   r.env['PATH_INFO'] = '/bar'
        #   r.path
        #   # => '/foo/bar'
        def path
          e = env
          "#{e[SCRIPT_NAME]}#{e[PATH_INFO]}"
        end


       def version
         env["HTTP_VERSION"]
       end

       def verb
         @_request.request_method
       end

       def accept
         @_request.get_header("HTTP_ACCEPT")
       end

       def accepts?(mimetype)
         accept.to_s.split(',').any?{|s| s.strip == mimetype}
       end

       def params
         @params ||= begin
           @_request.GET.merge(post_params)
         rescue EOFError
           self.GET.dup
         end
       end

       def [](k)
         # TODO: this was being redirected to rack request, but this method is deprecated
         params[k.to_s]
       end

        # The session for the current request.  Raises a RodaError if
        # a session handler has not been loaded.
       def session
         env[SESSION_KEY] || raise(RodaError, "You're missing a session handler. You can get started by adding use Rack::Session::Cookie")
       end

       def env
         @_request.env
       end


       def post_params
         @_request.POST
       end

       # CACHE HELPERS

       # this name sucks, but roda already defines a name like that(??)
       # TODO: rename the roda name, as it's private API and it could be done?
       def if_matchh
         get_header(HTTP_IF_MATCH)
       end

       def if_none_match
         get_header(HTTP_IF_NONE_MATCH)
       end

       def modified_since
         get_header(HTTP_IF_MODIFIED_SINCE)
       end

       def unmodified_since
         get_header(HTTP_IF_UNMODIFIED_SINCE)
       end
      end
    end

    register_plugin(:rack, Rack)
  end
end
