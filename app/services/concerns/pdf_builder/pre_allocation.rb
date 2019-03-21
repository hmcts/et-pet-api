module PdfBuilder
  # This concern provides the abilty to receive a pre allocated key
  # which is used by the system so that the API can respond immediately with where the pdf file WILL be
  # but then generate the pdf in the background.
  #
  # Front end javascript can then keep re checking this url to see when it is present.
  module PreAllocation
    extend ActiveSupport::Concern

    private

    def pre_allocated_key(filename)
      source.pre_allocated_file_keys.where(filename: filename).first.try(:key)
    end
  end
end
