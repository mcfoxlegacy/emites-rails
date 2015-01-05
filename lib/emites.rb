# require 'emites/version'
require 'httparty'
require 'emites/version'
require 'emites/emitente'
require 'emites/tomador'
require 'emites/emissao'

module Emites

  include HTTParty

  attr_accessor :token, :endpoint

  def self.setup(token,production)
    if production
      @endpoint = 'https://app.emites.com.br'
    else
      @endpoint = 'https://sandbox.emites.com.br'
    end
    base_uri @endpoint
    @token = token
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

  def self.lput(url,post_data)
    options = {
        :basic_auth => {:username => @token, :password => 'x'},
        :body => post_data.to_json,
        :headers => { 'Content-Type' => 'application/json' }
    }
    response = put url, options
    response
  end

  def self.format_time(dt)
    dt.strftime('%FT%H:%MZ') rescue nil
  end

end
