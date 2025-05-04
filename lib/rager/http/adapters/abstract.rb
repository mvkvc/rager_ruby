# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Http
    module Adapters
      class Abstract
        extend T::Sig
        extend T::Helpers
        abstract!

        sig { abstract.params(request: Rager::Http::Request).returns(Rager::Http::Response) }
        def make_request(request)
        end
      end
    end
  end
end
