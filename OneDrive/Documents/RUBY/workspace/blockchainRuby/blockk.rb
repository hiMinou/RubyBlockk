require 'digest'
#digest sert au cryptage du hash
require 'pp'
#pp ne sert que pour un affichage plus jolie

#Définition du ledger ==> grand livre de compte
LEDGER = []

class Block
  #on défini les attribut de lecture
  attr_reader :index, :nonce, :timestamp, :transaction, :transaction_count, :previous_hash , :hash

  def initialize(index, transaction, previous_hash)
    #on définit les vairables d'instances du block
    @index = index
    @timestamp = Time.now
    @transaction = transaction
    @transaction_count = transaction.size
    @previous_hash = previous_hash
    @hash, @nonce = compute_hash_with_proof_of_work
  end

  #methode de la proof of workk
  def compute_hash_with_proof_of_work(difficulty ="0")
    nonce = 0
    loop do
      hash = compute_hash_with_nonce(nonce)
      if hash.start_with?(difficulty)
        return [hash, nonce]
      else
        nonce += 1
        print "#{nonce} - "
      end
    end

  end

  def compute_hash_with_nonce(nonce = 0)
    #sha est la methode qui permet d'obtenir un hash
    sha = Digest::SHA256.new
    sha.update( @index.to_s + nonce.to_s + @timestamp.to_s + @transaction.to_s + @transaction_count.to_s + @previous_hash)
    sha.hexdigest
  end
  #création du genesis block, le premier block de la chaine
  #on rentre un index = 0, de la data et un hash = "0"
  def self.first(*transaction)
    Block.new(0, transaction, "0")
  end

  #création du block d'après
  #on rentre previous = les donnée du block précedent
  # les les paramettre de  du nouveau block sont previous.index+1, data, previous_hash
  def self.next(previous,transaction)
    Block.new(previous.index + 1, transaction, previous.hash)
  end

end #class Block

#creation du premier block de la chaine avec une methode
def create_first_block
  i = 0
  instance_variable_set("@b#{i}", Block.first({from: "Minou", to: "VINE", what:"BTC", qty: "1000000"}))
  #instance_variable_set permet de passer d'une chaine de caractère à une variable
  LEDGER << @b0
  p "=============================="
  pp @b0
  p "=============================="
  add_block
end

#creation des nouveau blocks
def add_block
  i= 1
  loop do
    instance_variable_set("@b#{i}", Block.next(instance_variable_get("@b#{i-1}"), get_transaction))
    #dans cette loop en demande nouveau blockd'aller prendre les donnée du block précédant

    LEDGER << instance_variable_get("@b#{i}")

    p "=============================="
    pp instance_variable_get("@b#{i}")
    p "=============================="
    i += 1
  end

end


#methode pour entrer une transaction
def get_transaction
  transaction_block ||= []
  blank_transaction = Hash[from: "", to: "", what:"", qty: ""]

  loop do
    puts ""
    puts "Entrer le nom de l'envoyeur"
    from = gets.chomp
    puts ""
    puts "Que voulez-vous envoyer?"
    what = gets.chomp
    puts ""
    puts "Entrer la quantité"
    qty = gets.chomp
    puts ""
    puts "Entrer le nom du destinataire"
    to = gets.chomp
    puts ""

    transaction = Hash[from: "#{from}", to: "#{to}", what:"#{what}", qty: "#{qty}"]
    transaction_block << transaction

    puts ""
    puts "Voulez-vous faire une autre transaction? (Y/N)"
    new_transaction = gets.chomp.downcase

    if new_transaction == "y"
      self
    else
      return transaction_block
      break
    end
  end
end

create_first_block

#b0 =  Block.first("THP")
#b1 = Block.next(b0, "THPPP")
#b2 = Block.next(b1, "more")
#b3 = Block.next(b2, "moremore")
#
#pp [b0, b1, b2, b3]
