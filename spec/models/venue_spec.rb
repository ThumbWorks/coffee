require 'rails_helper'

RSpec.describe Venue, type: :model do
  describe '.find' do
    it 'finds the venue with the specified id', vcr: { cassette_name: :foursquare_venue_details } do
      foursquare_id = '4feddd79d86cd6f22dc171a9'
      expect(Venue.find(foursquare_id).foursquare_id).to eq(foursquare_id)
    end
  end

  describe '.where' do
    it 'finds all venues with the specified params', vcr: { cassette_name: :foursquare_venue_search } do
      expect(Venue.where(name: 'The Mill').count).to eq(30)
    end
  end
end
