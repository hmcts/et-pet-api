class Command < ApplicationRecord
  belongs_to :root_object, polymorphic: true, optional: true, autosave: false, inverse_of: false

  default_scope { order(created_at: :asc) }
end
