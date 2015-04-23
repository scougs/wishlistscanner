class ScansController < ApplicationController


  def index
    @scan = Scan.find(params[:id])
  end


  def edit
    @scan = Scan.find(params[:id])
  end


  def update

  end


  def destroy

  end


  def create
    Scan.create(scan_params)
  end


  def new
    @scan = Scan.new
  end


  private

    def scan_params
      params.require(:scan).permit(:total_items_scanned, :items_scanned_on_last_daily_scan, :last_scan_start_time, :last_scan_end_time, :emails_sent_during_last_daily_scan)
    end

end