require 'savon'
require 'open-uri'
require 'active_support/core_ext/hash/conversions'

class RsServiceNow::Record

  def initialize user, password, instance, proxy = nil
    @user = user
    @password = password
    @url = "https://#{instance}.service-now.com"
    @proxy = proxy
  end

  def _request table, encoded_query
    client = setup_client table
    num_entries = get_keys(client, encoded_query)[:count].to_i
    index = 0
    result = []

    while index < num_entries
      response = client.call(:get_records, :message => {:__encoded_query => encoded_query, :__first_row => index, :__last_row => (index + 250)})
      index = index + 250

      records = response.hash[:envelope][:body][:get_records_response][:get_records_result]
      if records.is_a? Array
        result.push *records
      else
        result.push records
      end
    end

    result
  end

  def _export table, encoded_query, max_export
    client = setup_client table
    get_keys_result = get_keys(client, encoded_query)
    num_entries = get_keys_result[:count].to_i
    keys = get_keys_result[:sys_id].split(/,/)
    index = 0
    export = []

    while index < num_entries
      # Use a URL to retrieve an XML export as documented at http://wiki.servicenow.com/index.php?title=Exporting_Data
      xml = open("#{@url}/#{table}.do?XML&" +
                         "sysparm_order_by=sys_id&" +
                         "sysparm_query=#{CGI.escape(encoded_query + '^')}" +
                         "sys_id#{CGI.escape('>=') + keys[index]}&" +
                         "sysparm_record_count=#{max_export}",
                     :http_basic_authentication => [@user, @password]
        ).read

      records = Hash.from_xml(xml)["xml"][table]
      if records.is_a? Array
        export.push *records
      else
        export.push records
      end

      index = index + max_export
    end

    export
  end

  def get_keys client, encoded_query
    response = client.call(:get_keys, :message => {:__encoded_query => encoded_query, :__order_by => "sys_id"})
    response.hash[:envelope][:body][:get_keys_response]
  end

  def _get table, sys_id
    client = setup_client table
    response = client.call(:get, :message => {:sys_id => sys_id})
    response.hash[:envelope][:body][:get_response]
  end

  def setup_client table
    Savon.client do |globals|
      globals.wsdl "#{@url}/#{table}.do?WSDL"
      globals.basic_auth [@user, @password]
      globals.convert_request_keys_to :none
      globals.namespace_identifier :u
      if @proxy
        globals.proxy @proxy
      end
    end
  end

  def _insert table, parameters
    client = setup_client table
    response = client.call(:insert, :message => parameters)
    response.hash[:envelope][:body][:insert_response][:sys_id]
  end

  def _update table, parameters
    if parameters[:sys_id].nil?
      raise "You must supply the sys_id of the record to update"
    end

    client = setup_client table
    client.call(:update, :message => parameters)
  end
end