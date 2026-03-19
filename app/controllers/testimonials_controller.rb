class TestimonialsController < ApplicationController
  def index
    @testimonials = Testimonial.all
    @medias = TestimonialMedium.all
  end
end
