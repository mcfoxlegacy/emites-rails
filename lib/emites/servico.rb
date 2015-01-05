module Emites

  # pego o id do servico pelo seu nome
  def self.servico_id(nome)
    servico_id = nil
    response = lget '/api/v1/service-values'
    servicos = response['collection']
    servicos.each do |servico|
      if servico['name'] == nome
        servico_id = servico['id']
        break
      end
    end
    servico_id
  end

  # criar modelo de servico
  def self.cria_servico(servico)
    response = lpost '/api/v1/service-values', servico
    response
  end


end