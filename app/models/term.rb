class Term < ActiveRecord::Base
  def to_json
    {
      id: id.to_s,
      description: description,
      title: title,
      eng_title: eng_title,
      uri: uri
    }
  end

  # get rus text from rdfs:comment
  def upload_rus(sparql, keyword)
    sparql.query(
      <<-SPARQL
        SELECT DISTINCT ?concept ?description
        WHERE {
          ?concept rdfs:comment ?description .
          ?concept rdfs:label "#{keyword}"@en .
          FILTER ( lang(?description) = "ru" )
        }
      SPARQL
    )
  end

  # get rus text from dbo:abstract
  def upload_rus_mod(sparql, keyword)
    sparql.query(
      <<-SPARQL
        SELECT DISTINCT ?concept ?description
        WHERE {
          ?concept dbo:abstract ?description .
          ?concept rdfs:label "#{keyword}"@en .
          FILTER ( lang(?description) = "ru" )
        }
      SPARQL
    )
  end

  # get eng text from rdfs:comment
  def upload_eng(sparql, keyword)
    sparql.query(
      <<-SPARQL
        SELECT DISTINCT ?concept ?description
        WHERE {
          ?concept rdfs:comment ?description .
          ?concept rdfs:label "#{keyword}"@en .
          FILTER ( lang(?description) = "en" )
        }
      SPARQL
    )
  end

  # get eng text from dbo:abstract
  def upload_eng_mod(sparql, keyword)
    sparql.query(
      <<-SPARQL
        SELECT DISTINCT ?concept ?description
        WHERE {
          ?concept dbo:abstract ?description .
          ?concept rdfs:label "#{keyword}"@en .
          FILTER ( lang(?description) = "en" )
        }
      SPARQL
    )
  end

  def correct_keyword
    sparql = SPARQL::Client.new('http://dbpedia.org/sparql')
    result = sparql.query(
      <<-SPARQL
        SELECT DISTINCT  ?label
        WHERE
          { ?concept  rdfs:label    ?label ;
                      rdf:type      owl:Thing
            FILTER ( lang(?label) = "en" )
            FILTER (lcase(str(?label)) = "#{eng_title.downcase}")
          }
        LIMIT 1
      SPARQL
    )
    result.first[:label].value
  end

  def load_descriptions
    sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
    keyword = correct_keyword
    solutions = []
    solutions << upload_rus(sparql, keyword).first[:description].value
    solutions << upload_rus_mod(sparql, keyword).first[:description].value
    solutions << upload_eng(sparql, keyword).first[:description].value
    solutions << upload_eng_mod(sparql, keyword).first[:description].value
    solutions
  end
end
