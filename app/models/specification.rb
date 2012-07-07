class Specification
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  PAPERS = [:glossy, :matte]
  
  field :paper, :type => String
  
  belongs_to  :product
  embedded_in :photo
  
  def self.to_h
    { :paper => PAPERS.inject({}){ |papers, paper| papers[paper] = I18n.t "photo.specs.paper.#{paper}"; papers } }
  end
  
end
