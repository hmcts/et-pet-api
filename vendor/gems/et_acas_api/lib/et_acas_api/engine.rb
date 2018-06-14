module EtAcasApi
  class Engine < ::Rails::Engine
    isolate_namespace EtAcasApi
    #config.generators.api_only = true
    config.generators do |g|
      g.api_only = true
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
    end
    config.et_acas_api = ::Rails::Application::Configuration::Custom.new
  end
end
