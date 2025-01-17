# loading installation configs
GlobalConfig.clear_cache
ConfigLoader.new.process

account = Account.create!(
  name: 'Sifa.id',
  domain: 'support.sifa.id',
  support_email: ENV.fetch('MAILER_SENDER_EMAIL', 'accounts@sifa.id')
)

user = User.new(name: 'Sifa Help', email: 'help@sifa.id', password: '123456')
user.skip_confirmation!
user.save!

SuperAdmin.create!(email: 'help@sifa.id', password: '123456') unless Rails.env.production?

AccountUser.create!(
  account_id: account.id,
  user_id: user.id,
  role: :administrator
)

web_widget = Channel::WebWidget.create!(account: account, website_url: 'https://sifa.id')

inbox = Inbox.create!(channel: web_widget, account: account, name: 'Sifa Support')
InboxMember.create!(user: user, inbox: inbox)

contact = Contact.create!(name: 'jane', email: 'jane@example.com', phone_number: '0000', account: account)
contact_inbox = ContactInbox.create!(inbox: inbox, contact: contact, source_id: user.id)
conversation = Conversation.create!(
  account: account,
  inbox: inbox,
  status: :open,
  assignee: user,
  contact: contact,
  contact_inbox: contact_inbox,
  additional_attributes: {}
)
Message.create!(content: 'Hello', account: account, inbox: inbox, conversation: conversation, message_type: :incoming)
CannedResponse.create!(account: account, short_code: 'start', content: 'Hello welcome to Sifa.')
