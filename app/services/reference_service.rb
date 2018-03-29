module ReferenceService
  def self.next_number
    ::UniqueReference.create.id
  end
end