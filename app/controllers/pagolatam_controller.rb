class PagolatamController < ApplicationController
  protect_from_forgery except: [:notify]

  def notify
    payload = {
      pl_service_token: params['pl_service_token'],
      pl_amount: params['pl_amount'],
      pl_currency: params['pl_currency'],
      pl_gateway_reference: params['pl_gateway_reference'],
      pl_order_id: params['pl_order_id'],
      pl_result: params['pl_result'],
      pl_timestamp: params['pl_timestamp'],
      pl_session_id: params['pl_session_id'],
      pl_signature: params['pl_signature']
    }

    create_signature = ''
    payload.keys.sort.each do |key|
      next if key.to_s == 'pl_signature'
      create_signature += (key.to_s + payload[key].to_s)
    end

    signature = OpenSSL::HMAC.hexdigest('sha256', ENV['PAGOLATAM_SECRET_TOKEN'], create_signature)
    raise 'signature dont match' if signature != payload[:pl_signature]

    payment = Payment.find_by!(token: payload[:pl_session_id])
    order = Order.find_by!(token: payload[:pl_order_id])

    if !payment.confirmed?
      case payload[:pl_result]
      when 'completed'
        payment.confirmed!
        order.confirmed!
      end
    end
    head :ok
  rescue
    head :unprocessable_entity
  end
end
