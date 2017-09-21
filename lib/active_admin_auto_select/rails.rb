module Autoselect
  module Rails
    class Engine < ::Rails::Engine
      require 'select2-rails'
      require 'underscore-rails'
    end
  end
end
