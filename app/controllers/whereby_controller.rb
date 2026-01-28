class WherebyController < ApplicationController
  before_action :authenticate_user_from_token!

  def create_room
    # Create a Whereby room via API
    require 'net/http'
    require 'json'
    require 'uri'
    require 'openssl'

    # Check if API key is available
    api_key = ENV['WHEREBY_API_KEY']
    unless api_key.present?
      Rails.logger.error "WHEREBY_API_KEY is not set"
      return render json: { error: 'Whereby API key not configured' }, status: :internal_server_error
    end

    # Set endDate to 1 hour from now
    end_date = (Time.now + 1.hour).utc.iso8601(3)

    Rails.logger.info "Creating Whereby room with endDate: #{end_date}"

    # Create Whereby room via API
    uri = URI('https://api.whereby.dev/v1/meetings')
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30
    
    # Handle SSL verification - try to use system certs, but allow fallback
    begin
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      http.cert_store = store
    rescue => ssl_error
      Rails.logger.warn "SSL certificate setup warning: #{ssl_error.message}"
      # For development, we can disable SSL verification if cert store fails
      # In production, you should fix the certificate store
      if Rails.env.development?
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        raise ssl_error
      end
    end

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'
    
    request.body = {
      endDate: end_date,
      fields: ['hostRoomUrl', 'roomUrl']
    }.to_json

    response = http.request(request)

    Rails.logger.info "Whereby API response code: #{response.code}"
    Rails.logger.info "Whereby API response body: #{response.body}"

    if response.code == '201'
      data = JSON.parse(response.body)
      render json: {
        meetingId: data['meetingId'],
        roomUrl: data['roomUrl'],
        hostRoomUrl: data['hostRoomUrl'],
        startDate: data['startDate'],
        endDate: data['endDate']
      }
    else
      Rails.logger.error "Whereby API error: #{response.code} - #{response.body}"
      render json: { 
        error: 'Failed to create Whereby room',
        details: response.body,
        status_code: response.code
      }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Whereby room creation error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { 
      error: 'Failed to create Whereby room',
      message: e.message
    }, status: :internal_server_error
  end
end

