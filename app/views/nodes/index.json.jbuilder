json.array!(@nodes) do |node|
  json.extract! node, :id, :ip_address
  json.url node_url(node, format: :json)
end
