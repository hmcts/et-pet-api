require 'gov_fake_notify'
RSpec.configure do |c|
  c.before do
    GovFakeNotify.reset!
  end
end
GovFakeNotify.config do |c|
  c.delivery_method = :test
  c.include_templates = [
    {
      id: 'a55e0b84-8d65-4bf4-93a7-e974e0d8d48d',
      name: 'et1-confirmation-email-v1-en',
      subject: 'Employment tribunal: claim submitted',
      message: <<~MESSAGE
        Claim number: ((claim.reference))

        ((primary_claimant.first_name)) ((primary_claimant.last_name))

        Thank you for submitting your claim to an employment tribunal.

        ---

        WHAT HAPPENS NEXT

        We'll contact you once we have sent your claim to the respondent and explain what happens next.
        At present, this is taking us an average of 25 days.
        Once we have sent them your claim, the respondent has 28 days to reply.

        ---

        SUBMISSION DETAILS

        Claim submitted:       ((submitted_date))
        Tribunal office:       ((office.name))
        Contact: ((office.email)), ((office.telephone))

        ---

        Please use the link below to download a copy of your claim.
        ((link_to_pdf))

        ---

        Additional Information File

        ((link_to_additional_info))

        ---

        Group Claim File

        ((link_to_claimants_file))

        ---



        Your feedback helps us improve this service:
        https://www.gov.uk/done/employment-tribunals-make-a-claim

        Help us keep track. Complete our diversity monitoring questionnaire.
        https://employmenttribunals.service.gov.uk/en/apply/diversity

        Contact us: http://www.justice.gov.uk/contacts/hmcts/tribunals/employment
      MESSAGE

    },
    {
      id: '97a117f1-727d-4631-bbc6-b2bc98d30a0f',
      name: 'et1-confirmation-email-v1-cy',
      subject: 'Tribiwnlys Cyflogaeth: hawliad wedi’i gyflwyno',
      message: <<~MESSAGE
        Eich rhif hawliad: ((claim.reference))

        ((primary_claimant.first_name)) ((primary_claimant.last_name))
        Diolch am gyflwyno eich hawliad i dribiwnlys cyflogaeth.
        ---

        BETH SY'N DIGWYDD NESAF

        Byddwn yn cysylltu â chi unwaith y byddwn wedi anfon eich hawliad at yr atebydd i egluro beth fydd yn digwydd nesaf. Ar hyn o bryd, mae’n cymryd oddeutu 25 diwrnod.
        Unwaith y byddwn wedi anfon eich hawliad atynt, mae gan yr atebydd 28 diwrnod i ymateb.

        ---

        MANYLION CYFLWYNO

        Hawliad wedi'i gyflwyno:      Cyflwynwyd ar ((submitted_date))
        Swyddfa tribiwnlys:           Cymru, Tribiwnlys Cyflogaeth
        Cyswllt: ((office.email)), 0300 303 0654

        ---#{'     '}

        Defnyddiwch y ddolen isod i lawrlwytho copi o’ch hawliad.
        ((link_to_pdf))

        ---

        Ffeil Gwybodaeth Ychwanegol

        ((link_to_additional_info))

        ---

        Hawliad Grŵp

        ((link_to_claimants_file))

        ---

        Mae eich adborth yn ein helpu i wella'r gwasanaeth hwn:
        https://www.gov.uk/done/employment-tribunals-make-a-claim

        Helpwch ni i gadw cofnodion cywir . Llenwch ein holiadur monitro amrywiaeth.
        https://employmenttribunals.service.gov.uk/en/apply/diversity

        Cysylltu â ni: http://www.justice.gov.uk/contacts/hmcts/tribunals/employment
      MESSAGE
    },
    {
      id: '169d5f7b-edf3-488b-a2b9-39fdc9062405',
      name: 'et3-confirmation-email-v2-en',
      subject: 'Your Response to Employment Tribunal claim online form receipt',
      message: <<~MESSAGE
        Thank you for your submission. It has been forwarded to the ((office.name)) office which will contact you in due course.

        ^ Office address: ((office.address ))
        ^ Telephone: ((office.telephone))

        ---

        This is your reference number: ((response.reference)) which should be quoted on all correspondence.

        Submission date: ((submitted_date))

        Our national enquiry line can be contacted on:

        ^ England and Wales: 0300 123 1024
        ^ Scotland: 0141 354 8574
        ^ Minicom/Textphone: 01509 221564

        They can also provide general procedural information about the employment tribunals.
      MESSAGE

    },
    {
      id: 'd7aba71c-194b-4e5a-a996-9314eaf18c8d',
      name: 'et3-confirmation-email-v2-cy',
      subject: 'E-bost yn cadarnhau bod eich ymateb i’r hawliad Tribiwnlys Cyflogaeth ar-lein wedi cyrraedd',
      message: <<~MESSAGE
        Diolch am gyflwyno eich ymateb. Mae wedi cael ei anfon i’r swyddfa ym ((office.name)) a byddant yn cysylltu â chi maes o law.

        ^ Cyfeiriad y swyddfa: ((office.address ))
        ^ Rhif ffôn: ((office.telephone))

        ---

        Eich cyfeirnod yw: ((response.reference)) Dylech ei ddyfynnu ar bob gohebiaeth.

        Dyddiad cyflwyno: ((submitted_date))

        Gallwch ffonio ein llinell ymholiadau cenedlaethol ar:

        ^ Rhif ffôn i siaradwyr Cymraeg: 0300 303 517
        ^ Rhif ffôn ar gyfer ymholiadau yn Saesneg: 0300 123 1024
        ^ Yr Alban: 0141 354 8574
        ^ Minicom/Ffôn Testun: 01509 221564

        Gallant hefyd roi gwybodaeth gyffredinol i chi ynglŷn â phrosesaur tribiwnlys cyflogaeth.
      MESSAGE

    }
  ]
  c.include_api_keys = [
    {
      service_name: 'Employment Tribunals',
      service_email: 'employmenttribunals@email.com',
      key: Rails.application.config.govuk_notify.test_api_key
    }
  ]
end
