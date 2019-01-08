Capybara.add_selector :response_email_label do
  xpath do |locator, options|
    locale = options.delete(:locale)
    translated = EtApi::Test::Messaging.instance.translate(locator, locale: locale)
    XPath.generate { |x| x.descendant(:p)[x.string.n.starts_with(translated)] }
  end
end
