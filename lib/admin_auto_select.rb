require "admin_auto_select/version"

module AdminAutoSelect
  module ActiveAdmin
    def admin_auto_select(field)
      puts "I am auto selecting this #{field}"
    end
  end
end
