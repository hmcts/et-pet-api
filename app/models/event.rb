class Event < ApplicationRecord
  belongs_to :attached_to, polymorphic: true
  enum name: {
    confirmation_email_sent: 'ConfirmationEmailSent'
  }
end
