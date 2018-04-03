# frozen_string_literal: true

class ClaimXmlImportService
  REPRESENTATIVE_TYPE_MAPPINGS = {
    'CAB' => 'citizen_advice_bureau',
    'FRU' => 'free_representation_unit',
    'Law Centre' => 'law_centre',
    'Union' => 'trade_union',
    'Solicitor' => 'solicitor',
    'Private Individual' => 'private_individual',
    'Trade Association' => 'trade_association',
    'Other' => 'other'
  }.freeze
  private_constant :REPRESENTATIVE_TYPE_MAPPINGS

  attr_accessor :uploaded_files

  def initialize(data)
    self.data = Hash.from_xml(data)
  end

  def files
    root['Files'].map do |_, node|
      { filename: node['Filename'], checksum: node['Checksum'] }
    end
  end

  def import
    Claim.create! converted_root_data
  end

  private

  def converted_root_data
    r = root
    {
      reference: r['FeeGroupReference'],
      submission_reference: r['SubmissionUrn'],
      claimant_count: r['CurrentQuantityOfClaimants'],
      submission_channel: r['SubmissionChannel'],
      case_type: r['CaseType'],
      jurisdiction: r['Jurisdiction'],
      office_code: r['OfficeCode'],
      date_of_receipt: r['DateOfReceiptEt'],
      administrator: r['Administrator'].to_i > 0,
      claimants_attributes: converted_claimants_data,
      respondents_attributes: converted_respondents_data,
      representatives_attributes: converted_representatives_data,
      uploaded_files_attributes: converted_files_data
    }
  end

  def converted_claimants_data
    r = root
    claimants = r['Claimants']['Claimant']
    claimants = [claimants] unless claimants.is_a?(Array)
    claimants.map do |c|
      {
        title: c['Title'],
        first_name: c['Forename'],
        last_name: c['Surname'],
        address_attributes: {
          building: c.dig('Address', 'Line'),
          street: c.dig('Address', 'Street'),
          locality: c.dig('Address', 'Town'),
          county: c.dig('Address', 'County'),
          post_code: c.dig('Address', 'Postcode')
        },
        address_telephone_number: c['OfficeNumber'],
        mobile_number: c['AltPhoneNumber'],
        email_address: c['Email'],
        contact_preference: c['PreferredContactMethod'],
        gender: c['Sex'],
        date_of_birth: Date.parse(c['DateOfBirth'])
      }
    end
  end

  def converted_respondents_data
    r = root
    respondents = r['Respondents']['Respondent']
    respondents = [respondents] unless respondents.is_a?(Array)
    respondents.map do |r|
      {
        name: r['Name'],
        address_attributes: {
          building: r.dig('Address', 'Line'),
          street: r.dig('Address', 'Street'),
          locality: r.dig('Address', 'Town'),
          county: r.dig('Address', 'County'),
          post_code: r.dig('Address', 'Postcode')
        },
        work_address_attributes: {
          building: r.dig('AltAddress', 'Line'),
          street: r.dig('AltAddress', 'Street'),
          locality: r.dig('AltAddress', 'Town'),
          county: r.dig('AltAddress', 'County'),
          post_code: r.dig('AltAddress', 'Postcode')
        },
        work_address_telephone_number: r['OfficeNumber'],
        address_telephone_number: r['PhoneNumber'],
        alt_phone_number: r['AltPhoneNumber'],
        acas_number: r.dig('Acas', 'Number')
      }
    end
  end

  def converted_representatives_data
    r = root
    reps = r['Representatives']['Representative']
    reps = [reps] unless reps.is_a?(Array)
    reps.map do |r|
      {
        name: r['Name'],
        organisation_name: r['Organisation'],
        address_attributes: {
          building: r.dig('Address', 'Line'),
          street: r.dig('Address', 'Street'),
          locality: r.dig('Address', 'Town'),
          county: r.dig('Address', 'County'),
          post_code: r.dig('Address', 'Postcode'),
        },
        address_telephone_number: r['OfficeNumber'],
        mobile_number: r['AltPhoneNumber'],
        email_address: r['Email'],
        representative_type: convert_representative_type(r['Type']),
        dx_number: r['DXNumber']
      }
    end
  end

  def converted_files_data
    r = root
    files = r['Files']['File']
    files = [files] unless files.is_a?(Array)
    files.map do |f|
      filename = f['Filename']
      {
        filename: filename,
        checksum: f['Checksum'],
        file: uploaded_files.dig(filename, :file)
      }
    end
  end

  def convert_representative_type(t)
    REPRESENTATIVE_TYPE_MAPPINGS[t]
  end

  def root
    data['ETFeesEntry']
  end

  attr_accessor :data
end
