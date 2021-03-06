class Event < ApplicationRecord
  belongs_to :group

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :name, presence: true
  validates :group, presence: true
  validates :foursquare_venue_id, presence: true
  validate :end_at_cannot_be_before_start_at

  scope :future_or_now, -> { where("end_at >= ?", Time.current).order(:start_at) }
  scope :past, -> { where("end_at < ?", Time.current).order(start_at: :desc) }
  def self.next
    future_or_now.first
  end

  before_save :ensure_updated_foursquare_venue_data

  def venue
    Venue.new(foursquare_venue_data)
  end

  delegate :image_url, to: :venue
  delegate :url, to: :venue, prefix: :venue

  def formatted_local_time
    start_at_local = start_at.in_time_zone(group.time_zone)
    start_at_local.strftime("%A, %B %e, %Y, %-I:%M %p")
  end

  private

  def end_at_cannot_be_before_start_at
    errors.add(:end_at, "can't be before start at") if end_at && start_at && end_at <= start_at
  end

  def ensure_updated_foursquare_venue_data
    if new_record?
      EventVenueHydrator.run(self)
      return
    end

    return unless foursquare_venue_id_changed?

    self.foursquare_venue_data = nil
    EventVenueHydrator.run(self)
  end
end
