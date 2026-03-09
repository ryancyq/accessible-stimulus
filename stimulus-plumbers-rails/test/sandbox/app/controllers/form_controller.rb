# frozen_string_literal: true

class FormController < ActionController::Base
  layout "form"
  helper StimulusPlumbers::Helpers

  def sign_up
    @form = SignUp.new
  end

  def field_error
    @form = SignUp.new.tap do |f|
      f.errors.add(:email, "is already taken")
      f.errors.add(:name, "can't be blank")
    end
  end
end
