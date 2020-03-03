class Donate
  attr_accessor :params, :charity, :charge, :omise_token, :amount

  def initialize(params)
    @params = params
    @omise_token = params[:omise_token]
    @amount = params[:amount]
  end

  def track_donation
    find_random_or_valid_charity

    return false if !(valid_donation?)
    @charge = generate_charge
    credit_charge_amount if charge.paid
  end

  def find_random_or_valid_charity
    if params[:charity] == 'random'
      @charity = Charity.find_by_id Charity.ids.sample
    else
      @charity = Charity.find_by_id(params[:charity])
    end
  end

  def valid_donation?
    if omise_token.nil? || charity.nil?
      return false
    elsif amount.present? && amount.to_i > 20 # amount greater than 20 is valid
      return true
    else
      return false
    end
  end

  def generate_charge
    if Rails.env.test?
      charge = OpenStruct.new({
        amount: amount.to_f * 100,
        paid: (amount.to_i != 999),
      })
    else
      charge = Omise::Charge.create({
        amount: amount.to_f * 100,
        currency: "THB",
        card: omise_token,
        description: "Donation to #{charity.name} [#{charity.id}]",
      })
    end
    charge
  end

  def credit_charge_amount
    charity.credit_amount(charge.amount)
  end

end
