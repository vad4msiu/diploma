# -*- encoding : utf-8 -*-
class Admin::ReportsController < Admin::MainController
  inherit_resources
  
  def show
    @report = Report.find params[:id]
    if @report.complited?
      @document = @report.serialized_object
      show!      
    else
      redirect_to admin_reports_path
    end    
  end
  
  def create
    if params[:file]
      params[:content] = params[:file].read.force_encoding("UTF-8")
    end

    report = current_user.reports.new(:algorithm => params[:algorithm])
    # begin
      # Timeout.timeout(5) do
        ActiveRecord::Base.transaction do
          report.generate_and_save(:content => params[:content],
                                   :web => (params[:web] == 'true'))
        end
      # end
      
      redirect_to admin_report_path(report)
    # rescue Exception => e
    #   report.cancel_generate
    #   report.delay.generate_and_save(:content => params[:content],
    #                                  :web => (params[:web] == 'true'))
    #   
    #   redirect_to admin_reports_path
    # end    
  end
  
  protected

  def collection
    @reports = end_of_association_chain.page(params[:page])
  end    
end
