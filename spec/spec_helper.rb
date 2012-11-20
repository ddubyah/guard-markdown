require 'guard/markdown'
RSpec.configure do |config|
  config.color_enabled = true

  config.before(:each) do
    ENV["GUARD_ENV"] = 'test'
  end
end
