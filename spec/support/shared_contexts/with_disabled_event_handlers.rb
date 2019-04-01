shared_context 'with disabled event handlers' do
  around do |example|
    EventService.instance.ignoring_events do
      example.run
    end
  end
end
