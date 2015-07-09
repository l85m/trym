class LinkDelayNotifier
  include Sidekiq::Worker

  def perform
    LinkedAccount.where(status: "syncing").where("updated_at < ?", 5.minutes.ago).each do |linked_account|
      notify_of_delay(linked_account)
    end
  end

  private

  def notify_of_delay(linked_account)
    return true unless linked_account.reload.status == "syncing"
    linked_account.update( status: "delayed" )
    push = {
      button_icon: "clock-o",
      button_text: "delayed",
      button_tooltip: "#{linked_account.name} is taking longer than normal to respond.  Don't worry, nothing is wrong.  We'll send you an email when the process is complete.",
      button_disabled_state: "disabled",
      button_link: '#',
      flash: "#{linked_account.name} is taking longer than normal to respond.  Don't worry, this happens sometimes.  We'll send you an email when the process is complete."
    }
    linked_account.push_update_to_client(push)
    LinkedAccountMailer.send('delayed_account_linking', linked_account)
  end

end