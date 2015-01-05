describe 'Manipulando Emitentes', type: :feature do

  require 'emites'

  it 'deve poder pegar o id de um emitente pelo seu nome' do
    Emites.setup('3FEC36E110BA7A7F8DC5791F44D06992', false)
    cnpj = '11008913000170'
    id = Emites.emitente_id(cnpj)
    expect(id).to_not be_nil
  end

  it 'deve poder ler os dados um emitente pelo seu nome' do
    Emites.setup('3FEC36E110BA7A7F8DC5791F44D06992', false)
    cnpj = '11008913000170'
    entidade = Emites.emitente(cnpj)
    expect(entidade['social_reason']).to_not be_nil
  end

end