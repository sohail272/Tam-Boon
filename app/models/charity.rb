class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
    self.total += amount
    self.save!
  end
end
