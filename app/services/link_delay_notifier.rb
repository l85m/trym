class LinkDelayNotifier
  
  def perform
    LinkedAccount.where(status: "syncing").where("updated_at < ?", 5.minutes.ago).each do |link|
      notify_of_delay(link)
    end
  end

  private

  def notify_of_delay(link)
    return true unless link.reload.status == "syncing"
    link.update( status: "delayed" )
    push = {
      button_icon: "clock-o",
      button_text: "delayed",
      button_tooltip: "#{account_name} is taking longer than normal to respond.  Don't worry, nothing is wrong.  We'll send you an email when the process is complete.",
      button_disabled_state: "disabled",
      button_link: '#',
      flash: "#{account_name} is taking longer than normal to respond.  Don't worry, this happens sometimes.  We'll send you an email when the process is complete."
    }
    link.push_update_to_client(push)
  end

end