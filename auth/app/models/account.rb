class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  enum role: {
    admin: 'admin',
    accounting_clerk: 'accounting_clerk',
    repairman: 'repairman',
    employee: 'employee'
  }

  after_create do
    account = self

    # ----------------------------- produce event -----------------------
    event = {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.now.to_s,
      producer: 'auth_service',
      event_name: 'Account.Created',
      data: {
        public_id: account.public_id,
        email: account.email,
        full_name: account.full_name,
        position: account.role
      }
    }
    result = SchemaRegistry.validate_event(event, 'account.created', version: 1)

    if result.success?
      puts "Validation success"
      WaterDrop::SyncProducer.call(event.to_json, topic: 'accounts-stream')
    else
      puts "Validation failed"
      puts result.failure
    end
    # --------------------------------------------------------------------
  end

  def initialize(*, **)
    super

    self.public_id ||= SecureRandom.uuid
  end
end
