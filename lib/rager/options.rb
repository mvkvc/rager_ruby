# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Options
    extend T::Sig
    extend T::Helpers
    requires_ancestor { T::Struct }
    interface!

    sig { abstract.returns(T::Hash[String, T.untyped]) }
    def serialize_safe
    end

    sig { abstract.void }
    def validate
    end
  end
end
