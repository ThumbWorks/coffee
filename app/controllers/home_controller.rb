class HomeController < ApplicationController
  def index
    event = Event.next
    @event = event.present? ? event.decorate : nil
  end
end