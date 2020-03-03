class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    donate = Donate.new(params)

    if donate.track_donation
      flash.notice = t(".success")
      redirect_to root_path
    else
      @token = params[:omise_token].present? ? retrieve_token(params[:omise_token]) : nil
      flash.now.alert = t(".failure")
      render :index
    end
  end

  private

  def retrieve_token(token)
    if Rails.env.test?
      OpenStruct.new({
        id: "tokn_X",
        card: OpenStruct.new({
          name: "J DOE",
          last_digits: "4242",
          expiration_month: 10,
          expiration_year: 2020,
          security_code_check: false,
        }),
      })
    else
      Omise::Token.retrieve(token)
    end
  end
end
