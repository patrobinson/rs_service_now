class RsServiceNow::Ci < RsServiceNow::Record
  TABLE = 'cmdb_ci'

  def request encoded_query
    self._request TABLE, encoded_query
  end

  def export encoded_query, max_export = 10000
    self._export TABLE, encoded_query, max_export
  end
end