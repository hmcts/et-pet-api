class BuildClaimPdfFileService # rubocop:disable Metrics/ClassLength
  include PdfBuilder::Base
  include PdfBuilder::MultiTemplate
  include PdfBuilder::Rendering
  include PdfBuilder::PreAllocation
  include PdfBuilder::ActiveStorage
  PAY_CLAIMS = ['redundancy', 'notice', 'holiday', 'arrears', 'other'].freeze

  def self.call(source, template_reference: 'et1-v2-en', time_zone: 'London')
    new(source, template_reference: template_reference, time_zone: time_zone).call
  end

  def call
    claimant = source.primary_claimant
    filename = "et1_#{scrubber claimant.first_name}_#{scrubber claimant.last_name}.pdf"
    source.uploaded_files.build filename: filename,
                                file: blob_for_pdf_file(filename)
  end

  private

  def scrubber(text)
    text.gsub(/\s/, '_').gsub(/\W/, '').downcase
  end

  def pdf_fields
    result = {}
    apply_office_use_only_fields(result)
    apply_your_details_fields(result)
    apply_respondents_details_fields(result)
    apply_secondary_respondents_details_fields(result)
    apply_multiple_cases_section(result)
    apply_employment_details_section(result)
    apply_earnings_and_benefits_section(result)
    apply_what_happened_since_section(result)
    apply_type_and_details_section(result)
    apply_what_do_you_want_section(result)
    apply_information_to_regulators_section(result)
    apply_your_representative_section(result)
    apply_disability_section(result)
    apply_additional_information_section(result)
    result
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def apply_your_details_fields(result)
    primary_claimant = source.primary_claimant
    pca = primary_claimant.address
    apply_field result, primary_claimant.title, :your_details, :title unless primary_claimant.title.nil?
    apply_field result, primary_claimant.first_name, :your_details, :first_name
    apply_field result, primary_claimant.last_name, :your_details, :last_name
    apply_field result, primary_claimant.gender, :your_details, :gender
    apply_field result, pca.building, :your_details, :building
    apply_field result, pca.street, :your_details, :street
    apply_field result, pca.locality, :your_details, :locality
    apply_field result, pca.county, :your_details, :county
    apply_field result, format_post_code(pca.post_code), :your_details, :post_code
    apply_field result, primary_claimant.mobile_number, :your_details, :alternative_telephone_number
    apply_field result, primary_claimant.contact_preference, :your_details, :correspondence
    apply_field result, primary_claimant.date_of_birth.day, :your_details, :dob_day
    apply_field result, primary_claimant.date_of_birth.month, :your_details, :dob_month
    apply_field result, primary_claimant.date_of_birth.year, :your_details, :dob_year
    apply_field result, primary_claimant.email_address, :your_details, :email_address
    apply_field result, primary_claimant.address_telephone_number, :your_details, :telephone_number
    apply_field result, primary_claimant.allow_video_attendance, :your_details, :allow_video_attendance
  end

  def apply_office_use_only_fields(result)
    apply_field result, format_date(source.date_of_receipt), :official_use_only, :date_received
    apply_field result, source.office&.name, :official_use_only, :tribunal_office
  end

  def apply_respondents_details_fields(result)
    resp1 = source.primary_respondent
    apply_field result, resp1.name, :respondents_details, :name
    apply_field result, resp1.acas_certificate_number, :respondents_details, :acas, :acas_number
    apply_field result, resp1.acas_certificate_number.present?, :respondents_details, :acas, :have_acas
    apply_field result, resp1.address.building, :respondents_details, :address, :building
    apply_field result, resp1.address.street, :respondents_details, :address, :street
    apply_field result, resp1.address.locality, :respondents_details, :address, :locality
    apply_field result, resp1.address.county, :respondents_details, :address, :county
    apply_field result, format_post_code(resp1.address.post_code), :respondents_details, :address, :post_code
    apply_field result, resp1.address_telephone_number, :respondents_details, :address, :telephone_number
    apply_field result, resp1.work_address&.building, :respondents_details, :different_address, :building
    apply_field result, resp1.work_address&.street, :respondents_details, :different_address, :street
    apply_field result, resp1.work_address&.locality, :respondents_details, :different_address, :locality
    apply_field result, resp1.work_address&.county, :respondents_details, :different_address, :county
    apply_field result, format_post_code(resp1.work_address&.post_code, optional: resp1.present?), :respondents_details, :different_address, :post_code
    apply_field result, resp1.work_address_telephone_number, :respondents_details, :different_address, :telephone_number
    apply_field result, source.secondary_respondents.present?, :respondents_details, :additional_respondents
  end

  def apply_secondary_respondents_details_fields(result)
    4.times.each do |idx|
      resp = source.secondary_respondents[idx]
      pdf_field = :"respondent#{idx + 2}"
      pdf_section = idx < 2 ? :respondents_details : :additional_respondents

      apply_field result, resp&.name, pdf_section, pdf_field, :name
      apply_field result, resp&.acas_certificate_number, pdf_section, pdf_field, :acas, :acas_number
      apply_field result, resp&.acas_certificate_number&.present?, pdf_section, pdf_field, :acas, :have_acas
      apply_field result, resp&.address&.building, pdf_section, pdf_field, :address, :building
      apply_field result, resp&.address&.street, pdf_section, pdf_field, :address, :street
      apply_field result, resp&.address&.locality, pdf_section, pdf_field, :address, :locality
      apply_field result, resp&.address&.county, pdf_section, pdf_field, :address, :county
      apply_field result, format_post_code(resp&.address&.post_code, optional: resp.blank?), pdf_section, pdf_field, :address, :post_code
      apply_field result, resp&.address_telephone_number, pdf_section, pdf_field, :address, :telephone_number

    end
  end

  def apply_multiple_cases_section(result)
    apply_field result, source.other_known_claimant_names&.present?, :multiple_cases, :have_similar_claims
    apply_field result, source.other_known_claimant_names, :multiple_cases, :other_claimants
  end

  def apply_employment_details_section(result)
    return if source.employment_details.empty?

    ed = source.employment_details.symbolize_keys
    apply_field result, ed[:end_date].nil? || Time.zone.parse(ed[:end_date]).future?, :employment_details, :employment_continuing
    apply_field result, ed[:job_title], :employment_details, :job_title
    apply_field result, format_date(ed[:start_date], optional: true), :employment_details, :start_date
    apply_field result, format_date(ed[:end_date], optional: true), :employment_details, :ended_date
    apply_field result, format_date(ed[:notice_period_end_date], optional: true), :employment_details, :ending_date
  end

  def apply_earnings_and_benefits_section(result)
    ed = source.employment_details.symbolize_keys
    apply_field result, ed[:average_hours_worked_per_week], :earnings_and_benefits, :average_weekly_hours
    apply_field result, ed[:benefit_details], :earnings_and_benefits, :benefits
    apply_field result, ed[:enrolled_in_pension_scheme], :earnings_and_benefits, :employers_pension_scheme
    apply_field result, ed[:worked_notice_period_or_paid_in_lieu], :earnings_and_benefits, :paid_for_notice_period
    apply_field result, ed[:notice_pay_period_type] == 'months' ? ed[:notice_pay_period_count] : '', :earnings_and_benefits, :notice_period, :months
    apply_field result, ed[:notice_pay_period_type] == 'weeks' ? ed[:notice_pay_period_count] : '', :earnings_and_benefits, :notice_period, :weeks
    apply_field result, ed[:gross_pay]&.to_s, :earnings_and_benefits, :pay_before_tax, :amount
    apply_field result, ed[:gross_pay_period_type], :earnings_and_benefits, :pay_before_tax, :period
    apply_field result, ed[:net_pay]&.to_s, :earnings_and_benefits, :pay_after_tax, :amount
    apply_field result, ed[:net_pay_period_type], :earnings_and_benefits, :pay_after_tax, :period
  end

  def apply_what_happened_since_section(result)
    ed = source.employment_details.symbolize_keys
    apply_field result, ed[:found_new_job], :what_happened_since, :have_another_job
    apply_field result, format_date(ed[:new_job_start_date], optional: true), :what_happened_since, :start_date
    apply_field result, ed[:new_job_gross_pay], :what_happened_since, :salary
  end

  def apply_type_and_details_section(result)
    apply_field result, source.pay_claims.include?('redundancy'), :type_and_details, :claiming_redundancy_payment
    apply_field result, source.discrimination_claims.present?, :type_and_details, :discriminated
    apply_field result, source.discrimination_claims.include?('age'), :type_and_details, :discriminated_age
    apply_field result, source.discrimination_claims.include?('disability'), :type_and_details, :discriminated_disability
    apply_field result, source.discrimination_claims.include?('gender_reassignment'), :type_and_details, :discriminated_gender_reassignment
    apply_field result, source.discrimination_claims.include?('marriage_or_civil_partnership'), :type_and_details, :discriminated_marriage
    apply_field result, source.discrimination_claims.include?('sexual_orientation'), :type_and_details, :discriminated_sexual_orientation
    apply_field result, source.discrimination_claims.include?('pregnancy_or_maternity'), :type_and_details, :discriminated_pregnancy
    apply_field result, source.discrimination_claims.include?('race'), :type_and_details, :discriminated_race
    apply_field result, source.discrimination_claims.include?('religion_or_belief'), :type_and_details, :discriminated_religion
    apply_field result, source.discrimination_claims.include?('sex_including_equal_pay'), :type_and_details, :discriminated_sex
    apply_field result, source.other_claim_details.present?, :type_and_details, :other_type_of_claim
    apply_field result, source.other_claim_details, :type_and_details, :other_type_of_claim_details
    apply_field result, owed_anything?, :type_and_details, :owed
    apply_field result, source.pay_claims.include?('arrears'), :type_and_details, :owed_arrears_of_pay
    apply_field result, source.pay_claims.include?('holiday'), :type_and_details, :owed_holiday_pay
    apply_field result, source.pay_claims.include?('notice'), :type_and_details, :owed_notice_pay
    apply_field result, source.pay_claims.include?('other'), :type_and_details, :owed_other_payments
    apply_field result, source.is_unfair_dismissal, :type_and_details, :unfairly_dismissed
    apply_field result, source.claim_details, :type_and_details, :claim_description
  end

  def apply_what_do_you_want_section(result)
    apply_field result, source.desired_outcomes.include?('compensation_only'), :what_do_you_want, :prefer_compensation
    apply_field result, source.desired_outcomes.include?('new_employment_and_compensation'), :what_do_you_want, :prefer_re_engagement
    apply_field result, source.desired_outcomes.include?('reinstated_employment_and_compensation'), :what_do_you_want, :prefer_re_instatement
    apply_field result, source.desired_outcomes.include?('tribunal_recommendation'), :what_do_you_want, :prefer_recommendation
    apply_field result, source.other_outcome, :what_do_you_want, :compensation
  end

  def apply_information_to_regulators_section(result)
    apply_field result, source.send_claim_to_whistleblowing_entity.present?, :information_to_regulators, :whistle_blowing
  end

  def apply_your_representative_section(result)
    rep = source.primary_representative
    apply_field result, rep&.organisation_name, :your_representative, :name_of_organisation
    apply_field result, rep&.name, :your_representative, :name_of_representative
    apply_field result, rep&.address&.building, :your_representative, :building
    apply_field result, rep&.address&.street, :your_representative, :street
    apply_field result, rep&.address&.locality, :your_representative, :locality
    apply_field result, rep&.address&.county, :your_representative, :county
    apply_field result, format_post_code(rep&.address&.post_code, optional: rep.blank?), :your_representative, :post_code
    apply_field result, rep&.address_telephone_number, :your_representative, :telephone_number
    apply_field result, rep&.mobile_number, :your_representative, :alternative_telephone_number
    apply_field result, rep&.dx_number, :your_representative, :dx_number
    apply_field result, rep&.email_address, :your_representative, :email_address
    apply_field result, nil, :your_representative, :communication_preference
  end

  def apply_disability_section(result)
    apply_field result, source.primary_claimant.special_needs.present?, :disability, :has_special_needs
    apply_field result, source.primary_claimant.special_needs, :disability, :special_needs
  end

  def apply_additional_information_section(result)
    apply_field result, source.miscellaneous_information, :additional_information, :additional_information
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def format_post_code(val, optional: false)
    return nil if val.nil? && optional

    match = val.match(/\A\s*(\S+)\s*(\d\w\w)\s*\z/)
    return val.slice(0, 7) unless match && match[1].length <= 4

    spaces = 4 - match[1].length
    val = "#{match[1]}#{' ' * spaces}#{match[2]}"
    val.slice(0, 7)
  end

  def format_date(date, optional: false)
    return nil if date.nil? && optional

    date = ActiveSupport::TimeZone['London'].parse(date) if date.is_a?(String)
    date.in_time_zone(time_zone).strftime "%d/%m/%Y"
  end

  def owed_anything?
    (PAY_CLAIMS - ['redundancy']).any? { |type| source.pay_claims.include?(type) }
  end

end
