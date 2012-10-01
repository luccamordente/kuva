class Specification

  include Mongoid::Document
  include Mongoid::Timestamps

  GLOSSY_PAPER = :glossy
  MATTE_PAPER  = :matte

  PAPERS = [ GLOSSY_PAPER, MATTE_PAPER ].map(&:to_s)

  PAPERS_DIRECTORY = Hash[ PAPERS.zip(%W{ B F }) ]

  field :paper, :type => String

  embedded_in :photo

  validates :paper, inclusion: { :in => PAPERS }

  def self.to_h
    { :paper => PAPERS.inject({}){ |papers, paper| papers[I18n.t "photo.specs.paper.#{paper}"] = paper; papers } }
  end

  def paper_to_directory_string
    PAPERS_DIRECTORY[self.paper]
  end

end
