shared_context 'with local storage' do
  before do
    Capybara.current_driver = :selenium
    Capybara.current_session
    # FileUtils.remove_dir "#{ActiveStorage::Blob.services.fetch(:test).root}", true
    # FileUtils.remove_dir "#{ActiveStorage::Blob.services.fetch(:test_direct_upload).root}", true

    prepare_local_active_storage
  end

  def prepare_local_active_storage
    capybara_url = URI.parse(Capybara.current_session.server_url)
    ActiveStorage::Current.url_options = { host: capybara_url.host, port: capybara_url.port }
  end
end
