# frozen_string_literal: true
require 'action_dispatch/http/upload'

# Imports API V1 XML data from the front end application
#
# It is expected that this is to be a short lived service - it will be replaced with
# a ClaimJsonImportService which does the same thing but with JSON input from the V2
# API.
# The JSON version will have to generate its own XML if it REALLY is needed to be exported
# to the final zip files.  At the time of writing, noone really knows.
#
# Note: The class length has upset the local rubo cops - but I have pleaded with them to let me have it this
# length as I don't want to split this XML import code up as it will end up being removed soon when we go to
# API V2
class ClaimXmlImportService # rubocop:disable Metrics/ClassLength
  attr_accessor :uploaded_files

  # Creates an instance of this service for use
  #
  # @param [String] data The XML data
  def initialize(data, file_builder_service: ClaimFileBuilderService)
    self.original_data = data
    self.data = Hash.from_xml(data)
    self.file_builder_service = file_builder_service
  end

  # Provides an array of hashes representing the files in the XML
  #
  # @return [Array<Hash>] An array of hashes like { filename: xxx, checksum: yyy }
  def files
    collection(root, 'Files').map do |node|
      { filename: node['Filename'], checksum: node['Checksum'] }
    end
  end

  # Performs the import
  #
  # @return [Claim] The imported claim
  # @param [Claim] into The claim to import the data into
  def import(into:)
    claim = into
    claim.attributes = converted_root_data.merge(converted_associated_data)
    generate_reference_for(claim) if claim.reference.blank?
    file_builder_service.new(claim).call
    rename_csv_file(claim: claim)
    rename_rtf_file(claim: claim)
    claim.save!
    claim
  end

  private

  def generate_reference_for(claim)
    resp = claim.respondents.first
    postcode_for_reference = resp.work_address.try(:post_code) || resp.address.try(:post_code)
    reference = ReferenceService.next_number
    office = OfficeService.lookup_postcode(postcode_for_reference)
    claim.reference = "#{office.code}#{reference}00"
  end

  def converted_root_data
    r = root
    {
      reference: r['FeeGroupReference'], submission_reference: r['SubmissionUrn'],
      claimant_count: r['CurrentQuantityOfClaimants'], submission_channel: r['SubmissionChannel'],
      case_type: r['CaseType'], jurisdiction: r['Jurisdiction'],
      office_code: r['OfficeCode'], date_of_receipt: r['DateOfReceiptEt'],
      administrator: r['Administrator'].to_i.positive?
    }
  end

  def converted_associated_data
    {
      secondary_claimants_attributes: converted_secondary_claimants_data,
      primary_claimant_attributes: converted_primary_claimant_data,
      respondents_attributes: converted_respondents_data,
      representatives_attributes: converted_representatives_data,
      uploaded_files_attributes: converted_files_data
    }
  end

  def converted_secondary_claimants_data
    collection(root, 'Claimants').reject { |c| c['GroupContact'] == 'true' }.map do |claimant|
      convert_claimant_data(claimant)
    end
  end

  def converted_primary_claimant_data
    claimant = collection(root, 'Claimants').detect { |c| c['GroupContact'] == 'true' }
    convert_claimant_data claimant
  end

  def convert_claimant_data(clm)
    {
      title: clm['Title'], first_name: clm['Forename'], last_name: clm['Surname'],
      address_attributes: convert_address_data(clm, 'Address'),
      address_telephone_number: clm['OfficeNumber'], mobile_number: clm['AltPhoneNumber'],
      email_address: clm['Email'], contact_preference: clm['PreferredContactMethod'],
      gender: clm['Sex'], date_of_birth: Date.parse(clm['DateOfBirth'])
    }
  end

  def convert_address_data(obj, root)
    {
      building: obj.dig(root, 'Line'), street: obj.dig(root, 'Street'),
      locality: obj.dig(root, 'Town'), county: obj.dig(root, 'County'),
      post_code: obj.dig(root, 'Postcode')
    }
  end

  def converted_respondents_data
    collection(root, 'Respondents').map do |r|
      {
        name: r['Name'], address_attributes: convert_address_data(r, 'Address'),
        work_address_attributes: convert_address_data(r, 'AltAddress'),
        work_address_telephone_number: r['OfficeNumber'], address_telephone_number: r['PhoneNumber'],
        alt_phone_number: r['AltPhoneNumber'], acas_number: r.dig('Acas', 'Number')
      }
    end
  end

  def converted_representatives_data
    collection(root, 'Representatives').map do |r|
      {
        name: r['Name'], organisation_name: r['Organisation'],
        address_attributes: convert_address_data(r, 'Address'), address_telephone_number: r['OfficeNumber'],
        mobile_number: r['AltPhoneNumber'], email_address: r['Email'],
        representative_type: r['Type'], dx_number: r['DXNumber']
      }
    end
  end

  def converted_files_data
    collection(root, 'Files').map do |f|
      filename = f['Filename']
      {
        filename: filename, checksum: f['Checksum'],
        file: uploaded_files.dig(filename, :file)
      }
    end
  end

  def rename_csv_file(claim:)
    file = claim.uploaded_files.detect { |f| f.filename.ends_with?('.csv') }
    return if file.nil?
    claimant = claim.primary_claimant
    file.filename = "et1a_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.csv"
  end

  def rename_rtf_file(claim:)
    file = claim.uploaded_files.detect { |f| f.filename.ends_with?('.rtf') }
    return if file.nil?
    claimant = claim.primary_claimant
    file.filename = "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.rtf"
  end

  def root
    data['ETFeesEntry']
  end

  def collection(root, collection_name)
    return [] if root[collection_name].nil?
    collection = root[collection_name][collection_name.singularize]
    collection = [collection] unless collection.is_a?(Array)
    collection
  end

  attr_accessor :data, :original_data, :file_builder_service
end
