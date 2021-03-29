class PagolatamController < ApplicationController
  def notify
    pl_service_token = params['pl_service_token']
    pl_amount = params['pl_amount']
    pl_currency = params['pl_currency']
    pl_gateway_reference = params['pl_gateway_reference']
    pl_order_id = params['pl_order_id']
    pl_result = params['pl_result']
    pl_timestamp = params['pl_timestamp']
    pl_signature = params['pl_signature']
    pl_session_id = params['pl_session_id']

    payment = Payment.find_by!(token: pl_session_id)
    order = Order.find_by!(token: pl_order_id)

    create_signature = 'pl_amount'+pl_amount+
                       'pl_currency'+pl_currency+
                       'pl_gateway_reference'+pl_gateway_reference+
                       'pl_order_id'+pl_order_id+
                       'pl_result'+pl_result+
                       'pl_session_id'+pl_session_id+
                       'pl_service_token'+pl_service_token+
                       'pl_timestamp'+pl_timestamp

    signature = OpenSSL::HMAC.hexdigest('sha256', ENV['PAGOLATAM_SECRET_TOKEN'], create_signature)

    if !payment.completed? && signature == pl_signature
      case pl_result
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
