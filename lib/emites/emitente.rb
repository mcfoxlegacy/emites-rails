module Emites

  def self.emitente_id(cnpj)
    cnpj = clean_cnpj(cnpj)
    emitter = lget "/api/v1/emitters?cnpj=#{cnpj}"
    # assumindo que volta apenas um registro na collection
    emitter["collection"][0]['id']
  end

  def self.emitente(cnpj)
    id = emitente_id(cnpj)
    response = lget "/api/v1/emitters/#{id}"
    response.parsed_response
  end

  def self.emitentes
    lget '/api/v1/emitters'
  end

end
