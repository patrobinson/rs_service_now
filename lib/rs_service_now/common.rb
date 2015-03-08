class RsServiceNow::Common < RsServiceNow::Record
  def self.create_methods table
    define_method('get') do |sys_id|
      self._get table, sys_id
    end

    define_method('export') do |encoded_query, max_export = 10000|
      self._export table, encoded_query, max_export
    end

    define_method('request') do |encoded_query|
      self._request table, encoded_query
    end

    define_method('insert') do |parameters|
      self._insert table, parameters
    end
  end
end