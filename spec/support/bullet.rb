RSpec.configure do |c|
  c.before(:suite) do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.raise = true
  end

  c.before do
    next unless Bullet.enable?

    Bullet.start_request
  end

  c.after do
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
  end
end
