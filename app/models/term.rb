class Term < ActiveRecord::Base
  belongs_to :user

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

  def new_term_desc(sparql)
    query = <<-SPARQL
        select distinct ?label ?description where {
            <http://dbpedia.org/resource/#{eng_title.humanize.gsub(/\s/, '_')}> rdfs:label ?label .
            FILTER ( lang(?label) = "en" )
        }
        LIMIT 1
      SPARQL
    result = sparql.query(query)
    result.first['label'].value
  end

  def query_descriptions
    sparql = SPARQL::Client.new('http://dbpedia.org/sparql')
    keyword = new_term_desc sparql
    query = <<-SPARQL
        SELECT DISTINCT ?concept ?rus_description_1 ?rus_description_2 ?eng_description_1 ?eng_description_2
          WHERE {
            ?concept rdfs:label "#{keyword}"@en .

            OPTIONAL {
              ?concept rdfs:description ?rus_description_1 .
              FILTER ( lang(?rus_description_1) = "ru" )
            }

            OPTIONAL {
              ?concept dbo:abstract ?rus_description_2 .
              FILTER ( lang(?rus_description_2) = "ru" )
            }

            OPTIONAL {
              ?concept rdfs:comment ?eng_description_1 .
              FILTER ( lang(?eng_description_1) = "en" )
            }

            OPTIONAL {
              ?concept dbo:abstract ?eng_description_2 .
              FILTER ( lang(?eng_description_2) = "en" )
            }
          } LIMIT 1
      SPARQL
    result = sparql.query(query).first
    solutions = []
    solutions << result['rus_description_1'].value if result['rus_description_1'].present?
    solutions << result['rus_description_2'].value if result['rus_description_2'].present?
    solutions << result['eng_description_1'].value if result['eng_description_1'].present?
    solutions << result['eng_description_2'].value if result['eng_description_2'].present?
    solutions
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
