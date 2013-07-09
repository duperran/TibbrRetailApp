class Store < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :manager, :name, :street, :street_number, :zipcode
end
