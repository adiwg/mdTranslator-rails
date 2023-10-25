# Alaska Data Integration working group - ADIwg

# build ISO CT_CodelistCatalogue in XML

# History:
# 	Stan Smith 2014-11-04 initial code
# 	Stan Smith 2014-12-18 changed @codeLists format

require 'builder'

# create new XML document
xml = Builder::XmlMarkup.new(indent: 3)

# document head
xml.instruct! :xml, encoding: 'UTF-8'
xml.comment!('The codelist is supported by the Alaska Data Integration working group (ADIwg)')
xml.comment!('The codelist conatins all ISO 19115-1, 19115-2, ISO 19115-3, and ADIwg codes')
xml.tag!('CT_CodelistCatalogue',{'xmlns:gco' => 'http://www.isotc211.org/2005/gco',
							 'xmlns:gml' => 'http://www.opengis.net/gml/3.2',
							 'xmlns:gmx' => 'http://www.isotc211.org/2005/gmx',
							 'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
							 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
							 'xsi:schemaLocation' => 'http://www.isotc211.org/2005/gmx ../../gmx/gmx.xsd http://www.isotc211.org/2005/gco ../../gco/gco.xsd http://www.opengis.net/gml/3.2 ../../../ISO_19136_Schemas/gml.xsd http://www.w3.org/1999/xlink http://schemas.opengis.net/xlink/1.0.0/xlinks.xsd'}) do
	xml.comment!('====Catalogue Description====')
	xml.name do
		xml.tag!('gco:CharacterString','gmxCodelist')
	end
	xml.scope do
		xml.tag!('gco:CharacterString','Codelists for description of metadata datasets compliant with ISO/TC 211 19115:2003-2014, NGDC, and ADIwg')
	end
	xml.fieldOfApplication do
		xml.tag!('gco:CharacterString','GMX (and imported) namespaces')
	end
	xml.versionNumber do
		xml.tag!('gco:CharacterString','0.1.0')
	end
	xml.versionDate do
		xml.tag!('gco:Date','2014-12-18')
	end
	xml.comment!('=============================================================================================')
	xml.comment!('=============================================================================================')
	xml.comment!('=========================================Codelists===========================================')
	codeSpace = {}
	codeSpace['codeSpace'] = 'ISOTC211/19115'
	@codeLists.each do |key, value|
		s = '====' + value['sourceName'] + '===='
		xml.comment!(s)
		xml.codelistItem do
			attributes = {}
			attributes['gml:id'] = value['sourceName']
			xml.tag!('CodeListDictionary', {'gml:id' => value['sourceName']}) do
				xml.tag!('gml:description',value['description'])
				xml.tag!('gml:identifier', value['sourceName'], codeSpace)
				value['codelist'].each do |item|
					xml.codeEntry do
						s = value['sourceName'] + '_' + item['codeName']
						xml.tag!('CodeDefinition', {'gml:id' => s}) do
							xml.tag!('gml:description', item['description'])
							xml.tag!('gml:identifier', item['codeName'], codeSpace)
						end
					end
				end
			end
		end
	end
end