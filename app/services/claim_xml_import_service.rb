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
  REPRESENTATIVE_TYPE_MAPPINGS = {
    'CAB' => 'citizen_advice_bureau', 'FRU' => 'free_representation_unit',
    'Law Centre' => 'law_centre', 'Union' => 'trade_union',
    'Solicitor' => 'solicitor', 'Private Individual' => 'private_individual',
    'Trade Association' => 'trade_association', 'Other' => 'other'
  }.freeze
  private_constant :REPRESENTATIVE_TYPE_MAPPINGS

  attr_accessor :uploaded_files

  # Creates an instance of this service for use
  #
  # @param [String] data The XML data
  def initialize(data)
    self.original_data = data
    self.data = Hash.from_xml(data)
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
  def import
    claim = Claim.new(converted_root_data.merge(converted_associated_data))
    add_file :text_file, to: claim
    add_file :claimants_text_file, to: claim if claim.claimants.length > 1
    claim.save!
    claim
  end

  private

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
      claimants_attributes: converted_claimants_data,
      respondents_attributes: converted_respondents_data,
      representatives_attributes: converted_representatives_data,
      uploaded_files_attributes: converted_files_data
    }
  end

  def converted_claimants_data
    collection(root, 'Claimants').map do |claimant|
      convert_claimant_data(claimant)
    end
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
        representative_type: convert_representative_type(r['Type']), dx_number: r['DXNumber']
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
    end + [file_for_data]
  end

  def convert_representative_type(rep_type)
    REPRESENTATIVE_TYPE_MAPPINGS[rep_type]
  end

  def root
    data['ETFeesEntry']
  end

  def collection(root, collection_name)
    collection = root[collection_name][collection_name.singularize]
    collection = [collection] unless collection.is_a?(Array)
    collection
  end

  def file_for_data
    claimant = converted_claimants_data.first
    filename = "et1_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.xml"
    {
      filename: filename,
      file: raw_file_for_data(filename)
    }
  end

  def raw_file_for_data(filename)
    tempfile = Tempfile.new.tap do |file|
      file.write original_data
      file.rewind
    end
    ActionDispatch::Http::UploadedFile.new filename: filename, tempfile: tempfile, type: 'text/xml'
  end

  def text_file(claim)
    claimant = claim.claimants.first
    filename = "et1_#{claimant.first_name.tr(' ', '_')}_#{claimant.last_name}.txt"
    {
      filename: filename,
      file: raw_text_file(filename, claim: claim)
    }
  end

  def raw_text_file(filename, claim:)
    tempfile = Tempfile.new.tap do |file|
      file.write ApplicationController.render "api/v1/claims/export.txt.erb", locals: {
        claim: claim, primary_claimant: claim.claimants.first,
        primary_respondent: claim.respondents.first,
        primary_representative: claim.representatives.first,
        additional_respondents: claim.respondents[1..-1]
      }
      file.rewind
    end
    ActionDispatch::Http::UploadedFile.new filename: filename, tempfile: tempfile, type: 'text/xml'
  end

  def claimants_text_file(claim)
    claimant = claim.claimants.first
    filename = "et1a_#{claimant.first_name.tr(' ', '_')}_#{claimant.last_name}.txt"
    {
      filename: filename,
      file: raw_claimants_text_file(filename, claim: claim)
    }
  end

  def raw_claimants_text_file(filename, claim:)
    tempfile = Tempfile.new.tap do |file|
      file.write ApplicationController.render "api/v1/claims/export_claimants.txt.erb", locals: {
        claim: claim, primary_claimant: claim.claimants.first,
        secondary_claimants: claim.claimants[1..-1],
        primary_respondent: claim.respondents.first
      }
      file.rewind
    end
    ActionDispatch::Http::UploadedFile.new filename: filename, tempfile: tempfile, type: 'text/xml'
  end

  def add_file(method, to:)
    to.uploaded_files.build send(method, to)
  end

  attr_accessor :data, :original_data
end
