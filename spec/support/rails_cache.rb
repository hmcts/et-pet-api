RSpec.configure do |c|
  c.before do
    Rails.cache.clear
  end
end
