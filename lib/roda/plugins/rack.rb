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


      module RequestMethods

 #       def initialize(scope, request)
 #         super(scope)
 #         @rack_request = request
 #       end

      end
    end

    register_plugin(:rack, Rack)
  end
end
