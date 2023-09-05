class BuildClaimEt1aPdfFileService
  include PdfBuilder::Base
  include PdfBuilder::MultiTemplate
  include PdfBuilder::Rendering
  include PdfBuilder::PreAllocation

  attr_reader :output_file

  def self.call(source, template_reference: 'et1-v3-en', time_zone: 'London', **)
    new(source, template_reference: template_reference, time_zone: time_zone).call
  end

  def call
    @output_file = render_to_file
    self
  end

  private

  def scrubber(text)
    text.gsub(/\s/, '_').gsub(/\W/, '').downcase
  end

  def pdf_fields
    result = {}
    apply_header(result)
    secondary_claimants = source.secondary_claimants[0..5].to_a
    6.times do |idx|
      apply_secondary_claimant(result, secondary_claimants[idx], idx)
    end
    result
  end

  def apply_header(result)
    apply_field result, source.primary_representative&.name || '', :multiple_claim_form, :represented_by
    apply_field result, [source.primary_claimant.first_name, source.primary_claimant.last_name].join(' '), :multiple_claim_form, :main_claim_name
  end

  def apply_secondary_claimant(result, claimant, idx)
    section = :"additional_claimant_#{idx + 1}"
    address = claimant&.address
    apply_field result, claimant&.title, :multiple_claim_form, section, :title
    apply_field result, claimant&.first_name, :multiple_claim_form, section, :first_name
    apply_field result, claimant&.last_name, :multiple_claim_form, section, :last_name
    apply_field result, address&.building, :multiple_claim_form, section, :building
    apply_field result, address&.street, :multiple_claim_form, section, :street
    apply_field result, address&.locality, :multiple_claim_form, section, :locality
    apply_field result, address&.county, :multiple_claim_form, section, :county
    apply_field result, format_post_code(address&.post_code, optional: claimant.nil?), :multiple_claim_form, section, :post_code
    apply_field result, claimant&.date_of_birth&.strftime('%d'), :multiple_claim_form, section, :dob_day
    apply_field result, claimant&.date_of_birth&.strftime('%m'), :multiple_claim_form, section, :dob_month
    apply_field result, claimant&.date_of_birth&.strftime('%Y'), :multiple_claim_form, section, :dob_year
  end

  def format_post_code(val, optional: false)
    return nil if val.nil? && optional

    match = val.match(/\A\s*(\S+)\s*(\d\w\w)\s*\z/)
    return val.slice(0, 7) unless match && match[1].length <= 4

    spaces = 4 - match[1].length
    val = "#{match[1]}#{' ' * spaces}#{match[2]}"
    val.slice(0, 7)
  end
end
