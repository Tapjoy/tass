module Tapjoy
  module AutoscalingBootstrap
    module Version
      MAJOR = 1
      MINOR = 0
      PATCH = 4
    end

    VERSION = [Version::MAJOR, Version::MINOR, Version::PATCH].join('.')
  end
end
