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
      end

      module RequestMethods
       extend Forwardable

       def_delegators :@__request, :path, :get?, :post?, :delete?, :head?,
                      :options?, :link?, :patch?, :put?, :trace?, :unlink?, :path,
                      :path_info, :path_info=, :script_name, :script_name=,
                      :host_with_port, :params, :[], :content_type, :user_agent, :host,
                      :get_header, :ssl?, :scheme, :port, :logger, :referrer

       def version
         env["HTTP_VERSION"]
       end

       def verb
         @__request.request_method
       end

       def accept
         @__request.get_header("HTTP_ACCEPT")
       end

       def accepts?(mimetype)
         accept.to_s.split(',').any?{|s| s.strip == mimetype}
       end

        # The session for the current request.  Raises a RodaError if
        # a session handler has not been loaded.
       def session
         env[::Rack::RACK_SESSION] || raise(RodaError, "You're missing a session handler. You can get started by adding use Rack::Session::Cookie")
       end

       def env
         @__request.env
       end

      end
    end

    register_plugin(:rack, Rack)
  end
end
