require 'csv_class_maker'
require 'geocoder'
require "geocoder/models/mongoid"
require 'mongoid'
require 'haml'

Mongoid.load!('./config/mongoid.yml', :development)

CsvClassMaker::generate_class('CsvLocation', './store_locations.csv')

class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  geocoded_by :address
  after_validation :geocode

  field :coordinates, :type => Array
  field :address, type: String
  field :name, type: String
end

# CsvLocation.all.each do |loc|
#   Location.create(name: loc.name, address: loc.address)
#   sleep 2
# end
#

locations = Location.all.map(&:coordinates).to_json
template = File.open('./geotry.html.haml')
html = Haml::Engine.new(template.read, test: 'this is a test').render(Object.new, locations: locations)
File.open('./geotry.html', 'w') { |file| file.write(html) }
