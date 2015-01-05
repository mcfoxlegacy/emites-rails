module Emites

  def self.tomador_id(cnpj)
    cnpj = clean_cnpj(cnpj)
    emitter = lget "/api/v1/takers?cnpj=#{cnpj}"
    id = nil
    # assumindo que volta apenas um registro na collection
    if emitter and emitter["collection"] and emitter["collection"][0]
      id = emitter["collection"][0]['id']
    else
      puts "Não encontramos o tomador #{cnpj}"
    end
    id
  end

  def self.tomador(cnpj)
    id = taker_id(cnpj)
    lget "/api/v1/emitters/#{id}"
  end

end
