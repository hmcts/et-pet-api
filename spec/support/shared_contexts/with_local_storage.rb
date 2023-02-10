shared_context 'with local storage' do
  before do
    Capybara.current_driver = :selenium
    Capybara.current_session
    capybara_url = URI.parse(Capybara.current_session.server_url)
    ActiveStorage::Current.url_options = { host: capybara_url.host, port: capybara_url.port }
  end
end
