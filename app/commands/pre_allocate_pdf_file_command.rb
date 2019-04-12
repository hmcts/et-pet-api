class PreAllocatePdfFileCommand < BaseCommand
  def initialize(*args, allocator_service: UploadedFileAllocatorService.new, **kw_args)
    super(*args, **kw_args)
    self.allocator_service = allocator_service
  end

  def apply(root_object, meta: {})
    allocate_pdf_file(root_object)
    meta.merge! pdf_url: allocator_service.allocated_url
  end

  private

  attr_accessor :allocator_service

  def allocate_pdf_file(root_object)
    primary_claimant = root_object.primary_claimant
    filename = "et1_#{scrubber(primary_claimant.first_name)}_#{scrubber(primary_claimant.last_name)}.pdf"
    allocator_service.allocate(filename, into: root_object)
  end

  def scrubber(text)
    text.gsub(/\s/, '_').gsub(/\W/, '').downcase
  end
end
