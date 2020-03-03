class BuildFeedbackCommand < BaseCommand
  attribute :problems, :string
  attribute :suggestions, :string
  attribute :email_address, :string

  def apply(root_object, **_args)
    root_object.merge!(attributes)
    EventService.publish('FeedbackCreated', root_object)
  end
end
