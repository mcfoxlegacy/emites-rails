require "emites/version"

module Emites

  include HTTParty

  attr_accessor :token, :endpoint

  def self.servico_ccde
    'Custódia de XMLs'
  end

  def self.setup(token,production=false)
    if production
      @endpoint = 'https://sandbox.emites.com.br'
    else
      @endpoint = 'https://app.emites.com.br'
    end
    base_uri @endpoint
    @token = token
  end


  def self.emitter_id(cnpj)
    cnpj = clean_cnpj(cnpj)
    emitter = lget "/api/v1/emitters?cnpj=#{cnpj}"
    # assumindo que volta apenas um registro na collection
    emitter["collection"][0]['id']
  end

  def self.emitter(cnpj)
    id = emitter_id(cnpj)
    lget "/api/v1/emitters/#{id}"
  end

  def self.taker_id(cnpj)
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

  def self.taker(cnpj)
    id = taker_id(cnpj)
    lget "/api/v1/emitters/#{id}"
  end

  def self.cria_lote(cnpj, nome)
    emitente_id = Emites.emitter_id(cnpj)
    lote = {
        emitter_id: emitente_id,
        name: nome
    }
    response = lpost '/api/v1/batches', lote
    response
  end

  # Crio um tomador para uma conta
  def self.cria_tomador_para_conta(conta_id)
    conta = Conta.find(conta_id)
    dados = conta.dados_cobranca if conta
    raise 'Id de conta invalido' unless dados

    # se não tiver cnpj não crio.
    return nil unless dados.cnpj.present?


    email = dados.email.split(';').first if dados.email
    email = 'financeiro@taxweb.com.br' unless email

    taker = {
        cnpj: dados.cnpj,
        social_reason: dados.razao_social,
        city_inscription: dados.im,
        # state_inscription: dados.ie,
        address: {
            street: "#{dados.tipo_lgr} #{dados.lgr}",
            number: (dados.nro || 'S/N'),
            complement: dados.cpl,
            neighborhood: dados.bairro,
            state: dados.uf,
            zip_code: dados.cep,
            city: dados.mun,
            city_code: '3550308'
        },
        contact: {
            email: email,
            phone: '11 3018-3818'
        }
    }
    response = lpost '/api/v1/takers', taker
    response
  end



  # criar modelo de servico
  def self.cria_servico_custodia
    servico = {
        emitter_id: Emites.emitter_id('11.008.913/0001-70'),
        name: Emites.servico_ccde,
        description: 'Custódid de XMLs',
        deduction_percentage: 0.00,
        service_item_code: '0105',
        city_code: '3550308',
        city_tax_code: '010501'
    }
    response = lpost '/api/v1/service-values', servico
    response
  end

  # pegar id de modelo de servico pelo nome
  def self.servico_custodia_id
    servico_id = nil
    response = lget '/api/v1/service-values'
    servicos = response['collection']
    servicos.each do |servico|
      if servico['name'] == Emites.servico_ccde
        servico_id = servico['id']
        break
      end
    end
    servico_id
  end

  # Emito a nota pelos CNPJs e pelo Valor
  def self.emite_nfs_custodia_por_cnpj(cnpj_prestador,cnpj_tomador, valor, lote = nil)
    emitente_id = emitter_id(cnpj_prestador)
    tomador_id = taker_id(cnpj_tomador)
    if emitente_id and tomador_id
      emite_nfs_custodia emitente_id, tomador_id, valor, lote
    end
  end

  # emitir nota com o modelo de serviço criado e alterando o valor
  def self.emite_nfs_custodia(emitente_id, tomador_id, valor, lote = nil)
    servico_id = servico_custodia_id
    unless servico_id
      cria_servico_custodia
      servico_id = servico_custodia_id
    end
    aliq = 5.0

    nfs = {
        emitter_id: emitente_id,
        taker_id: tomador_id,
        serie: 1,
        rps_type: 1,
        emission_date: format_time(Time.now),
        operation_nature: 1,
        competence: format_time(Time.now),
        service_values: {
            id: servico_id,
            service_amount: valor,
            calculation_base: valor,
            nfse_liquid_amount: valor,
            deduction_amount: 0,
            iss_percentage: aliq,
            iss_amount: (valor * aliq / 100).round(2),
            pis_amount: 0,
            cofins_amount: 0,
            inss_amount: 0,
            ir_amount: 0,
            csll_amount: 0,
            discount_conditioning_amount: 0,
        }
    }

    nfs['batch_name'] = lote if lote

    response = lpost '/api/v1/nfse', nfs
    puts response.inspect unless response['number'].present?
    response
  end




  def self.emite_nfs_ccde(emitente_id, tomador_id, descricao, valor, cod_servico, aliq, lote=nil)
    # Data e hora de emissao vem do prefeitura, não sei se devemos informar

    nfs = {
        emitter_id: emitente_id,
        taker_id: tomador_id,
        rps_type: 1,
        emission_date: format_time(Time.now),
        operation_nature: 1,
        competence: format_time(Time.now),
        service_values: {
            description: descricao,
            service_amount: valor,
            calculation_base: valor,
            nfse_liquid_amount: valor,
            deduction_amount: 0,
            iss_percentage: aliq,
            iss_amount: (valor * aliq / 100).round(2),
            pis_amount: 0,
            cofins_amount: 0,
            inss_amount: 0,
            ir_amount: 0,
            csll_amount: 0,
            discount_conditioning_amount: 0,
            service_item_code: cod_servico,
            city_tax_code: cod_servico,
            city_code: '3550308',
        }
    }

    nfs['batch_name'] = lote if lote

    response = lpost '/api/v1/nfse', nfs
    response

  end

  def self.clean_cnpj(cnpj)
    cnpj.gsub('.','').gsub('/','').gsub('-','').gsub(' ','')
  end

  private

  def self.lget(url)
    options = {
        :basic_auth => {:username => @token, :password => 'x'},
    }
    get url, options
  end

  def self.lpost(url,data)
    options = {
        :basic_auth => {:username => @token, :password => 'x'},
        :body => data.to_json,
        :headers => { 'Content-Type' => 'application/json' }
    }
    response = post url, options
    response
  end

  def self.format_time(dt)
    dt.strftime('%FT%H:%MZ') rescue nil
  end



end
