require 'spec_helper'

module RsServiceNow
  describe Record do
    let(:subject) { RsServiceNow::Record.new "user", "supersekrit", "reporting" }
    let(:max_export) { 100 }
    let(:single_record_hash) { make_record_hash }
    let(:single_record_xml) { make_record_xml }
    let(:encoded_query) { 'active=true' }

    describe '#_request' do
      let(:dummy_client) { Object.new }
      let(:dummy_response) { Object.new }
      let(:multi_record_hash) { (0..251).collect { single_record_hash } }

      before :each do
        allow( subject ).to receive(:setup_client).and_return(dummy_client)
      end

      context 'single result' do
        let(:dummy_response_hash) { {:envelope => {:body => {:get_records_response => {:get_records_result => single_record_hash } } } } }

        before :each do
          allow( subject ).to receive(:get_keys).and_return({:count => "1"})
          allow( dummy_response ).to receive(:hash).and_return(dummy_response_hash)
          allow( dummy_client ).to receive(:call).and_return(dummy_response)
        end

        it 'should return an array with one hash' do
          expect( subject._request 'core_company', encoded_query ).to be == [single_record_hash]
        end
      end

      context 'multiple results' do
        let(:dummy_response_hash) { {:envelope => {:body => {:get_records_response => {:get_records_result => multi_record_hash } } } } }

        before :each do
          allow( subject ).to receive(:get_keys).and_return({:count => "251"})
          allow( dummy_response ).to receive(:hash).and_return(dummy_response_hash)
          allow( dummy_client ).to receive(:call).and_return(dummy_response)
        end

        it 'should get records 250 at a time' do
          expect( dummy_client ).to receive(:call).with(:get_records, :message => {:__encoded_query => encoded_query, :__first_row => 0, :__last_row => 250}).ordered
          expect( dummy_client ).to receive(:call).with(:get_records, :message => {:__encoded_query => encoded_query, :__first_row => 250, :__last_row => 500}).ordered

          subject._request 'core_company', encoded_query
        end

        it 'should return an array of hashes containing each entry' do
          expect( subject._request 'core_company', encoded_query ) == [multi_record_hash]
        end
      end

    end

    describe '#_export' do
      let(:dummy_open) { Object.new }
      let(:multi_record_hash) { (0..251).map { |n| make_record_hash n } }

      context 'single result' do
        let(:export_url) { "https://reporting.service-now.com/core_company.do?XML&sysparm_order_by=sys_id&sysparm_query=#{CGI.escape(encoded_query + '^')}sys_id#{CGI.escape('>=') + "deadbeefdeadbeefdeadbeefdeadbeef"}&sysparm_record_count=#{max_export}" }

        before :each do
          allow( subject ).to receive(:get_keys).and_return({:count => "1", :sys_id => "deadbeefdeadbeefdeadbeefdeadbeef"})
        end

        it 'should use the first sys_id in the first query' do
          expect( subject ).to receive(:open).with(
                                  export_url,
                                  :http_basic_authentication => ["user", "supersekrit"]
                               ).and_return(dummy_open)
          allow( dummy_open ).to receive(:read).and_return(single_record_xml)

          subject._export 'core_company', encoded_query, max_export
        end

        it 'should return an array with one hash' do
          allow( subject ).to receive(:open).and_return(dummy_open)
          allow( dummy_open ).to receive(:read).and_return(single_record_xml)
          expect( subject._export 'core_company', encoded_query, max_export ).to be == [single_record_hash]
        end
      end

      context 'multiple results' do
        let(:multi_xml_return0) { make_multiple_xml 0, 100 }
        let(:multi_xml_return1) { make_multiple_xml 100, 200 }
        let(:multi_xml_return2) { make_multiple_xml 200, 252 }
        let(:sys_ids) { (0..299).map { |num| "deadbeefdeadbeefdeadbeefdead#{num}" }.join(',') }
        let(:export_url0) { "https://reporting.service-now.com/core_company.do?XML&sysparm_order_by=sys_id&sysparm_query=#{CGI.escape(encoded_query + '^')}sys_id#{CGI.escape('>=') + "deadbeefdeadbeefdeadbeefdead0"}&sysparm_record_count=#{max_export}" }
        let(:export_url1) { "https://reporting.service-now.com/core_company.do?XML&sysparm_order_by=sys_id&sysparm_query=#{CGI.escape(encoded_query + '^')}sys_id#{CGI.escape('>=') + "deadbeefdeadbeefdeadbeefdead100"}&sysparm_record_count=#{max_export}" }
        let(:export_url2) { "https://reporting.service-now.com/core_company.do?XML&sysparm_order_by=sys_id&sysparm_query=#{CGI.escape(encoded_query + '^')}sys_id#{CGI.escape('>=') + "deadbeefdeadbeefdeadbeefdead200"}&sysparm_record_count=#{max_export}" }

        before :each do
          allow( subject ).to receive(:get_keys).and_return({:count => "251", :sys_id => sys_ids})

        end

        it 'should get records 100 at a time using sys_ids as the index' do
          expect( subject ).to receive(:open).with(export_url0, :http_basic_authentication => ["user", "supersekrit"]).and_return(dummy_open)
          expect( subject ).to receive(:open).with(export_url1, :http_basic_authentication => ["user", "supersekrit"]).and_return(dummy_open)
          expect( subject ).to receive(:open).with(export_url2, :http_basic_authentication => ["user", "supersekrit"]).and_return(dummy_open)
          allow( dummy_open ).to receive(:read).and_return(multi_xml_return0, multi_xml_return1, multi_xml_return2)
          subject._export 'core_company', encoded_query, max_export
        end

        it 'should parse the xml and return an array of hashes' do
          allow( subject ).to receive(:open).and_return(dummy_open)
          allow( dummy_open ).to receive(:read).and_return(multi_xml_return0, multi_xml_return1, multi_xml_return2)
          expect( subject._export 'core_company', encoded_query, max_export ).to be == multi_record_hash
        end
      end

    end

    describe '#get' do
      let(:dummy_client) { Object.new }
      let(:dummy_response) { Object.new }
      let(:get_response) { make_record_hash }
      let(:dummy_response_hash) { {:envelope => {:body => {:get_response => get_response } } } }
      let(:sys_id) { "deadbeefdeadbeefdeadbeefdeadbeef" }

      before :each do
        allow( subject ).to receive(:setup_client).and_return(dummy_client)
        allow( dummy_response ).to receive(:hash).and_return(dummy_response_hash)
        allow( dummy_client ).to receive(:call).and_return(dummy_response)
      end

      it 'should return a hash' do
        expect( dummy_client ).to receive(:call).with(:get, :message => {:sys_id => sys_id})

        expect( subject._get("core_company", sys_id) ).to be == get_response
      end
    end

    describe '#_insert' do
      let(:dummy_client) { Object.new }
      let(:dummy_response) { Object.new }
      let(:insert_response) { make_insert_response_hash }
      let(:insert_request) { 
        {
          :active => true,
          :assigned_to => "me",
          :cmdb_ci => "router1",
          :severity => 1,
          :urgency => 1,
        }
      }

      before :each do
        allow( subject ).to receive(:setup_client).and_return(dummy_client)
        allow( dummy_response ).to receive(:hash).and_return(insert_response)
        allow( dummy_client ).to receive(:call).and_return(dummy_response)
      end

      it 'should return a sys_id' do
        expect( dummy_client ).to receive(:call).with(:insert, :message => insert_request)

        expect( subject._insert("incident", insert_request) ).to be == "deadbeefdeadbeefdeadbeefdeadbeef"
      end
    end

    describe '#_update' do
            let(:dummy_client) { Object.new }
      let(:dummy_response) { Object.new }
      let(:update_response) { make_insert_response_hash }
      let(:update_request) { 
        {
          :active => true,
        }
      }

      before :each do
        allow( subject ).to receive(:setup_client).and_return(dummy_client)
        allow( dummy_response ).to receive(:hash).and_return(update_response)
        allow( dummy_client ).to receive(:call).and_return(dummy_response)
      end

      it 'should update the record' do
        expect( dummy_client ).to receive(:call).with(:insert, :message => update_request)
        subject._insert("incident", update_request)
      end
    end

  end
end