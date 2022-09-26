module EtAcasApi
  class SoapSignature < Akami::WSSE::Signature
    def to_token
      hash = super
      add_timestamp(hash)
      hash
    end

    private

    def signed_info
      {
          "SignedInfo" => {
              "CanonicalizationMethod/" => nil,
              "SignatureMethod/" => nil,
              "Reference" => [
                  #signed_info_transforms.merge(signed_info_digest_method).merge({ "DigestValue" => timestamp_digest }),
                  signed_info_transforms.merge(signed_info_digest_method).merge({ "DigestValue" => timestamp_digest }),
              ],
              :attributes! => {
                  "CanonicalizationMethod/" => { "Algorithm" => ExclusiveXMLCanonicalizationAlgorithm },
                  "SignatureMethod/" => { "Algorithm" => RSASHA1SignatureAlgorithm },
                  "Reference" => { "URI" => ["##{timestamp_id}"] },
              },
              :order! => ["CanonicalizationMethod/", "SignatureMethod/", "Reference"],
          },
      }
    end

    def timestamp_digest
      doc = Nokogiri::XML(timestamp_xml)
      Base64.encode64(OpenSSL::Digest::SHA1.digest(canonicalize(doc.root))).strip
    end

    def timestamp_xml
      @timestamp_xml ||= Gyoku.xml(timestamp_hash)
    end

    def timestamp_hash
      @timestamp_hash ||= {
          "wsu:Timestamp" => {
              "wsu:Created" => (Time.now).utc.xmlschema,
              "wsu:Expires" => (5.minutes.since).utc.xmlschema
          }, :attributes! => { "wsu:Timestamp" => { "wsu:Id" => timestamp_id, "xmlns:wsu" => ::Akami::WSSE::WSU_NAMESPACE } }
      }
    end

    def timestamp_id
      "_0"
    end


    def add_timestamp(hash)
      hash.deep_merge!(timestamp_hash)
      hash[:order!].unshift "wsu:Timestamp"
    end
  end
end
