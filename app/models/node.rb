require 'netaddr'

class Node < ActiveRecord::Base
  after_save :update_collectd_for_node
  
  def id_hex 
    "%012x" % self.id
  end
  
  def update_collectd_for_node
  	Node.update_collectd
  end

  def self.update_collectd
    conf = Collectd.new
    conf.set_ping_hosts(Node.all.map(&:link_local_address))
    # Set mac-Adresses
    macs_by_ll = {}
    
    Node.all.each do |node|
      macs_by_ll[node.link_local_address] = NetAddr::EUI48.new(node.id).address(:Delimiter => ':')
    end
    conf.write_mac_list macs_by_ll
    
  end
  
  def link_local_address
    NetAddr::EUI48.new(self.id).link_local
  end

  def to_collectd_node
    Collectd::CollectdNode.new(self.id_hex,self.link_local_address)
  end

end
