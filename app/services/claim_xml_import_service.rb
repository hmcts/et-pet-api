# frozen_string_literal: true

# Imports API V1 XML data from the front end application
#
# It is expected that this is to be a short lived service - it will be replaced with
# a ClaimJsonImportService which does the same thing but with JSON input from the V2
# API.
# The JSON version will have to generate its own XML if it REALLY is needed to be exported
# to the final zip files.  At the time of writing, noone really knows.
class ClaimXmlImportService
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
    self.data = Hash.from_xml(data)
  end

  # Provides an array of hashes representing the files in the XML
  #
  # @return [Array<Hash>] An array of hashes like { filename: xxx, checksum: yyy }
  def files
    root['Files'].map do |_, node|
      { filename: node['Filename'], checksum: node['Checksum'] }
    end
  end

  # Performs the import
  #
  # @return [Claim] The imported claim
  def import
    Claim.create! converted_root_data.merge(converted_associated_data)
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
    end
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

  attr_accessor :data
end
