require "chef/search/query"

class NagiosDataBags
  attr_accessor :bag_list

  def initialize(bag_list=nil)
    if bag_list == nil
      if Chef::Config[:solo]
        unless File.directory?(Chef::Config[:data_bag_path])
          raise Chef::Exceptions::InvalidDataBagPath, "Data bag path '#{Chef::Config[:data_bag_path]}' is invalid"
        end

        bag_list = Dir.glob(File.join(Chef::Config[:data_bag_path], "*")).map{|f|File.basename(f)}.sort
      else
        bag_list = Chef::DataBag.list
      end
    end
    @bag_list = bag_list
  end

  # Returns an array of data bag items or an empty array
  # Avoids unecessary calls to search by checking against
  # the list of known data bags.
  def get(bag_name)
    results = []
    if @bag_list.include?(bag_name)
      Chef::Search::Query.new.search(bag_name.to_s, "*:*") {|rows| results << rows}
    else
      Chef::Log.info "The #{bag_name} data bag does not exist."
    end
    results
  end
end
