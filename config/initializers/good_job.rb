GoodJob.configure_active_record do
  connects_to database: { writing: :queue }
end
