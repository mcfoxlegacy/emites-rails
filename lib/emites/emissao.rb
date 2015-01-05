module Emites

  def self.cria_lote(cnpj, nome)
    emitente_id = Emites.emitter_id(cnpj)
    lote = {
        emitter_id: emitente_id,
        name: nome
    }
    response = lpost '/api/v1/batches', lote
    response
  end

  def self.emite_nfs(nfs, lote = nil)
    nfs['batch_name'] = lote if lote
    response = lpost '/api/v1/nfse', nfs
    puts response.inspect unless response['number'].present?
    response
  end

end