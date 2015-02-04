require 'nokogiri'

module ServiceNowHelpers
  def make_multiple_xml start, max_export
    xml_doc = Nokogiri::XML(make_record_xml)
    index_array = (start..(max_export - 1)).to_a
    (index_array.length - 1).times do |num|
      xml_doc.at('core_company').add_next_sibling(xml_doc.at('core_company').dup)
    end

    xml_doc.xpath('//xml/core_company/sys_id').each_with_index do |id, index|
      id.children = "deadbeefdeadbeefdeadbeefdead#{index_array[index]}"
    end

    xml_doc.to_xml
  end

  def make_record_xml
    <<EOF
<xml>
<core_company>
<apple_icon/>
<banner_image/>
<banner_text></banner_text>
<city/>
<color_scheme/>
<contact/>
<country/>
<customer>true</customer>
<discount/>
<fax_phone/>
<fiscal_year/>
<lat_long_error/>
<latitude/>
<longitude/>
<manufacturer>false</manufacturer>
<market_cap>0</market_cap>
<name>ACME</name>
<num_employees/>
<parent/>
<phone/>
<primary>false</primary>
<profits>0</profits>
<publicly_traded>false</publicly_traded>
<rank_tier/>
<revenue_per_year>0</revenue_per_year>
<state/>
<stock_price/>
<stock_symbol/>
<street/>
<sys_created_by>acme_administrator</sys_created_by>
<sys_created_on>2015-02-01 22:52:00</sys_created_on>
<sys_domain_number>3.14</sys_domain_number>
<sys_id>deadbeefdeadbeefdeadbeefdeadbeef</sys_id>
<sys_mod_count>28</sys_mod_count>
<sys_updated_by>acme_administrator</sys_updated_by>
<sys_updated_on>2015-02-01 22:52:00</sys_updated_on>
<theme/>
<vendor>false</vendor>
<vendor_manager/>
<vendor_type/>
<website/>
<zip/>
</core_company>
</xml>
EOF
  end

  def make_record_hash suffix = "beef"
    {
      "apple_icon"=>nil,
      "banner_image"=>nil,
      "banner_text"=>nil,
      "city"=>nil,
      "color_scheme"=>nil,
      "contact"=>nil,
      "country"=>nil,
      "customer"=>"true",
      "discount"=>nil,
      "fax_phone"=>nil,
      "fiscal_year"=>nil,
      "lat_long_error"=>nil,
      "latitude"=>nil,
      "longitude"=>nil,
      "manufacturer"=>"false",
      "market_cap"=>"0",
      "name"=>"ACME",
      "num_employees"=>nil,
      "parent"=>nil,
      "phone"=>nil,
      "primary"=>"false",
      "profits"=>"0",
      "publicly_traded"=>"false",
      "rank_tier"=>nil,
      "revenue_per_year"=>"0",
      "state"=>nil,
      "stock_price"=>nil,
      "stock_symbol"=>nil,
      "street"=>nil,
      "sys_created_by"=>"acme_administrator",
      "sys_created_on"=>"2015-02-01 22:52:00",
      "sys_domain_number"=>"3.14",
      "sys_id"=>"deadbeefdeadbeefdeadbeefdead#{suffix}",
      "sys_mod_count"=>"28",
      "sys_updated_by"=>"acme_administrator",
      "sys_updated_on"=>"2015-02-01 22:52:00",
      "theme"=>nil,
      "vendor"=>"false",
      "vendor_manager"=>nil,
      "vendor_type"=>nil,
      "website"=>nil,
      "zip"=>nil
    }
  end
end