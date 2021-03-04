module UniversallyUniqueIdentifiable
  extend ActiveSupport::Concern

  included do
    before_validation :set_token
  end

  def set_token
    self.token ||= SecureRandom.uuid
  end
end
