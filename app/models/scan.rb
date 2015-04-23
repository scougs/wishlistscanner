class Scan < ActiveRecord::Base

  def send_daily_admin_email
    #send the update email
    ApplicationMailer.daily_admin_email(self.id).deliver
  end


  def duration
    Time.at(last_scan_end_time - last_scan_start_time).utc.strftime("%H:%M:%S")
  end


  def duration_new
    scan.last_scan_end_time.minus_with_coercion(scan.last_scan_start_time)
  end


  def duration_change
    Time.at(scan.duration.to_time - scan.prev.duration.to_time).utc.strftime("%H:%M:%S")
  end


  def prev
    Scan.where("id < ?", id).last
  end

end