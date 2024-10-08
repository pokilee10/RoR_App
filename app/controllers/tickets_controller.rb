class TicketsController < ApplicationController
  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)
    if @ticket.save
      if send_to_slack(@ticket)
        redirect_to root_path, notice: "Ticket was successfully created and sent to Slack."
      else
        redirect_to root_path, alert: "Ticket was successfully created, but there was a problem sending to Slack."
      end
    else
      render :new
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:name, :email, :description)
  end


  # def send_to_slack(ticket)
  #   slack_webhook_url = ENV['SLACK_WEBHOOK_URL']
  #   message = {
  #     text: "New Ticket Received:\n Name: #{ticket.name}\n Email: #{ticket.email}\n Description: #{ticket.description}"
  #   }
  
  #   require 'net/http'
  #   require 'uri'
  #   require 'json'
  
  #   uri = URI.parse(slack_webhook_url)
  #   request = Net::HTTP::Post.new(uri)
  #   request.content_type = "application/json"
  #   request.body = message.to_json
  
  #   response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  #     http.request(request)
  #     http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #   end
  
  #   # Kiểm tra xem phản hồi có thành công không
  #   response.is_a?(Net::HTTPSuccess)
  # end
  def send_to_slack(ticket)
    slack_webhook_url = ENV['SLACK_WEBHOOK_URL']
    uri = URI.parse(slack_webhook_url)
    
    message = {
      text: "New Ticket Received:\n Name: #{ticket.name}\n Email: #{ticket.email}\n Description: #{ticket.description}"
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = '/etc/ssl/certs/cacert.pem'  # Đường dẫn đến file cacert.pem

    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = message.to_json

    begin
      response = http.request(request)
      Rails.logger.info "Response from Slack: #{response.code} - #{response.message}"
      return response.is_a?(Net::HTTPSuccess)
    rescue => e
      Rails.logger.error "Error sending to Slack: #{e.message}"
      return false
    end
  end
end

