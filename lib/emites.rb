# require 'emites/version'
require 'httparty'

module Emites

  include HTTParty

  attr_accessor :token, :endpoint

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

  def self.emite_nfs(nfs, lote = nil)
    nfs['batch_name'] = lote if lote
    response = lpost '/api/v1/nfse', nfs
    puts response.inspect unless response['number'].present?
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
